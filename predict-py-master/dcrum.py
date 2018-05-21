import config
import requests
from requests.auth import HTTPBasicAuth

from flask import Response
#response = Response()

def get_dcrum():
    url = "https://cas01.sa.evry.com/rest/dmiquery/getDMIData3"
    querystring = {"appId":"CVENT","viewId":"ClientView",
                  #"dimensionIds":"['bgAppl','begT']","metricIds":"['trans']","resolution":"r",
                  "dimensionIds":"['begT']","metricIds":"['trans']","resolution":"r",
                  #"dimFilters":"[['bgAppl','DS_DIPS',false]]",
                  "dimFilters":"[]",
                  "metricFilters":"[]",
                  "sort":"[]",
                  "top":"0",
                  "dataSourceId":
                  "ALL_AGGR","timePeriod":"7D"}
    response = requests.request("GET", url, auth=HTTPBasicAuth(config.username,config.password),  params=querystring)
    result = response.json()
    
    return result


#DEBUG
#b = get_dcrum()
#print(b)
#print(b['rawData'])

