from qso import *

c('W6REK')  # My call sign
l('SCLA')   # My location
m('PH')   # Mode == Phone

f(3500)   # 80m
f(14000)  # 20m
f(7000)   # 40m

# Page 1

f(7000)   # Freq: 40m
d('2016-10-01') # Date
h(18)     # Hour

q('''
  53 1 k6s 41 sisk
  58 2 n6aj 25 kern
  59 3 w6rkk 4 shas
''')

h(19)
q('''
  00 4 w6sf 40 sjoa
  01 5 k6mbd 24 sacr
  02 6 n6sjv 13 sjoa
  03 7 ko6jf 62 napa
  04 8 ke6lb 12 lang
  05 9 k6vwl 3 sdie
  05 10 ka7lyq 7 or
''')

# Page 2

f(7242)
q('''
  08 11 k6czh 5 nv
  09 12 nc6dx 147 neva
  09 13 n6sbc 3 sben
  11 14 k6ks 18 shas
  11 15 w1nv 15 shas
  12 16 kb6lzw 1 mend
''')

# Page 3

f(7242)
q('''
  13 17 nj6g 6 cala
  14 18 wa6ktk 1 sjoa
  15 19 wa6cal 9 yuba
  16 20 ai6in 28 plac
''')

h(23)
f(14000) # 20m
q("4 21 k6mm 507 scla")

h(23)
f(7000) # 40m
q("11 22 k6yl 125 sber")

# Page 4

q('''
  18 23 n6js 620 sola
  25 24 w6zq 61 sber
  27 25 w6yx 81 scla
  34 26 km6z 433 lang
  36 27 va7rr 465 bc
''')

d('2016-10-02')
h(18)

q('''
  08 28 kq6tv 478 sdie
  16 29 ka6hhw 1 vent
  17 30 n6kw 12 vent # qrp=5w
''')

h(21)
q('''
  12 31 kj6qvi/ag 32 tuol
  20 32 km6g 190 mend
  23 33 k6y 249 yolo
  25 34 k6z 814 inyo
  26 35 kj6ttr 58 vent
''')

# Page 5
q('''
  29 36 w6esl 140 scla
  30 37 wb6kdh 43 sber
  31 38 km6dnb 32 made
  32 39 ak7mg 62 nv
  32 40 n6ldp 45 alam
  33 41 n6mm 55 alam
  33 42 n6bct 36 smat
  34 43 k6mbd 127 sacr
  34 44 kk6gpy 9 kern
  35 45 w6var 332 ccos
  36 46 kc7o 64 lang
''')

CountUnique()
Verbose()

WriteHeader()
WriteQsoLines()
WriteFooter()
