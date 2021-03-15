Param(
    [parameter(Mandatory=$true)] [alias("i")] $WAFIP,
	[parameter(Mandatory=$true)] [alias("u")] $Username,
	[parameter(Mandatory=$true)] [alias("p")] $Password,
	[parameter(Mandatory=$true)] [alias("s")] $ServerIP,
	[parameter(Mandatory=$true)] [alias("m")] [ValidateSet("In Service", "Out of Service Maintenance", "Out of Service Sticky", "Out of Service All")] $Mode
)

Function Barracuda-WAF-Login($waf_netloc, $username, $password)
{
    $res = "Fail"
	$auth = @{"username" = $username; "password" = $password}
	$authJson = $auth | ConvertTo-Json
 	$res = Invoke-RestMethod ("https://" + $waf_netloc + "/restapi/v1/login") -Body $authJson -Method POST -ContentType application/json
        
    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to connect to "$waf_netloc
        exit
    }

    return @{netloc = $waf_netloc; token = $res.token}
}

Function Barracuda-WAF-Get-V3($token, $path)
{
    $res = "Fail"
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))
    $headers = @{Authorization = $auth_header}
    $res = Invoke-RestMethod ("https://" + $token.netloc + "/restapi/v3/" + $path) -Headers $headers
    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to get "$path
        exit
    }
	
	# Convert PSCustomObject response to hash table for easier enumerating
	$res_hash = @{}
	$res.data.psobject.properties | Foreach { $res_hash[$_.Name] = $_.Value }

    return $res_hash
}

Function Barracuda-WAF-Get($token, $path)
{
    $res = "Fail"
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))
    $headers = @{Authorization = $auth_header}
    $res = Invoke-RestMethod ("https://" + $token.netloc + "/restapi/v1/" + $path) -Headers $headers
    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to get "$path
        exit
    }
    return $res
}

Function Barracuda-WAF-Post($token, $path, $data)
{
    $res = "Fail"
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))
    $headers = @{Authorization = $auth_header}
    $body = $data | ConvertTo-Json
    $res = Invoke-RestMethod ("https://" + $token.netloc + "/restapi/v1/" + $path) -Headers $headers -Method POST -Body $body -ContentType application/json

    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to post to "$path
        exit
    }

    return $res
}

Function Barracuda-WAF-Put($token, $path, $data)
{
    $res = "Fail"
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))
    $headers = @{Authorization = $auth_header}
    $body = $data | ConvertTo-Json
    Write-Host "arguments passed"$token.netloc, $path, $headers, $body
    $res = Invoke-RestMethod ("https://" + $token.netloc + "/restapi/v1/" + $path) -Headers $headers -Method PUT -Body $body -ContentType application/json
    Write-Host $res
    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to put "$path
        exit
    }

    return $res
}

Function Barracuda-WAF-Put-V3($token, $path, $data)
{
    $res = "Fail"
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))
    $headers = @{Authorization = $auth_header}
    $body = $data | ConvertTo-Json
    # Write-Host "arguments passed"$token.netloc, $path, $headers, $body
    $res = Invoke-RestMethod ("https://" + $token.netloc + "/restapi/v3/" + $path) -Headers $headers -Method PUT -Body $body -ContentType application/json
    # Write-Host $res
    # Check to see if connection was successful
    if($res -eq "Fail"){
        Write-Host "Failed to put "$path
        exit
    }

    return $res
}

Function Barracuda-WAF-Set-Server-Maintenance-Mode($token, $vsite, $server_ip, $maintenance_mode)
{
    <#
    .DESCRIPTION
    Sets maintenance mode of a single server.

    .PARAMETER $token
    WAF access token, returned from Barracuda-WAF-Login

    .PARAMETER $vsite
    The ID of the virtual service to work on.

    .PARAMETER $server_ip
    The server you want to set maintenance mode for.

    .PARAMETER $maintenance_mode
    Mode to change the server to.  One of: "In Service", "Out of Service Maintenance", "Out of Service Sticky", "Out of Service All"
    #>

    # Get all servers
    $servers = Barracuda-WAF-Get-V3 $token ("services/" + $vsite + "/servers")
	
    # Iterate over servers
    foreach ($server_key in $servers.Keys)
    {
		$server = $servers[$server_key]
		if ($server.'ip-address' -eq $server_ip)
		{
			Write-Host "  Found server"$server.'ip-address'"(currently in mode"$server.status"), changing mode..."
			$update = @{status = $maintenance_mode}
			$res = Barracuda-WAF-Put-V3 $token ("services/" + $vsite + "/servers/" + $server.name) $update
			Write-Host "    "$res.msg
		}
    }
}

# disable SSL/TLS Certificate Validation check (use this is you have a self-signed certificate on your WAF)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Log in to WAF
Write-Host "Logging in to WAF..."
$token = Barracuda-WAF-Login $WAFIP $Username $Password

# Get all virtual services
Write-Host "Retrieving service list..."
$services = Barracuda-WAF-Get-V3 $token services
# Write-Host ($vsites | Get-Member -MemberType NoteProperty | Format-List | Out-String)

# Process each virtual service
foreach ($service in $services.Keys) {
  Write-Host "Inspecting virtual service"$service"..."
  Barracuda-WAF-Set-Server-Maintenance-Mode $token $service $ServerIP $Mode
}
