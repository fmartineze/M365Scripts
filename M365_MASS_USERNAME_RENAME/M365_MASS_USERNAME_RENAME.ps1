<#
.NOTES
  This script allows you to bulk rename the email addresses of users in a Microsoft 365 tenant.
  
  Version:        0.1
  Author:		  F.Martínez
  Creation Date:  28/10/2022
  Links:		  https://github.com/fmartineze

. REQUIREMENTS

  * You need to have a .pfx certificate
  * Register an app in Azure Active Directory for each tenant. (Graph permisions: User.ReadWrite.All, User.ManageIdentities.All, Directory.ReadWrite.All)
  * Fill in a csv with the list of tenants in the following format: email, new_email (example: myusername@contoso.com, mynewusername@contoso.com).
#>

# --- Dependences

Import-Module Microsoft.Graph.Users

# --- Parameters

$csv_Path = ""                # CSV Path
$Tenantid = ""                # Tenant ID
$Clientid = ""                # Registered app - Clientid
$CertificateThumbprint = ""   # Registered app - Certificate Thumbprint

# --- SCRIPT --- 

$csv_users = Import-Csv -Path $csv_Path -Header email, new_email
Connect-MgGraph -ClientId $ClientId -TenantId $Tenantid -CertificateThumbprint $CertificateThumbprint

foreach ($csv_user in $csv_users){
    try{
        $user = Get-MgUser -UserId $csv_user.email -ErrorAction silentlycontinue
        $params = @{
            userPrincipalName = $csv_user.new_email
        }
        Update-MgUser -UserId $user.Id -BodyParameter $params
        Write-Host "[*] Renamed [$($csv_user.email)] as [$($csv_user.new_email)]."
    }
    catch {
        Write-Host "[!] ERROR: Renaming [$($csv_user.email)]"
    }  
}

Disconnect-MgGraph

