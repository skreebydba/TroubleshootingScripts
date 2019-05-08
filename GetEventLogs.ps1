<# Declare the server to capture logs from #>
$server = "DESKTOP-1KGJIH9";
<# Declare the path to write log files to #>
$logpath = "C:\temp\logs";

<# Get the current date and set the start time for log collection #>

$date = Get-Date;
$StartDate = $date.AddHours(-1);
<# Get the formatted date fro use in the log file paths #>
$formatdate = Get-Date -Format yyyyMMddHHmmss;

<# Check if the log path exists #>
$exists = Test-Path -Path $logpath;

<# If it does not exist, create it #>
if($exists -ne $true)
{
    New-Item -Path $logpath -ItemType Directory;
}

<# Delete all files for the log path #>
Remove-Item -Path "$logpath\*";

<# Get the system, application, and security log records for the last hour from the server #>
Get-Eventlog -ComputerName $server -LogName System -After $StartDate | Export-CSV -Path "$logpath\$server`_$formatdate`_SystemLog.csv";
Get-Eventlog -ComputerName $server -LogName Application -After $StartDate | Export-CSV -Path "$server`_$formatdate`_AppLog.csv";
Get-Eventlog -ComputerName $server -LogName Security -After $StartDate | Export-CSV -Path "$server`_$formatdate`_SecLog.csv";

<# Compress log files into a .zip file #>
Compress-Archive -Path "$logpath\*$server*" -CompressionLevel Fastest -DestinationPath "$logpath\logfiles";