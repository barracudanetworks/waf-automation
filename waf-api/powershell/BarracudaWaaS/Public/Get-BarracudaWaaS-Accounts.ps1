<#
.SYNOPSIS
    Get's a list of accounts associated with this login
.Description
    Get's a list of accounts associated with this login
.Example
Get-BarracudaWaaS-Accounts -authkey $waas_token.key
.Notes
v0.1
#>
function Get-BarracudaWaaS-Accounts{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey
    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }


    $header = @{"auth-api" = "$authkey"}

    
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $results.Content
       
    }

	try{
		$results =Invoke-WebRequest -Uri "https://api.waas.barracudanetworks.com/v2/waasapi/accounts/" -Method GET -Headers $header -UseBasicParsing 
	}catch [System.Net.WebException] {
                $Error[0] | Get-ExceptionResponse
                throw   
            }
			
	#returns to the login.
	return ($results.Content | ConvertFrom-Json)
}