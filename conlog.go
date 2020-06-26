package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/chzyer/readline"
)

var rigctl = flag.String("rigctl", "", "rigctl command with necessary flags")

var reIndex = regexp.MustCompile("^([0-9]+)[.]$").FindStringSubmatch
var reFreq = regexp.MustCompile("^f=([0-9.]+)$").FindStringSubmatch
var reMode = regexp.MustCompile("^m=([*]|[a-z]+)$").FindStringSubmatch
var reDate = regexp.MustCompile("^d=([*]|[-0-9]+)$").FindStringSubmatch
var reTime = regexp.MustCompile("^t=([*]|[0-9]+)$").FindStringSubmatch
var reMine = regexp.MustCompile("^[']([^']*)[']$").FindStringSubmatch

var reNext = regexp.MustCompile("^(['][^']*[']|[^ ']+)(.*)$").FindStringSubmatch

func main() {
	log.SetFlags(0)
	flag.Parse()
	if flag.NArg() != 1 {
		log.Fatalf("Expected one arg, the filename, but got %d args.", flag.NArg())
	}
	filename := flag.Arg(0)
	log.Printf("[] filename: %q", filename)
	home := os.Getenv("HOME")
	if home == "" {
		home = "."
	}

	rl, err := readline.NewEx(&readline.Config{
		Prompt:          "==> ",
		HistoryFile:     filepath.Join(home, ".conlog.history"),
		InterruptPrompt: "*SIGINT*",
		EOFPrompt:       "*EOF*",
		// AutoComplete:    completer,
		// HistorySearchFold:   true,
		// FuncFilterInputRune: filterInput,
	})
	if err != nil {
		panic(err)
	}
	defer rl.Close()

	p := NewParser()
	p.Load(filename)
	for {
		// p.Show()

		line, err := rl.Readline()
		if err == readline.ErrInterrupt {
			if len(line) == 0 {
				break
			} else {
				continue
			}
		} else if err == io.EOF {
			break
		} else if err != nil {
			log.Printf("ReadLine error: %v", err)
			continue
		}

		line = strings.TrimSpace(line)
		line = strings.ToLower(line)
		if line == "" {
			p.Show()
			continue
		}

		p.DoLine(line)
		p.Store(filename)
	}
}

type Basic struct {
	Freq float64
	Mode string
	Date string
	Time string
	Mine string
}

type Qso struct {
	Base   Basic
	Theirs []string
}

type Parser struct {
	Proto Basic
	Qsos  []*Qso
}

func NewParser() *Parser {
	return &Parser{
		Proto: Basic{
			Freq: 7,
			Mode: "ph",
			Date: "*",
			Time: "*",
			Mine: "*",
		},
	}
}

func (p *Parser) FindDup(theirs []string) bool {
	proto := fixStars(p.Proto)
	call := theirs[0]
	for i, q := range p.Qsos {
		if q.Theirs[0] == call {
			if proto.QsoMatches(theirs, q, i) {
				return true
			}
		}
	}
	return false
}

func (b *Basic) QsoMatches(theirs []string, q *Qso, i int) bool {
	return (int(b.Freq) == int(q.Base.Freq) && b.Mode == q.Base.Mode)
	if int(b.Freq) != int(q.Base.Freq) {
		return false
	}
	if b.Mode != q.Base.Mode {
		return false
	}
	if len(theirs) != len(q.Theirs) {
		log.Printf("*** DETAILS DIFF:  %4d.  %v ***", i, q)
		return false
	}
	for i, e := range theirs {
		if e != q.Theirs[i] {
			log.Printf("*** DETAILS DIFF:  %4d.  %v ***", i, q)
			return false
		}
	}
	log.Printf(">>> SAME:  %4d.  %v <<<", i, q)
	return true
}

func (p *Parser) DoLine(line string) {
	defer func() {
		r := recover()
		if r != nil {
			log.Printf("***** ERROR: %v", r)
		} else {
			log.Printf("[OK]")
		}
	}()

	rest := trim(line)
	if rest == "" {
		return
	}

	var index int
	var theirs []string
	var words []string
	for rest != "" {
		m := reNext(rest)
		if m == nil {
			log.Panicf("cannot parse: %q", rest)
		}
		word, rest2 := m[1], m[2]
		words = append(words, word)
		rest = trim(rest2)
	}

	var target *Qso
	base := &p.Proto
	for i, w := range words {
		m := reIndex(words[0])
		if i == 0 && m != nil {
			index = atoi(m[1])
			target = p.Qsos[index-1]
			base = &target.Base
			continue
		}

		consumed := base.SetWord(w)
		if consumed {
			continue
		}

		theirs = append(theirs, w)
	}

	if len(theirs) == 1 {
		p.FindDup(theirs)
		/*
			// Call sign check.
			call := theirs[0]
			for i, q := range p.Qsos {
				if q.Theirs[0] == call {
					if p.QsoMatches(theirs, q) {
						log.Printf(">>> SAME:  %4d.  %v <<<", i, q)
					} else {
						log.Printf("Different:  %4d.  %v", i, q)
					}
				}
			}
		*/

	} else if len(theirs) > 1 {
		if target != nil {
			// Edit an old Qso.
			target.Theirs = theirs
			log.Printf("EDITED %d. : %v", index, target)
		} else {
			if p.FindDup(theirs) {
				log.Printf(">>>>>>> DUP IGNORED <<<<<<<<")
			} else {

				// Create a new Qso.
				q := &Qso{
					Base:   fixStars(*base),
					Theirs: theirs,
				}
				p.Qsos = append(p.Qsos, q)
				log.Printf("ADDED %d. : %v", len(p.Qsos), q)
			}
		}
	} else {
		if target != nil {
			log.Printf("EDITED %d. : %v", index, target)
		} else {
			log.Printf("PROTOTYPE : %v", p.Proto)
		}
	}
}

