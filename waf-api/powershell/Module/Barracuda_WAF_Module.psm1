function ConvertTo-Base64{
	param(
		[string]$this
	)
	[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this))

}
function ConvertFrom-Base64{
	param(
		[string]$this
	)
	[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($this))

}

function Login-BarracudaWAF{
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
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$device,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$username,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]$password,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
	[int]$api_version=3,
    [switch]$IsHTTPS,
	[switch]$UseSelfSignedCert

    )
	#makes the connection HTTPS
	if($IsHTTPS){
		$s = "s"
	}

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }
		
    switch($api_version){
		1 {
			try{
				$r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v1/login" -ContentType 'application/json' -Body "{`"username`":`"$($username)`",`"password`":`"$($password)`"}" -Method Post }
			catch{
				Write-Error("Unable to Login to API http$($s)://$($device):$($device_port)/restapi/v1/login due to " + $_.Exception)
			}
			
			}
		default {
			try{
				$r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v3/login" -ContentType 'application/json' -Body "{`"username`":`"$($username)`",`"password`":`"$($password)`"}" -Method Post }
			catch{
				Write-Error("Unable to Login to API http$($s)://$($device):$($device_port)/restapi/v3/login due to " + $_.Exception)
			}
    
		}
	}
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $r
        Write-Host "Token Value"
        Write-Host $r.token
        
    }
	
	#returns a prebuilt auth header string to be used in future requests.

        #Takes the token and the original password and turns them into a Base64 string 
        $Base64Token = ConvertTo-Base64 "$($r.token):$($password)"
        #Adds the Authorization header with the Encoded string
        $auth_header = @{"Authorization" = "Basic $($Base64Token)"}
	#returns to the login.
	return $auth_header
}

function Logout-BarracudaWAF{
<#
.Synopsis
    Log's out a API session
.Description
    This will log out an API session token
.Example
Logout-Barracuda -device $dev_name -token $token

.Notes
v1.1
#>
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $authentication,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [switch]$IsHTTPS,
	[switch]$UseSelfSignedCert

    )
	#makes the connection HTTPS
	if($IsHTTPS){
		$s = "s"
    }

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }


	switch($api_version){
		1 {
			try{
				$r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v1/logout" -ContentType 'application/json' -Method DELETE -Headers $authentication -Body ''
			}catch{
				Write-Error("Unable to Logout of API http$($s)://$($device):$($device_port)/restapi/v1/login due to " + $_.Exception)
			}
		}
		default {
			try{
				$r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v3/logout" -ContentType 'application/json' -Method DELETE -Headers $authentication -Body ''
			}catch{
				Write-Error("Unable to Logout of API http$($s)://$($device):$($device_port)/restapi/v3/login due to " + $_.Exception)
			}
		}
	}
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Auth Header"
        Write-Host $auth_header.Authorization
        $r
        
    }

return $r.msg[0]
}

Function Get-BarracudaWAFService{
<#
.Synopsis
    Get's info about Barracuda services
.Description
    This will get all information about either the named service or all services
.Example
$services = Get-BarracudaService -device $dev_name -token $token -password $password 

This will get all barracuda services and store them in the $services variable
.Example
$ssl_services = Get-BarracudaService -device $dev_name -token $token -password $password -servicename "HTTPS"

This will get information about the HTTPS service and store them in a variable

.Notes
v1.0
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
	[int]$api_version=3,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$service_name="",
    [switch]$IsHTTPS,
	[switch]$UseSelfSignedCert

    )
	
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
	#makes the connection HTTPS
	if($IsHTTPS){
		$s = "s"
    }
    

    switch($api_version){
		1 {$url = "http$($s)://$($dev_name):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($dev_name):$($device_port)/restapi/v3/services"}
    }
    if($service_name.length -gt 0){
        $url = "$($url)/$($service_name)"
    }
        
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $a
        [Void]$PSBoundParameters.Remove("Debug")
			try{
				#$r = New-BWAFRequest -url $url -method "GET" -auth "$($token)" -password $password -Debug
	            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method get -Headers $token -Debug

			}catch{
				Write-Error("Unable to Logout of API $($url) due to " + $_.Exception)
			}
        
    }else{
        try{
			
	        $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method get -Headers $token

			}catch{
				Write-Error("Unable to Logout of API $($url) due to " + $_.Exception)
			} 
    }
    
    return $r.data
}

