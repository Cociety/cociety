import { Construct } from 'constructs'
import {
  GatewayVpcEndpoint,
  GatewayVpcEndpointAwsService,
  InterfaceVpcEndpoint,
  InterfaceVpcEndpointAwsService,
  SubnetSelection,
  SubnetType,
  Vpc
} from 'aws-cdk-lib/aws-ec2'

interface SubnetSelectionWithGroupName extends SubnetSelection {
  subnetGroupName: string
}

interface Subnets {
  loadBalancer: SubnetSelectionWithGroupName
  compute: SubnetSelectionWithGroupName
  database: SubnetSelectionWithGroupName
}

interface Endpoints {
  cloudWatchLogs: InterfaceVpcEndpoint
  ecrDocker: InterfaceVpcEndpoint
  ecrApi: InterfaceVpcEndpoint
  secrets: InterfaceVpcEndpoint
}

interface Gateways {
  s3: GatewayVpcEndpoint
}

export class CocietyVpc extends Vpc {
  readonly subnets: Subnets
  readonly endpoints: Endpoints
  readonly gateways: Gateways

  constructor(scope: Construct) {
    const subnets = {
      loadBalancer: { subnetGroupName: 'LoadBalancer' },
      compute: { subnetGroupName: 'Compute' },
      database: { subnetGroupName: 'Database' }
    }

    super(scope, 'CocietyVpc', {
      cidr: '10.0.0.0/16',
      vpcName: 'CocietyVpc',
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: subnets.loadBalancer.subnetGroupName,
          subnetType: SubnetType.PUBLIC
        },
        {
          cidrMask: 24,
          name: subnets.compute.subnetGroupName,
          subnetType: SubnetType.PRIVATE_WITH_NAT // needed to download ALB public keys to verify OIDC tokens
        },
        {
          cidrMask: 24,
          name: subnets.database.subnetGroupName,
          subnetType: SubnetType.PRIVATE_ISOLATED
        }
      ]
    })
    this.subnets = subnets

    // https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-vpc-endpoint-considerations
    // https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch-logs-and-interface-VPC.html

    this.endpoints = {
      ecrDocker: this.addInterfaceEndpoint('EcrDockerEndpoint', {
        service: InterfaceVpcEndpointAwsService.ECR_DOCKER,
        subnets: subnets.compute
      }),
      ecrApi: this.addInterfaceEndpoint('EcrApiEndpoint', {
        service: InterfaceVpcEndpointAwsService.ECR,
        subnets: subnets.compute
      }),
      secrets: this.addInterfaceEndpoint('SecretsEndpoint', {
        service: InterfaceVpcEndpointAwsService.SECRETS_MANAGER,
        subnets: subnets.compute
      }),
      cloudWatchLogs: this.addInterfaceEndpoint('CloudWatchEndpoint', {
        service: InterfaceVpcEndpointAwsService.CLOUDWATCH_LOGS,
        subnets: subnets.compute
      })
    }

    this.gateways = {
      s3: this.addGatewayEndpoint('S3', {
        service: GatewayVpcEndpointAwsService.S3,
        subnets: [subnets.compute]
      })
    }
  }
}
