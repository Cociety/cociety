import { App } from 'aws-cdk-lib'
import { Capture, Match, Template } from 'aws-cdk-lib/assertions'
import { CocietyStack } from '../lib'

const app = new App()
const stack = new CocietyStack(app, 'TestCocietyStack', {
  domainName: 'some.domain.amazon.dev',
  hostedZoneAttributes: {
    hostedZoneId: 'hostedZoneId',
    zoneName: 'zoneName'
  },
  secretKeyBase: {
    arn: 'secretKeyBaseArn',
    encryptionKeyArn: 'encryptionKeyArn'
  }
})
const template = Template.fromStack(stack)

describe('Load Balancer', () => {
  test('Created with one Listener', () => {
    template.hasResourceProperties('AWS::ElasticLoadBalancingV2::LoadBalancer', {
      Type: 'application'
    })
    template.resourceCountIs('AWS::ElasticLoadBalancingV2::Listener', 1)
  })

  test('Only allows HTTPS traffic in', () => {
    const securityGroups = template.findResources('AWS::EC2::SecurityGroup', {
      Properties: {
        GroupDescription: `${stack.stackName}/LoadBalancer-SecurityGroup`,
        SecurityGroupEgress: [
          {
            CidrIp: '0.0.0.0/0'
          }
        ],
        SecurityGroupIngress: [
          {
            CidrIp: '0.0.0.0/0',
            FromPort: 443,
            ToPort: 443,
            IpProtocol: 'tcp'
          }
        ]
      }
    })

    const securityGroupNames = Object.keys(securityGroups)

    expect(securityGroupNames).toHaveLength(1)

    template.hasResourceProperties(
      'AWS::ElasticLoadBalancingV2::LoadBalancer',
      Match.objectLike({
        SecurityGroups: [
          {
            'Fn::GetAtt': [securityGroupNames[0], 'GroupId']
          }
        ]
      })
    )
  })
})

describe('Compute', () => {
  test('Created', () => {
    template.resourceCountIs('AWS::ECS::Service', 1)
  })

  test('Attached to Load Balancer on port 3000', () => {
    const loadBalancers = new Capture()
    template.hasResourceProperties('AWS::ECS::Service', {
      LoadBalancers: loadBalancers
    })
    expect(loadBalancers.asArray()).toHaveLength(1)
    expect(loadBalancers.asArray()[0].ContainerPort).toEqual(3000)
  })
})

describe('Database', () => {
  test('Created', () => {
    template.resourceCountIs('AWS::RDS::DBCluster', 1)
  })
})
