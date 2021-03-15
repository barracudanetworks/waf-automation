function Login {

    Param(
    [Parameter(Mandatory=$true, Position=0)]
	$wafIpAddress,
    [Parameter(Mandatory=$true, Position=1)]
	$wafUserName,
    [Parameter(Mandatory=$true, Position=2)]
	$wafPassword
    )

    $loginUrl = "http://$wafIpAddress//restapi/v3/login"

    $body = @{
        "username" = "$wafUserName";
        "password" = "$wafPassword";
    } | ConvertTo-Json

    try {
        $errorActionPreference = "Stop"; #Make all errors terminating
        #Call Login API and store authtoken
        $wafAuthToken = Invoke-RestMethod -Uri $loginUrl -ContentType "application/json" -Method Post -Body $body -ErrorAction $errorActionPreference
        #$confirmServiceStatus = 1
    } 
    catch {
        #$confirmServiceStatus = 0
        Write-Warning "exception is $($_.Exception.Message)"
        throw
    }

    finally{
        $errorActionPreference = "Continue"; #Reset the error action pref to default
    }

    return $wafAuthToken
}

function CreateHeader {

    Param(
    [Parameter(Mandatory=$false, Position=0)]
	$wafAuthToken
    )
    
    $Base64Token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($wafAuthToken.token)"))
    
    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("Content-type", 'application/json')
    $header.Add("Accept", 'application/json')
    $header.Add("Authorization", "Basic $($Base64Token)")

    return $header
}

function readJsonContent {

    Param(
    [Parameter(Mandatory=$true, Position=0)]
	$filePath
    )
  
    Write-Host "#### FUNCTION - readJsonContent #############"
           
    try {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        
        $fileContents= Get-Content $filePath | Out-String #Read in file and save as a string
        $jsonContentStatus = 1
    } 
    catch {
        $jsonContentStatus = 0
        Write-Warning "exception is $($_.Exception.Message)"
    }
    finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }

	#Write-Warning "jsonconfig contents are $jsonconfig"

    return $fileContents
}

function Failure {
	$global:helpme = $body
	$global:helpmoref = $moref
	$global:result = $_.Exception.Response.GetResponseStream()
	$global:reader = New-Object System.IO.StreamReader($global:result)
	$global:responseBody = $global:reader.ReadToEnd();
	Write-Host -BackgroundColor:Black -ForegroundColor:Red "Status: A system exception was caught."
	Write-Host -BackgroundColor:Black -ForegroundColor:Red $global:responsebody
	Write-Host -BackgroundColor:Black -ForegroundColor:Red "The request body has been saved to `$global:helpme"
	break
}

function updateCookiesecurity {

	Param(
    [Parameter(Mandatory=$false, Position=0)]
	$policyName,
	[Parameter(Mandatory=$false, Position=1)]
	$policyAPI
	)
	
	Write-Host "#### FUNCTION - updateCookiesecurity - `"$($policyName)`" #############"
	
	$confirmPolicySettingsURL = "http://$wafIpAddress//restapi/v3/security-policies/$policyName/cookie-security"
    $policyAPIconfig = $policyAPI | ConvertTo-Json

    Write-Warning "#### confirmPolicySettingsURL is $confirmPolicySettingsURL"
    Write-Warning "#### policyAPIconfig is $policyAPIconfig"
        
    try {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        $policyAPIresponse = Invoke-RestMethod -Uri $confirmPolicySettingsURL -Method PUT -Headers $myHeader -body $policyAPIconfig | ConvertTo-Json
		
    } 
    catch {
		if ($_.Exception.Response) {
			Failure
		}
    }
    finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
	
	return $policyAPIresponse
}
	
$wafIpAddress = $args[0]
$wafUserName = $args[1]
$wafPassword = $args[2]
$myPolicy = $args[3]
$configJson = $args[4]

## Call Login Function and capture AuthToken as variable 
$wafAuthToken = Login $wafIpAddress $wafUserName $wafPassword

write-host "wafAuthToken is: " $wafAuthToken 

## Call CreateHeader Function and capture header as variable for use with other functions
$global:myHeader = CreateHeader $wafAuthToken


$global:policyAPI = readJsonContent $configJson | ConvertFrom-Json

$result = updateCookiesecurity $myPolicy $policyAPI

write-host "Response is: " $result 
