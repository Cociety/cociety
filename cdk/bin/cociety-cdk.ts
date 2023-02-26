#!/usr/bin/env node
import { App } from 'aws-cdk-lib'
import 'source-map-support/register'
import { CocietyStack } from '../lib'

const app = new App()

// const account = process.env.CDK_DEPLOY_ACCOUNT || process.env.CDK_DEFAULT_ACCOUNT
// const region = process.env.CDK_DEPLOY_REGION || process.env.CDK_DEFAULT_REGION
// const user = process.env.USER

const domainNameProd = 'cociety.org'
new CocietyStack(app, 'Cociety-Prod', {
  env: { account: '806302365898', region: 'us-east-1' }, // Cociety-Prod
  hostedZoneAttributes: {
    hostedZoneId: 'Z00311283SVCJVZCXWAPD',
    zoneName: domainNameProd
  },
  domainName: `www.${domainNameProd}`,
  secretKeyBase: {
    arn: 'arn:aws:secretsmanager:us-west-2:694414025211:secret:RAILS_SECRET_KEY_BASE-A3sPJK',
    encryptionKeyArn: 'arn:aws:kms:us-west-2:694414025211:key/58b9c90b-9e83-4eb7-8d62-12cf17ba4904'
  }
})
