$packageName = 'icaros'
$version = '2.3.0'
$installerType = 'EXE'
$sha1 = 'c9cc1b488cade186ba28436dd4db5e2508f49559'
$url = "http://www.videohelp.com/download/Icaros_v$version.exe"
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum "$sha1" -checksumType 'sha1'