fconfigure stdout -translation {auto crlf}

set FormattedQsos []
proc q {band time call ser} {
  global M Q Date LastTime FormattedQsos MySer
  if {[string length $time] == 2} {
    if [regexp {^(.*[:])..$} $LastTime - hr] {
      set time $hr$time
    } else {
      error "BAD TIME: $LastTime"
    }
  }
  if ![regexp {^[0-9][0-9][:][0-9][0-9]$} $time] {
    error "BAD time: $time"
  }
  set LastTime $time
  set s [clock scan "$Date $time" -gmt true]
  set dt [clock format $s -format "%Y-%m-%d %H%M" -gmt true]

  incr MySer
  set fq [format "QSO: %5s PH %17s   W6REK 59 %4d  %10s 59 %4d" $band $dt $MySer $call $ser]
  lappend FormattedQsos [string toupper $fq]
}
proc 6 {time call ser} { q 50 $time $call $ser}
proc 10 {time call ser} { q 28000 $time $call $ser}
proc 15 {time call ser} { q 21000 $time $call $ser}
proc 20 {time call ser} { q 14000 $time $call $ser}
proc 40 {time call ser} { q 7000 $time $call $ser}
proc 80 {time call ser} { q 3500 $time $call $ser}

set Date 2018-03-25
set MySer 0

20 01:11 kh7xs 2973
20 15 wi0wa 1414
20 21 ko0a 518
20 23 n5jj 401
20 28 cb1a 813
20 32 ti7w 2914
20 37 wd5k 904
20 49 nh7a 2007
20 53 k5lla 579
20 55 w5ct 1249
20 02:01 w0bt 29

40 02:13 aa5b 932
40 16 n7mzw 341
40 18 w2rd 321
40 20 n5it 341
40 26 nc7m 1007

40 31 aa4aq 1670
40 56 nv7j 314
40 58 kd7rf 930
40 03:00 ki6rrn 974
40 05 ve6wzl 702
40 06 wn6k 542
40 08 ad5xd 1439
40 10 wr5j 1319
40 15 ki7rvf 299

40 19 ad5xd 1450
40 21 kk7pr 540
40 23 ag4w 1030
40 24 nk7l 761

40 08:15 ww4ll 1367
40 18 km5vi 1100

80 08:22 ku1cw 566
80 23 nd8dx 918
80 09:19 ww4ll 696
80 22 wr5j 1609
80 24 nl8f 180
80 25 nr6o 50

15 19:10 n8cwu 179
15 20 nh7a 2720

10 19:25 yv1kk 799
10 31 px2a 323
10 33 pj2t 675
10 35 4m6r 411
10 47 yw4v 86

###############################################################

fconfigure stdout -translation crlf
puts "START-OF-LOG: 3.0
Created-By: https://github.com/strickyak/ham-cabrillo-py
CONTEST: CQ-WPX-SSB
CALLSIGN: W6REK
LOCATION: SCV
X-ARRL-SECTION: SCV
CATEGORY-OPERATOR: MULTI-OP
CATEGORY-STATION: FIXED
CATEGORY-TRANSMITTER: ONE
CATEGORY-POWER: HIGH
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-BAND: ALL
CATEGORY-MODE: SSB
OPERATORS: W6REK W4TCP
CERTIFICATE: YES
NAME: Henry Strickland
ADDRESS: 1215 Monte Sano Ave Apt 1
ADDRESS-CITY: Augusta
ADDRESS-STATE-PROVINCE: Georgia
ADDRESS-POSTALCODE: 30904
ADDRESS-COUNTRY: USA
EMAIL: strick@yak.net
[join $FormattedQsos "\n"]
END-OF-LOG:"
