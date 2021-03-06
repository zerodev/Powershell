#requires -Version 2

$netstats = NETSTAT.EXE -anop tcp | Select-Object -Skip  4 |
ForEach-Object -Process {[regex]::replace($_.trim(),'\s+',' ')} |
ConvertFrom-Csv -delimiter ' ' -Header 'proto', 'src', 'dst', 'state', 'pid' |
Select-Object -Property pid, proto, dst, src, state, 
    @{name = 'process_name'; expression = {(Get-Process -id $_.pid).name}},
    @{name = 'session_id'; expression = {(Get-Process -id $_.pid).sessionid}},
    @{name = 'window_title'; expression = {(Get-Process -id $_.pid).mainwindowtitle}},
    @{name = 'ppid'; expression = {(gwmi win32_process -Filter "processid='$($_.pid)'").parentprocessid}},
    @{name = 'gpid'; expression = {(gwmi win32_process -Filter "processid='$($_.ppid)'").parentprocessid}},
    @{name = 'parent_process_name'; expression = {(Get-Process -id $_.ppid).name}}

$netstats | Sort -Property pid | FT -Property proto, process_name, pid, ppid, gpid, parent_process_name, src, dst, state, session_id, window_title