func (p *Basic) SetWord(w string) bool {
	m := reFreq(w)
	if m != nil {
		p.SetFreq(m[1])
		return true
	}

	m = reMode(w)
	if m != nil {
		p.SetMode(m[1])
		return true
	}

	m = reDate(w)
	if m != nil {
		p.SetDate(m[1])
		return true
	}

	m = reTime(w)
	if m != nil {
		p.SetTime(m[1])
		return true
	}

	m = reMine(w)
	if m != nil {
		p.SetMine(m[1])
		return true
	}

	return false
}

func (b *Basic) SetFreq(s string) {
	b.Freq = atof(s)
}

func (b *Basic) SetMode(s string) {
	b.Mode = s
}

func (b *Basic) SetDate(s string) {
	b.Date = s
}

func (b *Basic) SetTime(s string) {
	b.Time = s
}

func (b *Basic) SetMine(s string) {
	b.Mine = s
}

func (p *Parser) Load(filename string) {
	fd, err := os.Open(filename)
	if err != nil {
		return
	}
	defer fd.Close()

	scanner := bufio.NewScanner(fd)
	for scanner.Scan() {
		p.DoLine(scanner.Text())
	}
	if err2 := scanner.Err(); err2 != nil {
		log.Fatalf("failed reading %q: %v", filename, err2)
	}
}

func (p *Parser) Store(filename string) {
	tmpfile := filename + ".~tmp~"
	f, err := os.Create(tmpfile)
	if err != nil {
		log.Fatalf("cannot create %q: %v", tmpfile, err)
	}
	w := bufio.NewWriter(f)
	for _, q := range p.Qsos {
		fmt.Fprintf(w, "%v\n", q)
	}
	fmt.Fprintf(w, "%v\n", p.Proto)

	err = w.Flush()
	if err != nil {
		log.Fatalf("cannot flush %q: %v", tmpfile, err)
	}
	err = f.Close()
	if err != nil {
		log.Fatalf("cannot close %q: %v", tmpfile, err)
	}

	cmd := exec.Command("/bin/mv", tmpfile, filename)
	err = cmd.Run()
	if err != nil {
		log.Fatalf("cannot rename %q to %q: %v", tmpfile, filename, err)
	}
}

func (b Basic) String() string {
	return fmt.Sprintf("f=%-8.3f m=%-2s d=%-10s t=%-4s  '%s'", b.Freq, b.Mode, b.Date, b.Time, b.Mine)
}

func (q Qso) String() string {
	return fmt.Sprintf("%v  %s", q.Base, unravel(q.Theirs))
}

func (p Parser) Show() {
	for i, q := range p.Qsos {
		log.Printf("\t####\t %4d.  %v", i+1, q)
	}
	log.Printf("\t####\t .....  %v  .....", &p.Proto)
}

// misc functions

func atoi(s string) int {
	x, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		log.Panicf("cannot ParseInt %q: %v", s, err)
	}
	return int(x)
}

func atof(s string) float64 {
	y, err := strconv.ParseFloat(s, 64)
	if err != nil {
		panic(err)
	}
	return y
}

func unravel(vec []string) string {
	var buf bytes.Buffer
	for i, s := range vec {
		if i > 0 {
			buf.WriteByte(' ')
		}
		buf.WriteString(s)
	}
	return buf.String()
}

func trim(s string) string {
	return strings.Trim(s, " \t\r\n\v")
}

func runRigctl(query string) string {
	if *rigctl == "" {
		log.Panic("No --rigctl command specified")
	}
	ww := strings.Fields(*rigctl)
	ww = append(ww, query)
	// var bb bytes.Buffer
	cmd := exec.Command(ww[0], ww[1:]...)
	out, err := cmd.Output()
	if err != nil {
		msg := ""
		switch t := err.(type) {
		case *exec.ExitError:
			msg = string(t.Stderr)
		}
		log.Panicf("Error in --rigctl command: %v -> %v: %q", ww, err, msg)
	}
	words := strings.Fields(string(out))
	return words[0]
}
func getFreq() float64 {
	return atof(runRigctl("f")) / 1e6
}
func getMode() string {
	s := strings.ToLower(runRigctl("m"))
	switch s {
	case "lsb":
		return "ph"
	case "usb":
		return "ph"
	case "am":
		return "ph"
	case "fm":
		return "ph"
	case "cw":
		return "cw"
	default:
		return "dg"
	}
}

func fixStars(b Basic) Basic {
	nowZulu := time.Now().UTC()
	if b.Date == "*" {
		b.Date = nowZulu.Format("2006-01-02")
	}
	if b.Time == "*" {
		b.Time = nowZulu.Format("1504")
	}
	if b.Freq == 0 {
		b.Freq = getFreq()
	}
	if b.Mode == "*" {
		b.Mode = getMode()
	}
	return b
}
