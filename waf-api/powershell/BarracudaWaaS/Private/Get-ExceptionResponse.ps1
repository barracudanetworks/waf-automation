function Get-ExceptionResponse {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorRecord]
        $InputObject
    )


    switch($InputObject.Exception.Response.StatusCode.value__){
         "404" { Write-Error $("{`"code`":$($InputObject.Exception.Response.StatusCode.value__),`"message`":`"$($InputObject.Exception.Response.StatusDescription)`"}" | ConvertFrom-Json -ErrorAction SilentlyContinue) }
         default {  Write-Error $($InputObject.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue) }
        
            
        }
}