param (
    # The Log Analytics Workspace ID
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceId,
    
    # The Log Analytics Workspace Key
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceKey,

    # The GitHub Action Number Run
    [Parameter(Mandatory=$true)]
    [string]$GitHubActionRunNumber,

    # The GitHub Repository
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo
)

$CustomerId = $WorkspaceId 

# Replace with your Primary Key
$SharedKey = $WorkspaceKey

# Specify the name of the record type that you'll be creating.
$LogType = "GitHubHeartbeat"

# Optional name of a field that includes the timestamp for the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = ""

# Create two records with the same set of properties to create
$hash = @{
    "alive" = "true"
    "GitHubRepo" = $GitHubRepo
    "GitHubActionRunNumber" = $GitHubActionRunNumber
}
$json = $hash | ConvertTo-Json

# Create the function to create the authorization signature.
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}

# Create the function to create and post the request.
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

# Submit the data to the API endpoint.
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
