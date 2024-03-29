#CONSTS

$dependencies_PROJECT_ID = 14
$COMMIT_REGISTRY_PACKAGE_NAME = "plugins"

#END CONSTS


#CONST VARS

$requestHeaders = @{ 
    "PRIVATE-TOKEN"="$($Env:GITLAB_TMP_TOKEN)"
}

$referenceRegEx = '<Reference Include=".*" HintPath="(\$\(MISTAKEN_REFERENCES\)[\/\\])(.*\.dll)" \/>'

#END CONST VARS

$isRelease = !($VERSION -eq "0.0.0" -or !($VERSION))
$latestVersion = Get-Content "./version"

function FindFile ([string]$parentDir, [string]$patern) 
{
    foreach($_file in (Get-ChildItem -Path $parentDir -Force -Attributes !Directory)) 
    {
        $_file = $_file | Resolve-Path -Relative;
        $file = ".\${_file}"
        if (!($file -match $patern))
        {
            continue;
        }

        return $file
    }

    foreach($dir in (Get-ChildItem -Path  $parentDir -Attributes Directory -Force))
    {   
        $dir = $dir | Resolve-Path -Relative;
        $res = FindFile ".\${dir}" $patern
        if (!($res -eq "")) 
        {
            return $res
        }
    }

    return ""
}

class Dependencie {
    [string] $FileName = "ERROR"
    [bool] $IsPlugin = $false
    [string] $DownloadUrl
}

class Manifest {
    [string] $Name = "ERROR"
    [string] $Author = "ERROR"
    [string] $LatestVersion = "ERROR"
    [string] $BuildDate
    [string] $BuildId = "ERROR"
    [string] $FileName = "ERROR"
    [string] $UpdateUrl = "ERROR"
    [Collections.Generic.List[Dependencie]] $Dependencies

