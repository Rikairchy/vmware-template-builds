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

$sensitive_env_keys = @("vcenter_username","vcenter_password","redhat_sub_pass")

function Get-Pass($msg){
    $temp_pass = Read-Host -Prompt $msg -AsSecureString
    return [system.Runtime.interopServices.marshal]::PtrToStringAuto([system.runtime.Interopservices.Marshal]::SecurestringToBstr($temp_pass))
}
function Remove-PackerTemplate($config){
    $current_config = Get-Content -Path $config | ConvertFrom-JSON
    if ($current_config.variables.vm_name -in (Get-Template).name){
        Remove-Template -Template $current_config.variables.vm_name -DeletePermanently -Confirm:$false
    }
}

$config = Get-Content -Path $ConfigFile | ConvertFrom-JSON

$env:vcenter_username = Read-Host -Prompt "Vcenter User"
$env:vcenter_password = Get-Pass -msg "Password"
$env:login_password = Get-Pass -msg "Host login password"

try{
    $global:DefaultViServer | Out-Null
}
catch {
    Connect-VIServer -Server $config.vcenter_server -User $env:vcenter_username -Password $env:vcenter_password | Out-Null
}

foreach($key in ($config | Get-Member -MemberType NoteProperty).Name){
    if (Test-Path -Path ENV:$key){
        Remove-Item -Path ENV:$key
    }
    New-Item -Path ENV:$key -Value $config.$key
}

$esx_hosts = Get-VMHost
$env:esx_host = $esx_hosts[(Get-Random -Minimum 0 -Maximum $esx_hosts.Count)].Name

if ($PackerConfig){
    #if redhat build ask for sub managet password
    if ($PackerConfig -match "rhel"){
        $env:redhat_sub_pass = Get-Pass -msg "RHEL subpass"
    }
    Remove-PackerTemplate -config "$Builds/$PackerConfig"
    packer build -force "$Builds/$PackerConfig"
}
else{
    #add jobs at some point
    if ((Get-ChildItem -Path $Builds).name -match "rhel"){
        $env:redhat_sub_pass = Get-Pass -msg "RHEL subpass"
    }
    foreach($packer in (Get-ChildItem -Path $Builds)){
        Remove-PackerTemplate -config "$Builds/$packer"
        packer build -force "$Builds/$packer"
    }
}
#clear sensitive info
foreach($cred in $sensitive_env_keys){
    if(Test-Path -Path ENV:$cred){
        Remove-Item -Path ENV:$cred
    }  
}