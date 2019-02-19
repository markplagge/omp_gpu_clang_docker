#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${USERID:-9001}
USER_NAME=${UNAME}

echo "Starting with UID : $USERID"
echo "creating shared folder in: $HOME"
useradd --shell /bin/bash -g users -G wheel -u $USERID -o -c ""  $UNAME
mkdir "/home/$UNAME"
export HOME="/home/$UNAME"

echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#echo 'sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
echo "gosu cmd:echo"

exec /usr/local/bin/gosu ${USERID} bash -l
pip install tensorflow-gpu
pip3 install tensorflow-gpu
export HOME="/home/$UNAME"