Function Get-BarracudaWAFWANIP {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$device,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
        $token,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [int]$device_port=8443,
	    [int]$api_version=3,
		[switch]$IsHTTPS,
	    [switch]$UseSelfSignedCert
    )
	#makes the connection HTTPS
	 if($IsHTTPS){
		$s = "s"
	}
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    switch($api_version){
		1 {
        	Write-Error("No V1 API available for this function")
		}
		default {

			try{
                if($PSBoundParameters.ContainsKey("Debug")){
                    $r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v3/system/wan-configuration" -ContentType 'application/json' -Method GET -Headers $token -Debug
                }else{
                    $r = Invoke-RestMethod -Uri "http$($s)://$($device):$($device_port)/restapi/v3/system/wan-configuration" -ContentType 'application/json' -Method GET -Headers $token
                }
				
			}catch{
				Write-Error("Unable to query http$($s)://$($device):$($device_port)/restapi/v3/system/wan-configuration due to " + $_.Exception)
			}
		}
	}
#Returns only the WAN Configuration
return $r.data.System.'WAN Configuration'
}


Function New-BarracudaWAFService{
<#
.Synopsis
    Creates a new Barracuda WAF Service
.Description
    This will create a new service with all the information provided or 
.Example
$services = New-BarracudaWAFService -device $dev_name -token $token -password $password -servicename "HTTP" -port "80"


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$name="",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$status="on",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [int]$port=80,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$enable_access_logs="Yes",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$group="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$vsite="default",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateSet("HTTP", "HTTPS", "Instant SSL", "Redirect Service", "Custom", "Custom SSL", "FTP", "FTP SSL")]  
    [string]$type="HTTP",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("IPv4", "IPv6")]  
    [string]$addressversion="IPv4",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$appid="$($name)",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [int]$session_timeout=60,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$service_ipaddress="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$service_mask="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$comments="$name",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$certificate="",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$securesitedomain="",
	[switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

    switch($api_version){
		1 {$url = "http$($s)://$($device):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
   <# if($name.length -gt 0){
        $url = "$($url)/$($name)"
    }#>
    if($service_ipaddress -eq "default" -and $addressversion -eq "IPv4"){
        [Void]$PSBoundParameters.Remove("service_ipaddress")
        try{   
			if($IsHTTPS){
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS ).'ip-address'))
			}elseif($UseSelfSignedCert){
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS -UseSelfSignedCert ).'ip-address'))
			}else{
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port  ).'ip-address'))
			}
            
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }elseif($service_ipaddress -eq "default" -and $addressversion -eq "IPv6"){
        [Void]$PSBoundParameters.Remove("service_ipaddress")
        try{ 
			if($IsHTTPS){
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS  ).'ipv6-address'))
			}elseif($UseSelfSignedCert){
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS -UseSelfSignedCert ).'ipv6-address'))
			}else{
				$PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port ).'ipv6-address'))
			}
            
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }    
    }else{
    #Presumes that an IP has been supplied and presents these instead
        [Void]$PSBoundParameters.Remove("service_ipaddress")   
        $PSBoundParameters.Add("ip-address",$service_ipaddress)
    } 
    if($service_mask -eq "default" -and $addressversion -eq "IPv4"){
        [Void]$PSBoundParameters.Remove("service_mask")   
        try{
            $PSBoundParameters.Add("mask",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port).'mask'))
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }elseif($service_mask -eq "default" -and $addressversion -eq "IPv6"){
        [Void]$PSBoundParameters.Remove("service_mask")
        try{   
            $PSBoundParameters.Add("mask",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port).'ipv6-mask')) 
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }else{
    #Presumes that an IP has been supplied and presents these instead
        [Void]$PSBoundParameters.Remove("service_mask")   
        $PSBoundParameters.Add("mask",$service_mask)
    }    
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
    #The below need renaming as the json expects a - seperating the words    
    [Void]$PSBoundParameters.Remove("appid")   
    $PSBoundParameters.Add("app-id",$appid)
    [Void]$PSBoundParameters.Remove("addressversion")   
    $PSBoundParameters.Add("address-version",$addressversion)
	#When left to defaults
	if(!$PSBoundParameters.ContainsKey("group")){
		$PSBoundParameters.Add("group",$group)
	}
	if(!$PSBoundParameters.ContainsKey("vsite")){
		$PSBoundParameters.Add("vsite",$vsite)
	}

    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}

