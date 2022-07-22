<#
.NOTES
  This Script allows you to analyze the space used in the mailboxes of different tenants.
  Generates a report of the mailboxes with a use greater than that indicated in $SizeLimit and exports an analysis of each affected mailbox in csv.

  Version:        1.0
  Author:		  F.Martínez
  Creation Date:  16 Jun 2022
  Links:		  https://github.com/fmartineze

. REQUIREMENTS

  * You need to have a .pfx certificate
  * Register an app in Azure Active Directory for each tenant.
  * Fill in a csv with the list of tenants in the following format: appid, tenant, organization (example: 9c7c3e1g-9713-400e-8200-6b00a1007005,mytenant.onmicrosoft.com,My Organization Name )
#>

# --- PARAMETERS ---

$Cert_Path = ".\mycert.pfx"					# Path to pfx certificate
$Cert_Pass = "mypassword"					# Certificate password
$Tenants_Path = ".\tenants.csv"				# Tenant list csv
$ExportPath = ".\exports\"					# Path to export results
$SizeLimit = 40								# Minimum mailbox size to filter.
$OnlyThisTenant = ""						# Indicate the name of the tenant, in case you wish to carry out the analysis of only one of those indicated in the csv file.

# --- SCRIPT --- 

$tenants = Import-Csv -Path $Tenants_Path -Header AppID,Organization,Name
$output = @()

if ( $ExportPath.Length -gt 0){				# Test Export Path
	if (( $ExportPath.substring($ExportPath.Length -1) -eq "\") -or ( $ExportPath.substring($ExportPath.Length -1) -eq "/")){
		Write-Host "Export Path: $($ExportPath)"
	}else{
		Write-Host "PATH ERROR: $($ExportPath.substring($ExportPath.Length -1))"	
		Break		
	}
	
}


foreach ($item in $tenants){
	if (( $OnlyThisTenant -ieq $item.Organization) -or ($OnlyThisTenant -eq "")){
		Write-Host "### $($item.Organization)"
		.\GET_MAILBOX.ps1 -organization $item.Organization -ADAppID $item.AppID -CertPath $Cert_Path -CertPassword $Cert_Pass -path "$($ExportPath)export.csv"
		$csv = Import-Csv -Path "$($ExportPath)export.csv"
		Connect-ExchangeOnline -CertificateFilePath $Cert_Path -CertificatePassword $(ConvertTo-SecureString -String $Cert_Pass -AsPlainText -Force) -AppId $item.AppID -Organization $item.Organization  -ShowBanner:$false #Connect to retrieve mailbox Statics
		$output += ForEach ($row in $csv){
			if ( [decimal]::Parse($row.TotalSizeGB) -gt $SizeLimit) {			
				
				#Generate a HashTable with oversize mailboxes
				[pscustomobject]@{
					"Tenant" = $row.Tenant
					"AppID" = $item.AppID
					"DisplayName" = $row.DisplayName
					"Email" = $row.Email
					"MailBoxUsedGB" = $row.TotalSizeGB
					"ArchiveBoxUsedGB" = $row.ArchiveSizeGB
				}
				
				#Export statistics of oversized mailbox			
				Get-MailboxFolderStatistics $row.Email | Select-Object -Property FolderPath, FolderSize, FolderAndSubfolderSize  | Export-Csv "$($ExportPath)$($row.Email).csv" 
			}
		}
		Disconnect-ExchangeOnline -Confirm:$false
		Remove-Item "$($ExportPath)export.csv"
	}
}
$output | Format-Table
$output | Export-Csv "$($ExportPath)Oversized_mailboxex_report.csv"

