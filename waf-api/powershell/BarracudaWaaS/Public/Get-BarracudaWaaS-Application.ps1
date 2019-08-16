
<#
.Synopsis
    Get's information about the WaaS Applications or a WaaS Application
.Description
    Supplies a session token for authorizing API Calls
.Example
	Get-BarracudaWaaS-Application -authkey <token>
.Notes
v0.1
#>
function Get-BarracudaWaaS-Application{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [string]$appname,
    [switch]$testbackend    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$appname"
    if($testbackend){
        $url = $url + '/backend-ip-test/'
    }

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
	return ($results.Content | ConvertFrom-Json).results
}