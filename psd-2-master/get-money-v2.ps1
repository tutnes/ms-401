. .\config.ps1

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $dcrum_username,$dcrum_password)))

# Hostname of DCRUM Server
$hostname = "dnbprod.rovca.eu"
# Port for DCRUM Server
$port = 886

# Dimension ids to include    

$dimensionIds = "['bgAppl','bgTrans']"
$dimensionIds = "['pUrlURLHierarchyLvl1']" 

$metricIds = "['cm1Total','cm1Count']"

# Dimension filters to include
$dimFilters = "[['pUrlURLHierarchyLvl1','Payments - Abroad|Payments - Mobile|Payments - Private|Payments - Corporate',false]]"

# Construction of URL
# ClientView is important to get Task etc
$timeString = "&timePeriod=1H"
$uri = "https://" + $hostname + ":" + $port + "/rest/dmiquery/getDMIData3?appId=CVENT&viewId=ClientView&dimensionIds=" + $dimensionIds + " &metricIds=" + $metricIds + "&resolution=r&dimFilters=" + $dimFilters + "&metricFilters=[]&sort=[]&top=0&dataSourceId=ALL_AGGR" + $timeString




$response = Invoke-RestMethod -Method GET -URI $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} 


$origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0

$timeBegin = $origin.AddMilliSeconds($response.timeBegin)
$timeEnd = $origin.AddMilliSeconds($response.timeEnd)


$timeBegin.toLocalTime()
$timeEnd.toLocalTime()

for ($i=0; $i -lt $response.formattedData.length; $i++) {
for ($z=0; $z -lt $response.formattedData[$i].length; $z++) {
	#$string = $string + $response.columnHeaderName[$element] + $element
    
}	
   $string = $string + $response.columnHeaderName[$i] + " " + $response.formattedData[$i] + "`n"
}
$string

