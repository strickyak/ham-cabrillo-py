package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"

	"github.com/chzyer/readline"
)

var txtfile = flag.String("f", "conlog.csv", "contest log file name")

var reLine = regexp.MustCompile("^[#]([1-9][0-9]*)$").FindStringSubmatch
var reFreq = regexp.MustCompile("^f=([0-9.]+)$").FindStringSubmatch
var reMode = regexp.MustCompile("^m=([a-z]+)$").FindStringSubmatch
var reDate = regexp.MustCompile("^d=([0-9][0-9])$").FindStringSubmatch
var reTime = regexp.MustCompile("^t=([0-9][0-9][0-9][0-9])$").FindStringSubmatch

func main() {
	flag.Parse()
	home := os.Getenv("HOME")
	if home == "" {
		home = "."
	}

	rl, err := readline.NewEx(&readline.Config{
		Prompt:          "<=> ",
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

	p := Parser{}
	p.Load()
	for {
		p.Show()

		line, err := rl.Readline()
		if err == readline.ErrInterrupt {
			if len(line) == 0 {
				break
			} else {
				continue
			}
		} else if err == io.EOF {
			break
		}

		line = strings.TrimSpace(line)
		line = strings.ToLower(line)
		if line == "" {
			continue
		}

		p.Handle(line)
		p.Store()
	}
}

var midQuote = regexp.MustCompile(`^([^"]*)["]([^"]*)["]([^"]*)$`).FindStringSubmatch

type Qso struct {
	Freq   float64
	Mode   string
	Date   string
	Time   string
	Mine   string
	Theirs []string
}

type Parser struct {
	Line   int
	Freq   float64
	Mode   string
	Date   string
	Time   string
	Mine   string
	Theirs []string

	Qsos []*Qso
}

func (p *Parser) Handle(line string) {
	defer func() {
		r := recover()
		if r != nil {
			log.Printf("***** ERROR: %v", r)
		} else {
			log.Printf("OK")
		}
	}()

	p.StartLine()
	m := midQuote(line)
	if m != nil {
		p.HandleMidquote(m[1], m[2], m[3])
	} else {
		words := strings.Split(line, " ")
		p.HandleWords(words)
	}
	p.FinishLine()
}

func (p *Parser) HandleMidquote(a, b, c string) {
	p.Mine = b
	p.HandleWords(strings.Split(a, " "))
	p.HandleWords(strings.Split(c, " "))
}

func (p *Parser) StartLine() {
	p.Line = 0
}

func (p *Parser) FinishLine() {
	switch len(p.Theirs) {
	case 0:
		p.Show()
	case 1:
		// look up call sign
		p.Show()
	default:
		p.Add()
		p.Theirs = nil
	}
}

func (p *Parser) Add() {
	q := &Qso{
		Freq:   p.Freq,
		Mode:   p.Mode,
		Date:   p.Date,
		Time:   p.Time,
		Mine:   p.Mine,
		Theirs: p.Theirs,
	}
	p.Qsos = append(p.Qsos, q)
}

func (p *Parser) HandleWords(words []string) {
	for _, w := range words {
		if len(w) > 0 {
			p.HandleWord(w)
		}
	}
}

func (p *Parser) HandleWord(w string) {
	m := reLine(w)
	if m != nil {
		p.HandleLine(m[1])
		return
	}

	m = reFreq(w)
	if m != nil {
		p.HandleFreq(m[1])
		return
	}

	m = reMode(w)
	if m != nil {
		p.HandleMode(m[1])
		return
	}

	m = reDate(w)
	if m != nil {
		p.HandleDate(m[1])
		return
	}

	m = reTime(w)
	if m != nil {
		p.HandleTime(m[1])
		return
	}

	p.Theirs = append(p.Theirs, w)
}

func (p *Parser) HandleLine(x string) {
	y, err := strconv.ParseInt(x, 10, 64)
	if err != nil {
		panic(err)
	}
	p.Line = int(y)
}

func (p *Parser) HandleFreq(x string) {
	y, err := strconv.ParseFloat(x, 64)
	if err != nil {
		panic(err)
	}
	p.Freq = y
}

func (p *Parser) HandleMode(x string) {
	p.Mode = x
}

func (p *Parser) HandleDate(x string) {
	p.Date = x
}

func (p *Parser) HandleTime(x string) {
	p.Time = x
}

func (p *Parser) Load() {
}
func (p *Parser) Store() {
	tmpfile := *txtfile + ".~"
	f, err := os.Create(tmpfile)
	if err != nil {
		log.Fatalf("Cannot create %q: %v", tmpfile, err)
	}
	defer f.Close()
	w := bufio.NewWriter(f)
	defer w.Flush()

	for i, q := range p.Qsos {
		fmt.Fprintf(w, `#%-4d f=%8.3f m=%2s d=%2s t=%4s  "%s"  %v%c`,
			i+1, q.Freq, q.Mode, q.Date, q.Time, q.Mine, q.Theirs, '\n')
	}
}

func (p *Parser) Show() {
	for i, q := range p.Qsos {
		fmt.Printf(`#%-4d f=%8.3f m=%2s d=%2s t=%4s  "%s"  %v%c`,
			i+1, q.Freq, q.Mode, q.Date, q.Time, q.Mine, q.Theirs, '\n')
	}
	fmt.Printf(`..... f=%8.3f m=%2s d=%2s t=%4s  "%s" ...%c`,
		p.Freq, p.Mode, p.Date, p.Time, p.Mine, '\n')
}
