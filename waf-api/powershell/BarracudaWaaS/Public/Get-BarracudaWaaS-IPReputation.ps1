<#
.Synopsis
    Get's values in the IP Reputation feature
.Description
    Collects the current values configured under the IP reputation feature.
.Example
    Get-BarracudaWaaS-IPReputation
.Notes
v0.1
#>
function Get-BarracudaWaaS-IPReputation{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$application_id
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }
     $header = @{"auth-api" = "$authkey"}
     $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/ip_reputation/"

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