    Manifest() {
        $this.Dependencies = New-Object Collections.Generic.List[Dependencie]
        $this.BuildDate = [datetime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
    }
}

function parseDepHelperPluginMistakenReference ([string]$dllName) 
{
    Write-Host "Checking $dllName | Dependencie Plugin from MistakenReferences"

    $tor = New-Object Dependencie
    $tor.FileName = $dllName
    $tor.IsPlugin = $true
    $tor.DownloadUrl = "$CI_API_V4_URL/projects/$dependencies_PROJECT_ID/repository/files/$($dllName)/raw?ref=master"
    return $tor
}

function parseDepHelperDepMistakenReference ([string]$dllName) 
{
    Write-Host "Checking $dllName | Dependencie from MistakenReferences"

    $tor = New-Object Dependencie
    $tor.FileName = $dllName
    $tor.IsPlugin = $false
    $tor.DownloadUrl = "$CI_API_V4_URL/projects/$dependencies_PROJECT_ID/repository/files/$($dllName)/raw?ref=master"
    return $tor
}

function parseDepHelperPlugin ([string]$dllName) 
{
    Write-Host "Checking $dllName | Dependencie Plugin ..."

    $tor = New-Object Dependencie
    $tor.FileName = $dllName
    $tor.IsPlugin = $true

    $search = [regex]::match($dllName, "Mistaken\.(.*)\.dll").Groups[1].Value

    $res = searchForManifestPath $search

    Write-Host "Checked  $dllName | Dependencie Plugin $res"

    if ($res -match "[!].*") 
    {
        $tor.DownloadUrl = $null
    }
    else 
    {
        $tor.DownloadUrl = $res
    }

    return $tor
}

function searchForManifestPath ([string]$search, [bool] $tryOther = $true) 
{
    $reqRes = Invoke-RestMethod -Headers $requestHeaders -Method get -uri "$CI_API_V4_URL/projects?archived=false&simple=true&search=$search"

    if ($reqRes.length -eq 1) 
    {
        return "$CI_API_V4_URL/projects/$($reqRes[0].id)/repository/files/manifest.json/raw?ref=master"
    }

    if($tryOther) 
    {
        $res = searchForManifestPath $search.Replace('.', '-') $false

        if (!($res -match "[!].*")) 
        {
            return $res
        }

        [char[]] $c = ('.', '-')
        $res = searchForManifestPath $search.Split($c)[-1] $false

        if (!($res -match "[!].*")) 
        {
            return $res
        }
    }

    if ($reqRes.length -eq 0) 
    {
        return "[!] No matches found for `"$search`""
    }
    elseif ($reqRes.length -gt 1) 
    {
        $tmp = ""
        foreach ($item in $reqRes) 
        {
            $tmp += "$($item.name), "

            if ($item.name -eq $search) 
            {
                return "$CI_API_V4_URL/projects/$($item.id)/repository/files/manifest.json/raw?ref=master"
            }
        }
        
        return "[!] More than one match found for `"$search`", found: $tmp"
    }
    else 
    {
        throw New-Object System.NotImplementedException
    }

    return $tor
}

function ParseDep ([string]$dllName) 
{
    if(
        $dllName -match "0Harmony.dll" -or
        $dllName -match "Newtonsoft.Json.dll" -or
        $dllName -match "Mistaken.APILib.Public.dll"
        ) 
    {
        return parseDepHelperDepMistakenReference $dllName
    }
    elseif(
        $dllName -match ".*Mistaken.*\.dll"
        )
    { 
        return parseDepHelperPlugin $dllName
    }

    return parseDepHelperDepMistakenReference $dllName
}

function GetPluginName ([Manifest] $manifest) 
{
    $pluginHandlerPath = FindFile ".\" 'PluginHandler\.cs$'
    $pluginNameRegEx   = "public override string Name (=>|{\s*get;\s*}) `"(.*)`";"
    $pluginAuthorRegEx = "public override string Author (=>|{\s*get;\s*}) `"(.*)`";"

    $content = Get-Content $pluginHandlerPath;
    for($i = 0; $i -lt $content.length; $i++) 
    {
        $line = $content[$i];
        if ($line -match $pluginNameRegEx)
        {
            $manifest.Name = [regex]::match($line, $pluginNameRegEx).Groups[2].Value;
        }
        elseif ($line -match $pluginAuthorRegEx)
        {
            $manifest.Author = [regex]::match($line, $pluginAuthorRegEx).Groups[2].Value;
        }
    }
}

function GenerateManifest([string]$csProjPath) 
{
    if(Test-Path "manifest.json") 
    {
        [Manifest] $manifest = Get-Content "manifest.json" | ConvertFrom-Json
    }
    else 
    {
        $manifest = New-Object Manifest
    }

    GetPluginName $manifest

    $manifest.LatestVersion = $latestVersion
    $manifest.FileName = $DLL_NAME

    if ($isRelease) 
    {
        $manifest.BuildId = "$latestVersion-release-$CI_COMMIT_SHORT_SHA"
    }
    else 
    {
        $manifest.BuildId = "$latestVersion-$CI_COMMIT_REF_NAME-$CI_COMMIT_SHORT_SHA"
    }

    $manifest.UpdateUrl = "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages/generic/$COMMIT_REGISTRY_PACKAGE_NAME/$latestVersion/$DLL_NAME"

    $content = Get-Content $csProjPath;
    for($i = 0; $i -lt $content.length; $i++) 
    {
        $line = $content[$i];
        if($line -match $referenceRegEx)
        {
            $dllName = [regex]::match($line, $referenceRegEx).Groups[2].Value;
            if (
                $dllName -match "Assembly.*" -or
                $dllName -eq "CommandSystem.Core.dll" -or
                $dllName -eq "Mirror.dll" -or
                $dllName -eq "NorthwoodLib.dll" -or
                $dllName -eq "Exiled.Loader.dll" -or
                $dllName -match "UnityEngine.*" -or
                $dllName -match "Exiled.*"
            ) {
                continue
            }

            $skip = $false
            foreach ($item in $manifest.Dependencies.ToArray()) 
            {
                if ($item.FileName -eq $dllName) 
                {
                    if(!($item.DownloadUrl -eq ""))
                    {
                        $skip = $true
                    }
                    else 
                    {
                        $manifest.Dependencies.Remove($item)
                    }
                    
                    break
                }
            }

            if ($skip) 
            {
                continue
            }

            $res = ParseDep $dllName

            $manifest.Dependencies.Add($res)
        }
    }
    [string] $res = $manifest | ConvertTo-Json
    $res | Out-File -FilePath .\manifest.json
}

$csProj = FindFile ".\" '.*\.csproj$'

GenerateManifest $csProj

Write-Output "Generated Manifest"
