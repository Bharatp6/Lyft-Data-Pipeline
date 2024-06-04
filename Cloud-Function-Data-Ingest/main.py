from gbfs.client import GBFSClient
from google.cloud import pubsub_v1
import json
import requests 
import pytz
from datetime import datetime

def get_station_status(request):  
  
  # Initialize a Publisher client
  publisher = pubsub_v1.PublisherClient()
  # Specify your Google Cloud project ID
  project_id = "future-mystery-418617"
  # Specify the Pub/Sub topic name
  topic_name = "Station_status_stream"

  # Construct the fully qualified topic path
  topic_path = publisher.topic_path(project_id, topic_name)

  # Initialize the GBFS Client
  client = GBFSClient('https://gbfs.lyft.com/gbfs/2.3/dca-cabi/gbfs.json', 'en')

  station_stat = client.request_feed('station_status')['data']['stations']
  #free_bike_stat = client.request_feed('free_bike_status')['data']['bikes']

  # Serialize the dictionary to a JSON string
  station_status_data_json = json.dumps((station_stat))
  #free_bike_stat_data_json = json.dumps((free_bike_stat))

  # Encode the JSON string to bytes
  station_status_data_bytes = station_status_data_json.encode("utf-8")
  #free_bike_stat_data_bytes = free_bike_stat_data_json.encode("utf-8")

  # Publish the byte string to the Pub/Sub topic
  future = publisher.publish(topic_path, data= station_status_data_bytes, message_type="station_stat")
  #future1 = publisher.publish(topic_path, data = free_bike_stat_data_bytes, message_type="free_bike_stat")


  return f"Published message ID: {future.result()}"
