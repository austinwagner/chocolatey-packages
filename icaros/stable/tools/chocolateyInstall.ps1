$packageName = 'icaros'
$version = '3.3.1'
$installerType = 'EXE'
$sha512 = 'C61F3235A4695225420964F2D724E47974EB8741BDF174B5569747CACAB47031DCCC58AF27EEDA87B5F9D86CFF4D48996846085D6E6CAF17DE5A0ED364CDDB09'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'

$downloadUrl = 
    Invoke-WebRequest -Uri "http://www.videohelp.com/download/Icaros_v$version.exe" -UseBasicParsing |
    Select-Object -ExpandProperty Links |
    Where-Object { $_ -like "*Icaros_v$version*" } |
    Select-Object -First 1 -ExpandProperty href

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$downloadUrl" -checksum "$sha512" -checksumType 'sha512'
