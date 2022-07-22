# M365Scripts: GEN_CERT_PFX

## PURPOSE: 
   
   This Script generates a self-signed certificate and exports the .cer and .pfx files.

## SYNTASIX: 
    
```sh
GEN_CERT.PFX.ps1 -dnsname contoso.com -passowrd mypassword
```
    
## PARAMETERS:

   -dnsname     Domain name
   -password    Password to protect the certificate