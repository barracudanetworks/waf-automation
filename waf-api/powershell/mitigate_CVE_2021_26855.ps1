# mitigate_CVE_2021_26855.ps1

param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $waf_ip,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $waf_port,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $username,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $password,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $https = $false
)

$apiVer = 'v3'

if ( $https -eq $true ) {
    $baseurl='https://' + $waf_ip + ':' + $waf_port + "/restapi/$apiVer"
} else {
    $baseurl='http://' + $waf_ip + ':' + $waf_port + "/restapi/$apiVer"
}

$loginurl = "$baseurl/login"
$loginBody = @{
    password = "$password"
    username = "$username"
}
$loginBodyJSON = $loginBody | ConvertTo-Json

## Retrieve login token
try {
    $authResponse = Invoke-WebRequest -Uri $loginurl -Method Post -Body $loginBodyJSON -ContentType $contentType -SkipCertificateCheck
} catch {
    Write-Host "Unable to retrieve login token for $waf_ip" -ForegroundColor Yellow
    Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
    Write-Host "  Error Details:" ($_.ErrorDetails.Message | ConvertFrom-Json).errors
    exit
}

if ( $null -ne $authResponse.errors ) {
    Write-Host("Error retrieving data: $authResponse.errors, aborting operation...") -ForegroundColor Red
    exit
}
$waftoken = ($authResponse.Content | ConvertFrom-Json).token + ':'

if ( $waftoken -ne '' ) {
    Write-Host "Successfully retrieved WAF login token." -ForegroundColor Green
} else {
    Write-Host "Failed to retrieve login token." -ForegroundColor Yellow
    exit
}

## Prep basic params
$creds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($waftoken))
$headers = @{
    'Authorization' = 'Basic ' + $creds
    'Accept' = 'application/json'
}
$contentType = 'application/json'
$adr_base_url = "$baseurl/security-policies/owa/global-acls"

## Populate list of ACLs to add
$global_acl_list = New-Object System.Collections.ArrayList
$global_acl_list = @(
    @{
        "name" = "Exchange-AnonCookie-CVE-2021-26855"
        "url" = "/*"
        "extended-match" = '(Header Cookie rco X-AnonResource-Backend=.*\/.*~.*)'
        "extended-match-sequence" = 4
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "Exchange-ResourceCookie-CVE-2021-26855"
        "url" = "/*"
        "extended-match" = '(Header Cookie rco X-BEResource=.*\/.*~.*)'
        "extended-match-sequence" = 5
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "themes-CVE-2021-26855"
        "url" = "/owa/auth/Current/themes/resources*"
        "extended-match" = '(Method eq POST) && (Header User-Agent rco ".*(DuckDuckBot|facebookexternalhit|Baiduspider|Bingbot|Googlebot|Konqueror|Yahoo|YandexBot|antSword).*")'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "ecp-CVE-2021-26855"
        "url" = "/ecp/"
        "extended-match" = '(Method eq POST) && (Header  User-Agent rco ".*(ExchangeServicesClient|python-requests).*")'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "aspnetclient-CVE-2021-26855"
        "url" = "/aspnet_client/"
        "extended-match" = '(Method eq POST) && (Header  User-Agent rco ".*(antSword|Googlebot|Baiduspider).*")'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "owa-CVE-2021-26855"
        "url" = "/owa/"
        "extended-match" = '(Method eq POST) && (Header  User-Agent rco ".*(antSword|Googlebot|Baiduspider).*")'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "owaauth-CVE-2021-26855"
        "url" = "/owa/auth/Current/"
        "extended-match" = '(Method eq POST)'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "ecpdefault-CVE-2021-26855"
        "url" = "/ecp/default.flt"
        "extended-match" = '(Method eq POST)'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    },
    @{
        "name" = "ecpcss-CVE-2021-26855"
        "url" = "/ecp/main.css"
        "extended-match" = '(Method eq POST)'
        "extended-match-sequence" = 1
        "action" = "Deny and Log"
        "response-page" = "default"
    }
)

## Create ADRs
foreach ($item in $global_acl_list) {
    Write-Host "Adding ACL:" $item.Name
    $bodyJSON = $item | ConvertTo-Json

    try {
        $r = Invoke-RestMethod -uri $adr_base_url -Method Post -Body $bodyJSON -Headers $headers -ContentType $contentType -SkipCertificateCheck
    } catch {
        Write-Host "Failed to add global ACL" -ForegroundColor Yellow
        Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "  Error Details:" ($_.ErrorDetails.Message | ConvertFrom-Json).errors
        exit
    }
    
    if ( $null -ne $r.errors ) {
        Write-Host("Error: $r.errors, aborting operation...") -ForegroundColor Red
        exit
    } else {
        Write-Host "Successfully added" $r.id -ForegroundColor Green
    }
    
}

Write-Host
Write-Host "All global ACLs have been added successfully." -ForegroundColor Green
