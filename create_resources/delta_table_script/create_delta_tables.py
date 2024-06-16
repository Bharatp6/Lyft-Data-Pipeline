from pyspark.sql.types import StructType, StructField, StringType,FloatType,IntegerType, BooleanType ,TimestampType
import pyspark
from delta import *

# Initialize SparkSession with Delta Lake configuration
builder = pyspark.sql.SparkSession.builder.appName("MyApp") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.jars.packages", "com.google.cloud.bigdataoss:gcs-connector:hadoop3-2.2.5") \
    .config("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
    .config("spark.hadoop.google.cloud.auth.service.account.json.keyfile", "/path/to/gcloud-service-key.json")

spark = configure_spark_with_delta_pip(builder).getOrCreate()

# Define the schema
schema_station_status_nrt = StructType([
    StructField("datetime", TimestampType(), True),
    StructField("station_id", StringType(), True),
    StructField("num_bikes_available", IntegerType(), True),
    StructField("vehicle_type_id_1", IntegerType(), True),
    StructField("vehicle_type_id_2", IntegerType(), True),
    StructField("num_ebikes_available", IntegerType(), True),
    StructField("num_docks_available", IntegerType(), True),
    StructField("num_docks_disabled", IntegerType(), True),
    StructField("num_bikes_disabled", IntegerType(), True),
    StructField("num_scooters_available", IntegerType(), True),
    StructField("num_scooters_unavailable", IntegerType(), True),
    StructField("is_installed", BooleanType(), True),
    StructField("is_renting", BooleanType(), True),
    StructField("is_returning", BooleanType(), True),
    StructField("last_reported", IntegerType(), True)
])


schema_station_info = StructType([
    StructField("station_id", StringType(), True),
    StructField("name", StringType(), True),
    StructField("short_name", StringType(), True),
    StructField("region_id", StringType(), True),
    StructField("lon", FloatType(), True),
    StructField("lat", FloatType(), True),
    StructField("capacity", IntegerType(), True),
    StructField("datetime", TimestampType(), True)
])

schema_weather = StructType([
    StructField("datetime", TimestampType(), True),
    StructField("temperature_2m", FloatType(), True),
    StructField("wind_speed_10m", FloatType(), True),
    StructField("relative_humidity_2m", FloatType(), True),
    StructField("precipitation", FloatType(), True),
    StructField("dew_point_2m", FloatType(), True),
    StructField("rain", FloatType(), True),
    StructField("showers", FloatType(), True),
    StructField("snowfall", FloatType(), True),
    StructField("wind_gusts_10m", FloatType(), True),
    StructField("sunshine_duration", FloatType(), True),
    StructField("visibility", FloatType(), True),
    StructField("diffuse_radiation", FloatType(), True),
    StructField("station_id", StringType(), True)
])


# Define the path of the gcs folders for the delta tables  
ssn_path = "gs://delta_table_bucket/station_status_nrt_delta_table/"
ssi_path = "gs://delta_table_bucket/station_info_delta_table/"
w_path = "gs://delta_table_bucket/weather_delta_table/" 


# Function to create a delta table
def create_delta_table(delta_path, schema):
    # Create an empty DataFrame with the specified schema
    empty_df = spark.createDataFrame([], schema)

    # Write the empty DataFrame as a Delta table
    empty_df.write.format("delta").mode("overwrite").save(delta_path)

# Execute the function
create_delta_table(ssn_path, schema_station_status_nrt)
create_delta_table(ssi_path, schema_station_info)
create_delta_table(w_path, schema_weather)
