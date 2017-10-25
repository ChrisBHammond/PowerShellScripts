Function PrintToLogFile()
{
    param ($text)
    Add-Content $LogFile "$(Get-Date) - $text"
}

Function PrintHeader(){

Add-Content $LogFile " "
Add-Content $LogFile "---------------------------------------------------------------------------------------------------------------------------------"
Add-Content $LogFile "Testing connection to device $device" 
Add-Content $LogFile "$(Get-Date) - Script Started"

}

#Log File Location
$LogFile = "c:\scripts\pingOutput.txt"

#Set the IP of the device you want to ping, make sure its setup to respond to pings. 
$device = "192.168.128.1"

#Print Logfile Header
PrintHeader


while($true)
{
    $status = @{ "ServerName" = $device; "TimeStamp" = (Get-Date -f s) }
    if (Test-Connection $device -Count 1 -ea 0 -Quiet)
    { 
        $status["Results"] = "Up"
    } 
    else 
    { 
        $status["Results"] = "Down" 
    }
     #New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
    
    Start-Sleep -m 1000

    Write-Host "$($status.ServerName) - $($status.TimeStamp) - $($status.Results)"

    PrintToLogFile("$($status.ServerName) - $($status.TimeStamp) - $($status.Results)")
}
