<#
.SYNOPSIS
    Get's the values of a parameter profile
.Description
    Gets the values of a parameter profile, you need to collect the param_id fromn the Application Profile
.Example
	Get-BarracudaWaaS-AppProfile -authkey <token> -application_id <myappid> -param_id <myappid>
.Notes
v0.1
#>
function Get-BarracudaWaaS-ParameterProfile{

    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$application_id,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$param_id   
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/profile_parameter/$($param_id)/"

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