Function Remove-BarracudaWAFService{
	    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$device,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
        $token,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [int]$device_port=8443,
		[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string]$name,
	    [int]$api_version=3,
		[switch]$IsHTTPS,
	    [switch]$UseSelfSignedCert
    )
		#makes the connection HTTPS
	if($IsHTTPS){
		$s = "s"
    }
    
    switch($api_version){
		1 {$url = "http$($s)://$($device):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
	    if($name.length -gt 0){
			$url = "$($url)/$($name)"
		}
	if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $a
        [Void]$PSBoundParameters.Remove("Debug")
			try{
				#$r = New-BWAFRequest -url $url -method "GET" -auth "$($token)" -password $password -Debug
	            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method DELETE -Headers $token -Debug

			}catch{
				Write-Error("Unable to Logout of API $($url) due to " + $_.Exception)
			}
        
    }else{
        try{
			
	        $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method DELETE  -Headers $token

			}catch{
				Write-Error("Unable to Logout of API $($url) due to " + $_.Exception)
			} 
    }

}

Function New-BarracudaWAFServer{
<#
.Synopsis
    Creates a new Barracuda WAF Server
.Description
    This will create a new service with all the information provided or 
.Example
$services = New-BarracudaWAFService -device $dev_name -token $token -password $password -servicename "HTTP" -port "80"


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$servicename="",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [int]$port=80,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$name="",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$hostname="",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateSet("In Service", "Out of Service Maintenance", "Out of Service Sticky", "Out of Service All")]  
    [string]$status="In Service",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("IPv4", "IPv6")]  
    [string]$addressversion="IPv4",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$ipaddress="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$comments="$name",
	[switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

    switch($api_version){
		1 {$url = "http$($s)://$($device):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
   if($servicename.length -gt 0){
        $url = "$($url)/$($servicename)/servers"
    }
    
   
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("servicename")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
    #The below need renaming as the json expects a - seperating the words    
    [Void]$PSBoundParameters.Remove("addressversion")   
    $PSBoundParameters.Add("address-version",$addressversion)

	#When left to defaults

	   if($ipaddress.length -gt 0){
            [Void]$PSBoundParameters.Remove("ipaddress")   
			$PSBoundParameters.Add("ip-address",$ipaddress)
			$PSBoundParameters.Add("identifier","IP Address")
		}elseif($hostname.length -gt 0){
			$PSBoundParameters.Add("identifier","Hostname")
		}

    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}

Function Set-BarracudaWAFServiceSecurity{
<#
.Synopsis
    Configures the Basic Security settings of a service
.Description
    This will configure the basic security settings of a service including mode, policy, rate control and trusted hosts
.Example
$services = New-BarracudaWAFService -device $dev_name -token $token -password $password -servicename "HTTP" -port "80"


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$servicename="",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$ratecontrolstatus="Off",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$ratecontrolpool="NONE",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("0-Emergency", "1-Alert", "2-Critical", "3-Error","4-Warning","5-Notice","6-Information","7-Debug")]  
    [string]$loglevel="5-Notice",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("Yes", "No")]  
    [string]$ignorecase="Yes",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("Active", "Passive")]  
    [string]$mode="Passive",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$webfirewallpolicy="",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$clientipheader="X-Forwarded-For",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("Default", "Passive", "Allow")]  
    [string]$trustedhostsaction="Default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$trustedhostsgroup="",
	[switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

    switch($api_version){
		1 {$url = "http$($s)://$($device):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
   if($servicename.length -gt 0){
        $url = "$($url)/$($servicename)/basic-security"
    }
    
   
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("servicename")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
    #The below need renaming as the json expects a - seperating the words    
	if($PSBoundParameters.ContainsKey("ratecontrolstatus")){
		    [Void]$PSBoundParameters.Remove("ratecontrolstatus")   
		$PSBoundParameters.Add("rate-control-status",$ratecontrolstatus)
	}
	if($PSBoundParameters.ContainsKey("ratecontrolpool")){
		    [Void]$PSBoundParameters.Remove("ratecontrolpool")   
		$PSBoundParameters.Add("rate-control-pool",$ratecontrolpool)
	}
	
	if($PSBoundParameters.ContainsKey("webfirewallpolicy")){
		[Void]$PSBoundParameters.Remove("webfirewallpolicy")   
		$PSBoundParameters.Add("web-firewall-policy",$webfirewallpolicy)
	}
	if($PSBoundParameters.ContainsKey("loglevel")){
	    [Void]$PSBoundParameters.Remove("loglevel")   
		$PSBoundParameters.Add("web-firewall-log-level",$loglevel)
	}
	if($PSBoundParameters.ContainsKey("trustedhostsgroup")){
	    [Void]$PSBoundParameters.Remove("trustedhostsgroup")   
		$PSBoundParameters.Add("trusted-hosts-group",$trustedhostsgroup)
	}
	if($PSBoundParameters.ContainsKey("clientipheader")){
	    [Void]$PSBoundParameters.Remove("clientipheader")   
		$PSBoundParameters.Add("client-ip-addr-header",$clientipheader)
	}
	if($PSBoundParameters.ContainsKey("ignorecase")){
	    [Void]$PSBoundParameters.Remove("ignorecase")   
		$PSBoundParameters.Add("ignore-case",$ignorecase)
	}
	if($PSBoundParameters.ContainsKey("trustedhostsaction")){
	    [Void]$PSBoundParameters.Remove("trustedhostsaction")   
		$PSBoundParameters.Add("trusted-hosts-action",$trustedhostsaction)
	}
	#When left to defaults

	   if($ipaddress.length -gt 0){
            [Void]$PSBoundParameters.Remove("ipaddress")   
			$PSBoundParameters.Add("ip-address",$ipaddress)
			$PSBoundParameters.Add("identifier","IP Address")
		}elseif($hostname.length -gt 0){
			$PSBoundParameters.Add("identifier","Hostname")
		}

    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method PUT -Body $data -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method PUT -Body $data -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}

Function Get-BarracudaWAFServiceSecurity{
<#
.Synopsis
    Gets the details of the Basic Security settings of a service

.Example
$security = Get-BarracudaWAFServiceSecurity -device $dev_name -token $authorisation -IsHTTPS $true -UseSelfSignedCert $true -servicename $servicename


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$servicename="",
    [switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

    switch($api_version){
		1 { Write-Output "Not a v1 API function"; return }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
   if($servicename.length -gt 0){
        $url = "$($url)/$($servicename)/basic-security"
    }
    
   
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("servicename")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
	
	
    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method GET  -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method GET -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}
#Needs finishing

Function Get-BarracudaWAFLog{
<#
.Synopsis
    Gets logs from the WAF
.Description
    Gets logs from the WAF
.Example
$services = New-BarracudaWAFService -device $dev_name -token $token -password $password -servicename "HTTP" -port "80"


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateSet("access-logs", "audit-logs", "web-firewall-logs", "network-firewall-logs","system-logs")]  
    [string]$logname="web-firewall-logs",
	[switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

	$url = "http$($s)://$($device):$($device_port)/restapi/v3/logs/$($logname)"


    
   
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("servicename")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
  
    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method GET -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method GET -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}



Function Update-BarracudaWAFService{
<#
.Synopsis
    Updates an existing Barracuda WAF Service
.Description
    This will create a new service with all the information provided or 
.Example
$services = New-BarracudaWAFService -device $dev_name -token $token -password $password -servicename "HTTP" -port "80"


.Notes
v1.1
#>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$device,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [int]$device_port=8443,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [string]$name="",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$status="on",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [int]$port=80,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$enable_access_logs="Yes",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$group="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$vsite="default",
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateSet("HTTP", "HTTPS", "Instant SSL", "Redirect Service", "Custom", "Custom SSL", "FTP", "FTP SSL")]  
    [string]$type="HTTP",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet("IPv4", "IPv6")]  
    [string]$addressversion="IPv4",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$appid="$($name)",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [int]$session_timeout=60,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$service_ipaddress="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$service_mask="default",
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$comments="$name",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$ertificate="",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$securesitedomain="",
	[Parameter(Mandatory=$false,ValueFromPipeline=$true)] 
    [string]$dpsenabled="No",
	[switch]$IsHTTPS,
	[switch]$UseSelfSignedCert
    )
    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Get-VService Input Debug"
        Write-Host  $PSBoundParameters
        
    }
    if($IsHTTPS){
		$s = "s"
	}

    switch($api_version){
		1 {$url = "http$($s)://$($device):$($device_port)/restapi/v1/virtual_services" }
        default{$url = "http$($s)://$($device):$($device_port)/restapi/v3/services"}
    }
   if($name.length -gt 0){
        $url = "$($url)/$($name)"
    }
    if($service_ipaddress -eq "default" -and $addressversion -eq "IPv4"){
        [Void]$PSBoundParameters.Remove("service_ipaddress")
        try{   
            $PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS $IsHTTPS -UseSelfSignedCert $UseSelfSignedCert).'ip-address'))
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }elseif($service_ipaddress -eq "default" -and $addressversion -eq "IPv6"){
        [Void]$PSBoundParameters.Remove("service_ipaddress")
        try{   
            $PSBoundParameters.Add("ip-address",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port -IsHTTPS $IsHTTPS -UseSelfSignedCert $UseSelfSignedCert).'ipv6-address'))
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }    
    }else{
    #Presumes that an IP has been supplied and presents these instead
        [Void]$PSBoundParameters.Remove("service_ipaddress")   
        $PSBoundParameters.Add("ip-address",$service_ipaddress)
    } 
    if($service_mask -eq "default" -and $addressversion -eq "IPv4"){
        [Void]$PSBoundParameters.Remove("service_mask")   
        try{
            $PSBoundParameters.Add("mask",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port).'mask'))
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }elseif($service_mask -eq "default" -and $addressversion -eq "IPv6"){
        [Void]$PSBoundParameters.Remove("service_mask")
        try{   
            $PSBoundParameters.Add("mask",((Get-BarracudaWAF-WANIP -device $dev_name -token $authorisation -device_port $device_port).'ipv6-mask')) 
        }catch{
            Write-Error("Unable to collect WAN IP for service " + $_.Exception)
        }
    }else{
    #Presumes that an IP has been supplied and presents these instead
        [Void]$PSBoundParameters.Remove("service_mask")   
        $PSBoundParameters.Add("mask",$service_mask)
    }    
    #Delete these from the parameter hashtable as this us used to create the json POST
    [Void]$PSBoundParameters.Remove("device_port")
    [Void]$PSBoundParameters.Remove("token")
    [Void]$PSBoundParameters.Remove("device")
	[Void]$PSBoundParameters.Remove("IsHTTPS")
    [Void]$PSBoundParameters.Remove("UseSelfSignedCert")
    #The below need renaming as the json expects a - seperating the words    
    [Void]$PSBoundParameters.Remove("appid")   
    $PSBoundParameters.Add("app-id",$appid)
    [Void]$PSBoundParameters.Remove("addressversion")   
    $PSBoundParameters.Add("address-version",$addressversion)
	[Void]$PSBoundParameters.Remove("dpsenabled")   
    $PSBoundParameters.Add("dps-enabled",$dpsenabled)
	[Void]$PSBoundParameters.Remove("enableaccesslogs")   
    $PSBoundParameters.Add("enable-access-logs",$enableaccesslogs)
		[Void]$PSBoundParameters.Remove("sessiontimeout")   
    $PSBoundParameters.Add("session-timeout",$sessiontimeout)
	#When left to defaults
	if(!$PSBoundParameters.ContainsKey("group")){
		$PSBoundParameters.Add("group",$group)
	}
	if(!$PSBoundParameters.ContainsKey("vsite")){
		$PSBoundParameters.Add("vsite",$vsite)
	}

    if($PSBoundParameters.ContainsKey("Debug")){
        [Void]$PSBoundParameters.Remove("Debug")
        $data = ConvertTo-Json $PSBoundParameters
		Write-Host "JSON Data"
        Write-Host $data
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token -Debug
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
        }
    }else{
        $data = ConvertTo-Json $PSBoundParameters
        try{
            $r = Invoke-RestMethod -Uri "$($url)" -ContentType 'application/json' -Method POST -Body $data -Headers $token 
        }catch{
		    Write-Error("Unable to Create new service $($url) due to " + $_.Exception)
		}
    }
    #returns the results
    return $r
}