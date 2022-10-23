<#
.NOTES
  This Script allows you to analyze the space used in the users onedrive, in several tenants.
  
  Version:        1.0
  Author:		  F.Martínez
  Creation Date:  23/10/2022
  Links:		  https://github.com/fmartineze

. REQUIREMENTS

  * You need to have a .pfx certificate
  * Register an app in Azure Active Directory for each tenant.
  * Fill in a csv with the list of tenants in the following format: $, app_id, digital_foot_print, tenant_name (example: 9c7c3e1g-9713-400e-8200-6b00a1007005, 1b072e34-123b-1cef-2c34-1d02b34c1d2d, mytenant.onmicrosoft.com).
#>

# --- Dependences

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Files

# --- Parameters

$Tenants_Path = ".\tenants.csv"				# Tenant list csv

# --- Functions

Function Get-OnedriveUsage {
<#
		.SYNOPSIS
			Return size of the current folder and its subfolders
	#>
	param(
	  [Parameter(
		Mandatory = $true
	  )]
	  [string]$ClientId,

	  [Parameter(
		Mandatory = $true
	  )]
	  [string]$TenantId,

	  [Parameter(
		Mandatory = $true
	  )]
	  [string]$CertificateThumbprint,

	  [Parameter(
		Mandatory = $true
	  )]
	  [string]$TenantName

	)
	process {
		Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint
		$users = Get-MgUser
	
		foreach ($user in $users){

			# Get Onedrive storage info
			try{
				$drive = Get-MgUserDrive -UserId $user.Id  -ErrorAction Stop
				$drive_used = [math]::round($drive.Quota.Used  /1Gb,2)
				$drive_total = [math]::round($drive.Quota.Total   /1Gb,2)
				$drive_percent = [math]::round( ($drive_used * 100) / $drive_total , 2)
			}
			catch {
				$drive_used = 0
				$drive_total = 0
				$drive_percent = 0
			}

			# Add row to result.
			[pscustomobject]@{
				"Tenant" = $TenantName
				"Email" = $user.UserPrincipalName
				"DriveUsed" = $drive_used
				"DriveTotal" = $drive_total
				"DrivePercent" = $drive_percent			
			}
			
		}
		
		Disconnect-MgGraph
	}	
}

# --- SCRIPT --- 

$tenants = Import-Csv -Path $Tenants_Path -Header tenant_id, app_id, app_value, tenant_name
$stats = $null
foreach ($item in $tenants){
		Write-Host "# Analyzing: [$($item.tenant_name)]"	
		$stats += Get-OnedriveUsage -ClientId $item.app_id -TenantId $item.tenant_id -CertificateThumbprint  $item.app_value -TenantName $item.tenant_name
}
$stats | Format-Table -AutoSize


