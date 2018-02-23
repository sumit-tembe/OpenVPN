# OpenVPN

This document assumes OpenVPN Server is already installed and configured (minimum two)
If not Follow the given link - https://help.ubuntu.com/lts/serverguide/openvpn.html

Step 1: Set Up CA in Windows AD

    Follow the given doc - Setting Up a Certification Authority.docx	

Step 2: Create new Certificate template for VPN connection

    Follow the given doc - Creating a new certificate template for User certificates.docx

Step 3: Configure User certificate Auto-Enrollment

    Follow the given doc - Auto-Enrollment.docx

Step 4: Export CA certificate

    Follow the given doc - Export CA Certificate.docx

Step 5: Export User certificate

    Follow the given doc - Export AD cert _ key.docx

Step 6: Modify OpenVpn to use AD CA certificates.

Copy windows AD ca certificate which we exported in step 5 in /etc/openvpn directory.
Export administrator or any other user certificate and key, by following step 6 and then copy the same in /etc/openvpn directory.
Edit /etc/openvpn/server.conf file to change following - 

	ca RootCA.crt		#Windows AD CA certificate
    cert administrator.crt	#Windows AD administrator certificate
    key administrator.key	#Windows AD administrator key

Step 7: User authentication and certification validation.

    Username and Password authentication
    /etc/openvpn/server.conf
    username-as-common-name
	script-security 3
	auth-user-pass-verify /etc/openvpn/scripts/auth.sh via-env

Certificate verification (Script to ensure users using only his/her creds and cert to access openvpn and user creds validation)
    
/etc/openvpn/scripts/auth.sh

    #!/bin/bash

    dn="cn=users,dc=vpn,dc=local"	#Change dc depends upon your AD domain
    ad_host="10.136.60.58"		#Windows AD IP
    ad_domain="vpn.local"		#Windows AD domain

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

Step 8: Setup OpenVpn server in HA (Active-Passive mode)

Assuming you have two OpenVpn servers already configured.
Follow the given doc - HA Virtual IP (keepalived).docx

    Change in /etc/openvpn/server.conf:-
	local <your Virtual HA ip>	#Change it with your HA Virtual IP

Restart OpenVpn Server:-

    $ service openvpn@server restart

Step 9: Change client ovpn file 

    remote <your Virtual HA ip> 1194
    Add auth-user-pass
    #Use AD certificates
	ca RootCA.crt		#Windows AD CA certificate
    cert administrator.crt	#Windows AD User certificate
    key administrator.key	#Windows AD User key

Comment ns-cert-type server

	#ns-cert-type server

Step 10: Ensure User will get same IP from both OpenVpn servers

Follow the given doc - How To Set Up and Configure NFS on Ubuntu 16.04.docx

    Step 11: Restart the OpenVpn server
    $ service openvpn@server restart
