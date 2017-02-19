<#
    Set-CapsToControl.ps1
    ---------------------

    This script will change Windows 10 keyboard mapping Caps Lock to Control
    
    If you get an error message about "ExecutionPolicy" needing powershell files to be "RemoteSigned" do not
    change it to something unsecure system wide like "Unrestricted" as many websites tell you. Just read/understand
    this script and run an 'Unblock-File Set-CapsToControl.ps1' in Powershell to allow this file to run. 
#>

$hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"}
$kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout'
New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified)
