puts {
START-OF-LOG: 3.0
CONTEST: ARRL-VHF-JUN
CALLSIGN: W6REK
LOCATION: SCV
OPERATORS: W6REK
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-BAND: VHF-3-BAND
CATEGORY-MODE: MIXED
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-POWER: LOW
CATEGORY-STATION: FIXED
CATEGORY-TRANSMITTER: ONE
CLAIMED-SCORE:
SOAPBOX: This contest was fun, thanks!
NAME: Henry Strickland
ADDRESS: 1215 Monte Sano Ave Apt 1
ADDRESS: Augusta GA 30904
}

proc q {band time call grid points} {
  global M Q Date
  set s [clock scan "$Date $time" -gmt false]
  set dt [clock format $s -format "%Y-%m-%d %H%M" -gmt true]
  set key [string toupper "$band-$call"]
  set mult [string toupper "$band-$grid"]
  incr M($mult)
  incr Q($key) $points

  if {$Q($key) == $points} {
    puts [string toupper "QSO: $band PH $dt   W6REK CM97   $call $grid"]
  } else {
    puts stderr "DUP: $band $time $call $grid" 
    incr Q($key) -$points
  }
}
proc 2m {time call grid} { q 144 $time $call $grid 1}
proc 6m {time call grid} { q 50 $time $call $grid 1}
proc 70 {time call grid} { q 432 $time $call $grid 2}

# page 1
set Date 2017-06-10

2m 16:36 k6scc cm87
2m 16:38 w5mmw cm87
2m 16:39 wa6azp cm87
2m 16:40 ag6qx  cm97
2m 16:41 k6tj cm87
2m 16:43 w6bsd cm87
2m 16:44 k6dtx cm97

# page 2

6m 16:52 w5mmw cm87

70 16:55 w5mmw cm87
70 16:58 k6scc cm97

6m 17:02 kg6uef cm97
6m 17:03 np2t cm87

6m 17:10 n6ajs cm87
6m 17:10 n6tu cm97
6m 17:15 ai6xn cm97
6m 17:16 w6pql cm97
6m 17:17 w6bsd cm87
6m 17:23 wb2fko dm65

# page 3

2m 17:28 ag6ja cm87
2m 17:28 w6ia cm97

6m 17:44 w6oat cm87
6m 17:48 w7qq dm75
6m 17:51 n6mm cm87

70 18:00 n6jet/r cm87
70 18:02 kj6pwh cm87
70 18:04 w6bsd cm87
2m 18:06 kj6pwh cm87
6m 18:10 w5mmw cm87
6m 18:12 k6mw cm87
6m 18:15 aa6xv cm87

# page 4
set Date 2017-06-10

70 16:05 w6car cm87
6m 16:17 w6car cm87
70 16:21 km6dac cm97
2m 16:22 nu6s cm87
6m 16:23 nu6s cm87
6m 16:25 k6dtx cm97
2m 16:31 wb6khp cm97
2m 16:32 w6car cm97

puts END-OF-LOG:

foreach q [array names Q] {incr qscore $Q($q)}
foreach m [array names M] {incr mults 1}

puts "SOAPBOX: number of Qs: [llength [array names Q]] ([lsort [array names Q]])"
puts "SOAPBOX: score of Qs: $qscore"
puts "SOAPBOX: multipliers: $mults ([lsort [array names M]])"

puts "CLAIMED-SCORE: [expr $mults * $qscore]"

puts ==
parray Q
puts ==
parray M
puts ==
