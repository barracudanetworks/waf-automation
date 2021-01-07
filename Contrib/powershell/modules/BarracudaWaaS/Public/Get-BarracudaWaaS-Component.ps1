<#
.SYNOPSIS
    Get's the WaaS feature components enabled
.Description
    Get's the WaaS feature components enabled
.Example
	Get-BarracudaWaaS-Component -authkey <token> -application_id <myappid>
.Notes
v0.1
#>
function Get-BarracudaWaaS-Component{

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

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/components/"

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
	return ($results.Content | ConvertFrom-Json)
}