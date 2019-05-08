$server = "INVMARIASQLT01";
$logpath = "C:\temp\logs";
$query = @"
;WITH RingBufferConnectivity as
(	SELECT
		records.record.value('(/Record/@id)[1]', 'int') AS [RecordID],
		records.record.value('(/Record/ConnectivityTraceRecord/RecordType)[1]', 'varchar(max)') AS [RecordType],
		records.record.value('(/Record/ConnectivityTraceRecord/RecordTime)[1]', 'datetime') AS [RecordTime],
		records.record.value('(/Record/ConnectivityTraceRecord/SniConsumerError)[1]', 'int') AS [Error],
		records.record.value('(/Record/ConnectivityTraceRecord/State)[1]', 'int') AS [State],
		records.record.value('(/Record/ConnectivityTraceRecord/Spid)[1]', 'int') AS [Spid],
		records.record.value('(/Record/ConnectivityTraceRecord/RemoteHost)[1]', 'varchar(max)') AS [RemoteHost],
		records.record.value('(/Record/ConnectivityTraceRecord/RemotePort)[1]', 'varchar(max)') AS [RemotePort],
		records.record.value('(/Record/ConnectivityTraceRecord/LocalHost)[1]', 'varchar(max)') AS [LocalHost]
	FROM
	(	SELECT CAST(record as xml) AS record_data
		FROM sys.dm_os_ring_buffers
		WHERE ring_buffer_type= 'RING_BUFFER_CONNECTIVITY'
	) TabA
	CROSS APPLY record_data.nodes('//Record') AS records (record)
)
SELECT RBC.RecordID, 
RBC.RecordType, 
RBC.RecordTime,
RBC.Error, 
RBC.State, 
RBC.Spid,
RBC.RemoteHost,
RBC.RemotePort,
RBC.LocalHost,
m.text
FROM RingBufferConnectivity RBC
LEFT JOIN sys.messages M ON
	RBC.Error = M.message_id AND M.language_id = 1033
WHERE RBC.RecordType='Error' --Comment Out to see all RecordTypes
ORDER BY RBC.RecordTime DESC
"@;
$logpath
$date = Get-Date;
$StartDate = $date.AddHours(-1);

$exists = Test-Path -Path $logpath;

if($exists -ne $true)
{
    New-Item -Path $logpath -ItemType Directory;
}

Remove-Item -Path "$logpath\*";

Invoke-Sqlcmd -ServerInstance "$server\DEV2016" -Database master -InputFile $queryfile | Format-Table | Out-File "$logpath\mylog`_FailedConnections.txt";
Get-Eventlog -ComputerName $server -LogName System -After $StartDate | Export-CSV -Path "$logpath\$server`_SystemLog.csv";
Get-Eventlog -ComputerName $server -LogName Application -After $StartDate | Export-CSV -Path "$logpath\$server`_AppLog.csv";
Get-Eventlog -ComputerName $server -LogName Security -After $StartDate | Export-CSV -Path "$logpath\$server`_SecLog.csv";

Compress-Archive -Path "$logpath\*$server*" -CompressionLevel Fastest -DestinationPath "$logpath\logfiles";