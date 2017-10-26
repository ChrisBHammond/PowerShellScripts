# Script to back up my test Web Applications and keep a 30 day back up of them.

$SourceLocation = "c:\projects\Website\"
$DestinationLocation = "c:\projects\WebsiteBackups\"
$CreateDirectory  = $true

$DateTime = Get-Date -format "yyyy-MMM-d-hh-mm-ss"

Write-host $DateTime

#Create the destination directory, I am assuming the source directory is there but we will still check for it
If(!(Test-path $DestinationLocation) -And $CreateDirectory)
{
    New-Item -Path $DestinationLocation -ItemType directory
}

#Test the source path if its not there let the user know
If(!(Test-path $SourceLocation))
{
    Write-Host "$SourceLocation not found to backup files from"
}
else
{

    #Copy and compress the files from the source to the destination    
    compress-archive -path $SourceLocation -destinationpath "$DestinationLocation $DateTime .zip" -update -compressionlevel optimal
    Write-Host "Successfully compressed and backed up the folder $SourceLocation"

    #This line could also be used to uncompress a file
    #expand-archive -path 'c:\projects\WebsiteBackups\NameOfFile.zip' -destinationpath '.\unzipped'



}

#Remove all backup files older than 30 days
#$limit = (Get-Date).AddSeconds(-30) <--- 30 seconds old for testing.
$limit = (Get-Date).AddDays(-30)


# Delete files older than the $limit.
Get-ChildItem -Path $DestinationLocation -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force


