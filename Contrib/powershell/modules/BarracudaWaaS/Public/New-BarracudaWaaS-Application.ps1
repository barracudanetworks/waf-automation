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
function New-BarracudaWaaS-Application{

    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$applicationName,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$backendIp,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [string]$backendType="HTTPS",
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [int]$backendPort,
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [array]$hostnames,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [int]$httpServicePort=80,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [int]$httpsServicePort=443,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [string]$maliciousTraffic="Passive",
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$redirectHTTP=$true,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [string]$serviceType="HTTPS",
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$useHttp=$true,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$useHttps=$true,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$useExistingIP=$true
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Verbose "Login Input Debug"
        Write-Verbose $PSBoundParameters
        
    }

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/"

    $header = @{"auth-api" = "$authkey"}
   
    $PSBoundParameters["managed_service"] = $application_id

    #sets any default variables to parameters in $PSBoundParameters
    foreach($key in $MyInvocation.MyCommand.Parameters.Keys)
    {
        $value = Get-Variable $key -ValueOnly -EA SilentlyContinue
        if(($value -or $value -eq $false) -and !$PSBoundParameters.ContainsKey($key)) {$PSBoundParameters[$key] = $value}
    }
       
        #references need to be hashtables inside array
        ForEach($obj in $hostnames){
            $hosts = $hosts += @{"hostname"=$obj}
        }
        $PSBoundParameters['hostnames'] = @($hosts)
    #Void's anything we don't want
    [Void]$PSBoundParameters.Remove("authkey")
    [Void]$PSBoundParameters.Remove("Debug")


#}
Write-Debug $PSBoundParameters   
$json = ConvertTo-Json $PSBoundParameters -Depth 99
Write-Debug $json

try{

    $results = Invoke-WebRequest -Uri "$($url)" -Method POST -Headers $header -Body $json -ContentType "application/json" -UseBasicParsing

}catch [System.Net.WebException] {
            return $error[0].ErrorDetails.Message | ConvertFrom-Json
             
}
	

	#returns the results
	return ($results.Content | ConvertFrom-Json)
}