import { Construct } from 'constructs'
import { RemovalPolicy } from 'aws-cdk-lib'
import { Bucket, BucketEncryption } from 'aws-cdk-lib/aws-s3'
import { Grant, IGrantable } from 'aws-cdk-lib/aws-iam'
import { Key } from 'aws-cdk-lib/aws-kms'

/**
 * S3
 */
class EncryptedBucket extends Bucket {
  constructor(id: string, scope: Construct) {
    super(scope, id, {
      encryption: BucketEncryption.KMS,
      encryptionKey: new Key(scope, `${id}-Key`, {
        alias: id.toUpperCase(),
        enableKeyRotation: true,
        removalPolicy: RemovalPolicy.DESTROY
      }),
      enforceSSL: true,
      serverAccessLogsBucket: new Bucket(scope, `${id}-Logs`, {
        // For logging buckets "Encryption using AWS-KMS (SSE-KMS) is not supported."
        // https://aws.amazon.com/premiumsupport/knowledge-center/s3-server-access-log-not-delivered/
        encryption: BucketEncryption.S3_MANAGED,
        enforceSSL: true
      }),
    })
  }

  grantRead(identity: IGrantable, objectsKeyPattern?: any): Grant {
    this.encryptionKey?.grantEncryptDecrypt(identity)
    return Bucket.prototype.grantRead.call(this, identity, objectsKeyPattern)
  }

  grantReadWrite(identity: IGrantable, objectsKeyPattern?: any): Grant {
    this.encryptionKey?.grantEncryptDecrypt(identity)
    return Bucket.prototype.grantReadWrite.call(this, identity, objectsKeyPattern)
  }
}
export class ComputeFileStorage extends EncryptedBucket {
  constructor(scope: Construct) {
    super('Compute-Bucket', scope)
  }
}
