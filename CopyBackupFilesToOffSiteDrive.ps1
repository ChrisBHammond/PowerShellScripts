
Function PrintHeader(){

Add-Content $LogFile " "
Add-Content $LogFile "---------------------------------------------------------------------------------------------------------------------------------"
Add-Content $LogFile "Backup PowerShell Script to Copy over container VHD files from last Primary backup folder found to the last Offsite backup drive found."
Add-Content $LogFile "$(Get-Date) - Script Started"

}

Function PrintToLogFile()
{
    param ($text)
    Add-Content $LogFile "$(Get-Date) - $text"
    Write-Host $text
}

Function PrintFooter()
{

Add-Content $LogFile "---------------------------------------------------------------------------------------------------------------------------------"
Add-Content $LogFile " "

} 


PrintToLogFile(" ")
PrintToLogFile("Backup PowerShell Script to Copy over container VHD files from last Primary backup folder found to the last Offsite backup drive found.")
PrintToLogFile(" ")

#Log File Location
$LogFile = "c:\scripts\log.txt"

#Print Logfile Header
PrintHeader

$scanDiskResult = "rescan" | diskpart
PrintToLogFile("Scan Disk Result: $scanDiskResult") 

#pause for 10 seconds or the script continues running to find all drives while disk scan is running and might not find any drives.
Start-Sleep -s 10

$primaryBackupPath = ""
$offSiteBackupPath = ""
$drivelabelString = ""
$backupPathFound = $false
$primaryPathFound = $false
# The back up system is pretty static and is used for nothing else so these shouldnt go past P.
$DriveLettersArray = "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P" 

$SecureString = ConvertTo-SecureString "###########BitLocker Key Goes Here#############" -AsPlainText -Force

#Try to unlock all backup drives in the system.
foreach( $letter in $DriveLettersArray)
{
    
    $result = Unlock-BitLocker -MountPoint $letter":" -Password $SecureString

    Write-Host $result
    if(![string]::IsNullOrEmpty($result))
    {
        PrintToLogFile("Drive $result successfully unlocked.")
    }
}

#Check for Primary Backup and offsite back up drive
foreach( $letter in $DriveLettersArray)
{
    $primaryBackupTempPath = $letter + ":\primaryBackup\"   
    $primaryPathTest = Test-Path -Path  $primaryBackupTempPath
    
    if($primaryPathTest)
    {
        $primaryPathFound = $true
        $primaryBackupPath = $primaryBackupTempPath       
    }

    $offSiteBackupTempPath = $letter + ":\OffSitebackups\"    
    $backupPathTest = Test-Path -Path  $offSiteBackupTempPath 

    if($backupPathTest)
    {
        $backupPathFound = $true
        $offSiteBackupPath = $offSiteBackupTempPath      

		#Get Driver Name for log
        $label = Get-Volume $letter | Select FileSystemlabel
        $drivelabelString = $label.FileSystemlabel
    }
}


if(!$primaryPathFound)
{
    PrintToLogFile("Cant find a Primary backup drive, please check that all drives are plugged in correctly")
}
else
{
    PrintToLogFile("Found Primary Backup Location at: $primaryBackupPath")
}

if(!$backupPathFound)
{
    PrintToLogFile("Cant find a Offsite Backup Drive, please check that all drives are plugged in correctly")
}
else
{
    PrintToLogFile("Found Backup Location at: $offSiteBackupPath")
}

if($primaryPathFound -and $backupPathFound)
{
    # Do Logic here to backup data

    PrintToLogFile("Using Offsite backup path: - $offSiteBackupPath")
    PrintToLogFile("Using Primary Onsite backup path: - $primaryBackupPath")
    PrintToLogFile("Volume Offsite backup drive label: - $drivelabelString")
        
    PrintToLogFile("Deleting All old backup files in: - $offSiteBackupPath")
    $removeItemResult = Remove-Item ($offSiteBackupPath + "\" + "*") -recurse

    PrintToLogFile("Starting Backup of VHD Files")
    #$result = xcopy \\localhost\primaryBackup $tempSharePath <---- OLD WAY
    $result = Copy-Item -Recurse -verbose -PassThru ($primaryBackupPath + "*") $offSiteBackupPath 
       
    if(($result -eq $Null) -or ($result -eq ""))
    {                           
        PrintToLogFile("ERROR: Back up of VHD files was NOT completed" )
    }
    else
    {
        foreach($FileCopied in $result)
        {
            PrintToLogFile("Copied: $FileCopied")     
        }
                 
        Write-Host "Back up of VHD files completed successfully" 
        PrintToLogFile("Back up of VHD files completed successfully")
    }
}
else
{
    PrintToLogFile("Both Primary backup and Offsite Backup drives are needed, Please check that all drives are connected")
}

#Print Footer
PrintFooter
