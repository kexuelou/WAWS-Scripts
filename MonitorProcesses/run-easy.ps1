$sitename = $env:WEBSITE_SITE_NAME
$time = Get-date -Format "yyyymmdd-hhmmss"
$logFile = $env:HOME + "\LogFiles\" + $env:COMPUTERNAME + "-" + $sitename + "-" +  $time + ".log"

# | Format-Table -Property  TotalProcessorTime, UserProcessorTime, CPU, HandleCount, PrivateMemorySize, NonpagedSystemMemorySize, PagedMemorySize, PeakPagedMemorySize, VirtualMemorySize,PeakVirtualMemorySize, WorkingSet, PeakWorkingSet | Out-File -Append $logFile

$content= "Time" + "`t" + "Start_Time" + "`t" + "ProcessName" + "`t" + "Id" + " " + "TotalProcessorTime" + "`t" + "UserProcessorTime"  + "`t" + "CPU"  + "`t" + "HandleCount"  + "`t" + "PrivateMemorySize"   + "`t" + "NonpagedSystemMemorySize"   + "`t" + "PagedMemorySize" + "`t" + "PeakPagedMemorySize" + "`t" + "VirtualMemorySize" + "`t" + "PeakVirtualMemorySize" + "`t" + "WorkingSet" + "`t" + "PeakWorkingSet"
Add-Content $logFile $content
#"Time`t`t`t`t`tName`t`t`tID`t`tstart_time`t`t`t`t`t`tthread_count`thandle_count`t`ttotal_cpu_time`t`tuser_cpu_time`t`tworking_set`t`tpeak_working_set`t`tprivate_memory`t`tvirtual_memory`t`tpeak_virtual_memory`t`tpaged_memory`t`tpeak_paged_memory`t`tpaged_system_memory`t`tnon_paged_system_memory"

 while (1 -eq 1){
<<<<<<< HEAD
   #Get-Process | Format-Table -HideTableHeaders  -Property ProcessName, Id, StartTime, TotalProcessorTime, UserProcessorTime, CPU, HandleCount, PrivateMemorySize, NonpagedSystemMemorySize, PagedMemorySize, PeakPagedMemorySize, VirtualMemorySize,PeakVirtualMemorySize, WorkingSet, PeakWorkingSet  | Out-File -Append $logFile
   $procs = Get-Process
   $time = Get-Date -Format "yyyy-MM-dd hh:mm:ss"

   ForEach ($proc in $procs)
   {
      $content =  $time.ToString() + "`t" + $proc.StartTime.ToString('yyyy-MM-dd hh:mm:ss') + "`t" + $proc.ProcessName + "`t" + $proc.Id + " " + $proc.TotalProcessorTime + "`t" + $proc.UserProcessorTime  + "`t" + $proc.CPU  + "`t" + $proc.HandleCount  + "`t" + $proc.PrivateMemorySize   + "`t" + $proc.NonpagedSystemMemorySize   + "`t" + $proc.PagedMemorySize   + "`t" + $proc.PeakPagedMemorySize   + "`t" + $proc.VirtualMemorySize   + "`t" + $proc.PeakVirtualMemorySize   + "`t" + $proc.WorkingSet   + "`t" + $proc.PeakWorkingSet
      Add-Content $logFile $content
   }
   sleep -Seconds 30
=======
  Get-Process | Format-Table -HideTableHeaders  -Property ProcessName, Id, StartTime, TotalProcessorTime, UserProcessorTime, CPU, HandleCount, PrivateMemorySize, NonpagedSystemMemorySize, PagedMemorySize, PeakPagedMemorySize, VirtualMemorySize,PeakVirtualMemorySize, WorkingSet, PeakWorkingSet  | Out-File -Append $logFile
  sleep -Seconds 30
>>>>>>> origin/master
}
