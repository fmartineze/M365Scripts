# M365Scripts: EXO_OVERSIZED_REPORT

## PURPOSE: 
   
   This Script allows you to analyze the space used in the mailboxes of different tenants.
   Generates a report of the mailboxes with a use greater than that indicated in $SizeLimit and exports an analysis of each affected mailbox in csv.

## SYNTASIX: 
    
```sh
GET_OVERSIZED_MAILBOXES.ps1
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
   * Take the application id indicated in "Application (Client) ID), to use it in the CSV
   * Go to "Certificates & Secrets"
   * Select "Certificates","Upload certificate" and add your .cer certificate file
   * Go to "API Permissions"
   * Select "+ Add permission"
   * Select "APIs used in my organization" and search for "Office 365 Exchange Online".
   * Select "Aplicatión Permission" (Right Box)
   * Search and mark the check box of "Exchange.ManageAsApp". Press "Add Permission".
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
1a2b3c4d-9713-400e-8200-6b00a1007005,mytenant1.onmicrosoft.com,My First Organization Name
4a5b6c7d-8783-001e-2230-4b50a1607707,mytenant2.onmicrosoft.com,My Second Organization Name
```

4. Modify the variables in the GET_OVERSIZED_MAILBOXES.ps1 file in the PARAMETERS section.

| Variable       | Use
|----------------|-------------------------------
|$Cert_Path      | Path to pfx certificate
|$Cert_Pass      | Certificate password
|$Tenants_Path   | Tenant list csv
|$ExportPath     | Path to export results
|$SizeLimit      | Minimum mailbox size to filter.
|$OnlyThisTenant | Indicate the name of the tenant, in case you wish to carry out the analysis of only one of those indicated in the csv file.
|                |

