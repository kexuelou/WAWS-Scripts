$sitename = $env:WEBSITE_SITE_NAME
$time = Get-date -Format "yyyymmdd-hhmmss"
$logFile = $env:HOME + "\LogFiles\" + $env:COMPUTERNAME + "-" + $sitename + "-" +  $time + ".log"

$content= "Time" + "`t" + "Start_Time" + "`t" + "ProcessName" + "`t" + "Id" + " " + "TotalProcessorTime" + "`t" + "UserProcessorTime"  + "`t" + "CPU"  + "`t" + "HandleCount"  + "`t" + "PrivateMemorySize"   + "`t" + "NonpagedSystemMemorySize"   + "`t" + "PagedMemorySize" + "`t" + "PeakPagedMemorySize" + "`t" + "VirtualMemorySize" + "`t" + "PeakVirtualMemorySize" + "`t" + "WorkingSet" + "`t" + "PeakWorkingSet"
Add-Content $logFile $content

 while (1 -eq 1){
   $procs = Get-Process
   $time = Get-Date -Format "yyyy-MM-dd hh:mm:ss"

   ForEach ($proc in $procs)
   {
      $content =  $time.ToString() + "`t" + $proc.StartTime.ToString('yyyy-MM-dd hh:mm:ss') + "`t" + $proc.ProcessName + "`t" + $proc.Id + " " + $proc.TotalProcessorTime + "`t" + $proc.UserProcessorTime  + "`t" + $proc.CPU  + "`t" + $proc.HandleCount  + "`t" + $proc.PrivateMemorySize   + "`t" + $proc.NonpagedSystemMemorySize   + "`t" + $proc.PagedMemorySize   + "`t" + $proc.PeakPagedMemorySize   + "`t" + $proc.VirtualMemorySize   + "`t" + $proc.PeakVirtualMemorySize   + "`t" + $proc.WorkingSet   + "`t" + $proc.PeakWorkingSet
      Add-Content $logFile $content
   }
   sleep -Seconds 30
}
