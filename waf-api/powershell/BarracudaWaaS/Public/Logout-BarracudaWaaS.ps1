<#
.Synopsis
    Logs into the barracuda API
.Description
    Supplies a session token for authorizing API Calls
.Example
Login-Barracuda -device $dev_name -username "username" -password "password"
.Notes
v1.1
#>
function Logout-BarracudaWaaS{

    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$authkey
    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

$header = @{"auth-api" = "$authkey"}


			try{
				
				$results =Invoke-WebRequest -Uri "https://api.waas.barracudanetworks.com/v1/waasapi/logout/" -Method GET -Headers $authkey -UseBasicParsing
			}catch{
				Write-Error("Unable to Logout of WaaS API due to " + $_.Exception)
			}
			

        if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Data"
        Write-Host $($postParams)
        Write-Host "Login Results Debug"
        Write-Host $results.StatusCode
        Write-Host $results.RawContent
    }

	#returns to the login.
	return ($results.Content | ConvertFrom-Json)
}