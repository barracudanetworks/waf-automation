
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
    [string]$appid,
    [switch]$testbackend    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$appid"
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
        
	}catch{
        if(Test-Json -Json $Error[0].ErrorDetails.Message -ErrorAction SilentlyContinue){
            $Error[0].ErrorDetails.Message | ConvertFrom-Json
        }else{
            $Error[1].ErrorDetails.Message
        }
        
    }
			


    #returns to the login.
    if(!$appid){
        return ($results.Content | ConvertFrom-Json).results
    }else{
        return ($results.Content | ConvertFrom-Json)
    }
}