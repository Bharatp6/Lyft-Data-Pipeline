variable "project_id" {
  description = "The ID of the GCP project to use."
  type        = string
}

variable "region" {
  description = "The GCP region to use."
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account"
  type        = string
}

variable "station_status_nrt_schema" {
  description = "Schema for STATION_STATUS_NRT table"
  type = list(object({
    name        = string
    mode        = string
    type        = string
    description = string
    fields      = list(any)
  }))
  default = [
    { name = "datetime", mode = "NULLABLE", type = "DATETIME", description = null, fields = [] },
    { name = "station_id", mode = "NULLABLE", type = "STRING", description = null, fields = [] },
    { name = "num_bikes_available", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "vehicle_type_id_1", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "vehicle_type_id_2", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_ebikes_available", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_docks_available", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_docks_disabled", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_bikes_disabled", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_scooters_available", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "num_scooters_unavailable", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "is_installed", mode = "NULLABLE", type = "BOOLEAN", description = null, fields = [] },
    { name = "is_renting", mode = "NULLABLE", type = "BOOLEAN", description = null, fields = [] },
    { name = "is_returning", mode = "NULLABLE", type = "BOOLEAN", description = null, fields = [] },
    { name = "last_reported", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] }
  ]
}

variable "station_info_schema" {
  description = "Schema for STATION_INFO table"
  type = list(object({
    name        = string
    mode        = string
    type        = string
    description = string
    fields      = list(any)
  }))
  default = [
    { name = "station_id", mode = "NULLABLE", type = "STRING", description = null, fields = [] },
    { name = "name", mode = "NULLABLE", type = "STRING", description = null, fields = [] },
    { name = "short_name", mode = "NULLABLE", type = "STRING", description = null, fields = [] },
    { name = "region_id", mode = "NULLABLE", type = "STRING", description = null, fields = [] },
    { name = "lon", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "lat", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "capacity", mode = "NULLABLE", type = "INTEGER", description = null, fields = [] },
    { name = "datetime", mode = "NULLABLE", type = "DATETIME", description = null, fields = [] }
  ]
}

variable "weather_table_schema" {
  description = "Schema for WEATHER_TABLE"
  type = list(object({
    name        = string
    mode        = string
    type        = string
    description = string
    fields      = list(any)
  }))
  default = [
    { name = "datetime", mode = "NULLABLE", type = "DATETIME", description = null, fields = [] },
    { name = "temperature_2m", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "wind_speed_10m", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "relative_humidity_2m", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "precipitation", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "dew_point_2m", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "rain", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "showers", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "snowfall", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "wind_gusts_10m", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "sunshine_duration", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "visibility", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "diffuse_radiation", mode = "NULLABLE", type = "FLOAT", description = null, fields = [] },
    { name = "station_id", mode = "NULLABLE", type = "STRING", description = null, fields = [] }
  ]
}
