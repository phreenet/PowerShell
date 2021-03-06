﻿<#
    Get-VSCodeExtensions.ps1 
    ------------------------

    This script will download all the extensions listed in the array of hash tables called
    $extenions from Microsoft's Visual Studio Code Marketplace so that you can sideload/offline
    install them. 

    https://code.visualstudio.com/Docs/extensions/install-extension#_side-loading

    Hashtable parameters. 
    name => Local friendly name of the package, can be whatever you want

    packagespec => This must be the raw link to the extensions package.json file.
                    Usually hosted on GitHub but could be stored anywhere as long
                    as the extension is uploaded to vscode marketplace. 
                
    version => Optional, will override the latest version listed in the package spec.
                Useful if the publisher has a newer version or beta version in their
                github branch (e.g. master) that is not in the Marketplace yet. If the version
                you list isn't in the marketplace you will see an error and it is skipped. 

    Script stores downloaded extensions in a locally created directory called "vscode-ext" whereever this
    script is executed from. 

    If you get an error message about "ExecutionPolicy" needing powershell files to be "RemoteSigned" do not
    change it to something unsecure system wide like "Unrestricted" as many websites tell you. Just read/understand
    this script and run an 'Unblock-File Get-VSCodeExtensions.ps1' in Powershell to allow this file to run. 
#>

$extensions = @(
    @{
        "name" = "Ruby";
        "packagespec" = "https://raw.githubusercontent.com/rubyide/vscode-ruby/master/package.json"
        "version" = "0.10.4" # Override package.json because it has a newer version than what is in VSCode Marketplace. 
     },
    @{
        "name" = "Powershell";
        "packagespec" = "https://raw.githubusercontent.com/PowerShell/vscode-powershell/master/package.json"
     },
    @{
        "name" = "Docker";
        "packagespec" = "https://raw.githubusercontent.com/Microsoft/vscode-docker/master/package.json"
     },
    @{
        "name" = "Change-Case";
        "packagespec" = "https://raw.githubusercontent.com/wmaurer/vscode-change-case/master/package.json"
     },
     @{
        "name" = "Path Intellisense";
        "packagespec" = "https://raw.githubusercontent.com/ChristianKohler/PathIntellisense/master/package.json"
     },
     @{
        "name" = "Go";
        "packagespec" = "https://raw.githubusercontent.com/Microsoft/vscode-go/master/package.json"
     },
     @{
        "name" = "Python";
        "packagespec" = "https://raw.githubusercontent.com/DonJayamanne/pythonVSCode/master/package.json"
     },
     @{
        "name" = "VSCode Icons";
        "packagespec" = "https://raw.githubusercontent.com/vscode-icons/vscode-icons/master/package.json"
     },
     @{
        "name" = "VS Team Services";
        "packagespec" = "https://raw.githubusercontent.com/Microsoft/vsts-vscode/master/package.json"
     },
     @{
        "name" = "C#";
        "packagespec" = "https://raw.githubusercontent.com/OmniSharp/omnisharp-vscode/master/package.json"
        "version" = "1.7.0" #master has beta version
     }
)



if(-Not (Test-Path "vscode-ext")) {New-Item "vscode-ext" -ItemType Directory}

foreach($e in $extensions) {
    "Getting latest package spec for: $($e.Name)"
    
    try {
        $spec = (Invoke-WebRequest -Uri $e.packagespec -Method Get).content | ConvertFrom-Json
    } catch {
        "Failed to get package spec @ $($e.packagespec)"
        continue
    }

    # Check to see if version is overridden
    if($e.version) {$version = $e.version} else {$version = $spec.version}
    
    $package = "$($spec.name).$version"
    $OutputFile = ".\vscode-ext\$package.vsix"

    # Check if already downloaded. 
    if(-Not (Test-Path $OutputFile)) {
        $URI = "https://$($spec.publisher).gallery.vsassets.io/_apis/public/gallery/publisher/$($spec.publisher)/extension/$($spec.name)/$version/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"  
        "Getting $package"
        try {
            Invoke-WebRequest -Uri $URI -OutFile $OutputFile
        } catch {
            "Failed Web Request"
            $URI
        }
    } else {
        "Skipping $package, already downloaded"
    }
}