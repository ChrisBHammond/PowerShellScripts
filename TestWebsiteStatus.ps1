#Borrowed some code from this stack over flow page
#https://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url

# Thissubject came up in a interview I went too, decided to see how hard it would be to write a small script to see if the 
# webserver was responding to more than just pings. This tests if it returns the HTTP status code 200 OK.

#Print to log file and outputs to host if being run manually.
Function PrintToLogFile()
{
    param ($text)
    Add-Content $LogFile "$(Get-Date) - $text"
    Write-Host $text
}


#Log File Location
$LogFile = "c:\scripts\WebSiteStatusLog.txt"

#Run this forever testing the website
While($true)
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
        #Print out the error code to help trouble shoot the problem
        Write-Output "Ran into an issue: $($PSItem.ToString())"

        # Close the HTTP connection incase its not.
        $HTTP_Response.Close()

        #Exit the powershell script.
        Exit
    }
   
        # We then get the HTTP code as an integer.
        $HTTP_Status_Code = [int]$HTTP_Response.StatusCode

        # Get Status code as String.
        $HTTP_Status = $HTTP_Response.StatusCode


        If ($HTTP_Status_Code -eq 200) {
            PrintToLogFile("-----------------------------------------------------------")
            PrintToLogFile($(Get-Date))
            PrintToLogFile("Site is OK!")
            PrintToLogFile("Return Status code: $HTTP_Status_Code $HTTP_Status")
            PrintToLogFile("Response Time: $ResponseTime milliseconds")
            PrintToLogFile("-----------------------------------------------------------")

        }
        Else {
            Write-Host "The Site may be down, please check!"

            #TODO send email if the website is down?
            # Maybe even tie into API service to send SMS text message?
        }

        # Finally, we clean up the http request by closing it.
        $HTTP_Response.Close()
    

    Start-Sleep -s 2
}
