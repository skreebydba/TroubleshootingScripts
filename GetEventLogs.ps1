<# Declare the server to capture logs from #>
$server = "DESKTOP-1KGJIH9";
<# Declare the path to write log files to #>
$logpath = "C:\temp\logs";

<# Get the current date and set the start time for log collection #>
$formatdate = Get-Date -Format yyyyMMddHHmmss;
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