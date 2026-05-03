import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('file-metadata')

def lambda_handler(event, context):
    for record in event['Records']:
        file_name = record['s3']['object']['key']
        bucket_name = record['s3']['bucket']['name']
        
        table.put_item(
            Item={
                'file_name': file_name,
                'bucket': bucket_name,
                'upload_time': datetime.now().isoformat()
            }
        )
        
    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
