Function Invoke-RestAPI {
    param(
        [string]$User,
        [string]$Pwd,
        [string]$URL
        ) 

  #Create a URI instance since the HttpWebRequest.Create Method will escape the URL by default.
  $URI = New-Object System.Uri($URL,$true)
 
  #Create a request object using the URI
  $request = [System.Net.HttpWebRequest]::Create($URI)
 
  #Build up a nice User Agent
  $request.UserAgent = $UserAgent
 
  #Establish the credentials for the request
  $creds = New-Object System.Net.NetworkCredential($User,$Pwd)
  $request.Credentials = $creds
 
  $response = $request.GetResponse()
  $reader = [IO.StreamReader] $response.GetResponseStream()
  $respnseBody = $reader.ReadToEnd()
        
  $reader.Close()
  $response.Close()
  return $respnseBody
}

$script:result

$username = "your deploy user name"
$password = "your deploy password"

$sitename = $env:WEBSITE_SITE_NAME
$jobpath = $env:WEBJOBS_PATH 

 #$env:WEBSITE_SITE_NAME
 #$env:WEBJOBS_NAME 

$wps = Get-Process w3wp
$wpid = $wps.id

write-output $wpS

ForEach ($wp in $wps)
{
    $wpid = $wp.id
    Write-Output $wpid
    #$apiUrl = [string]::Format($apiBaseUrl,$siteName,$wp)
    $apiUrl = "https://${sitename}.scm.azurewebsites.net/api/processes/${wpid}"
    Write-Output $apiUrl
    #$proc = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET
    $result = Invoke-RestAPI $username $password $apiUrl
    $proc = ConvertFrom-Json $result
    $proc.is_scm_site
    if (!$proc.is_scm_site)
    {
        break
     }
}

write-output "worker process"
write-output $proc

ForEach ($cproc in $proc.children)
{
    #$nproc = Invoke-RestMethod -Uri $cproc -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET
    write-output $cproc
    $result = Invoke-RestAPI $username $password $cproc
    $nproc = ConvertFrom-Json $result
    if ($nproc.name.CompareTo("node") -eq 0)
    {
        write-output "node process"
        write-output $nproc

        $cmd =  "${jobpath}\NodeCrashDump\procdump.exe -accepteula -e -t " + $nproc.id + " D:\home\site\diagnostics"
        write-output $cmd

        iex $cmd
     }
}

