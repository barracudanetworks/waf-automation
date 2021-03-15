
<#
This example script can be used to create a new Application and enable the Vulnerability Remediation Service to scan it.

#>

Function Create-Menu-Choice {
<#
.SYNOPSIS
This function generates scriptblocks to be used to autogenerate input prompts.

.DESCRIPTION

.PARAMETERS
Pass in the  

#>
param($start_text, $array, $customlabel, $customvalue)

    $text = $start_text
    $scriptblock = ""
            ForEach($entry in $array){
               #uses array position to create index number
               $text += "$($array.IndexOf($entry)). $($entry.$customlabel) `r`n" 
               #
               $scriptblock += " `"$($array.IndexOf($entry))`" { `$value1=`"$($entry.$customvalue)`"; break; }"
            }
            $scriptblock += "} return `$value1"


    $b = "switch(Read-Host `"$($text)`"){"
    $b += $scriptblock

    return $b
}


Write-Host "Now my website is online. I need protection!"
Write-Host "Building a WAF"

#FQDN that you want the WaaS to respond to. This could be an array.
$hostnames = "mytestapp.com"
#IP to be protected by WaaS
$backendip = "mybackendappfqdn.com"

#Provide login creds
$waas_creds = Get-Credential

#Login to WaaS
$waas_token = Login-BarracudaWaaS -credentials $waas_creds 


$app1 = New-BarracudaWaaS-Application -authkey $waas_token.key -applicationName "APIApp1"  -backendIp "$($backendip)" -hostnames @("$($hostnames)") -httpServicePort 80 -httpsServicePort 443 -maliciousTraffic Passive -backendPort 443


$components = Get-BarracudaWaaS-Component -authkey $authkey.key -appid $app1.id

$component = ([Scriptblock]::Create((Create-Menu-Choice -start_text "Select the component to enable `n" -array ($components) -customlabel "sku" -customvalue "id")).Invoke())

$components = Get-BarracudaWaaS-Component -authkey $authkey.key -appid $app1.id

ForEach($component in $components){


    if($component.is_available -and !$component.is_added){
         Write-Host "Component:  $($component.sku) is present and could be enabled (ID: $($component.id))" -ForegroundColor Cyan
    }elseif($component.is_added){
         Write-Host "Component: $($component.sku) has already been enabled (ID: $($component.id))" -ForegroundColor Green
    }elseif($component.is_available_support){
         Write-Host "Component: $($component.sku) can only be enabled by Barraucda Support at this time (ID: $($component.id)) " -ForegroundColor Yellow
    }
    else{
         Write-Host "Component: $($component.sku) is coming soon... (ID: $($component.id)) " -ForegroundColor White
    }
    

}


Set-BarracudaWaaS-Component -authkey $authkey.key -appid $app1.id -componentid $components
Set-BarracudaWaaS-Component -authkey $authkey.key -appid $app1.id -componentid 19
Set-BarracudaWaaS-Component -authkey $authkey.key -appid $app1.id -componentid 3


Write-Host "Script complete. Services have been created and components configured to provide VRS support and "