
<#
.SYNOPSIS
    Authenticates to the Barraucda WAF as a Service API
.Description
    Supplies a session token for authorising future API calls
.Example
    Login-BarracudaWaaS -device $dev_name -username "username" -password "password"
.Notes
v0.1
#>
function Login-BarracudaWaaS{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    $credentials    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

     $postParams = @{"email"="$($credentials.Username)"; "password"="$($Credentials.GetNetworkCredential().Password)"}
 
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Data"
        Write-Host $($postParams)
        Write-Host "Login Results Debug"
        Write-Host $results.StatusCode
        Write-Host $results.RawContent
    }

			try{
				$results =Invoke-WebRequest -Uri "https://api.waas.barracudanetworks.com/v1/waasapi/api_login/" -Method POST -Body $postParams -UseBasicParsing -ErrorAction SilentlyContinue
			}catch [System.Net.WebException] {
                $Error[0] | Get-ExceptionResponse
                throw   
            }
			



	#returns to the login.
	return ($results.Content | ConvertFrom-Json)
}