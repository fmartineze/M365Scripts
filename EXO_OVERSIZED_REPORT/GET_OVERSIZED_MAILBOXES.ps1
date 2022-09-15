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

$Cert_Path = ".\cert\mycert.pfx"			# Path to pfx certificate
$Cert_Pass = "MyCertPassword"				# Certificate password
$Tenants_Path = ".\tenants.csv"				# Tenant list csv
$ExportPath = ".\exports\"					# Path to export results
$SizeLimitPercent = 80						# Minimum used mailbox space percent to filter
$OnlyThisTenant = ""						# Indicate the name of the tenant, in case you wish to carry out the analysis of only one of those indicated in the csv file.

# -- FUNCTIONS ---
Function ConvertTo-Gb {
	<#
	  .SYNOPSIS
		  Convert mailbox size to Gb for uniform reporting.
	#>
	param(
	  [Parameter(
		Mandatory = $true
	  )]
	  [string]$size
	)
	process {
	  if ($size -ne $null) {
		$value = $size.Split(" ")
  
		switch($value[1]) {
		  "GB" {$sizeInGb = ($value[0])}
		  "MB" {$sizeInGb = ($value[0] / 1024)}
		  "KB" {$sizeInGb = ($value[0] / 1024 / 1024)}
		}
  
		return [Math]::Round($sizeInGb,2,[MidPointRounding]::AwayFromZero)
	  }
	}
}
function Get-MailBoxStats {
	process {
		# CONNECT to M365
		if ((Get-Module -ListAvailable -Name ExchangeOnlineManagement) -ne $null)  {
			Connect-ExchangeOnline -CertificateFilePath $Cert_Path -CertificatePassword $(ConvertTo-SecureString -String $Cert_Pass -AsPlainText -Force) -AppId $item.AppID -Organization $item.Organization  -ShowBanner:$false -ShowProgress:$false
		} else {
			Write-Error "[!] Please install EXO v2 module."
		}
		
		#Get Mailboxe list
		$mailboxes = Get-EXOMailbox -ResultSize unlimited -RecipientTypeDetails "UserMailbox,SharedMailbox" -Properties IssueWarningQuota, ProhibitSendReceiveQuota, ArchiveQuota, ArchiveWarningQuota, ArchiveDatabase | select UserPrincipalName, DisplayName, PrimarySMTPAddress, RecipientType, RecipientTypeDetails, IssueWarningQuota, ProhibitSendReceiveQuota, ArchiveQuota, ArchiveWarningQuota, ArchiveDatabase 
		
		# Get and compare the size of each mailbox
		$mailboxes | foreach {
			
			$mbsize = Get-MailboxStatistics -identity $_.UserPrincipalName | Select TotalItemSize,TotalDeletedItemSize,ItemCount,DeletedItemCount,LastUserActionTime
			
			if ($mbsize -ne $null){
				$username = $_.DisplayName
				$archivesizereport = $null
				$mb_archivesize = 0

				#Get archive mailbox size
				if ($_.ArchiveDatabase -ne $null){
					$archivesizereport = Get-EXOMailboxStatistics -UserPrincipalName $_.UserPrincipalName -Archive | Select ItemCount,DeletedItemCount,@{Name = "TotalArchiveSize"; Expression = {$_.TotalItemSize.ToString().Split("(")[0]}}
					
					if ($archivesizereport -ne $null){
						$mb_archivesize = ConvertTo-Gb -size $archivesizereport.TotalArchiveSize
					} else {
						$mb_archivesize = 0
					}
				}

				$mb_percent_usage = [int]((100 * [int]( ConvertTo-Gb -size $mbsize.TotalItemSize.ToString().Split("(")[0] )) / [int]($_.ProhibitSendReceiveQuota.ToString().Split("GB")[0]))
				$mb_archive_percent_usage = [int]((100 * $mb_archivesize) / [int](ConvertTo-Gb -size $_.ArchiveQuota.ToString().Split("(")[0]))

				# Generate Reports in case the size exceeds the determined in SizeLimitPercent
				if (([int]$mb_percent_usage -gt $SizeLimitPercent) -or ([int]$mb_archive_percent_usage -gt $SizeLimitPercent))
				{
					# Add row to result.
					[pscustomobject]@{
						"Tenant" = $item.Organization
						"DisplayName" = $_.DisplayName
						"Email" = $_.PrimarySMTPAddress
						"MailboxType" = $_.RecipientTypeDetails
						"LastUserActionTime" = $mbsize.LastUserActionTime
						"MailboxUsedGB" = ConvertTo-Gb -size $mbsize.TotalItemSize.ToString().Split("(")[0]
						"MailboxTotalGB" = $_.ProhibitSendReceiveQuota.ToString().Split("GB")[0]
						"MailboxUsedPercent" = $mb_percent_usage.ToString()
						"ArchiveUsedGB" = $mb_archivesize
						"ArchiveTotalGB" = ConvertTo-Gb -size $_.ArchiveQuota.ToString().Split("(")[0]
						"ArchiveUsedPercent" =  $mb_archive_percent_usage
					}			

					# Export .csv with the account details
					Get-MailboxFolderStatistics $_.PrimarySMTPAddress -Archive | Select-Object -Property FolderPath, FolderSize, FolderAndSubfolderSize  | Export-Csv "$($ExportPath)$($_.PrimarySMTPAddress).csv" 
				}

			}
			
		}

		# Disconect from M365
		Disconnect-ExchangeOnline -Confirm:$false
	}
}


# --- SCRIPT --- 

$tenants = Import-Csv -Path $Tenants_Path -Header AppID,Organization,Name
$output = @()

if ( $ExportPath.Length -gt 0){				# Test Export Path
	if (( $ExportPath.substring($ExportPath.Length -1) -eq "\") -or ( $ExportPath.substring($ExportPath.Length -1) -eq "/")){
		Write-Host "Export Path: $($ExportPath)"
	}else{
		Write-Host "[!] PATH ERROR: $($ExportPath.substring($ExportPath.Length -1))"	
		Break		
	}
	
}

Remove-Item "$($ExportPath)*.csv" # Remove old csv files

$stats = $null
foreach ($item in $tenants){
	if (( $OnlyThisTenant -ieq $item.Organization) -or ($OnlyThisTenant -eq "")){
		Write-Host "# Analyzing: [$($item.Organization)]"		
		$stats += Get-MailBoxStats
	}
}

# Show and export data obtained
$stats | Format-Table -AutoSize
$stats | Export-Csv "$($ExportPath)mailboxex_report.csv"
