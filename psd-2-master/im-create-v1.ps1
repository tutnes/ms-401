# Im create version 1
# gets description of incident as parameters, and pushes to the ServiceNow URI ($servicenow_uri)

param (
    [string]$short_description,
    [string]$description
)

. .\config.ps1

$uri = $servicenow_uri

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $servicenow_username,$servicenow_password)))

# The JSON template agreed upon, and mirrored in ServiceNow
# Some of the fields, are for future development, and are not really in use 
# as of April 2018.


$sn_json_text = @"
{
    "Configuration item": "psd-2-reporting",
    "assigned_to": "psd-2-assignmentgroup",
    "cmdb_ci": "psd-2-reporting",
    "company": "",
    "correlation_display": "dynaTrace",
    "correlation_id": "fbbbd429-919c-413e-a589-eca1a77eeeb3",
    "description": "IM From Dynatrace, check in dashboards for further information",
    "u_measures": [{
        "name": "/boot",
        "ThresholdValue": 80.0,
        "TriggeredValue": "98.82"
    }, {
        "name": "EuroTransfer",
        "ThresholdValue": 4000000,
        "TriggeredValue": 5000000
    }],
    "impact": "3",
    "knowledge": "false",
    "known_error": "false",
    "priority": "3",
    "short_description": "IM From Dynatrace",
    "subcategory": "PSD2",
    "sysparm_action": "insert",
    "u_dtincrule": "",
    "u_dtprofile": "",
    "urgency": "2",
    "caller_id": "dynatraceint",
    "category": "IT og andre feil",
    "business_service": "1597 - reSolve ITSM (Production)",
    "contact_type": "event-alert",
    "u_incident_type": "Event",
    "assignment_group": "DNB & PSD2 Compliance Team"

}
"@

# Takes the JSON template and adds the two parameters that Dynatrace passes, when the script 
# is invoked


$sn_json_object = $sn_json_text | ConvertFrom-Json 
if ($short_description) {
    $sn_json_object.short_description = $short_description
}
if ($description) {
    $sn_json_object.description = $description
}

$postbody = $sn_json_object | ConvertTo-Json

$response = Invoke-RestMethod -Method POST -URI $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $postbody

# For logging purposes, and to gauge the degree of over reporting, logging was enabled
# a response from ServiceNow is also kept, for historical purposes, so that the 
# incident ticket can be retrieved at a later point.

$d = (Get-Date).toString("MMdy HHmm.fff")
$file = $d + ".json"
$str = $d + "," +$short_description
$str | Out-File -Append c:\scripts\log\im-prod.log


$response  | convertto-json | out-file c:\scripts\log\$file