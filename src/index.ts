import AWS from 'aws-sdk'
import { StreamingEventStream } from 'aws-sdk/lib/event-stream/event-stream'

const s3 = new AWS.S3({
    region: 'eu-central-1',
})

export async function readDragons(): Promise<void> {
    const s3Bucket = await s3.listBuckets().promise()
    const s3files = await s3
        .listObjects({ Bucket: 'dragons-stat-bucket' })
        .promise()

    let bucketName: string | undefined = ''
    let fileName: string | undefined = ''
    s3Bucket?.Buckets?.forEach((bucket: AWS.S3.Bucket) => {
        if (bucket?.Name?.includes('dragons-stat-bucket')) {
            bucketName = bucket.Name
        }
    })

    s3files?.Contents?.forEach((file: AWS.S3.Object) => {
        if (file?.Key?.includes('dragonsList')) {
            fileName = file.Key
        }
    })
    if (bucketName && fileName) {
        readDragonsFromS3(bucketName, fileName)
    } else {
        console.log('No bucket or file found')
    }
}

function readDragonsFromS3(bucketName: string, fileName: string): void {
    const expression = 'select * from s3object s'

    s3.selectObjectContent(
        {
            Bucket: bucketName,
            Expression: expression,
            ExpressionType: 'SQL',
            Key: fileName,
            InputSerialization: {
                JSON: {
                    Type: 'DOCUMENT',
                },
            },
            OutputSerialization: {
                JSON: {
                    RecordDelimiter: ',',
                },
            },
        },
        (err, data) => {
            if (err) {
                console.log(err)
            } else {
                const eventStream =
                    data.Payload as StreamingEventStream<AWS.S3.SelectObjectContentEventStream>
                return handleData(eventStream)
            }
        }
    )
}

function handleData(
    data: StreamingEventStream<AWS.S3.SelectObjectContentEventStream>
): void {
    data.on('data', (event: any) => {
        if (event.Records) {
            console.log(event.Records.Payload.toString())
        }
    })
}

;(async () => {
    readDragons()
})()
