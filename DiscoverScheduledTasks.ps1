# Script: DiscoverScheduledTasks
# Author: Romain Si
# Revision: Isaac de Moraes, Updated for Cyrillic support
# This script is intended for use with Zabbix > 3.x
#
# Add to Zabbix Agent
#   UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\DiscoverScheduledTasks.ps1" "$1" "$2"
#

# Установка UTF-8 кодировки для корректной работы с кириллицей
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

## Modifier la variable $path pour indiquer les sous dossiers de Tâches Planifiées à traiter sous la forme "\nomDossier\","\nomdossier2\sousdossier\" voir (Get-ScheduledTask -TaskPath )
## Change the $path variable to indicate the Scheduled Tasks subfolder to be processed as "\nameFolder\","\nameFolder2\subfolder\" see (Get-ScheduledTask -TaskPath )

$path = "\"

Function Convert-ToUnixDate ($PSdate) {
   $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
   (New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
  "DiscoverTasks" {
    $apptasks = Get-ScheduledTask -TaskPath $path | where {$_.state -like "Ready" -or $_.state -like "Running"}
    $apptasksok = $apptasks.TaskName
    $idx = 1
    write-host "{"
    write-host " `"data`":[`n"
    foreach ($currentapptasks in $apptasksok)
    {
        if ($idx -lt $apptasksok.count)
        {
            $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" },"
            write-host $line
        }
        elseif ($idx -ge $apptasksok.count)
        {
            $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" }"
            write-host $line
        }
        $idx++;
    } 
    write-host
    write-host " ]"
    write-host "}"
  }
}

switch ($ITEM) {
  "TaskLastResult" {
    [string] $name = $ID
    try {
        $pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name"
        $pathtask1 = $pathtask.Taskpath
        $taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name"
        Write-Output ($taskResult.LastTaskResult)
    }
    catch {
        Write-Output "Task not found"
    }
  }
}

switch ($ITEM) {
  "TaskLastRunTime" {
    [string] $name = $ID
    try {
        $pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name"
        $pathtask1 = $pathtask.Taskpath
        $taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name"
        $taskResult1 = $taskResult.LastRunTime
        if ($taskResult1 -ne $null) {
            $taskResult2 = Convert-ToUnixDate($taskResult1)
            Write-Output ($taskResult2)
        } else {
            Write-Output "0"
        }
    }
    catch {
        Write-Output "0"
    }
  }
}

switch ($ITEM) {
  "TaskNextRunTime" {
    [string] $name = $ID
    try {
        $pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name"
        $pathtask1 = $pathtask.Taskpath
        $taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name"
        $taskResult1 = $taskResult.NextRunTime
        if ($taskResult1 -ne $null) {
            $taskResult2 = Convert-ToUnixDate($taskResult1)
            Write-Output ($taskResult2)
        } else {
            Write-Output "0"
        }
    }
    catch {
        Write-Output "0"
    }
  }
}

switch ($ITEM) {
  "TaskState" {
    [string] $name = $ID
    try {
        $pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name"
        $pathtask1 = $pathtask.State
        Write-Output ($pathtask1)
    }
    catch {
        Write-Output "Unknown"
    }
  }
}
