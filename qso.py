## Put these in your environment.
import os, sys
Call = os.getenv("CALL").upper()
FullName = os.getenv("FULLNAME")
StreetAddress = os.getenv("STREET")
Email = os.getenv("EMAIL")

E = sys.stderr
FOR_PHONE = 2  # Points.  We only do Phone.

# Importer should reset these defaults.
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

def CountUnique():
  peers = {}
  for qso in QSOs:
    freq, mode, timestamp, call, seq, loc, peer, pseq, ploc = qso
    if peer in peers:
      print >>E, "Duplicate: %s" % peer
    n = peers.get(peer, 0)
    peers[peer] = n+1
  print >>E, "PEERS: %s" % sorted(peers.items())
  return len(peers)

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
  print >>E, "Score: %d" % (FOR_PHONE * CountMultipliers() * CountUnique())

def WriteHeader():
  print '''START-OF-LOG: 3.0
CALLSIGN: %s
CONTEST: 2016 California QSO Party
CATEGORY-OPERATOR: SINGLE-OP
CATEGORY-ASSISTED: NON-ASSISTED
CATEGORY-POWER: LOW
CATEGORY-TRANSMITTER: ONE
CLAIMED-SCORE: %d
LOCATION: SCV
CREATED-BY: http://github.com/strickyak/ham-cabrillo-py
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
    (FOR_PHONE * CountMultipliers() * CountUnique()),
    Email,
    FullName,
    StreetAddress,
    Call,
    )

def WriteFooter():
  print 'END-OF-LOG:'
