import pandas as pd
from deltalake import write_deltalake
import gcsfs
import os
from google.cloud import storage

# Set up Google Cloud Storage
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "gcloud-service-key.json"

# Define the schema and create empty DataFrames
schema_station_status_nrt = {
    "datetime": "1869-01-01 00:00:00",
    "station_id": "0",
    "num_bikes_available": 0,
    "vehicle_type_id_1": 0,
    "vehicle_type_id_2": 0,
    "num_ebikes_available": 0,
    "num_docks_available": 0,
    "num_docks_disabled": 0,
    "num_bikes_disabled": 0,
    "num_scooters_available": 0,
    "num_scooters_unavailable": 0,
    "is_installed": True,
    "is_renting": True,
    "is_returning": True,
    "last_reported": 0
}

schema_station_info = {
    "station_id": "0",
    "name": "0",
    "short_name": "0",
    "region_id": "0",
    "lon": 0.0,
    "lat": 0.0,
    "capacity": 0,
    "datetime": "1869-01-01 00:00:00"
}

schema_weather = {
    "datetime": "1869-01-01 00:00:00",
    "temperature_2m": 0.0,
    "wind_speed_10m": 0.0,
    "relative_humidity_2m": 0.0,
    "precipitation": 0.0,
    "dew_point_2m": 0.0,
    "rain": 0.0,
    "showers": 0.0,
    "snowfall": 0.0,
    "wind_gusts_10m": 0.0,
    "sunshine_duration": 0.0,
    "visibility": 0.0,
    "diffuse_radiation": 0.0,
    "station_id": "0"
}

# Create empty DataFrames
df_station_status_nrt = pd.DataFrame(schema_station_status_nrt) #pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_station_status_nrt.items()})
df_station_info = pd.DataFrame(schema_station_info) #pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_station_info.items()})
df_weather = pd.DataFrame(schema_weather) #pd.DataFrame({k: pd.Series(dtype=v) for k, v in schema_weather.items()})

# Define the path of the GCS folders for the Delta tables
ssn_path = "gs://delta_table_bucket/station_status_nrt_delta_table"
ssi_path = "gs://delta_table_bucket/station_info_delta_table"
w_path = "gs://delta_table_bucket/weather_delta_table"

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
