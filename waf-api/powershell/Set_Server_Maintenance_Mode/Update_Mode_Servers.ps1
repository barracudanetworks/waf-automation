{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf500
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww28600\viewh15360\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 Function Barracuda-WAF-Login($waf_netloc, $username, $password)\
\{\
    $res = "FAIL"\
       $auth = @\{"password" = $password; "username" = $username\}\
       $authJson = $auth | ConvertTo-Json\
	   Write-Host ("Login Request-----")\
       $res = Invoke-RestMethod ("http://" + $waf_netloc + "/restapi/v3/login") -Body $authJson -Method POST -ContentType application/json\
\
    # Check to see if connection was successful\
    if($res -eq "FAIL")\{\
        Write-Host ("Failed to connect to " + $waf_netloc)\
        exit\
    \}\
\
\
\
    return @\{netloc = $waf_netloc; token = $res.token\}\
\
\}\
\
Function Barracuda-WAF-Get($token, $path)\
\{\
    $res = "FAIL"\
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))\
    $headers = @\{Authorization = $auth_header\}\
	try \{\
		$errorActionPreference = "Stop";\
		Write-Host ("API GET REQUEST" + $path)\
		$res = Invoke-RestMethod ("http://" + $token.netloc + "/restapi/v3/$path") -Headers $headers -ErrorAction $errorActionPreference\
	\}\
	catch \{\
        Write-Warning "exception is $($_.Exception.Message)"\
        throw\
    \}\
\
    finally\{\
        $errorActionPreference = "Continue"; #Reset the error action pref to default\
    \}\
\
	Write-Host ("res is ----" + $res )\
    # Check to see if connection was successful\
    #if($res -eq "FAIL")\{\
     #   Write-Host ("Failed to get http://" + $token.netloc + "/restapi/v3/$path")\
      #  exit\
    #\}\
\
    return $res\
\}\
\
Function Barracuda-WAF-Post($token, $path, $data)\
\{\
    $res = "FAIL"\
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))\
    $headers = @\{Authorization = $auth_header\}\
    $body = $data | ConvertTo-Json\
    $res = Invoke-RestMethod ("http://" + $token.netloc + "/restapi/v3/$path") -Headers $headers -Method POST -Body $body -ContentType application/json\
\
    # Check to see if connection was successful\
    if($res -eq "FAIL")\{\
        Write-Host ("Failed to post to http://" + $token.netloc + "/restapi/v3/$path")\
        exit\
    \}\
\
    return $res\
