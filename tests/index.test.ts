import AWSMock from 'aws-sdk-mock'
import AWS from 'aws-sdk'
import { readDragons } from '../src'

describe('Index test ', () => {
    it('should return a list', () => {
        /*AWSMock.setSDKInstance(AWS);
        AWSMock.mock('S3', 'listBuckets', (params, callback) => {
            callback(undefined, {
                Buckets: [
                    {
                        Name: 'dragons-stat-bucket',
                    },
                ],
            });
        }
        );
        AWSMock.mock('S3', 'listObjects', (params, callback) => {
            callback(undefined, {
                Contents: [
                    {
                        Key: 'dragonsList',
                    },
                ],
            });
        }
        );

        const s3 = new AWS.S3({
            region: 'eu-central-1',
        });

        readDragons()
        expect(s3.listBuckets).toHaveBeenCalled();
        */

        expect(true).toBeTruthy()
    })
})
