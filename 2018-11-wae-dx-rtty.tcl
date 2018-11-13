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
  set fq [format "QSO: %5s RY %17s   W6REK 599 %03d  %10s 599 %03d" $band $dt $MySer $call $ser]
  lappend FormattedQsos [string toupper $fq]
}
proc 6 {time call ser} { q 50 $time $call $ser}
proc 10 {time call ser} { q 28000 $time $call $ser}
proc 15 {time call ser} { q 21000 $time $call $ser}
proc 20 {time call ser} { q 14000 $time $call $ser}
proc 40 {time call ser} { q 7000 $time $call $ser}
proc 80 {time call ser} { q 3500 $time $call $ser}

set Date 2018-11-10
set MySer 0

20 23:28 k2dsw 262
20 32 kn5s 138
40 44 w9ily 87
40 47 ad4xd 535
40 57 k0fx 290

set Date 2018-11-11

40 00:07 k2dsw 296
40 12 px2a 826
40 16 ko7ss 568
40 18 k6mmm 270
40 23 ve7io 164
40 05:09 kl7sb 251 
80 14 k6mmm 309
80 23 va7st 189


###############################################################

fconfigure stdout -translation crlf
puts "START-OF-LOG: 3.0
Created-By: https://github.com/strickyak/ham-cabrillo-py
CONTEST: DARC-WAEDC-RTTY
CALLSIGN: W6REK
LOCATION: SCV
X-ARRL-SECTION: SCV
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-STATION: FIXED
CATEGORY-TRANSMITTER: ONE
CATEGORY-POWER: HIGH
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-BAND: ALL
CATEGORY-MODE: RTTY
OPERATORS: W6REK
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
