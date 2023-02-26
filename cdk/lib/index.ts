import { Stack, StackProps } from 'aws-cdk-lib'
import { Construct } from 'constructs'
import { ARecord, HostedZone, HostedZoneAttributes, RecordTarget } from 'aws-cdk-lib/aws-route53'
import { LoadBalancerTarget } from 'aws-cdk-lib/aws-route53-targets'
import { CocietyVpc } from './vpc'
import { CocietyDatabase } from './database'
import { CocietyCompute } from './compute'
import { CocietyLoadBalancer } from './load-balancer'
import { ComputeFileStorage } from './file-storage'

interface CocietyStackProps extends StackProps {
  hostedZoneAttributes: HostedZoneAttributes
  domainName: string
}

/**
 * Application Load Balancer -> Target Group -> Fargate -> ECS -> Docker -> Rails
 */
export class CocietyStack extends Stack {
  constructor(scope: Construct, id: string, props: CocietyStackProps) {
    const defaultProps:StackProps = {
      description: 'Cociety website'
    }

    super(scope, id, {...defaultProps, ...props})

    const { domainName, hostedZoneAttributes } = props

    const vpc = new CocietyVpc(this)

    const database = new CocietyDatabase(this, { vpc })

    const computeFileStorage = new ComputeFileStorage(this)

    const hostedZone = HostedZone.fromHostedZoneAttributes(this, 'HostedZone', hostedZoneAttributes)

    const compute = new CocietyCompute(this, {
      vpc,
      database,
      fileStorage: computeFileStorage
    })

    const loadBalancerProps = {
      vpc,
      domainName,
      hostedZone,
      compute
    }

    const loadBalancer = new CocietyLoadBalancer(this, loadBalancerProps)

    new ARecord(this, 'AliasRecord', {
      zone: hostedZone,
      recordName: domainName,
      target: RecordTarget.fromAlias(new LoadBalancerTarget(loadBalancer))
    })

    // new MetricsStack(this, { compute, database, fileStorage, dashboardName: id })
  }
}

// interface MetricsStackProps extends NestedStackProps {
//   compute: CocietyCompute
//   database: CocietyDatabase
//   fileStorage: ComputeFileStorage
//   dashboardName: string
// }

// class MetricsStack extends NestedStack {
//   constructor(scope: Construct, props: MetricsStackProps) {
//     super(scope, 'Metrics', props)
//     new CloudwatchDashboardsWiki(this, 'CloudWatchDashboardsWiki', {})

//     const { compute, database, fileStorage, dashboardName } = props

//     const monitoring = new MonitoringFacade(this, 'Monitoring', {
//       alarmFactoryDefaults: {
//         alarmNamePrefix: '',
//         actionsEnabled: true,
//         action: new SIMAlaramStrategy(CocietyCTI, Severity.SEV3)
//       },
//       metricFactoryDefaults: {
//         namespace: 'Cociety'
//       },
//       dashboardFactory: new DefaultDashboardFactory(scope, 'DashboardFactory', {
//         dashboardNamePrefix: dashboardName
//       })
//     })

//     monitoring
//       .addLargeHeader(dashboardName)
//       .monitorRdsCluster({ cluster: database })
//       .monitorSimpleFargateService({ fargateService: compute })
//       .monitorS3Bucket({ bucket: fileStorage })
//       .monitorSecretsManagerSecret({ secret: database.secret })

//     const metricNamespace = 'Cociety'
//     const metricName = 'event'
//     const dimensions = {
//       type: '$.type',
//       action: '$.action',
//       controller: '$.controller'
//     }

//     new MetricFilter(scope, 'EventFilter', {
//       logGroup: compute.logGroup,
//       metricNamespace,
//       metricName,
//       filterPattern: FilterPattern.exists(dimensions.type),
//       metricValue: '$.value',
//       dimensions
//     })

//     const metrics = new CocietyMetrics({
//       namespace: metricNamespace,
//       name: metricName
//     })

//     MetricsStack.addSection(monitoring, 'Latency', ...metrics.latency)
//     MetricsStack.addSection(monitoring, 'HTTP Response Codes', ...metrics.responseCodes)
//     MetricsStack.addSection(monitoring, 'Authentication', ...metrics.auth)
//   }

//   static addSection(monitoring: MonitoringFacade, title: string, ...metrics: Metric[]) {
//     monitoring.monitorCustom({
//       alarmFriendlyName: title,
//       metricGroups: metrics.map((metric: Metric): CustomMetricGroup => {
//         const alarmFriendlyName = MetricsStack.metricTitle(metric)
//         return {
//           title: alarmFriendlyName,
//           metrics: [
//             {
//               metric,
//               anomalyDetectionStandardDeviationToRender: 3,
//               alarmFriendlyName: MetricsStack.alarmTitle(metric),
//               addAlarmOnAnomaly: {
//                 Warning: {
//                   standardDeviationForAlarm: 4,
//                   alarmWhenAboveTheBand: true,
//                   alarmWhenBelowTheBand: true
//                 }
//               }
//             }
//           ]
//         }
//       })
//     })
//   }

//   static metricTitle(metric: Metric) {
//     const { type, controller, action } = metric.dimensions || {}
//     return [type, controller, action, metric.statistic]
//       .filter(s => s && s !== '*') // '*' characters won't render on the dashboard
//       .join('_')
//   }

//   static alarmTitle(metric: Metric) {
//     const { type, controller, action } = metric.dimensions || {}
//     return `${type}_${controller}_${action}_${metric.statistic}`
//   }
// }
