#!/bin/bash

dn="cn=users,dc=vpn,dc=local"	#change dc depending upon you AD domain
ad_host="10.136.60.58"			#Windows AD IP
ad_domain="vpn.local"			#Windows AD domain


if [ "${username,,}" != "${common_name,,}" ]; then
   echo "$(date) | $username : DENIED  username [$username] and cert [$common_name] does not matched" >> /etc/openvpn/access.log
   exit 1
fi

user=`ldapsearch -x -h $ad_host -b $dn -D "$username@$ad_domain" -w $password -s sub \
-b $dn "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$username))" "dn" | grep 'numEntries:'`
if [ -z "$user" ]
then
    echo "$(date) | $username : Invalid password " >> /etc/openvpn/access.log
    exit 1
fi

echo "$(date) | $username : connected" >> /etc/openvpn/access.log
exit 0
