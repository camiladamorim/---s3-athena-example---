import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket='ninaohio', Key='athena/certo/2020/07/19/603beafc-c40c-4359-bf4b-138a63b8d076.csv')
    content = response['Body'].read().decode('utf-8')
    content=str(content)
    print(content)
    s3.put_object(Body=content, Bucket='ninaohio', Key='output/result.txt')
    return(0)
