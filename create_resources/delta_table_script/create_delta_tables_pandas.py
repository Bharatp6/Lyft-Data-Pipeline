import pandas as pd
from deltalake import write_deltalake
import gcsfs
import os
from google.cloud import storage

# Set up Google Cloud Storage
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "gcloud-service-key.json"

# Define the schema and create empty DataFrames
schema_station_status_nrt = {
    "datetime": "datetime64[ns]",
    "station_id": "object",
    "num_bikes_available": "Int64",
    "vehicle_type_id_1": "Int64",
    "vehicle_type_id_2": "Int64",
    "num_ebikes_available": "Int64",
    "num_docks_available": "Int64",
    "num_docks_disabled": "Int64",
    "num_bikes_disabled": "Int64",
    "num_scooters_available": "Int64",
    "num_scooters_unavailable": "Int64",
    "is_installed": "boolean",
    "is_renting": "boolean",
    "is_returning": "boolean",
    "last_reported": "Int64"
}

schema_station_info = {
    "station_id": "object",
    "name": "object",
    "short_name": "object",
    "region_id": "object",
    "lon": "float64",
    "lat": "float64",
    "capacity": "Int64",
    "datetime": "datetime64[ns]"
}

schema_weather = {
    "datetime": "datetime64[ns]",
    "temperature_2m": "float64",
    "wind_speed_10m": "float64",
    "relative_humidity_2m": "float64",
    "precipitation": "float64",
    "dew_point_2m": "float64",
    "rain": "float64",
    "showers": "float64",
    "snowfall": "float64",
    "wind_gusts_10m": "float64",
    "sunshine_duration": "float64",
    "visibility": "float64",
    "diffuse_radiation": "float64",
    "station_id": "object"
}

# Create empty DataFrames
df_station_status_nrt = pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_station_status_nrt.items()})
df_station_info = pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_station_info.items()})
df_weather = pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_weather.items()})

# Define the path of the GCS folders for the Delta tables
ssn_path = "gs://your-bucket-name/station_status_nrt_delta_table"
ssi_path = "gs://your-bucket-name/station_info_delta_table"
w_path = "gs://your-bucket-name/weather_delta_table"

# Initialize GCS filesystem
fs = gcsfs.GCSFileSystem(project=os.getenv("GOOGLE_CLOUD_PROJECT"))

# Function to create a Delta table
def create_delta_table(delta_path, df):
    write_deltalake(delta_path, df)

# Execute the function to create Delta tables
create_delta_table(ssn_path, df_station_status_nrt)
create_delta_table(ssi_path, df_station_info)
create_delta_table(w_path, df_weather)

print("Delta tables created successfully")
