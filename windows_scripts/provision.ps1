$ErrorActionPreference = "Stop"
Set-NetConnectionProfile -InterfaceIndex $(Get-NetConnectionProfile -InterfaceAlias "Ethernet0").InterfaceIndex -NetworkCategory Private
#install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Confirm:$false -Force
Import-Module -Name PSWindowsUpdate
#Get all updates
Get-WindowsUpdate -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot -Download -Install

Copy-Item A:\sysprep.xml C:\sysprep.xml
New-Item -Type Directory -Path C:\Windows\Setup\Scripts\
Copy-Item A:\SetupComplete.cmd C:\Windows\Setup\Scripts\SetupComplete.cmd
