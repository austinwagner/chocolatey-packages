$packageName = 'Icaros.install'
$installerType = 'EXE'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'

$exe = Join-Path "$env:ProgramFiles" 'Icaros\unins000.exe'

Uninstall-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$exe"