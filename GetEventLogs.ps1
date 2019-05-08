$server = "INVMARIASQLT01";
$logpath = "C:\temp\logs";

$date = Get-Date;
$StartDate = $date.AddHours(-1);

$exists = Test-Path -Path $logpath;

if($exists -ne $true)
{
    New-Item -Path $logpath -ItemType Directory;
}

Remove-Item -Path "$logpath\*";

Get-Eventlog -ComputerName $server -LogName System -After $StartDate | Export-CSV -Path "$logpath\$server`_SystemLog.csv";
Get-Eventlog -ComputerName $server -LogName Application -After $StartDate | Export-CSV -Path "$logpath\$server`_AppLog.csv";
Get-Eventlog -ComputerName $server -LogName Security -After $StartDate | Export-CSV -Path "$logpath\$server`_SecLog.csv";

Compress-Archive -Path "$logpath\*$server*" -CompressionLevel Fastest -DestinationPath "$logpath\logfiles";