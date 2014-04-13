$packageName = '__NAME__'
$url = '__REPLACE__'

function Invoke-BatchFile($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function Invoke-VsVars32() {
    $batchFile = Join-Path $env:VS120COMNTOOLS 'vsvars32.bat'
    Invoke-Batchfile `"$batchFile`"
}

function Get-TempWebFile($url, $filename) {
    $path = Join-Path ([IO.Path]::GetTempPath()) $filename

    if (Test-Path $path) { 
        Remove-Item -Force $path 
    }

    Get-ChocolateyWebFile $packageName $path $url
    return $path
}

function Install-VsixSilently($url, $name) {
    $extension = Get-TempWebFile $url $name

    try {
        Start-Process -FilePath 'VSIXInstaller.exe' -ArgumentList "/q $extension" -Wait
    } finally {
        if (Test-Path $extension) {
            Remove-Item -Force $extension
        }
    }
}

try {
    Invoke-VsVars32
    Install-VsixSilently $url ($packageName + '.vsix')

    Write-ChocolateySuccess $packageName
} catch {
    Write-ChocolateyFailure $packageName "$($_.Exception.Message)"
    throw
}
