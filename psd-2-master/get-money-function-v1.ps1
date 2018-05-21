#Includes the configuration
. .\config.ps1
# Gets data from DCRUM and restructures the response to something ServiceNow can handle and returns it to the caller
function getMoney() {

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $dcrum_username,$dcrum_password)))

# Hostname of DCRUM Server
$hostname = "dnbprod.rovca.eu"
# Port for DCRUM Server
$port = 886

# Dimension ids to include    

$dimensionIds = "['bgAppl','bgTrans']"
$dimensionIds = "['pUrlURLHierarchyLvl1']" 

$metricIds = "['cm1Total','cm1Count','cm1Average']"

# Dimension filters to include
$dimFilters = "[['pUrlURLHierarchyLvl1','Payments - Abroad|Payments - Mobile|Payments - Private|Payments - Corporate',false]]"

# Construction of URL
# ClientView is important to get Task etc

#$timeString = "&timeBegin=1524520800000&timeEnd=1524589500000"
$timeString = "&timePeriod=1H&numberOfPeriods=1"
$uri = $dcrum_base_uri + "/rest/dmiquery/getDMIData3?appId=CVENT&viewId=ClientView&dimensionIds=" + $dimensionIds + " &metricIds=" + $metricIds + "&resolution=r&dimFilters=" + $dimFilters + "&metricFilters=[]&sort=[]&top=0&dataSourceId=ALL_AGGR" + $timeString

write-host $uri
$response = Invoke-RestMethod -Method GET -URI $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} #| convertfrom-json | format-table 


$origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0

$timeBegin = $origin.AddMilliSeconds($response.timeBegin)
$timeEnd = $origin.AddMilliSeconds($response.timeEnd)

$json_measures = @" 
{ "u_measures":  [
    
                       
                   ]}
"@ | convertfrom-json

$item = @"
{
                           "name":  "Payment",
                            "sum": 0,
                            "count": 0,
                            "avg": 0,
                            "timeBegin": 0,
                            "timeEnd" : 0
    
                       }
"@ | convertfrom-json


for ($i=0; $i -lt $response.formattedData.length; $i++) {
    $item.name = $response.formattedData[$i][0]
    $item.sum = $response.rawData[$i][1]
    $item.count = $response.rawData[$i][2]
    $item.avg = $response.rawData[$i][3]
    # For EPOCH milliseconds formatting
    $item.timeBegin = [int64](($timebegin) - (get-date "1/1/1970")).TotalMilliseconds
    $item.timeEnd = [int64](($timeEnd) - (get-date "1/1/1970")).TotalMilliseconds
    
    $json_measures.u_measures += $item
    
}
return $json_measures

}