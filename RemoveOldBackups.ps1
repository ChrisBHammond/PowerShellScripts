#----- define parameters -----#
#----- get current date ----#
$Now = Get-Date 

#----- define amount of days ----#
$Days = "30"

#----- define folder where files are located ----#
$TargetFolder = "C:\backups\"

#----- define extension ----#
$Extension = "*.*"

#----- define LastWriteTime parameter based on $Days ---#
$LastWrite = $Now.AddDays(-$Days)

#----- get files based on lastwrite filter and specified folder ---#
$Files = Get-Childitem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}


Write-Host "Deleting Files"
foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        	write-host "Deleting File $File" -ForegroundColor "DarkRed"
        	Remove-Item $File.FullName | out-null
        }
    else
        {
        	Write-Host "No more files to delete!" -foregroundcolor "Green"
        }
    }