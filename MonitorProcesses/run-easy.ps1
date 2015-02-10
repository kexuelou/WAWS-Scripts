$sitename = $env:WEBSITE_SITE_NAME

$time = Get-date -Format "yyyymmdd-hhmmss"
$logFile = $env:HOME + "\LogFiles\" + $env:COMPUTERNAME + "-" + $sitename + "-" +  $time + ".log"


Get-Process | Format-Table -Property  TotalProcessorTime, UserProcessorTime, CPU, HandleCount, PrivateMemorySize, NonpagedSystemMemorySize, PagedMemorySize, PeakPagedMemorySize, VirtualMemorySize,PeakVirtualMemorySize, WorkingSet, PeakWorkingSet | Out-File -Append $logFile


 while (1 -eq 1){
  Get-Process | Format-Table -HideTableHeaders  -Property ProcessName, Id, StartTime, TotalProcessorTime, UserProcessorTime, CPU, HandleCount, PrivateMemorySize, NonpagedSystemMemorySize, PagedMemorySize, PeakPagedMemorySize, VirtualMemorySize,PeakVirtualMemorySize, WorkingSet, PeakWorkingSet  | Out-File -Append $logFile
  sleep -Seconds 1
}
