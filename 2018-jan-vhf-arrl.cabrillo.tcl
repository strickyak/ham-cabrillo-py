set FormattedQsos ""
proc q {band time call grid points} {
  global M Q Date LastTime MyGrid RoverGrids FormattedQsos
  if {[string length $grid] == 2} {
    set grid cm$grid
  }
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
  set key [string toupper "$band-$call-$grid-$MyGrid"]
  set mult [string toupper "$band-$grid"]
  incr M($mult)
  incr Q($key) $points
  incr RoverGrids(MyGrid=$MyGrid)

  if {$Q($key) != $points} {
    puts stderr "DUP: $band $time $call $grid" 
    incr Q($key) -$points
  }

  set fq [format "QSO: %3s PH %17s  %10s %4s  %10s %4s" $band $dt   W6REK/R $MyGrid   $call $grid]
  lappend FormattedQsos [string toupper $fq]
}
proc 6 {time call grid} { q 50 $time $call $grid 1}   ;# 6 = 6m
proc 2 {time call grid} { q 144 $time $call $grid 1}  ;# 2 = 2m
proc 5 {time call grid} { q 222 $time $call $grid 2}  ;# 5 = 125cm
proc 7 {time call grid} { q 432 $time $call $grid 2}  ;# 7 = 70cm

###############################################################
# page 1
set Date 2018-01-20
set MyGrid cm97
2 15:10 aa6xa cm88
7 15:22 n6tu cm98
2 15:32 n6rlz cm97
2 15:33 w6ia cm97
2 15:34 n6tv cm97
7 15:43 w6ia cm97
7 15:46 k6kqv cm87
2 15:47 k6kqv cm87
# page 2
2 15:48 w6bsd 87
6 16:09 n6mm 87
6 26 k6kly 87
set MyGrid cm87
6 32 ag6ja 87
set MyGrid cm88
6 18:20 n6jet/r 88
2 18:24 n6jet/r 88
7 19:00 n6jet/r 88
set MyGrid cm98
2 19:17 n6ghz 98
6 36 we6c 99

# page 3
6 54 n6ghz 98
2 20:19 wa6ike 98
2 23 w6rqr 99

set Date 2018-01-21
set MyGrid cm97
6 11:24 w6yx 87
6 23 k6ml 87
2 27 w6yx 87
2 32 w6ia 97
2 12:57 wb6jnn 97
6 13:33 na6xx 97
6 33 wb6jnn 97

# page 4
6 14:20 n6jet/r 87
6 21 kg6xf 87
6 21 nu6s 87
6 22 k6wis 97
6 41 wa6lie 96
2 41 wa6lie 96
2 15:20 k6myc dm07
2 22 wa6oib dm06
2 24 wa6ike 98
2 26 w6rqr 99
2 27 kj6ko 98
2 28 kw6s 96
2 29 n4dla 87

# page 5
2 15:29 w6wuh 88
2 32 ad6i 87
2 34 kk6vqk 87
2 36 k2gmy 88
2 38 n6jet/r 87
2 40 wu1q 88
7 40 wu1q 88
7 42 wb6khp 97
7 44 k2gmy 88
7 15:45 w9kkn 87
7 47 n4dla 87

# page 6
7 15:48 km6abf 97
2 49 w9kkn 87
2 51 we6c 99
2 55 n6ze/r 97
2 53 n9dk 87
2 54 k6eu 97
2 58 n6kog 97
2 16:00 wa6npc 87
2 01 n6ze/r 98
7 04 n6jet/r 87
7 05 n9dk 87
7 07 k6eu 97
5 13 n6jet/r 87
5 18 kc6zwt 98
5 19 wa6ike 98

# page 7
5 16:23 km6abf 97
5 24 k6eu 97
2 33 n6orb 87
2 34 ko6kl 97
2 36 w6pjj 98
6 38 k6wis 97
6 40 kw6s 96
6 41 k8bxd 87
6 42 k6eu 97
6 43 kc6zwt 98
6 45 n6kog 97
7 46 kc6zwt 98
7 47 n6kog 97

# page 8
2 16:50 af6tf 97
2 51 w6bsd 87
7 55 w6bsd 87
7 55 ko6kl 97
6 17:07 n4dla 87

6 11 n7fae 96
6 12 w6tv dm06
2 12 k2gmy 88
2 13 k6wis 97

2 20 k2gmy 88
7 20 k2gmy 88
6 21 kr6mr 98
6 22 k6oak 97

# page 9
5 23 k2gmy 88
2 35 kr6mr 98
2 38 km6mgh 87
2 40 aa7hk 87

###############################################################

foreach q [array names Q] {incr qscore $Q($q)}
foreach m [array names M] {incr mults 1}
foreach g [array names RoverGrids] {incr mults 1}


#puts ==
#parray Q
#puts ==
#parray M
#puts ==

puts "
START-OF-LOG: 3.0
Created-By: https://github.com/strickyak/ham-cabrillo-py
CONTEST: ARRL-VHF-JAN
CALLSIGN: W6REK/R
LOCATION: SCV
OPERATORS: W6REK
CATEGORY-ASSISTED: ASSISTED
CATEGORY-BAND: MIXED
CATEGORY-MODE: MIXED
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-POWER: LOW
CATEGORY-STATION: ROVER-LIMITED
SOAPBOX: number of Qs: [llength [array names Q]] ([lsort [array names Q]])
SOAPBOX: score of Qs: $qscore
SOAPBOX: multipliers: $mults ([lsort [array names M]]) ([lsort [array names RoverGrids]])
CLAIMED-SCORE: [expr $mults * $qscore]
NAME: Henry Strickland
ADDRESS: 1215 Monte Sano Ave Apt 1
ADDRESS: Augusta GA 30904
[join $FormattedQsos "\n"]
END-OF-LOG:
"

