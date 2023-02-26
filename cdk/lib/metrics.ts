import { DimensionsMap, Metric } from 'aws-cdk-lib/aws-cloudwatch'

interface CocietyMetricsProps {
  namespace: string
  name: string
}

interface MetricBuilderProps {
  stat?: string
  dimensionsMap: DimensionsMap
}

export class CocietyMetrics {
  namespace: string
  name: string
  readonly httpCodes = [2, 4, 5]

  constructor(props: CocietyMetricsProps) {
    this.namespace = props.namespace
    this.name = props.name
  }

  get auth(): Metric[] {
    return [
      { stat: 'SampleCount', dimensionsMap: { type: 'auth.success' } },
      { stat: 'SampleCount', dimensionsMap: { type: 'auth.failure' } },
    ].map(prop => this.#buildMetric(prop))
  }

  get latency(): Metric[] {
    const metricsProps: MetricBuilderProps[] = [
      { dimensionsMap: { type: 'rails.response.time' } },
      { dimensionsMap: { type: 'rails.response.time.active_record' } },
      { dimensionsMap: { type: 'rails.response.time.views' } }
    ]

    return metricsProps.map(prop => this.#buildMetric(prop))
  }

  get responseCodes(): Metric[] {

    const metricProps:MetricBuilderProps[] = [
      ...this.httpCodes.map(code => {
        return { stat: 'SampleCount', dimensionsMap: { type: `rails.response.code.${code}xx` } }
      })
    ]
    
    return metricProps.map(prop => this.#buildMetric(prop))
  }

  #buildMetric(props: MetricBuilderProps) {
    const defaultMetricProps = {
      namespace: this.namespace,
      metricName: this.name,
      statistic: 'Average',
      dimensionsMap: {
        controller: '*',
        action: '*'
      }
    }
    props.dimensionsMap = {
      ...defaultMetricProps.dimensionsMap,
      ...props.dimensionsMap
    }
    return new Metric({
      ...defaultMetricProps,
      ...props
    })
  }
}
