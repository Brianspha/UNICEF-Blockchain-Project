from sys import argv
from os.path import exists
import json
import geocoder

 
data = json.load(open('../src/json/shoolscapetown.json'))
 
geojson = {
    "type": "FeatureCollection",
    "features": [
    {
        "type": "Feature",
        "geometry" : {
            "type": "Polygon",
            "coordinates": [[d["GIS_Longitude"], d["GIS_Latitude"]] for d in data if ( d["GIS_Latitude"] and d["GIS_Longitude"])],
            },
        "properties" : [geocoder.google([d["GIS_Latitude"],d["GIS_Longitude"]], method='reverse') for d in data if ( d["GIS_Latitude"] and d["GIS_Longitude"])]  ,
     }]
}
 
 
output = open("GeoJSON.geojson.js", 'w')
json.dump(geojson, output)
 
print (geojson)