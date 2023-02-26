import { Construct } from 'constructs'
import { Certificate, CertificateValidation } from 'aws-cdk-lib/aws-certificatemanager'
import { ApplicationLoadBalancer, ApplicationProtocol, ApplicationTargetGroup, ListenerAction, Protocol, TargetType } from 'aws-cdk-lib/aws-elasticloadbalancingv2'
import { Peer, Port, SecurityGroup } from 'aws-cdk-lib/aws-ec2'
import { CocietyVpc } from './vpc'
import { CocietyCompute } from './compute'
import { IHostedZone } from 'aws-cdk-lib/aws-route53'

interface CocietyLoadBalancerProps {
  compute: CocietyCompute
  domainName: string
  hostedZone: IHostedZone
  vpc: CocietyVpc
}

/**
 * Load Balancer
 */
export class CocietyLoadBalancer extends ApplicationLoadBalancer {
  constructor(scope: Construct, props: CocietyLoadBalancerProps) {
    const { compute, domainName, vpc, hostedZone } = props

    // Don't use HTTP/2 on the target group. Rails web server, puma, does not support it
    const targetGroup = new ApplicationTargetGroup(scope, 'Compute-TargetGroup', {
      vpc,
      targetType: TargetType.IP,
      port: compute.port,
      protocol: ApplicationProtocol.HTTP
    })
    targetGroup.configureHealthCheck({
      path: '/healthcheck',
      protocol: Protocol.HTTP,
      unhealthyThresholdCount: 5
    })

    const securityGroup = new SecurityGroup(scope, 'LoadBalancer-SecurityGroup', { vpc })
    securityGroup.addIngressRule(Peer.anyIpv4(), Port.tcp(443), 'Allow public inbound HTTPS traffic')

    super(scope, 'LoadBalancer', {
      vpc,
      internetFacing: true,
      securityGroup,
      vpcSubnets: vpc.subnets.loadBalancer
    })

    const sslCert = new Certificate(this, 'LoadBalancer-Certificate', {
      domainName,
      validation: CertificateValidation.fromDns(hostedZone)
    })

    this.addListener('HttpsListener', {
      certificates: [sslCert],
      protocol: ApplicationProtocol.HTTPS,
      defaultAction: ListenerAction.forward([targetGroup])
    })

    this.addListener('HttptoHttpsListener', {
      protocol: ApplicationProtocol.HTTP,
      defaultAction: ListenerAction.redirect({
        protocol: ApplicationProtocol.HTTPS,
        permanent: true // 301 instead of 302
      })
    })

    // create load balancer before compute
    compute.node.addDependency(this)

    // attach fargate to load balancer
    compute.attachToApplicationTargetGroup(targetGroup)

    // allow fargate and load balancer to talk
    compute.connections.allowFrom(this.connections, Port.tcp(compute.port))
    compute.connections.allowTo(this.connections, Port.tcp(compute.port))
  }
}