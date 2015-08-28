$packageName = 'icaros'
$version = '3.0.0_b4'
$installerType = 'EXE'
$sha1 = '1f106b486dd294a3995770d21127857797d56d28'
$url = "http://www.videohelp.com/download/Icaros_v$version.exe"
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum "$sha1" -checksumType 'sha1'