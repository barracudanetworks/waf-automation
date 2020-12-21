<#
.SYNOPSIS
    Get's details of the Parameter Protection component settings

.EXAMPLE
	Get-BarracudaWaaS-ParameterProtect -authkey <token> -application_id <applicationid>
.Notes
v0.1
#>
function Get-BarracudaWaaS-ParameterProtect{

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
     $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/parameter_protection/"

	try{
       
		$results =Invoke-WebRequest -Uri "$($url)" -Method GET -Headers $header -UseBasicParsing 
	}catch{
        if(Test-Json -Json $Error[0].ErrorDetails.Message -ErrorAction SilentlyContinue){
            $Error[0].ErrorDetails.Message | ConvertFrom-Json
        }else{
            $Error[1].ErrorDetails.Message
        }
        
    }
			

	#returns the results
	return ($results.Content | ConvertFrom-Json)
}
