
<#
.Synopsis
    Get's information about the WaaS Applications or a WaaS Application
.Description
    Supplies a session token for authorizing API Calls
.Parameters

.Example
    #Gather all the endpoint ID's for a application
    Get-BarracudaWaaS-Endpoint -authkey <token> -appid 1234
    #Gather the details of a specific known endpoint ID
    Get-BarracudaWaaS-Endpoint -authkey <token> -endpointId 12345
    If both App ID and Endpoint are supplied, endpoint ID takes precedence.
    Data is returned as a hashtable in the format Name=EndpointID, Value=endpoint values


    $endpoint = Get-BarracudaWaaS-Endpoint -authkey $waas_token.key -endpointid $ep
.Notes
v0.1
#>
function Get-BarracudaWaaS-Endpoint{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string]$authkey,
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    [string]$appid,
   [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
   [string]$endpointID,
   [Parameter(Mandatory=$false,
   ValueFromPipelineByPropertyName=$true)]
   [switch]$details   
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $header = @{"auth-api" = "$authkey"}


    
    #When only and application ID is provided the app is queried for all it's endpoints. Data is then gathered about each endpoint and returned. 
    if($appid -and !$endpointID){
        $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/$appid/"
        $getendpointid = Invoke-WebRequest -Uri "$($url)" -Method GET -Headers $header -UseBasicParsing 

        if($PSBoundParameters.ContainsKey("Debug")){
            Write-Host $((ConvertFrom-Json $getendpointid.content).waas_services.id)
        }

        foreach ($ep in (ConvertFrom-Json $getendpointid.content).waas_services.id) {
            $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/0/endpoints/$ep/"
            $results = Invoke-WebRequest -Uri "$($url)" -Method GET -Headers $header -UseBasicParsing 
            $epcontent =  $epcontent += @{$ep=($results.Content | ConvertFrom-Json)}
            if($PSBoundParameters.ContainsKey("Debug")){
                Write-Host $epcontent 
            }
        }
        #returns a hashtable of endpoint objects as defined for that application.

        return $epcontent
    }else{
        #If and endpoint ID is provide than only than endpoint ID is queried
        $url = "https://api.waas.barracudanetworks.com/v2/waasapi/applications/0/endpoints/$endpointid/"
    }

	try{
        $results =Invoke-WebRequest -Uri "$($url)" -Method GET -Headers $header -UseBasicParsing 
        
	}catch{
        if(Test-Json -Json $Error[0].ErrorDetails.Message -ErrorAction SilentlyContinue){
            $Error[0].ErrorDetails.Message | ConvertFrom-Json
        }else{
            $Error[1].ErrorDetails.Message
        }
        
    }

    #returns to the login.
    if(!$details){
        #strips down the details to create something compatible with the PATCH and POST formats, so that data can be splatted between commands
        $fullep = ($results.Content | ConvertFrom-Json )
        $ep = ($fullep | ConvertTo-Json -Depth 99 | ConvertFrom-Json)
       
        #Remove unrequired
        $ep.PSObject.Properties.Remove('id')
        $ep.PSObject.Properties.Remove('cname')
        $ep.PSObject.Properties.Remove('managed_service')
        $ep.PSObject.Properties.Remove('dps_service')
        $ep.PSObject.Properties.Remove('advanced_configuration')
        $ep.PSObject.Properties.Remove('certificate')
        $ep.PSObject.Properties.Remove('protocol')

        #Reinsert values
        if($fullep.Values.protocol -eq 'Redirect Service'){
            Add-Member -InputObject $ep -Name 'redirectHTTP' -Value "redirect" -MemberType NoteProperty 
        }

        Add-Member -InputObject $ep -Name 'automaticCertificate' -Value $fullep.certificate.use_automatic -MemberType NoteProperty 
        if(!$fullep.certificate.use_automatic){
            Add-Member -InputObject $ep -Name 'certificate' -Value $fullep.certificate.ssl_certificate -MemberType NoteProperty
        }else{
            Add-Member -InputObject $ep -Name 'certificate' -Value $null -MemberType NoteProperty 
        }

        Add-Member -InputObject $ep -Name 'hostnames' -Value $fullep.dps_service.domains -MemberType NoteProperty 

        ForEach($item in (Get-Member -InputObject $fullep.advanced_configuration -MemberType NoteProperty).Name){    
           #adjusts capitalisation and removes underscores due to value name differences between GET and PATCH/POST
            $name = (Get-Culture).TextInfo.ToTitleCase($item)
            $name = $name.Substring(0,1).ToLower()+$name.Substring(1).Replace("_","")
            Add-Member -InputObject $ep -Name $name -Value $fullep.advanced_configuration.$item -MemberType NoteProperty 

        }

        #Convert Types - needed by Set-BarracudaWaaS-Endpoint using PATCH
        $ep.session_timeout = $ep.session_timeout.ToString()
        $ep.keepaliveRequests = $ep.keepaliveRequests.ToString()
        
        Add-Member -InputObject $ep -Name 'servicePort' -Value ($fullep.dps_service.port).ToString() -MemberType NoteProperty 
        Add-Member -InputObject $ep -Name 'serviceType' -Value $fullep.protocol -MemberType NoteProperty 
        return $ep
    }else{
        return @{$endpointID=($results.Content | ConvertFrom-Json)}
    }
}