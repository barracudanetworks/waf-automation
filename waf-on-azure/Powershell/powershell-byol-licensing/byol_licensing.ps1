#Login-AzureRmAccount
$value=(Get-Content .\test.txt -Raw) | ConvertFrom-Json | Select-Object -expand license1
$postParams = @{token=$value; system_default_domain='cudasystem.local'}
$publicip_output = Get-AzureRmVM -ResourceGroupName 'hiscox-test' -Name 'hiscox-test' | Get-AzureRmPublicIpAddress -Name 'hiscox-test-ip'
$ipadd = $publicip_output|Select-Object -ExpandProperty IpAddress
echo $ipadd
$url = "http://$ipadd`:8000"
echo $url 
Invoke-WebRequest $url/token -Method Post -ContentType "application/x-www-form-urlencoded" -Body $postParams
Start-Sleep -s 300
$eula = Invoke-WebRequest $url/ -Method GET
echo "$eula"
if ($eula -like '*You Must Accept the Barracuda Product Terms Below to Configure Your Barracuda Virtual Appliance*')
{
$eulasign = @{name_sign=<name>; email_sign="<email-name>"; company_sign="Hiscox"; eula_hash_val=ed4480205f84cde3e6bdce0c987348d1d90de9db; action=save_signed_eula}
Invoke-WebRequest $url/ -Method POST -Body $eulasign
}
else
{
echo "Waiting for the system to finish the license activation"
Start-Sleep -s 60
}
#$a=(Get-Content .\Desktop\license_BYOL_activation\test.txt -Raw)
#echo $a
#$a -replace "license1" | Out-File .\Desktop\license_BYOL_activation\test.txt