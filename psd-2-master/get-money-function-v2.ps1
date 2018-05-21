. .\config.ps1
# Takes multiple parameters, many of which are set to the default use case, but it opens up for future use cases, where the required data may differ
# Sends this DCRUM data to the facebook prophet API and gets the prediction back
function getMoney2 {
param (
    [string]$dimensionIds = "['begT','pUrlURLHierarchyLvl1']" , #Which dimensions to include, for prediction to work it needs to include time, (begT)
    [string]$metricIds = "['cm1Total','cm1Count','cm1Average','trans']", #Which metrics to include
    [string]$dimFilters = "[['pUrlURLHierarchyLvl1','Payments - Private',false]]", #Dimension filters
    [string]$timePeriod = "1H", # Timeperiod, which period to include (1H = 1 hour, 1D = 1 day, 7D = 7 days)
    [string]$resolution = "r", # Resolution, valid options are: r - one period, 1 - one hour, 6 - six hours, d - one day, w - one week, m - one month
    [string]$sort = "[['begT',ASC]]" # [['<dimension>',<ASC|DESC>]] Example for sorting by time: [['begT',ASC]]
    #[int]$numberOfPeriods= 1 # Number of periods to include not needed?
)
#Username and passwrord for Basic Authentication gets loaded from config.ps1
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $dcrum_username,$dcrum_password)))

# Construction of URL
# ClientView is important to get Task etc, which are the custom metrics for monetary values
$uri = $dcrum_base_uri + "/rest/dmiquery/getDMIData3?appId=CVENT&viewId=ClientView&dimensionIds=" + `
$dimensionIds + "&metricIds=" + $metricIds + "&resolution=" + $resolution + "&dimFilters=" + `
$dimFilters + "&metricFilters=[]&sort=" + $sort + "&top=0&dataSourceId=ALL_AGGR" + "&timePeriod=" + $timePeriod 

$response = Invoke-RestMethod -Method GET -URI $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} 

$predictUri = $fbprophet_uri

$prediction = Invoke-RestMethod -uri $predictUri -Body ($response |ConvertTo-Json) -Method POST -ContentType "application/json"


return $prediction


}

