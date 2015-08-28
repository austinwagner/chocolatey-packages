$packageName = 'icaros'
$version = '3.0.0_b4'
$installerType = 'EXE'
$sha1 = '1f106b486dd294a3995770d21127857797d56d28'
$urlBase = "http://www.videohelp.com/download/Icaros_v$version.exe?r="
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri http://www.videohelp.com/software/Icaros -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like '*itemprop="downloadURL"*' } |
    select -First 1 -ExpandProperty href

$referrer = $downloadUrl -replace '.*\?r=(\w+)','$1'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$urlBase$referrer" -checksum "$sha1" -checksumType 'sha1'