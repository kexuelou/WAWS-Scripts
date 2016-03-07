<#
.SYNOPSIS
    Verify if webapps are  ready for migration.

.DESCRIPTION
    Before subscription migration, we need to make sure the webapps and hosting plan are in the same resource group.
    In other words: 
    	• The site “foo” is in resource group “Rg1”
	    • The site is hosted in App Service Plan “bar”
	    • App Service Plan “bar” is in resource group “Rg2”

        Currently we don’t support migrating subscriptions in this state.  

        In order for the customer to migrate their subscription they’ll need to move their site to the same resource group as the server farm the site is hosted in.
        https://azure.microsoft.com/en-us/documentation/articles/resource-group-move-resources


.PARAMETER SubscriptionId
    If a subscription ID is specified, subscription-wide information will be provided.
    Otherwise, it will use the current subscription configured locally in Azure PowerShell.

.EXAMPLE
	WebAppsMigrationCheck.ps1 -SubscriptionId 220f53cc4de541c2b48a48ae78773ce3

.NOTES
    Name: WebAppMigrationCheck.ps1

    Author: wzhao
#>
[CmdletBinding()]
Param(
    [string]$SubscriptionID
)

#$im = Get-InstalledModule -Name AzureRM1 -ErrorVariable err -WarningVariable war -ErrorAction SilentlyContinue


function InstallModule([string]$ModuleName)
{
    #check the module was installed or not
    $ip = Get-Package -Name $ModuleName -ErrorVariable err -ErrorAction SilentlyContinue
    
    #module was not installed
    if ($err.count -gt 0)
    {
        Write-Host "$($ModuleName) was not installed!" -ForegroundColor Yellow
        $confirmation = Read-Host "Do you want install AzureRM module[y/n]?"

        if ($confirmation -eq 'y') 
        {
            Write-Host  "Now Instaling $($ModuleName)......"
            # Install the modules from PowerShell Gallery
            Install-Module $ModuleName -ErrorVariable err -ErrorAction SilentlyContinue

            #Failed to install the module
            if ($err.count -gt 0)
            {
                Write-Host  $err -ForegroundColor Red
                Write-Host  "Failed to Instal $($ModuleName)......" -ForegroundColor Red
                Exit
            }
        }
        else
        {
            Write-Host  "The script requirs Azure Powershell module." -ForegroundColor Red
            Exit
        }
    }
    else
    {
        Write-Verbose "$($ModuleName) was already installed"
    }

}


function InstallAzureRmPackage($ModuleName)
{
#check the module was installed or not
    $ip = Get-Package -Name $ModuleName -ErrorVariable err -ErrorAction SilentlyContinue
    
    #module was not installed
    if ($err.count -gt 0)
    {
        Write-Host "$($ModuleName) was not installed!" -ForegroundColor Yellow
        $confirmation = Read-Host "Do you want install AzureRM module[y/n]?"

        if ($confirmation -eq 'y') 
        {
            Write-Host  "Now Instaling $($ModuleName)......"
            # Install the modules from PowerShell Gallery
            Install-AzureRm

            #Failed to install the module
            if ($err.count -gt 0)
            {
                Write-Host  $err -ForegroundColor Red
                Write-Host  "Failed to Instal $($ModuleName)......" -ForegroundColor Red
                Exit
            }
        }
        else
        {
            Write-Host  "The script requirs AzureRm Powershell module." -ForegroundColor Red
            Exit
        }
    }
    else
    {
        Write-Verbose "$($ModuleName) was already installed"
    }

}



function ValidSubID($subId)
{

    return $subId -match("^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$")

}


function SelectSourceSubscription($subId)
{
    
    if (ValidSubID($subId))
    {
        $err = $null
        Select-AzureRmSubscription -SubscriptionId $subId -ErrorVariable err
        
        #Problem select subscription
        if ($err -ne $null)
        {
            Exit
        }

        return
    }


    $i = 0;
    $subId = ""
    $num = 0
    $subList = Get-AzureRmSubscription

    if ($subList.Count -gt 1)
    {
    
        $subList | ForEach-Object {
            $i += 1
            Write-Host  "Subscription#    ： $($i)"
            Write-Host  "SubscriptionName ： $($_.SubscriptionName)"
            Write-Host  "SubscriptionId   ： $($_.SubscriptionId)"

            Write-Host ""
        }
        
        Do {
            [int]$num = Read-Host "Please select a subscription# "
            $num = $num - 1
        } while ( ($num -lt 0) -or ($num -gt $subList.Count-1) )
        
        $subId = $subList[$num].SubscriptionId

    }
    else 
    {
        $subId = $subList[0].SubscriptionId
    }

    Select-AzureRmSubscription -SubscriptionId $subId
    
}


