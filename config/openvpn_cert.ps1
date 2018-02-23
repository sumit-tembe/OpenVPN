########## Export and Extract AD User Certificate and Key ##########

dir cert:\currentuser\my | 
  Where-Object { $_.hasPrivateKey } | 
  Foreach-Object { [system.IO.file]::WriteAllBytes(
    "$home\$env:username.pfx", 
    ($_.Export('PFX', 'gsLab123')) ) }

openssl pkcs12 -in "$home\$env:username.pfx" -nocerts -out "$home\key.pem"

openssl pkcs12 -in "$home\$env:username.pfx" -clcerts -nokeys -out "$home\$env:username.crt"

openssl rsa -in "$home\key.pem" -out "$home\$env:username.key"

remove-item -path "$home\$env:username.pfx" -force

remove-item -path "$home\key.pem" -force

# author GS-1283