import AWS from 'aws-sdk'
import { APIGatewayEvent, ProxyResult } from 'aws-lambda'
import { StreamingEventStream } from 'aws-sdk/lib/event-stream/event-stream'

const s3 = new AWS.S3({
    region: 'eu-central-1',
})

exports.handler = async (event: APIGatewayEvent): Promise<ProxyResult> => {
    return readDragons(event)
}

export async function readDragons(event: APIGatewayEvent): Promise<any> {
    const s3Bucket = await s3.listBuckets().promise()
    const s3files = await s3
        .listObjects({ Bucket: 'dragons-stat-bucket' })
        .promise()

    let bucketName: string = ''
    let fileName: string = ''

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
        const dragonList = await readDragonsFromS3(bucketName, fileName, event)
        if (typeof dragonList === 'string') {
            return {
                statusCode: 200,
                body: dragonList,
            }
        }
        return {
            statusCode: 500,
            body: 'Error while reading from S3',
        }
    }

    return {
        statusCode: 500,
        body: 'No bucket or file found',
    }
}

async function readDragonsFromS3(
    bucketName: string,
    fileName: string,
    event: APIGatewayEvent
): Promise<string | false | Error> {
    let expression = 'select * from s3object s'

    if (
        event.queryStringParameters &&
        event.queryStringParameters.family &&
        event.queryStringParameters.family !== ''
    ) {
        expression = `select * from S3Object[*][*] s where s.family_str = '${event.queryStringParameters.family}'`
    }

    const result = await s3
        .selectObjectContent({
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
        })
        .promise()

    if (result) {
        const eventStream =
            result.Payload as StreamingEventStream<AWS.S3.SelectObjectContentEventStream>
        return await handleData(eventStream)
    }

    return false
}

async function handleData(
    data: StreamingEventStream<AWS.S3.SelectObjectContentEventStream>
): Promise<Error | string> {
    return new Promise((resolve, reject) => {
        let dataString = ''
        data.on('data', (event: any) => {
            dataString += event.Records?.Payload?.toString()
        })
        data.on('end', () => {
            resolve(dataString)
        })
        data.on('error', (error: Error) => {
            reject(error)
        })
    })
}
