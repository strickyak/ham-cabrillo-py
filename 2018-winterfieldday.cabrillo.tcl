fconfigure stdout -translation {auto crlf}

set FormattedQsos ""
proc q {band time call class loc points} {
  global M Q Date LastTime FormattedQsos
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
  set s [clock scan "$Date $time" -gmt false]
  set dt [clock format $s -format "%Y-%m-%d %H%M" -gmt true]
  set key [string toupper "$band-$call"]
  set mult [string toupper "$band-PH"]
  incr M($mult)
  incr Q($key) $points

  if {$Q($key) != $points} {
    puts stderr "DUP: $band $time $call $grid" 
    incr Q($key) -$points
  }

  set fq [format "QSO: %5s PH %17s   W6REK/R 1H SCV  %10s %2s %4s" $band $dt $call $class $loc]
  lappend FormattedQsos [string toupper $fq]
}
proc 6 {time call class loc} { q 50 $time $call $class $loc 1}
proc 20 {time call class loc} { q 14000 $time $call $class $loc 1}
proc 40 {time call class loc} { q 7000 $time $call $class $loc 1}
proc 80 {time call class loc} { q 3500 $time $call $class $loc 1}

#####  TEMPLATE  ##########################################################
#QSO:  3750 PH 2017-01-07 1911 W8D           1O  OH     WB9XXX        2H  IL
#QSO:  7030 CW 2017-01-07 2021 W8D           1O  OH     K8UO          14I MI
#QSO: 14070 DI 2017-01-07 2131 W8D           1O  OH     K6XXX         14I LA

set Date 2018-01-27
20 23:45 aj0se 1h scv
20 23:46 n7mzw 1h wy
20 23:49 ww1usa 4i mo
6 23:59 kg6xf 1d scv

set Date 2018-01-28
20 00:03 n5cst 1i ok
20 08 nf6jc 1o pac
20 12 af5eh 1h ntx
20 15 w5mco 1h nm
20 19 w4ta 3o wcf
20 19 k0xe 1h co
20 22 kc7xe 1h scv
40 01:12 n7q 4o az
40 20 w5sh 5o ntx
40 23 k7car 1o az
40 24 ka0gn 1h co
40 26 n5hei 1h wwa
40 28 n7djd 1h ut
40 30 ve6voo 1i ab
40 31 wm7l 1h or
40 34 ve7fei 1h bc
40 36 va7rer 2o bc
80 02:01 kg7vi 1o nv
80 02:11 w6ze 4o org

###############################################################

foreach q [array names Q] {incr qscore $Q($q)}
foreach m [array names M] {incr mults 1}
foreach g [array names RoverGrids] {incr mults 1}

set PowerMult 2
set Score [expr {[array size Q] * [array size M] * $PowerMult}]

puts "
START-OF-LOG: 3.0
Created-By: https://github.com/strickyak/ham-cabrillo-py
CONTEST: WFD
CALLSIGN: W6REK
LOCATION: SCV
ARRL-SECTION: SCV
CATEGORY: 1H
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-STATION: FIXED
CATEGORY-TRANSMITTER: ONE
CATEGORY-POWER: LOW
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-BAND: ALL
CATEGORY-MODE: SSB
SOAPBOX: Number of QSOs: [array size Q]
SOAPBOX: Number of Multipliers: [array size M] = [array names M]
SOAPBOX: Power Multiplier: $PowerMult
SOAPBOX: BONUS Total 0
CLAIMED-SCORE: $Score
OPERATORS: W6REK
NAME: Henry Strickland
ADDRESS: 1215 Monte Sano Ave Apt 1
ADDRESS-STATE: Georgia
ADDRES-POSTALCODE: 30904
ADDRESS-COUNTRY: USA
EMAIL: strick@yak.net
[join $FormattedQsos "\n"]
END-OF-LOG:
"
