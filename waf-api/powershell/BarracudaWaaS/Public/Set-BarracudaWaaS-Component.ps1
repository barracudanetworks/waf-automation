<#
.Synopsis
    Logs into the barracuda API
.Description
    Supplies a session token for authorizing API Calls
.Example
Login-Barracuda -device $dev_name -username "username" -password "password"
.Notes
v0.1
#>
function Set-BarracudaWaaS-Component{
    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$application_id,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$component_id
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/components/$($component_id)/"

    $header = @{"auth-api" = "$authkey"}

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $results.Content
       
    }

	try{
		$results =Invoke-WebRequest -Uri "$($url)" -Method Patch -Headers $header -UseBasicParsing 
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