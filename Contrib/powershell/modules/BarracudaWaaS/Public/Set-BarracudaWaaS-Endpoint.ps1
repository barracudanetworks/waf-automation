<#
.SYNOPSIS
    Updates values of a Barracuda WAF-as-a-Service endpoint
.Description
    Will update the WaaS endpoint with the submitted values. The type of endpoint does need to be defined as either -HTTP or -HTTPS parameter, depending on this you may be required to provide more details, for example SSL ciphers.
    It is advised to use the Get-BarracudaWaaS-Endpoint command to collect existing values and pass those back with modification as required. 
.Example
Requests details on an endpoint and then passes back the same values but turning on automaticCertificates
Get-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep | Set-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep -HTTPS -automaticCertificate $true -cipher_suite_name "all" -enable_tls_1_2 $true -enable_tls_1_1 $false -enable_tls_1_3 $true -enable_ssl_3 $false

.Notes
v0.1
#>
function Set-BarracudaWaaS-Endpoint{
    [CmdletBinding(DefaultParameterSetName = 'HTTP')]

    param(
        [Parameter(Mandatory=$true,ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
        [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
   # [Parameter(Mandatory=$true,
   # ValueFromPipelineByPropertyName=$true)]
  #  [string]$applicationName,
    [Parameter(Mandatory=$true,ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [string]$endpointId,

   #defines the variables of and endpoint 
   [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
   [switch]$HTTPS,

    #defines the variables of and endpoint 
    [Parameter(Mandatory=$false, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [switch]$HTTP,

   #certificate variables
    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$automaticCertificate,

    #set to true and combine with 
    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$false, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$replaceCertificate=$false,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$false, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [string]$certificate,

    [Parameter(Mandatory=$false, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [string]$privateKey,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [ValidateSet("all","mozilla_modern_compatibility_suite","mozilla_intermediate_compatibility_suite","mozilla_old_compatibility_suite")] 
    [string]$cipher_suite_name,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$false, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [array]$custom_ciphers=@(),

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_pfs=$true,   

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_ssl_3=$false,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_tls_1=$false,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_tls_1_1=$true,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_tls_1_2=$true,

    [Parameter(Mandatory=$false, ParameterSetName="HTTP", ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true, ParameterSetName="HTTPS", ValueFromPipelineByPropertyName=$true)]
    [bool]$enable_tls_1_3=$true,


    #non SSL 

    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$enableHttp2=$false,
    
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$enableVdi=$false,

    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$enableWebsocket=$false,


    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [array]$hostnames,

    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    $keepaliveRequests,

    #is string in PATCH
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    $sessiontimeout,

    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    $servicePort,

  
    #somehow a string saying "redirect"
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$redirectHTTP=$true,

    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$ntlmIgnoreExtraData=$false,

# Don't need this if the Parameter set defines it.
  #  [Parameter(Mandatory=$true,
  #  ValueFromPipelineByPropertyName=$true)]
  #  [ValidateSet("HTTP", "HTTPS")] 
  #  [string]$serviceType,

    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [bool]$useOtherServiceIp=$true
    )
<#
    DynamicParam {
        if($automaticcertificate -eq $false){
            #create a new ParameterAttribute Object
            $ageAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ageAttribute.Position = 3
            $ageAttribute.Mandatory = $true

            #create an attributecollection object for the attribute we just created.
            $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]

            #add our custom attribute
            $attributeCollection.Add($ageAttribute)

            #add our paramater specifying the attribute collection
            $ageParam = New-Object System.Management.Automation.RuntimeDefinedParameter('certificate', [string], $attributeCollection)

            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('certifictate', $ageParam)
            return $paramDictionary
        }
    }
#>
 
      
  

    $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/0/endpoints/$($endpointId)"

    $header = @{"auth-api" = "$authkey"}
   
 #   $PSBoundParameters["managed_service"] = $application_id

    #sets any default variables to parameters in $PSBoundParameters
    foreach($key in $MyInvocation.MyCommand.Parameters.Keys)
    {
        $value = Get-Variable $key -ValueOnly -EA SilentlyContinue
        if(($value -or $value -eq $false) -and !$PSBoundParameters.ContainsKey($key)) {$PSBoundParameters[$key] = $value}
    }
        [array]$hosts
        #references need to be hashtables inside array
        ForEach($obj in $hostnames){
            $hosts += @($obj)
      
        }
        $PSBoundParameters['hostnames'] = $hosts
        
    #Compenstates for different types in GET and PATCH.
    if($redirectHTTP){
       $PSBoundParameters['redirectHTTP'].ToString() =  "redirect"
    }else{
       $PSBoundParameters['redirectHTTP'].ToString() =  "noRedirect" 
    }


 #   $PSBoundParameters['servicePort'].ToString()
    $PSBoundParameters['keepaliveRequests'].ToString()
    $PSBoundParameters['serviceType'] = $PsCmdlet.ParameterSetName
    #Void's anything we don't want
    if(!$certificate){
        #ironically this shouldn't be provided at all if HTTPS and autocert is enable. But should be provided if HTTP! :(
        [Void]$PSBoundParameters.Remove("certificate")
    }
    [Void]$PSBoundParameters.Remove("HTTP")
    [Void]$PSBoundParameters.Remove("HTTPS")
    [Void]$PSBoundParameters.Remove("endpointId")
    [Void]$PSBoundParameters.Remove("authkey")
    [Void]$PSBoundParameters.Remove("Debug")


#}

Write-Debug $PSBoundParameters   
$json = ConvertTo-Json $PSBoundParameters -Depth 99
Write-Debug $json

try{

    $results = Invoke-WebRequest -Uri "$($url)" -Method PATCH -Headers $header -Body $json -ContentType "application/json" -UseBasicParsing -ErrorAction SilentlyContinue
}catch{
    if(Test-Json -Json $Error[0].ErrorDetails.Message -ErrorAction SilentlyContinue){
        $Error[0].ErrorDetails.Message | ConvertFrom-Json
    }else{
        $Error[1].ErrorDetails.Message
        
    }
    throw
}
	

	#returns the results
	return ($results.Content | ConvertFrom-Json)
}