\}\
\
Function Barracuda-WAF-Put($token, $path, $data)\
\{\
    $res = "FAIL"\
    $auth_header = ("Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token.token + ":")))\
    $headers = @\{Authorization = $auth_header\}\
    $body = $data | ConvertTo-Json\
	try \{\
		$errorActionPreference = "Stop"\
		Write-Host ("API PUT REQUEST" + $path + "parameters" + $body)\
		$res = Invoke-RestMethod ("http://" + $token.netloc + "/restapi/v3/$path") -Headers $headers -Method PUT -Body $body -ContentType "application/json" -ErrorAction $errorActionPreference \
	\}\
	catch \{\
        Write-Warning "exception is $($_.Exception.Message)"\
        throw\
    \}\
\
    finally\{\
        $errorActionPreference = "Continue"; #Reset the error action pref to default\
    \}\
    # Check to see if connection was successful\
    #if($res -eq "FAIL")\{\
     #   Write-Host ("Failed to put http://" + $token.netloc + "/restapi/v3/$path")\
     #   exit\
    #\}\
\
    return $res\
\}\
\
Function Barracuda-WAF-Logout($token, $password)\
\{\
    $res = "FAIL"\
    $Base64Token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($token.token):$($password)"))\
    $headers = @\{"Authorization" = "Basic $($Base64Token)"\}\
       $res = Invoke-RestMethod ("http://" + $token.netloc + "/restapi/v3/logout") -Headers $headers -Method DELETE -ContentType application/json\
\
    # Check to see if connection was successful\
    if($res -eq "FAIL")\{\
        Write-Host ("Failed to connect to " + $token.netloc)\
        exit\
    \}\
\}\
\
Function Barracuda-WAF-Content-Rule-Set-Server-Maintenance-Mode($token, $servicesLIST, $server_ip, $postParams)\
\{\
    <#\
    .DESCRIPTION\
    Sets maintenance mode of a single server across all content rules of a specific virtual service.\
\
    .PARAMETER $token\
    WAF access token, returned from Barracuda-WAF-Login\
\
    .PARAMETER $services\
    The list of services\
\
    .PARAMETER $server_ip\
    The server you want to set maintenance mode for.\
    XXX.XXX.XXX.XXX\
\
    .PARAMETER $maintenance_mode\
    The status you want to put the server at. \
    (In Service, Out of Service Maintenance, Out of Service Sticky, or Out of Service All)\
    #>    \
\
    foreach ($service in  $servicesLIST)\{\
        \
        # Change the server mode that is under the service directly\
        # Get servers for this content rule\
        $rootservers = Barracuda-WAF-GET $token ("services/" + $service + "/servers")\
        \
        #Write-Host "Servers under service - "$service\
        #Write-Host ($rootservers.data | Format-List | Out-String)\
\
        # Write the Service name\
        Write-Host ("Service '" + $service + "'")\
\
        # Iterate servers\
        foreach ($rootserverObject in $rootservers.data.PSObject.Properties)\
        \{\
            $rootserver = $rootserverObject.Value\
            \
            Write-Host ("        Found server '" + $rootserver.name + "' (IP:" + $rootserver.'ip-address' + "), status'" + $rootserver.status + "'")\
\
            # If server IP matches...\
            if ($rootserver.'ip-address' -eq $server_ip)\
            \{\
                \
                # If current status does not match passed status then change it\
                if ($rootserver.status -ne $postParams.status)\{\
\
                    # Change the status of server to passed status\
                    Write-Host ("        Updating server '" + $rootserver.name + "' for service '" + $service + "' from '" + $rootserver.status + "' to '" + $postParams.status + "'") \
                    $res = Barracuda-WAF-Put $token ("services/" + $service + "/servers/" + $rootserver.name) $postParams\
                    \
                    # - MESSAGE IF FAILED OR SUCCESS\
                    If ($res -eq "FAIL")\{\
                        Write-Host ("        ** FAILED **")\
                    \}else\{\
                        Write-Host ("        ** SUCCESS **")\
                    \}\
\
                \}else\{\
\
                   Write-Host ("        Server '" + $rootserver.name + "' (IP " + $rootserver.'ip-address' + ") is already set to '" + $rootserver.status + "'" ) \
\
                \}\
                \
            \}\
\
        \}\
\
        # Get all content rules for this vsite\
        $content_rules = Barracuda-WAF-Get $token ("services/" + $service + "/content-rules")\
\
        #Write-Host "Content Rules under service - "$service\
        #Write-Host ($content_rules.data | Format-List | Out-String)\
\
        # Write the Service name / content Rule\
        If ($content_rules.data.PSObject.Properties -eq $null)\{\
            Write-Host ("        No content rules found")\
        \}\
\
        # Iterate through content rules\
        foreach ($ruleObject in $content_rules.data.PSObject.Properties)\
        \{\
            $rule = $ruleObject.Value\
\
            Write-Host ("        Content rule '" + $rule.name + "' in Service '" + $service + "'")\
\
            # Get servers for this content rule\
            $contentservers = Barracuda-WAF-GET $token ("services/" + $service + "/content-rules/" + $rule.Name + "/content-rule-servers")\
\
            #Write-Host "Content Rule Servers under rule - "$rule.Name\
            #Write-Host ($contentservers.data | Format-List | Out-String)\
\
            # Iterate servers\
            foreach ($contentserverObject in $contentservers.data.PSObject.Properties)\
            \{\
                $contentserver = $contentserverObject.Value\
\
                Write-Host ("            Found server '" + $contentserver.name + "' (IP " + $contentserver.'ip-address' + ", status = " + $contentserver.status + ")")\
\
                # If server matches...\
                if ($contentserver.'ip-address' -eq $server_ip)\
                \{\
                    # If current status does not match passed status then change it\
                    if ($contentserver.status -ne $postParams.status)\{\
                            \
                        # Change the status of server to passed status\
                        Write-Host ("            Updating server '" + $contentserver.name + "' for content rule '" + $rule.name + "' under service '" + $service + "' from '" + $contentserver.status + "' to '" + $postParams.status + "'") \
                        $res = Barracuda-WAF-Put $token ("services/" + $service + "/content-rules/" + $rule.name + "/content-rule-servers/" + $contentserver.name)  $postParams\
                        \
                        # - MESSAGE IF FAILED OR SUCCESS\
                        If ($res -eq "FAIL")\{\
                            Write-Host ("            FAILED")\
                        \}else\{\
                            Write-Host ("            SUCCESS")\
                        \}\
\
                    \}else\{\
\
                       Write-Host ("            Server '" + $contentserver.name + "' (IP " + $contentserver.'ip-address' + ") is already set to '" + $contentserver.status + "'" ) \
                       \
                    \}\
\
                \}\
\
            \}\
    \
        \}\
\
    \}\
\
\}\
\
function IsNull($objectToCheck) \{\
    if ($objectToCheck -eq $null) \{\
        return $true\
    \}\
\
    if ($objectToCheck -is [String] -and $objectToCheck -eq [String]::Empty) \{\
        return $true\
    \}\
\
    if ($objectToCheck -is [DBNull] -or $objectToCheck -is [System.Management.Automation.Language.NullString]) \{\
        return $true\
    \}\
\
    return $false\
\}\
\
# Allow Script to run\
Set-ExecutionPolicy Bypass\
\
# disable SSL/TLS Certificate Validation check (use this is you have a self-signed certificate on your barracuda!\
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = \{$true\}\
\
#Force TLS 1.2\
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12\
\
# Prompt for account username\
$bname = Read-Host 'What is your admin username?'\
\
#$bpass = Read-Host 'What is your admin password?' # -AsSecureString\
\
# Secure Password\
$response = Read-host "What's your password?" -AsSecureString\
$bpass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response))\
\
# Prompt for Primary device\
$bprimarydevice = Read-Host 'What is the Barracuda IP address?'\
\
# Prompt for the server ip\
$sip = Read-Host 'What is the Server IP Adress that you wish to modify?'\
\
\
# Prompt for enable / disable\
Write-Host "Choose from the following Server modes:"\
Write-Host "1. In Service"\
Write-Host "2. Out of Service Sticky (FIRST STEP - No New Connections)"\
Write-Host "3. Out of Service Maintenance (SECOND STEP - Only In-Process Connections Allowed)"\
Write-Host "4. Out of Service All (FINAL - Terminates ALL Connections)"\
$qstatus = Read-Host "Enter 1-4: "\
\
# set default status\
$postParams = $null\
\
switch ($qstatus)\{\
    1\{\
        $status = "In Service"\
        break\
    \}\
    2\{\
        $status = "Out of Service Sticky"\
        break\
    \}\
    3\{\
        $status = "Out of Service Maintenance"\
        break\
    \}\
    4\{\
        $status = "Out of Service All"\
        break\
    \}\
    default\{\
        Write-Host 'Invalid response must be a number 1-4, exiting....'\
        exit\
    \}\
\}\
\
\
$postParams = @\{status=$status\}\
\
\
$qproceed = Read-Host 'Are you sure you want to set Server IP:' $sip 'to "' $status '" for all services on barracuda device' $bprimarydevice '? y or n'\
\
# check confirmation\
If (($qproceed.ToUpper() -eq 'Y') -and ($postParams.status -ne $null))\{\
\
    # Print what is going to happen\
    Write-Host ("Attempting to set server IP: " + $sip + " to '" + $postParams.status + "' for all services on barracuda device " + $bprimarydevice + "...")\
    \
    # Set the login token\
    $token = Barracuda-WAF-Login $bprimarydevice $bname $bpass\
\
    #Setup an empty object\
    $vservices = @()\
\
    # Get a list of all the Virtual Services\
    $vservices = Barracuda-WAF-Get $token "services?groups=Service"\
\
    # List $vservices.data formatted to screen\
    #Write-Host ($vservices.data | Format-List | Out-String)\
\
    #Create an empty object array\
    $servicesLIST = @()\
\
    # Drop out the HTTP redirect services\
    foreach ($vserviceObject in $vservices.data.PSObject.Properties)\{\
        $vservice = $vserviceObject.Value\
        \
        # Do not add HTTP Services that REDIRECT to HTTP, we never put servers under these services\
        If (($vservice.type -eq "HTTPS"))\{\
            $servicesLIST += $vserviceObject.Name\
        \}\
\
    \}\
\
    #Print Services to window\
    #Write-Host "Services list - "$servicesLIST\
\
    #pass either $vsite for one site (Remove foreach), or $vites\
    Barracuda-WAF-Content-Rule-Set-Server-Maintenance-Mode $token $servicesLIST $sip $postParams \
	\
\
    # Log out\
    Barracuda-WAF-Logout $token $bpass\
	Write-Host ("Done Done Done !!!")\
\
\}Else\{\
\
    Write-Host 'Exiting script without making changes...'\
\
\}\
\
exit}