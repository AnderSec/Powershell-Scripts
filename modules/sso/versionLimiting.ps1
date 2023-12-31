#Import SharePoint Online PowerShell Module
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
  
#Set Parameters
$SiteURL="{TILFØJ SSO URL}"
$ListName="Documents"
$VersioningLimit = 100
 
#Get Credentials to connect
$Cred= Get-Credential
   
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
           
#Get the List - Versioning settings
$List = $Ctx.Web.Lists.GetByTitle($ListName)
$List.Retrieve("EnableVersioning")
$Ctx.ExecuteQuery()
          
#Set version history limit
If($List.EnableVersioning)
{
    $List.MajorVersionLimit = $VersioningLimit
    $List.Update()
    $Ctx.ExecuteQuery()
    Write-host -f Green "Version History Settings has been Updated on '$($ListName)'"
}
Else
{
    Write-host -f Yellow "Version History is turned-off on '$($ListName)'"
}
