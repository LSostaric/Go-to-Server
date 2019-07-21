#!/bin/bash
if [ -n "$2" ] ; then
    if [ "$2" != "root" ] ; then
        echo "Invalid argument \"$2\"! Terminating..."
        exit 2
    fi
fi
echo "Test" | expect 2> /dev/null
if [ $? -eq 127 ] ; then
    echo "Expect is not installed on your system! Terminating..."
    exit 1
fi
while IFS=";" read name ipa uname pass supass suc opt
do
    if [ "$name" = "$1" ] ; then
        ipaddress="$ipa"
        username="$uname"
        password="$pass"
        superpass="$supass"
        sucommand="$suc"
        options="$opt"
    fi
done < "$DF"

if [ -z "$username" ] || [ -z "$ipaddress" ] ; then

        echo "Unknown server specified. Terminating..."
        exit 1

fi

echo "#!/usr/bin/expect
trap {
 set rows [stty rows]
 set cols [stty columns]
 stty rows \$rows columns \$cols < \$spawn_out(slave,name)
} WINCH
spawn ssh "$options" -o StrictHostKeyChecking=no $username@$ipaddress
expect -timeout -1 \"*assword\"
send -- \"$password\r\"
if {{$2}=={root}} {
    expect \"*\$*\"
    send -- \"$sucommand\r\"
    expect \"*assword\"
    send -- \"$superpass\r\"
}
interact" > "$HOME/.go-to-server-winch-$(whoami)"
chmod 700 "$HOME/.go-to-server-winch-$(whoami)"
expect -f "$HOME/.go-to-server-winch-$(whoami)"
rm -f "$HOME/.go-to-server-winch-$(whoami)"
