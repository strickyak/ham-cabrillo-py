Call = 'W6REK'
Location = 'SCLA'
Mode = 'PH'
Freq = 7000
Date = '2000-01-01'
Hour = 0
QSOs = []

def c(x):
  global Call
  Call = x
def l(x):
  global Location
  Location = x
def m(x):
  global Mode
  Mode = x
def f(x):
  global Freq
  Freq = x
def d(x):
  global Date
  Date = x
def h(x):
  global Hour
  Hour = x

def q(t):
  for s in t.split('\n'):
    s = s.split('#')[0]
    s = s.strip()
    if not s: continue
    w = s.split()
    if not w: continue
    if len(w) != 5:
      raise Exception('Error: Not 5 words: Parsed %s Line %s in Qso Text %s' % (repr(w), repr(s), repr(t)))

    minute = int(w[0])
    seq = int(w[1])
    peer = w[2].upper()
    pseq = int(w[3])
    ploc = w[4].upper()

    QSOs.append((Freq, Mode, '%s %02d%02d' % (Date, Hour, minute), seq, Location, peer, pseq, ploc))
