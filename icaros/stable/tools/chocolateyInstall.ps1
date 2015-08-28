$packageName = 'icaros'
$version = '2.3.0'
$installerType = 'EXE'
$sha1 = 'c9cc1b488cade186ba28436dd4db5e2508f49559'
$urlBase = "http://www.videohelp.com/download/Icaros_v$version.exe?r="
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri http://www.videohelp.com/software/Icaros -UseBasicParsing |
    select -ExpandProperty Links |
    ? { $_ -like '*itemprop="downloadURL"*' } |
    select -First 1 -ExpandProperty href

$referrer = $downloadUrl -replace '.*\?r=(\w+)','$1'

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$urlBase$referrer" -checksum "$sha1" -checksumType 'sha1'