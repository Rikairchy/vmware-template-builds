$ErrorActionPreference = "Stop"
$version = (Get-Content config.json | ConvertFrom-JSON)."packer-plugin"
choco -y install packer

Invoke-WebRequest -Uri "https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v$version/packer-builder-vsphere-iso.exe" -OutFile "~/Downloads/packer-builder-vsphere-iso.exe"

if (!(Test-Path "~/Appdata/Roaming/packer.d/plugins")){
    New-Item -Type "Directory" -Path "~/Appdata/Roaming/packer.d/plugins/"
    Write-Output "Created plugins directory"
}

if((Test-Path "~/Appdata/Roaming/packer.d/plugins/packer-builder-vsphere-iso.exe")){
    $hash1 = (Get-FileHash "~/Appdata/Roaming/packer.d/plugins/packer-builder-vsphere-iso.exe").hash
    $hash2 = (Get-FileHash "~/Downloads/packer-builder-vsphere-iso.exe").hash
    if(!$hash1 -eq $hash2){
        Write-Output "Hashes did not match, packer plugin updated"
        Move-Item "~/Downloads/packer-builder-vsphere-iso.exe" "~/Appdata/Roaming/packer.d/plugins/packer-builder-vsphere-iso.exe" -Force
    }
    else{
        Write-Output "You have the current version of the plugin"
    }
}
else{
    Write-Output "Adding plugin"
    Move-Item "~/Downloads/packer-builder-vsphere-iso.exe" "~/Appdata/Roaming/packer.d/plugins/packer-builder-vsphere-iso.exe" -Force
}