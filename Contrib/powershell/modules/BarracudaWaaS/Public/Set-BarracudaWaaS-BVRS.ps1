<#
.SYNOPSIS
    Enables the BVRS service for an application
.Description
    Supplies a session token for authorizing API Calls
.Example
Login-Barracuda -device $dev_name -username "username" -password "password"
.Notes
v0.1
#>
function Set-BarracudaWaaS-BVRS{

    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$application_id
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Verbose "Login Input Debug"
        Write-Verbose $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/vrs/ "

    $header = @{"auth-api" = "$authkey"}
   

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Verbose "Login Results Debug"
        Write-Verbose $results.Content
       
    }

	try{
		$results =Invoke-WebRequest -Uri "$($url)" -Method POST -Headers $header -UseBasicParsing 
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