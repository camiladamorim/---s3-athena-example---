import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "db-glue", table_name = "dbglueninaninaohio", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "db-glue", table_name = "dbglueninaninaohio", transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("school", "string", "school", "string"), ("sex", "string", "sex", "string"), ("age", "long", "age", "long"), ("address", "string", "address", "string"), ("famsize", "string", "famsize", "string"), ("pstatus", "string", "pstatus", "string"), ("medu", "long", "medu", "long"), ("fedu", "long", "fedu", "long"), ("mjob", "string", "mjob", "string"), ("fjob", "string", "fjob", "string"), ("reason", "string", "reason", "string"), ("guardian", "string", "guardian", "string"), ("traveltime", "long", "traveltime", "long"), ("studytime", "long", "studytime", "long"), ("failures", "long", "failures", "long"), ("schoolsup", "string", "schoolsup", "string"), ("famsup", "string", "famsup", "string"), ("paid", "string", "paid", "string"), ("activities", "string", "activities", "string"), ("nursery", "string", "nursery", "string"), ("higher", "string", "higher", "string"), ("internet", "string", "internet", "string"), ("romantic", "string", "romantic", "string"), ("famrel", "long", "famrel", "long"), ("freetime", "long", "freetime", "long"), ("goout", "long", "goout", "long"), ("dalc", "long", "dalc", "long"), ("walc", "long", "walc", "long"), ("health", "long", "health", "long"), ("absences", "long", "absences", "long"), ("g1", "long", "g1", "long"), ("g2", "long", "g2", "long"), ("g3", "long", "g3", "long")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("school", "string", "school", "string"), ("sex", "string", "sex", "string"), ("age", "long", "age", "long"), ("address", "string", "address", "string"), ("famsize", "string", "famsize", "string"), ("pstatus", "string", "pstatus", "string"), ("medu", "long", "medu", "long"), ("fedu", "long", "fedu", "long"), ("mjob", "string", "mjob", "string"), ("fjob", "string", "fjob", "string"), ("reason", "string", "reason", "string"), ("guardian", "string", "guardian", "string"), ("traveltime", "long", "traveltime", "long"), ("studytime", "long", "studytime", "long"), ("failures", "long", "failures", "long"), ("schoolsup", "string", "schoolsup", "string"), ("famsup", "string", "famsup", "string"), ("paid", "string", "paid", "string"), ("activities", "string", "activities", "string"), ("nursery", "string", "nursery", "string"), ("higher", "string", "higher", "string"), ("internet", "string", "internet", "string"), ("romantic", "string", "romantic", "string"), ("famrel", "long", "famrel", "long"), ("freetime", "long", "freetime", "long"), ("goout", "long", "goout", "long"), ("dalc", "long", "dalc", "long"), ("walc", "long", "walc", "long"), ("health", "long", "health", "long"), ("absences", "long", "absences", "long"), ("g1", "long", "g1", "long"), ("g2", "long", "g2", "long"), ("g3", "long", "g3", "long")], transformation_ctx = "applymapping1")
## @type: DataSink
## @args: [connection_type = "s3", connection_options = {"path": "s3://ninaohio/transformed/"}, format = "csv", transformation_ctx = "datasink2"]
## @return: datasink2
## @inputs: [frame = applymapping1]
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://ninaohio/transformed/"}, format = "csv", transformation_ctx = "datasink2")
job.commit()