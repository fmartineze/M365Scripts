# M365Scripts: GET_ONEDRIVE_USAGE_REPORT

## PURPOSE: 
   
   This script allows you to bulk rename the email addresses of users in a Microsoft 365 tenant.
   
## SYNTASIX: 
    
```sh
M365_MASS_USERNAME_RENAME.ps1
```
## REQUIREMENTS
   
   You need to have the following modules installed:
   * Microsoft.Graph
   ```sh
   Install-Module Microsoft.Graph -Repository PSGallery -AllowClobber -Force
   ```

## CONFIGURE

1. Generate a .pfx certificate

   For this purpose you can use the [GEN_CERT_PFX](https://github.com/fmartineze/M365Scripts/tree/main/GET_CERT_PFX) script.

2. Register an app in Azure Active Directory for each tenant.

   * Go to [Azure portal](https://portal.azure.com/).
   * Open "Azure Active Directory"
   * Open "App Registration"
   * Select "New Registration"
   * Write the app name, select "Accounts in this organization directory only - (Single Tenant)
   * Select "Register"
   * Take the application id indicated in "Application Id (Client)"  to use it in the CSV
   * Take the tenant id indicated in "Directory Id (Tenant)"  to use it in the CSV
   * Go to "Certificates & Secrets"
   * Select "Certificates","Upload certificate" and add your .cer certificate file
   * Take the digital footprint of the newly uploaded certificate,  to use it in the CSV
   * Go to "API Permissions"
   * Select "+ Add permission"
   * Select "Microsoft Graph"
   * Select "Aplicatión Permission" (Right Box)
   * Find and check the checkboxes for "User.ReadWrite.All", "User.ManageIdentities.All", "Directory.ReadWrite.All"
   * Select "Grant admin consent" and check that the status of the newly added permission is "granted".
   * Go back to "Azure Active Directory"
   * Select "Roles and administrators"
   * Search and select "Exchange Administrator"
   * Select "add assignments" and add the script name

   * Done. Repeat all of the above for each tenant to include in the CSV file.

3. Create a .csv file with the tenant data to analyze. Use the following format:

```sh
user_email, new_user_email
```

Example:
```sh
myusername@contoso.com, mynewusername@contoso.com
secondusername@contoso.com, newsecondusername@contoso.com

```

4. Modify the variables in the GET_ONEDRIVE_USAGE_REPORT.ps1 file in the PARAMETERS section.

| Variable               | Use
|------------------------|-------------------------------
|$csv_Path               | CSV Path
|$Tenantid               | Tenant ID
|$Clientid               | Registered app - Clientid
|$CertificateThumbprint  | Registered app - Certificate Thumbprint

