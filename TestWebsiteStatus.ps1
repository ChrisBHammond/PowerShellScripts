#Borrowed some code from this stack over flow page
#https://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url

Function PrintToLogFile()
{
    param ($text)
    Add-Content $LogFile "$(Get-Date) - $text"
    Write-Host $text
}


#Log File Location
$LogFile = "c:\scripts\WebSiteStatusLog.txt"


While(True)
{
    # Wrap in Try block because if the URL cant be resolved it throws an error.
    Try
    {
        # First we create the request.
        $HTTP_Request = [System.Net.WebRequest]::Create('http://google.com')

        # We then get a response from the site.
        $ResponseTime = (Measure-Command {$HTTP_Response = $HTTP_Request.GetResponse()}).TotalMilliseconds

    }
    Catch
    {
        Write-Output "Ran into an issue: $($PSItem.ToString())"
        $HTTP_Response.Close()
        Exit
    }
    Finally
    {
        # We then get the HTTP code as an integer.
        $HTTP_Status_Code = [int]$HTTP_Response.StatusCode
        $HTTP_Status = $HTTP_Response.StatusCode


        If ($HTTP_Status_Code -eq 200) {
            PrintToLogFile("Site is OK!")
            PrintToLogFile("Return Status code: $HTTP_Status_Code $HTTP_Status")
            PrintToLogFile("Response Time: $ResponseTime milliseconds")

        }
        Else {
            Write-Host "The Site may be down, please check!"
        }

        # Finally, we clean up the http request by closing it.
        $HTTP_Response.Close()
    }


}
