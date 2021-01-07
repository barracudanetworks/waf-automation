<#
.Synopsis
    Logs into the barracuda API
.Description
    Supplies a session token for authorizing API Calls
.Example
Login-BarracudaVRS -device $dev_name -username "username" -password "password"
.Notes
v0.1
#>

function Login-BarracudaBVRS{
	[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,
    ValueFromPipelineByPropertyName=$true)]
    $credentials    
    )

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Input Debug"
        Write-Host $PSBoundParameters
        
    }

    $postParams = @{"email"="$($credentials.Username)"; "password"="$($Credentials.GetNetworkCredential().Password)"}
		

	try{
				
		$results =Invoke-WebRequest -Uri "https://vrs.barracudanetworks.com/login?redirect_to=api/v1"  -Method POST -Body $postParams -UseBasicParsing 
	}catch{
		Write-Error("Unable to Login to API http$($s)://$($device):$($device_port)/restapi/v1/login due to " + $_.Exception)
	}

    if($PSBoundParameters.ContainsKey("Debug")){
        Write-Host "Login Results Debug"
        Write-Host $results.Content
        Write-Host "Token Value"
        Write-Host $results.token
        
    }
	
	#returns a prebuilt auth header string to be used in future requests.
        $json = ConvertFrom-Json $results.Content
        
        #Takes the token and the original password and turns them into a Base64 string 
        $Base64Token = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("$($json.token_info.token):$($Credentials.GetNetworkCredential().Password)"))
        #Adds the Authorization header with the Encoded string
        $auth_header = @{"Authorization" = "Basic $($Base64Token)"}
	#returns to the login.
	return $auth_header
}