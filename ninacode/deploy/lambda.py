import boto3 

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket='ninaohio', Key='transformed/run-1595103236313-part-r-00000')
    content = response['Body'].read().decode('utf-8')
    content=str(content)
    s3.put_object(Body=content, Bucket='ninaohio', Key='output/file.txt')
    return(0)