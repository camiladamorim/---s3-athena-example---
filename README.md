# s3 athena etl example

### source: https://www.dataquest.io/blog/free-datasets-for-projects/
educational data from countries




### Attributes for both student-mat.csv (Math course) and student-por.csv (Portuguese language course) datasets:
1. school - student's school (binary: "GP" - Gabriel Pereira or "MS" - Mousinho da Silveira)
2. sex - student's sex (binary: "F" - female or "M" - male)
3. age - student's age (numeric: from 15 to 22)
4. address - student's home address type (binary: "U" - urban or "R" - rural)
5. famsize - family size (binary: "LE3" - less or equal to 3 or "GT3" - greater than 3)
6. Pstatus - parent's cohabitation status (binary: "T" - living together or "A" - apart)
7. Medu - mother's education (numeric: 0 - none,  1 - primary education (4th grade), 2 – 5th to 9th grade, 3 – secondary education or 4 – higher education)
8. Fedu - father's education (numeric: 0 - none,  1 - primary education (4th grade), 2 – 5th to 9th grade, 3 – secondary education or 4 – higher education)
9. Mjob - mother's job (nominal: "teacher", "health" care related, civil "services" (e.g. administrative or police), "at_home" or "other")
10. Fjob - father's job (nominal: "teacher", "health" care related, civil "services" (e.g. administrative or police), "at_home" or "other")
11. reason - reason to choose this school (nominal: close to "home", school "reputation", "course" preference or "other")
12. guardian - student's guardian (nominal: "mother", "father" or "other")
13. traveltime - home to school travel time (numeric: 1 - <15 min., 2 - 15 to 30 min., 3 - 30 min. to 1 hour, or 4 - >1 hour)
14. studytime - weekly study time (numeric: 1 - <2 hours, 2 - 2 to 5 hours, 3 - 5 to 10 hours, or 4 - >10 hours)
15. failures - number of past class failures (numeric: n if 1<=n<3, else 4)
16. schoolsup - extra educational support (binary: yes or no)
17. famsup - family educational support (binary: yes or no)
18. paid - extra paid classes within the course subject (Math or Portuguese) (binary: yes or no)
19. activities - extra-curricular activities (binary: yes or no)
20. nursery - attended nursery school (binary: yes or no)
21. higher - wants to take higher education (binary: yes or no)
22. internet - Internet access at home (binary: yes or no)
23. romantic - with a romantic relationship (binary: yes or no)
24. famrel - quality of family relationships (numeric: from 1 - very bad to 5 - excellent)
25. freetime - free time after school (numeric: from 1 - very low to 5 - very high)
26. goout - going out with friends (numeric: from 1 - very low to 5 - very high)
27. Dalc - workday alcohol consumption (numeric: from 1 - very low to 5 - very high)
28. Walc - weekend alcohol consumption (numeric: from 1 - very low to 5 - very high)
29. health - current health status (numeric: from 1 - very bad to 5 - very good)
30. absences - number of school absences (numeric: from 0 to 93)
31. G3 - final grade
>

## Stack para cloudformation

```
---
AWSTemplateFormatVersion: '2010-09-09'


Resources:

Resources:
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      VersioningConfiguration:
        Status: Enabled
        AccessControl: PublicReadWrite
        BucketName: ninaohio


  Crawler:
    Type: AWS::Glue::Crawler
    Properties:
      Name: crawlername
      Role: service-role/AWSGlueServiceRole-DefaultRole
      Description: o crawler vai pegar do bucket para uma tabela do glue todo dia as 22h
      DatabaseName: db-glue
      TablePrefix: dbgluenina
      Schedule:
        Schedule:
        ScheduleExpression: "cron(0 0 22 ? * * *)"
      Targets:
        S3Targets:
          - Path: !Ref "s3://ninaohio/"

  Lambda:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.handler
      Role: arn:aws:iam::123456789012:role/lambda-role
      Code:
        S3Bucket: ninaohio
        S3Key: lambda.py
      Runtime: Python 3.8
      Timeout: 5


  Athena:
    Type: AWS::Athena::WorkGroup
    Properties:
      Name: workgroup
      Description: My WorkGroup
      State: ENABLED
      WorkGroupConfigurationUpdates:
        BytesScannedCutoffPerQuery: 10000000
        EnforceWorkGroupConfiguration: true
        PublishCloudWatchMetricsEnabled: true
        RequesterPaysEnabled: false
        ResultConfigurationUpdates:
          OutputLocation: "s3://ninaohio/athena"


  AthenaNamedQuery:
    Type: AWS::Athena::NamedQuery
    Properties:
      Database: "db-glue"
      Description: "seleciona o genero,idade e saúde dos alunos que tem a nota mais alta"
      Name: "certo"
      QueryString: >
                    SELECT sex,age,nursery FROM  dbglueninaninaohio WHERE g3>4
````




### função lambda: modifica arquivos já transformados pela query do athena em legíveis

```
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket='ninaohio', Key='athena/certo/2020/07/19/603beafc-c40c-4359-bf4b-138a63b8d076.csv')
    content = response['Body'].read().decode('utf-8')
    content=str(content)
    print(content)
    s3.put_object(Body=content, Bucket='ninaohio', Key='output/file.txt')
    return(0)
```


### link:
<https://ninaohio.s3.us-east-2.amazonaws.com/output/file.txt>


<img src="./schema_AWS.png">

<img src="./athena.png">
