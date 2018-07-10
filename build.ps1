param(
    [String]$PackerConfig,
    [String]$ConfigFile = "config.json",
    [String]$Builds = "builds/"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

try{
    Import-Module -Name Vmware.VimAutomation.Core
}
catch {
    Write-Error "You are missing the PowerCLI Module"
}

$config = Get-Content -Path $ConfigFile | ConvertFrom-JSON

$env:vcenter_username = Read-Host -Prompt "Vcenter User"
$temp_pass = Read-Host -Prompt "Password" -AsSecureString
$env:vcenter_password = [system.Runtime.interopServices.marshal]::PtrToStringAuto([system.runtime.Interopservices.Marshal]::SecurestringToBstr($temp_pass))
$temp_pass = Read-Host -Prompt "Host login password" -AsSecureString
$env:login_password = [system.Runtime.interopServices.marshal]::PtrToStringAuto([system.runtime.Interopservices.Marshal]::SecurestringToBstr($temp_pass))

Connect-VIServer -Server $config.vcenter_server -User $env:vcenter_username -Password $env:vcenter_password | Out-Null

foreach($key in ($config | Get-Member -MemberType NoteProperty).Name){
    if (Test-Path -Path ENV:$key){
        Remove-Item -Path ENV:$key
    }
    New-Item -Path ENV:$key -Value $config.$key
}

$esx_hosts = Get-VMHost
$env:esx_host = $esx_hosts[(Get-Random -Minimum 0 -Maximum $esx_hosts.Count)].Name

if ($PackerConfig){
    packer build -force "$Builds/$PackerConfig"
}
else{
    #add jobs at some point
    foreach($packer in (Get-ChildItem -Path $Builds)){
        packer build -force "$Builds/$packer"
    }
}
#clear sensitive info
Remove-Item -Path ENV:$login_password
Remove-Item -Path ENV:$vcenter_password