function GetWebApps()
{
    $resorces = Get-AzureRmResource


    Get-AzureRmResource | Where-Object {$_.ResourceType.StartsWith("Microsoft.Web") } | ForEach-Object {
        $r = $_
        switch ($r.ResourceType) {

            "Microsoft.Web/serverFarms" {
                $srvFarms.Add($r.Name, $r)
            }


            "Microsoft.Web/sites" {
                $webSites[$r.Name] = $r
            }

            "Microsoft.Web/sites/slots" {
                $slots[$r.Name] = $r
            }

            #"Microsoft.Web/certificates" {
            #    $certs[$r.Name] = $r
            #}

        }
    }

    Write-Verbose "server farms"
    $srvFarms.GetEnumerator() | % {
            $farm = $_
            Write-Verbose  "ResourceName      : $($farm.value.ResourceName) "
            Write-Verbose  "ResourceType      : $($farm.value.ResourceType)"
            Write-Verbose  "ResourceGroupName : $($farm.value.ResourceGroupName)"

            Write-Verbose ""
    }

    #$srvFarms
    
    Write-Verbose "Sites"
    $webSites.GetEnumerator() | % {
            $site = $_
            Write-Verbose  "ResourceName      : $($site.value.ResourceName) "
            Write-Verbose  "ResourceType      : $($site.value.ResourceType)"
            Write-Verbose  "ResourceGroupName : $($site.value.ResourceGroupName)"

            Write-Verbose ""
    }

    Write-Verbose "Slots"
    $slots.GetEnumerator() | % {
            $slot = $_
            Write-Verbose  "ResourceName      : $($slot.value.ResourceName) "
            Write-Verbose  "ResourceType      : $($slot.value.ResourceType)"
            Write-Verbose  "ResourceGroupName : $($slot.value.ResourceGroupName)"

            Write-Verbose ""
    }

    
}


function GetFarmNameFromID($farmId)
{
    return $farmId.Substring($farmId.LastIndexOf('/')+1)

}

function AnalyzeWebAppsForMigration()
{
    
    #$srvFarms = @{}
    #$webSites = @{}
    #$slots = @{}
   
    Write-Verbose "Sites"
    $webSites.GetEnumerator() | % {
            $s = $_
            Get-AzureRmResource -OutVariable site -ResourceId $($s.value.ResourceId) -ApiVersion $WebAppApiVersion  | Out-Null
            
            $farmName = GetFarmNameFromID($site.Properties.ServerFarmId)

            Write-Verbose  "ResourceName         : $($site.ResourceName) "
            Write-Verbose  "ServerFarmName       : $($farmName)"
            Write-Verbose  "ResourceGroupName    : $($site.ResourceGroupName)"

            $farm = $srvFarms[$farmName]
            Write-Verbose  "ServerFarmRG         : $($farm.ResourceGroupName)"

            Write-Verbose ""

            if ($site.ResourceGroupName -ne $farm.ResourceGroupName)
            {
                $object = New-Object –Type PSObject
                $object | Add-Member –MemberType NoteProperty –Name siteName –Value $site.ResourceName
                $object | Add-Member –MemberType NoteProperty –Name siteRG –Value $site.ResourceGroupName
                $object | Add-Member –MemberType NoteProperty –Name siteResourceID –Value $site.ResourceId

                $object | Add-Member –MemberType NoteProperty –Name farmName –Value $farmName
                $object | Add-Member –MemberType NoteProperty –Name farmRG –Value $farm.ResourceGroupName
                $object | Add-Member –MemberType NoteProperty –Name farmResourceID –Value $site.Properties.ServerFarmId


                $results += $object
            }

    }

    Write-Verbose "Slots"
    #$slots
    $slots.GetEnumerator() | % {
            $s = $_
            Get-AzureRmResource -OutVariable slot -ResourceId $($s.value.ResourceId) -ApiVersion $WebAppApiVersion  | Out-Null
            
            $farmName = GetFarmNameFromID($slot.Properties.ServerFarmId)

            Write-Verbose  "ResourceName      : $($slot.ResourceName) "
            Write-Verbose  "ServerFarm        : $($farmName)"
            Write-Verbose  "ResourceGroupName : $($slot.ResourceGroupName)"
            
            $farm = $srvFarms[$farmName]
            Write-Verbose  "ServerFarmRG         : $($farm.ResourceGroupName)"

            Write-Verbose ""

            if ($farmName -ne $farm.ResourceGroupName)
            {
                $object = New-Object –Type PSObject
                $object | Add-Member –MemberType NoteProperty –Name siteName –Value $slot.ResourceName
                $object | Add-Member –MemberType NoteProperty –Name siteRG –Value $slot.ResourceGroupName
                $object | Add-Member –MemberType NoteProperty –Name siteResourceID –Value $slot.ResourceId

                $object | Add-Member –MemberType NoteProperty –Name farmName –Value $farmName
                $object | Add-Member –MemberType NoteProperty –Name farmRG –Value $farm.ResourceGroupName
                $object | Add-Member –MemberType NoteProperty –Name farmResourceId –Value $slot.Properties.ServerFarmId

                $results += $object
            }
    }

    return $results
}

