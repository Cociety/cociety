import { Construct } from 'constructs'
import { InstanceClass, InstanceSize, InstanceType, Peer, Port, SecurityGroup } from 'aws-cdk-lib/aws-ec2'
import { AuroraPostgresEngineVersion, Credentials, DatabaseCluster, DatabaseClusterEngine, ParameterGroup } from 'aws-cdk-lib/aws-rds'
import { Key } from 'aws-cdk-lib/aws-kms'
import { CocietyVpc } from './vpc'
import { ISecret, Secret, SecretRotation, SecretRotationApplication } from 'aws-cdk-lib/aws-secretsmanager'
import { RemovalPolicy } from 'aws-cdk-lib'

interface DatabaseProps {
  vpc: CocietyVpc
}

/**
 * Database
 * TODO Migrate to serverless cluster when it's supported in CDK
 * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html
 */
export class CocietyDatabase extends DatabaseCluster {
  readonly port: number = 5432
  readonly secret: ISecret

  constructor(scope: Construct, props: DatabaseProps) {
    const { vpc } = props
    const port = 5432

    const excludeCharacters = '/@" ';

    const secret = new Secret(scope, 'DatabaseSecret', {
      secretName: 'Cociety-DATABASE_JSON',
      description: 'connection details to cociety database',
      generateSecretString: {
        secretStringTemplate: JSON.stringify({
          username: 'cociety'
        }),
        generateStringKey: 'password',
        excludeCharacters
      },
      encryptionKey: new Key(scope, 'Database-CredentialsKey', {
        alias: 'DATABASE_JSON',
        enableKeyRotation: true,
        removalPolicy: RemovalPolicy.DESTROY
      })
    })

    super(scope, 'Database', {
      credentials: Credentials.fromSecret(secret),
      engine: DatabaseClusterEngine.auroraPostgres({
        version: AuroraPostgresEngineVersion.of('13.6', '13')
      }),
      instances: 1,
      instanceProps: {
        instanceType: InstanceType.of(InstanceClass.T3, InstanceSize.MEDIUM),
        securityGroups: [
          new SecurityGroup(scope, 'Database-SecurityGroup', {
            allowAllOutbound: false,
            vpc
          })
        ],
        vpc,
        vpcSubnets: vpc.subnets.database
      },
      parameterGroup: new ParameterGroup(scope, 'Database-ParameterGroup', {
        engine: DatabaseClusterEngine.auroraPostgres({
          version: AuroraPostgresEngineVersion.of('13.6', '13', { s3Import: false, s3Export: false })
        }),
        parameters: {
          'rds.force_ssl': '1',
          ssl: '1'
        }
      }),
      port: port,
      storageEncrypted: true,
      storageEncryptionKey: new Key(scope, 'Database-StorageKey', {
        description: 'database at rest encryption key',
        enableKeyRotation: true
      })
    })

    const rotationSecurityGroup = new SecurityGroup(scope, 'Database-SecurityGroup-Rotation', {
      allowAllOutbound: false,
      vpc
    })

    rotationSecurityGroup.addEgressRule(Peer.anyIpv4(), Port.tcp(443))

    new SecretRotation(scope, 'Database-Secret-Rotation', {
      application: SecretRotationApplication.POSTGRES_ROTATION_SINGLE_USER,
      secret,
      target: this,
      vpc,
      vpcSubnets: vpc.subnets.database,
      excludeCharacters,
      securityGroup: rotationSecurityGroup
    })

    this.secret = secret
    this.port = port
  }
}
