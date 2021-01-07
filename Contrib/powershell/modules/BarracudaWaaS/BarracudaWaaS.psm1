
$Script:DEFAULT_HEADERS = @{
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'
}

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