<#
.NOTES
  This Script generate .cer and .pfx certificate files

  Version:        1.0
  Author:		  F.Martínez
  Creation Date:  21 Jul 2022
  Links:		  https://github.com/fmartineze

. SYNTAXIS

  GEN_CERT.PFX.ps1 -dnsname contoso.com -passowrd mypassword
  
. OUTPUT

  Generate .cer and .pfx file with datetime in filename.

#>

param(
  
  [Parameter(
    Mandatory = $true,
    HelpMessage = "Dns Name (Example: mydomain.com)"
  )]
  [string]$dnsname,
  
  [Parameter(
    Mandatory = $true,
    HelpMessage = "Certificate Password"
  )]
  [string]$password
  
)

$filename = $((Get-Date).ToString("yyyyMMdd_HHmmss"))

$newCertSplat = @{
	DnsName = $dnsname
	CertStoreLocation = 'cert:\CurrentUser\My'
	NotAfter = (Get-Date).AddYears(50)
	KeySpec = 'KeyExchange'
}
$mycert = New-SelfSignedCertificate @newCertSplat

# Exportar a .pfx
$exportCertSplat = @{
	FilePath = "$($filename).pfx"
	Password = $(ConvertTo-SecureString -String $password -AsPlainText -Force)
}
$mycert | Export-PfxCertificate @exportCertSplat

# Export a .cert
$mycert | Export-Certificate -FilePath "$($filename).cer"