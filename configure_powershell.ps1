﻿#we need elevation for this script
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

#change default execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force


#install POSH GIT
if(![System.IO.Directory]::Exists("C:\github\dahlbyk\posh-git"))
{
	git clone https://github.com/dahlbyk/posh-git.git C:\github\dahlbyk\posh-git
	cd C:\github\dahlbyk\posh-git
}
else
{
	cd C:\github\dahlbyk\posh-git
	git pull
}

.\install.ps1

#remove that 'Could not find ssh-agent' warning when starting powershell
$profilescript = [System.IO.File]::ReadAllText("C:\github\dahlbyk\posh-git\profile.example.ps1")
$profilescript = $profilescript.Replace("Start-SshAgent", "#Start-SshAgent")
[System.IO.File]::WriteAllText("C:\github\dahlbyk\posh-git\myprofile.ps1", $profilescript);

#update all profiles to load myprofile instead of the example profile
$profiledirectory = [System.IO.Path]::GetDirectoryName($PROFILE)
$profiles = Get-ChildItem $profiledirectory -Filter *.ps1
foreach($oneprofile in $profiles)
{
    $profilescriptcontent = [System.IO.File]::ReadAllText($oneprofile.FullName)
    $profilescriptcontent = $profilescriptcontent.Replace("C:\github\dahlbyk\posh-git\profile.example.ps1", "C:\github\dahlbyk\posh-git\myprofile.ps1")
    [System.IO.File]::WriteAllText($oneprofile.FullName, $profilescriptcontent);
}

write-host "FIXED: 'Could not find ssh-agent'"


#modify powershell shortcut to start in c:\github
#based on http://stackoverflow.com/questions/484560/editing-shortcut-lnk-properties-with-powershell
$poshlnk = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\Windows PowerShell.lnk"
$shell = New-Object -COM WScript.Shell
$shortcut = $shell.CreateShortcut($poshlnk)  ## Open the lnk
$shortcut.WorkingDirectory = "C:\github\"
$shortcut.Save()  ## Save

#load console window properties to registry
regedit /s .\console_window_settings.reg