# M365Scripts: GET_ONEDRIVE_USAGE_REPORT

## PURPOSE: 
   
   This Script allows you to analyze the space used in the users onedrive, in several tenants..
   
## SYNTASIX: 
    
```sh
GET_ONEDRIVE_USAGE_REPORT.ps1
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
   * Find and check the checkboxes for "Files.Read.All", "User.Read.All". Press "Add Permission".
   * Select "Grant admin consent" and check that the status of the newly added permission is "granted".
   * Go back to "Azure Active Directory"
   * Select "Roles and administrators"
   * Search and select "Exchange Administrator"
   * Select "add assignments" and add the script name

   * Done. Repeat all of the above for each tenant to include in the CSV file.

3. Create a .csv file with the tenant data to analyze. Use the following format:

```sh
appid, tenant, organization
```

Example:
```sh
9c7c3e1g-9713-400e-8200-6b00a1007005, 1b072e34-123b-1cef-2c34-1d02b34c1d2d, mytenant1.onmicrosoft.com
1c2c3e4g-0123-123e-1234-1b23a1234567, 1b023e45-432b-4cef-4c32-6d54b32c3d1d, mytenant2.onmicrosoft.com
```

4. Modify the variables in the GET_ONEDRIVE_USAGE_REPORT.ps1 file in the PARAMETERS section.

| Variable         | Use
|------------------|-------------------------------
|$Tenants_Path     | Path to tenant list csv file
|                  |

5. Output Format

   * Tenant: Tenant name
   * Email: User email
   * DriveUsed: Space used on the user's Onedrive.
   * DriveTotal: Total space on the user's Onedrive.
   * DrivePercent: Percentage of space used on the user's Onedrive.

Output example:

|Tenant                    | Email                 | DriveUsed    | DriveTotal      | DrivePercent |
|--------------------------|-----------------------|--------------|-----------------|--------------|
|Mytenant.onmicrosoft.com  | user@mytenant.com     |  54.64       |  1024           |       5.34   |  
|                          |                       |              |                 |              |

