<#
.Synopsis
    Sets values of the IP Reputation feature
.DESCRIPTION
	This command allows you to configure the values within the IP Reputation feature.
.EXAMPLE
The below example passes in previously collected values on the pipeline and edits the value of the blocked countries
$iprep | Set-BarracudaWaaS-IPReputation -authkey $waas_token.key -id $iprep.id -managed_service 3399 -blocked_countries $country_array 
.EXAMPLE
The below example creates new values.
Set-BarracudaWaaS-IPReputation -authkey $waas_token.key -id $iprep.id -managed_service 3399 -blocked_countries $country_array 
.Notes
v1.1
#>
function Set-BarracudaWaaS-IPReputation{
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true)]
    [int]$id,
    [Alias("managed_service")]
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$application_id,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    $network_exceptions,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$block_barracuda_reputation_blacklist=$false,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$block_tor_nodes=$false,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$block_anonymous_proxies=$true,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$block_satellite_providers=$false,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$enabled=$true,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [array]$blocked_countries
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }
     $header = @{"auth-api" = "$authkey"}
     $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$($application_id)/ip_reputation/"
     $PSBoundParameters["managed_service"] = $application_id

        #sets any default variables to parameters in $PSBoundParameters
        foreach($key in $MyInvocation.MyCommand.Parameters.Keys)
        {
            $value = Get-Variable $key -ValueOnly -EA SilentlyContinue
            if(($value -or $value -eq $false) -and !$PSBoundParameters.ContainsKey($key)) {$PSBoundParameters[$key] = $value}
        }
    
        #Void's anything we don't want
        [Void]$PSBoundParameters.Remove("application_id")
        [Void]$PSBoundParameters.Remove("authkey")
        [Void]$PSBoundParameters.Remove("Debug")


        #Converts the true false string in the Allow column to be boolean and converted to json correctly.
        for ($i = 0; $i -le ($PSBoundParameters["network_exceptions"].length - 1); $i += 1) {
          $PSBoundParameters["network_exceptions"][$i].allow = [System.Convert]::ToBoolean($PSBoundParameters["network_exceptions"][$i].allow)
        }
        
        $PSBoundParameters["exceptions"] = $network_exceptions
        [Void]$PSBoundParameters.Remove("network_exceptions")
    
    #}
    Write-Debug $PSBoundParameters   
    $json = ConvertTo-Json $PSBoundParameters -Depth 99
    Write-Debug $json

	try{
    
		$results = Invoke-WebRequest -Uri "$($url)" -Method PATCH -Headers $header -Body $json -ContentType "application/json" -UseBasicParsing
	
    }catch{
        if(Test-Json -Json $Error[0].ErrorDetails.Message -ErrorAction SilentlyContinue){
            $Error[0].ErrorDetails.Message | ConvertFrom-Json
        }else{
            $Error[1].ErrorDetails.Message
        }
        
    }
			

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $results.Content
       
    }

	#returns to the login.
	return ($results.Content | ConvertFrom-Json)
}