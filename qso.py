import sys
E = sys.stderr

# Importer should reset these defaults.
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

    QSOs.append((Freq, Mode, '%s %02d%02d' % (Date, Hour, minute), Call, seq, Location, peer, pseq, ploc))

def CheckUnique():
  peers = {}
  for qso in QSOs:
    freq, mode, timestamp, call, seq, loc, peer, pseq, ploc = qso
    if peer in peers:
      raise Exception("You got peer %s twice: %s" % (peer, repr(qso)))

def CountMultipliers():
  plocs = {}
  for qso in QSOs:
    freq, mode, timestamp, call, seq, loc, peer, pseq, ploc = qso
    assert len(loc) in [2, 4], loc
    assert len(ploc) in [2, 4], ploc
    n = plocs.get(ploc, 0)
    plocs[ploc] = n+1
    if len(ploc) == 4:
      # Also counts as California.
      n = plocs.get('CA', 0)
      plocs['CA'] = n+1
  print >>E, ''
  print >>E, plocs
  print >>E, ''
  print >>E, 'Unique Peer Locs: %s' % sorted(plocs.keys())
  return len(plocs)

def WriteQsoLines():
  for qso in QSOs:
    z = "QSO: %6d %2s %s %10s %4d %4s %10s %4d %4s" % qso
    assert len(z) <= 80
    print z

def Verbose():
  print >>E, "Number QSOs: %d" % len(QSOs)
  print >>E, "Multipliers: %d" % CountMultipliers()
  print >>E, "Score: %d" % (CountMultipliers() * len(QSOs))

def WriteHeader():
  print '''START-OF-LOG: 3.0
CALLSIGN: %s
CONTEST: 2016 California QSO Party
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-POWER: LOW
CATEGORY-TRANSMITTER: ONE
CLAIMED-SCORE: %d
LOCATION: WMA
CREATED-BY: github.com/strickyak/ham-cabrillo-py
EMAIL: %s
NAME: %s
ADDRESS: %s
ADDRESS-CITY: Augusta
ADDRESS-STATE-PROVINCE: GA
ADDRESS-POSTALCODE: 30904
ADDRESS-COUNTRY: USA
OPERATORS: %s
SOAPBOX: Thanks this was fun!
SOAPBOX:''' % (
    Call,
    (CountMultipliers() * len(QSOs)),
    '%s@%s.%s' % tuple([Rot(s) for s in ('fgevpx','lnx','arg')]),
    Rot('Urael Fgevpxynaq'),
    Rot('%d Zbagr Fnab Nir Ncg 1' % (15*81)),
    Call,
    )

def WriteFooter():
  print 'END-OF-LOG:'

def Rot(s):
  a = [ord(c) for c in s]
  def r(n):
    if (0xE0 & n) == 64:
      return (((n-65)+13)%26)+65
    if (0xE0 & n) == 96:
      return (((n-97)+13)%26)+97
    return n
  b = [r(x) for x in a]
  return ''.join([chr(x) for x in b])
