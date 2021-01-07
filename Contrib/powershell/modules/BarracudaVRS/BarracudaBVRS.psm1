[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$Script:DEFAULT_HEADERS = @{
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'
}

$Script:BWAF_TOKEN = $null
$Script:BWAF_URI = $null

$Paths = @(
    'Public',
    'Private'
)

foreach ($p in $Paths) {
    "$(Split-Path -Path $MyInvocation.MyCommand.Path)\$p\*.ps1" | Resolve-Path | ForEach-Object {
        if ($_.ProviderPath -notlike '*_TEMPLATE*') {
            . $_.ProviderPath
        }
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1").BaseName