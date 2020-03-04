<#
.SYNOPSIS
    Get's the WaaS values under the Application Profile feature
.Description
    Get's the WaaS values under the Application Profile feature
.Example
	Get-BarracudaWaaS-AppProfile -authkey <token> -application_id <myappid>
.Notes
v0.1
#>
function Get-BarracudaWaaS-AppProfile{

    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$application_id  
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/url_profiles/"

    $header = @{"auth-api" = "$authkey"}

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $results.Content
       
    }

	try{
		$results =Invoke-WebRequest -Uri "$($url)" -Method GET -Headers $header -UseBasicParsing 
	}catch [System.Net.WebException] {
        $Error[0] | Get-ExceptionResponse
        throw   
    }
	#returns to the login.
	return ($results.Content | ConvertFrom-Json)
}