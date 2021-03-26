#!/bin/bash

DISTRO_PROC=$( cat /proc/version | awk '{print tolower($0)}' )
DISTRO_RELEASE=$( cat /etc/*release | awk '{print tolower($0)}' )

if [[ ${DISTRO_PROC} = *"red"* || ${DISTRO_PROC} = *"hat"* || ${DISTRO_RELEASE} = *"centos"* || ${DISTRO_RELEASE} = *"rhel"* ]]; then
  echo "Red Hat Family"

  #sudo
  sed -i '/NOPASSWD/c\%wheel    ALL=(ALL)    NOPASSWD: ALL' /etc/sudoers

  #User
  if ! cat /etc/passwd | grep trungly > /dev/null ; then
     useradd -m trungly -G wheel
  fi

elif [[ ${DISTRO_PROC} = *"ubuntu"* || ${DISTRO_RELEASE} = *"ubuntu"* || ${DISTRO_RELEASE} = *"debian"* ]]; then
  echo "Debian Family"

  #User
  if ! cat /etc/passwd | grep trungly > /dev/null ; then
    useradd -s /bin/bash -m trungly -G sudo; 
  fi

else
  echo "Unknown distro"
fi

mkdir ~trungly/.ssh

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0DPDW4FnlN+VNFuSaeyOUCjXbXdWPg94ZElG+AzVHm6DrUpdSDOXHyjsjJWW75Ws6DPNDdV1Sf294gWfsXjIbxdOZsfHBE4huJ19TX1L0JaZTtQ+kcSwSLnFdjGegRCt2wn190p8U2klZAqkccnOGh8o68TE0iiAnEkmc0C9kxmevUNrWSFXWTkhp+zKVx9io3s/rDcAHriVhy3nfhM5O+z0MTkLkmwkh9q+9KuinqbOw6U3HclXdGBzF65anNZYaKznLuqL3w0p5Bl59vf8alwWY+YuH7yAaHTEPAhyq/Hna4xijeDeq7pHHIWj+oouZLa2+b655JSSmyqgoYSJKKMFdjDkvfBOVJ6a57j/0kzpOnziZUraIC8QnViHk6Zr9hnPXHPpFm+SHFJvZipRnKyjgOiUnZYcpzuyTguK8yIY2nQCLsdkEePGwNcz1lgZqFv85QTcK7kVCP98LIvVgpPLlGzTT/FgAmHx47YMISBtftHZO1gJw6j+DaJ7lG7R2DdmXFeA6YEwnNjS77fJmz3P8PNe4Gs5/ZV2XaisjiD7RLaHI/2RCwaUNzQfBCWmHtRXaIf34RLleM1CQzhntjS3Z0JfBevzj59mOAhPMJU98yb6RA9eByzr5a8bvJDglod4aYzVXNIm1ouPTvP5zzRuCXClY0QkEN0wU0ocTEQ==' > ~trungly/.ssh/authorized_keys

chown trungly ~trungly/.ssh -R
chmod 700 ~trungly/.ssh
chmod 600 ~trungly/.ssh/authorized_keys
passwd -S trungly
