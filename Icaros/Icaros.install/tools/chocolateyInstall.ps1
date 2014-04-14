$packageName = 'Icaros.install'
$version = '2.2.3'
$installerType = 'EXE'
$url = "http://www.austinwagner.net/files/Icaros_v$version.exe"
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url"