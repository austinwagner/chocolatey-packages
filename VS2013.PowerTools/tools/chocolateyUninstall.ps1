$vsixId = 'VSProPack.Microsoft.D67305A0-1A33-49E1-913B-8A8BC420750C'

function Invoke-BatchFile ($file) {
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

function Uninstall-VsixSilently($id) {
    Start-Process -FilePath 'VSIXInstaller.exe' -ArgumentList "/q /u:$id" -Wait
}

try {
    Invoke-VsVars32
    Uninstall-VsixSilently $vsixId

    Write-ChocolateySuccess $packageName
} catch {
    Write-ChocolateyFailure $packageName "$($_.Exception.Message)"
    throw
}