function DoMove($resourceName, $oldRG, $newRG)
{
    $resourceToMove = Get-AzureRmResource -ResourceName $resourceName -ResourceGroupName $oldRG
    Move-AzureRmResource -DestinationResourceGroupName $newRG -ResourceId $resourceToMove.ResourceId
}

function MoveResource($resource)
{
    $num = 0
    write-host ""

    Write-Host  "Option #1: Move site " -NoNewLine
    Write-Host  $r.siteName  -NoNewLine -ForegroundColor Yellow
    Write-Host  " from resource group " -NoNewLine
    Write-Host  $r.siteRG -NoNewLine -ForegroundColor Yellow
    Write-Host  " to resource group " -NoNewLine
    Write-Host  $resource.farmRG -ForegroundColor Yellow


    #Write-Host  "Option #2: Move server farm "  -NoNewLine
    #Write-Host  $r.farmName  -NoNewLine  -ForegroundColor Yellow
    #Write-Host  " to resource group "  -NoNewLine
    #Write-Host  $resource.siteRG  -ForegroundColor Yellow

    Write-Host  "Option #2: I will move the site " -NoNewline
    Write-Host  $r.siteName  -NoNewLine -ForegroundColor Yellow
    Write-Host  " myself later"
    
    write-host ""
        
    $num = 0;
       
    Do {
        [int]$num = Read-Host "Please select an option# "
    } while ( ($num -lt 1) -or ($num -gt 3) )
        
    if ($num -eq 1)
    {
        #DoMove $resource.siteName $resource.siteRG $resource.farmRG
        Move-AzureRmResource -DestinationResourceGroupName $resource.farmRG -ResourceId $resource.siteResourceId

   #} 
   # elseif ($num -eq 2) {

        #DoMove($resource.farmName, $resource.farmRG, $resource.siteRG)
   #     Move-AzureRmResource -DestinationResourceGroupName $resource.siteRG -ResourceId $resource.farmResourceId
    
    } else {
        
        Write-Host ""
        Write-Host "Please reference "-NoNewline
        Write-Host "https://azure.microsoft.com/en-us/documentation/articles/resource-group-move-resources/" -ForegroundColor Yellow
        Write-Host ""

    }


}


function MoveResources($resourcesToMove)
{

    $resourcesToMove | ForEach-Object {
        $r = $_
        MoveResource($r)
    }

}

function PrintFindings($ProblemsFound)
{

    $ProblemsFound | ForEach-Object {
    

        $r = $_
        Write-Host "=== " -nonewline
        Write-Host "Site(" -nonewline
        Write-Host $($r.siteName) -ForegroundColor Yellow -nonewline
        Write-Host ") belongs to resource group " -nonewline
        Write-Host $r.siteRG -ForegroundColor Yellow -nonewline
        Write-Host ", but it's related App Service Plan(" -nonewline
        Write-Host $($r.farmName)  -ForegroundColor Yellow -nonewline
        Write-Host ") belongs to resource group (" -nonewline
        Write-Host $r.farmRG  -ForegroundColor Yellow -nonewline
        Write-Host ") === "
    }

}


##### Prerequisite/Make sure modules installed#######
#Check Azure module installed or not
InstallModule("AzureRM")
InstallModule("Azure")
InstallAzureRmPackage("AzureRM.Websites")


# Import AzureRM modules for the given version manifest in the AzureRM module
#Import-AzureRM

Import-Module AzureRM.Websites
Import-Module AzureRM.Profile
Import-Module AzureRM.Resources
# Import Azure Service Management module
Import-Module Azure


Write-Host "Azure Powershell module installed."

######## Login and Select Subscription ###########

# To login to Azure Resource Manager
Login-AzureRmAccount

# Select the subscription
SelectSourceSubscription($SubscriptionID)

$srvFarms = @{}
$webSites = @{}
$certs = @{}
$slots = @{}

$results = @()

$WebAppApiVersion = "2015-08-01"

GetWebApps
$results = AnalyzeWebAppsForMigration


#problems found
if (@($results).Count -gt 0)
{
    $moveNow = 'N'

    Write-Host @($results).Count -NoNewline -ForegroundColor Yellow
    Write-Host " problem(s) found!"
    Write-Host ""

    PrintFindings(@($results))
    
    [char]$moveNow = Read-Host "Do you want to move the resoruces now? Y/N？"

    if (($moveNow -eq 'Y') -or  ($moveNow -eq 'y'))
    {
        MoveResources(@($results))
    }
     

} else {
    Write-Host ""
    Write-Host "No issues found, Ready to migration!"
    Write-Host ""
}
