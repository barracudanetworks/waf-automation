<#
.SYNOPSIS
    Enables the BVRS service for an application
.Description
    Supplies a session token for authorizing API Calls
.Example
Login-Barracuda -device $dev_name -username "username" -password "password"
.Notes
v0.1
id                 : 9006
name               : APIApp1
basic_security     : @{protection_mode=Passive}
waas_services      : {@{id=10856; protocol=HTTPS; dps_service=; managed_service=; certificate=; advanced_configuration=; enable_ssl_3=False; enable_tls_1=False;
                     enable_tls_1_1=True; enable_tls_1_2=True; enable_tls_1_3=True; monitored=True; session_timeout=60; cname=app729995.prod.cudawaas.com; cipher_suite_name=all;     
                     custom_ciphers=System.Object[]; enable_pfs=False}, @{id=10855; protocol=Redirect Service; dps_service=; managed_service=; certificate=; 
                     advanced_configuration=; enable_ssl_3=False; enable_tls_1=False; enable_tls_1_1=True; enable_tls_1_2=True; enable_tls_1_3=True; monitored=True;
                     session_timeout=60; cname=app729995.prod.cudawaas.com; cipher_suite_name=all; custom_ciphers=System.Object[]; enable_pfs=False}}
components         : {}
servers            : {@{id=6140; health=Up; name=Default; protocol=HTTPS; host=www.bbc.co.uk; port=443; weight=1; cloud=none; is_backup=False; protocol_ssl_3_0_enabled=False;        
                     protocol_tls_1_0_enabled=False; protocol_tls_1_1_enabled=True; protocol_tls_1_2_enabled=True; protocol_tls_1_3_enabled=True; ssl_compatibility_mode=False;       
                     enable_sni=False; mode=In Service; validate_ssl_certificate=False; inband_max_http_errors=0; inband_max_refused=10; inband_max_timeout_failures=10;
                     inband_max_other_failures=10; enable_oob_health_checks=False; oob_health_check_interval=10; healthcheck_http_request_url=/; healthcheck_method=GET;
                     healthcheck_additional_headers=; healthcheck_status_code=200; healthcheck_match_content_string=; healthcheck_domain=; connection_pooling=False;
                     connection_pooling_keepalive_timeout=900000; advanced_timing_max_connections=10000; advanced_timing_max_requests=1000;
                     advanced_timing_max_keeipalive_requests=0; advanced_timing_max_establishing_connections=100; advanced_timing_max_spare_connections=0;
                     advanced_timing_timeout=300000; managed_service=9006}}
cloud_backend      : none
settings           : @{id=9005; attack_types_range=r_24h; blocked_attacks_range=r_24h; attack_origins_range=r_24h; incoming_requests_range=r_24h; connections_range=r_24h;
                     bandwidth_range=r_24h; app_health_range=r_1h; hide_CSG_link=False; managed_service=9006}
waf_application_id : app9006_729995

#>
function Set-BarracudaWaaS-Application{

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

    #WaaS Services is the "endpoints"


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