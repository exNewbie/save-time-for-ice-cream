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
    useradd -s /bin/bash -m trungly -G sudo
  fi

else
  echo "Unknown distro"
fi

mkdir ~trungly/.ssh

echo 'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAG1TB3Be57eKrBAnb0lhOdMlCHGt55j4bIBQ03rl6h707PSh4UJ3RbuZsjjGlyGWvePdhhlnfEKlEcuod8fHNPfnQAxLlzh3ETabMikkx7G6VLmU8luJO8fgwDF8UYmxXre/H6stxrg1in8KtLuo4rypQgOkExwxF6LwBTfjHX8e8eq2g==' > ~trungly/.ssh/authorized_keys

chown trungly ~trungly/.ssh -R
chmod 700 ~trungly/.ssh
chmod 600 ~trungly/.ssh/authorized_keys
passwd -S trungly
