import { Construct } from 'constructs'
import { Peer, Port, SecurityGroup } from 'aws-cdk-lib/aws-ec2'
import { Cluster, ContainerImage, FargateService, FargateTaskDefinition, LogDrivers } from 'aws-cdk-lib/aws-ecs'
import { Key } from 'aws-cdk-lib/aws-kms'
import { Secret } from 'aws-cdk-lib/aws-ecs'
import { CocietyVpc } from './vpc'
import * as secretsManager from 'aws-cdk-lib/aws-secretsmanager'
import { AnyPrincipal, Effect, PolicyStatement, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam'
import { CocietyDatabase } from './database'
import { Duration, RemovalPolicy } from 'aws-cdk-lib'
import { ComputeFileStorage } from './file-storage'
// import { SecretAttributes } from 'aws-cdk-lib/aws-secretsmanager'
import { LogGroup } from 'aws-cdk-lib/aws-logs'
import { DockerImageAsset } from 'aws-cdk-lib/aws-ecr-assets'
import path = require('path')
import fs = require('fs')
import { DockerImageName, ECRDeployment } from 'cdk-ecr-deployment'
import * as YAML from 'yaml'
import { Repository } from 'aws-cdk-lib/aws-ecr'


// https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#config-secrets-yml

interface ComputeProps {
  database: CocietyDatabase
  fileStorage: ComputeFileStorage
  vpc: CocietyVpc
}
/**
 * Compute
 */
export class CocietyCompute extends FargateService {
  readonly port: number

  readonly logGroup: LogGroup

  constructor(scope: Construct, props: ComputeProps) {
    const { vpc, database, fileStorage } = props
    const port = 8080

    const repository = new Repository(scope, 'Repository', {
      imageScanOnPush: true,
      repositoryName: 'cociety-compute',
      encryptionKey: new Key(scope, 'Compute-Repository', {
        alias: 'COCIETY_COMPUTE_REPOSITORY',
        enableKeyRotation: true,
        removalPolicy: RemovalPolicy.DESTROY
      }),
      lifecycleRules: [
        {
          maxImageCount: 10
        }
      ]
    })

    const directory = path.join(__dirname, '/../../')
    const composeFile = fs.readFileSync(path.join(directory, 'docker-compose.prod.yml'), 'utf8')
    const buildArgs = YAML.parse(composeFile).services.web.build.args
    const rubyVersion:string = fs.readFileSync(path.join(directory, '.ruby-version'), 'utf-8').trim()
    const asset = new DockerImageAsset(scope, 'ComputeBuildImage', {
      directory,
      buildArgs: {
        ...buildArgs,
        RUBY_VERSION: rubyVersion
      }
    })

    const deployment = new ECRDeployment(scope, 'DeployComputeFargateImage', {
      src: new DockerImageName(asset.imageUri),
      dest: new DockerImageName(repository.repositoryUri)
    })

    /**
     * Secrets to be injected into the app. key is the env variable the app will use to get the value
     */
    const secrets: { [key: string]: secretsManager.ISecret } = {}

    secrets.ACTIVE_RECORD_PRIMARY_KEY = new secretsManager.Secret(scope, 'Compute-ActiveRecordEncryption-PrimaryKey', {
      secretName: 'Cociety-ACTIVE_RECORD_PRIMARY_KEY',
      generateSecretString: {
        passwordLength: 32,
        excludePunctuation: true
      },
      encryptionKey: new Key(scope, 'Compute-ActiveRecordEncryption-PrimaryKey-CredentialsKey', {
        alias: 'Cociety-ACTIVE_RECORD_PRIMARY_KEY',
        enableKeyRotation: true,
        removalPolicy: RemovalPolicy.DESTROY
      })
    })

    secrets.ACTIVE_RECORD_DETERMINISTIC_KEY = new secretsManager.Secret(
      scope,
      'Compute-ActiveRecordEncryption-DeterministicKey',
      {
        secretName: 'Cociety-ACTIVE_RECORD_DETERMINISTIC_KEY',
        generateSecretString: {
          passwordLength: 32,
          excludePunctuation: true
        },
        encryptionKey: new Key(scope, 'Compute-ActiveRecordEncryption-DeterministicKey-CredentialsKey', {
          alias: 'Cociety-ACTIVE_RECORD_DETERMINISTIC_KEY',
          enableKeyRotation: true,
          removalPolicy: RemovalPolicy.DESTROY
        })
      }
    )

    secrets.ACTIVE_RECORD_KEY_DERIVATION_SALT = new secretsManager.Secret(
      scope,
      'Compute-ActiveRecordEncryption-KeyDerivationSalt',
      {
        secretName: 'Cociety-ACTIVE_RECORD_KEY_DERIVATION_SALT',
        generateSecretString: {
          passwordLength: 32,
          excludePunctuation: true
        },
        encryptionKey: new Key(scope, 'Compute-ActiveRecordEncryption-KeyDerivationSalt-CredentialsKey', {
          alias: 'Cociety-ACTIVE_RECORD_KEY_DERIVATION_SALT',
          enableKeyRotation: true,
          removalPolicy: RemovalPolicy.DESTROY
        })
      }
    )

    secrets.DATABASE_JSON = database.secret

    const executionRole = new Role(scope, 'Compute-ExecutionRole', {
      assumedBy: new ServicePrincipal('ecs-tasks.amazonaws.com')
    })

    secrets.SECRET_KEY_BASE = new secretsManager.Secret(scope, 'Compute-SECRET_KEY_BASE', {
      secretName: 'Cociety-SECRET_KEY_BASE',
      generateSecretString: {
        passwordLength: 128,
        excludePunctuation: true
      },
      removalPolicy: RemovalPolicy.RETAIN,
      encryptionKey: new Key(scope, 'Compute-SECRET_KEY_BASE-Key', {
        alias: 'Cociety-SECRET_KEY_BASE-Key',
        enableKeyRotation: true,
        removalPolicy: RemovalPolicy.RETAIN
      })
    })

    // allow fargate to get and decrypt all secrets
    const ecsSecrets: { [key: string]: Secret } = {}
    for (const [secretName, secret] of Object.entries(secrets)) {
      secret.grantRead(executionRole)
      secret.encryptionKey?.grantDecrypt(executionRole)
      ecsSecrets[secretName] = Secret.fromSecretsManager(secret)
    }

    const taskDefinition = new FargateTaskDefinition(scope, 'Compute-TaskDefinition', {
      cpu: 256,
      memoryLimitMiB: 2048,
      executionRole: executionRole
    })

    const logGroup = new LogGroup(scope, 'Compute-Container-LogGroup', {
      retention: 180
    })

    taskDefinition.addContainer('Compute-Container', {
      image: ContainerImage.fromEcrRepository(repository),
      logging: LogDrivers.awsLogs({
        streamPrefix: 'Compute-Container-Logs',
        logGroup
      }),
      portMappings: [{ containerPort: port }],
      environment: {
        RAILS_ENV: 'production',
        RACK_ENV: 'production',
        RAILS_LOG_TO_STDOUT: 'enabled',
        S3_BUCKET: fileStorage.bucketName,
      },
      secrets: {
        ...ecsSecrets
      },
      memoryLimitMiB: 2048,
      readonlyRootFilesystem: false,
      user: 'cociety',
      healthCheck: {
        command: ['CMD-SHELL', `curl --fail http://localhost:${port}/healthcheck || exit 1`],
        interval: Duration.seconds(30),
        retries: 3,
        startPeriod: Duration.minutes(2)
      }
    })

    fileStorage.grantReadWrite(taskDefinition.taskRole)

    const cluster = new Cluster(scope, 'Compute-Cluster', { vpc })
    const computeSecurityGroup = new SecurityGroup(scope, 'Compute-SecurityGroup', {
      allowAllOutbound: false,
      vpc
    })
    computeSecurityGroup.addEgressRule(Peer.anyIpv4(), Port.tcp(443))
    // TODO setup blue-green deployments https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-blue-green.html
    super(scope, 'Compute', {
      cluster,
      taskDefinition,
      securityGroups: [computeSecurityGroup],
      vpcSubnets: vpc.subnets.compute,
      healthCheckGracePeriod: Duration.minutes(3)
    })

    // https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-vpc-endpoint-considerations
    // https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch-logs-and-interface-VPC.html
    vpc.endpoints.ecrDocker.addToPolicy(
      new PolicyStatement({
        sid: 'AllowPull',
        principals: [executionRole],
        actions: ['ecr:BatchGetImage', 'ecr:GetDownloadUrlForLayer', 'ecr:GetAuthorizationToken'],
        resources: [repository.repositoryArn]
      })
    )

    const deleteRepositoryPolicy = new PolicyStatement({
      principals: [new AnyPrincipal()],
      actions: ['ecr:DeleteRepository'],
      effect: Effect.DENY,
      resources: [repository.repositoryArn]
    })

    vpc.endpoints.ecrDocker.addToPolicy(deleteRepositoryPolicy)

    vpc.endpoints.ecrApi.addToPolicy(
      new PolicyStatement({
        principals: [executionRole],
        actions: ['ecr:GetAuthorizationToken'],
        resources: ['*']
      })
    )

    vpc.endpoints.cloudWatchLogs.addToPolicy(
      new PolicyStatement({
        sid: 'PutOnly',
        principals: [executionRole],
        actions: ['logs:CreateLogStream', 'logs:PutLogEvents'],
        resources: ['*']
      })
    )

    // allow fargate and database to talk
    this.connections.allowTo(database.connections, Port.tcp(database.port))
    database.connections.allowTo(this.connections, Port.tcp(database.port))

    // create database instances before compute
    this.node.addDependency(database)

    // create s3 bucket before compute
    this.node.addDependency(fileStorage)

    // build the docker image before compute
    this.node.addDependency(deployment)

    this.port = port

    this.logGroup = logGroup
  }
}
