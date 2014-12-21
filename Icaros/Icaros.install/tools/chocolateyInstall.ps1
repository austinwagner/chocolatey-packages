$packageName = 'Icaros.install'
$version = '2.2.6'
$installerType = 'EXE'
$sha1 = '2a9b4916aff45c72c068e1008c40edf395457980'
$url = "http://www.austinwagner.net/files/Icaros_v$version.exe"
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum "$sha1" -checksumType 'sha1'