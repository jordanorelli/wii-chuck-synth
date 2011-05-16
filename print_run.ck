/*
Copyright (C) 2011 by Jordan Orelli

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
int midiChannel;

if(me.args() > 0) {
    Std.atoi(me.arg(0)) => midiChannel;
} else {
    ConsoleInput cin;
    cin.prompt("Enter MIDI port # to echo: ") => now;
    StringTokenizer tok;
    int midiChannel;
    while(cin.more()) {
        tok.set(cin.getLine());
        while(tok.more()) {
            Std.atoi(tok.next()) => midiChannel;
        }
    }
}

fun void print(Launchpad @ lp) {
    while(true) {
        lp.e => now;
        chout <= lp.e.toString() <= "\t"
            <= lp.e.column <= "\t"
            <= lp.e.row <= "\t"
            <= lp.e.velocity
            <= IO.newline();
    }
}

Launchpad.Launchpad(midiChannel) @=> Launchpad lp;
spork ~ print(lp);
while(true) {
    100::ms => now;
}
