fun int intPrompt(string msg) {
    int in;
    ConsoleInput cin;
    StringTokenizer tok;
    cin.prompt(msg) => now;
    while(cin.more()) {
        tok.set(cin.getLine());
        while(tok.more()) {
            Std.atoi(tok.next()) => in;
        }
    }
    return in;
}

int lpChannel;
int wiimoteChannel;
intPrompt("Enter Midi Channel for Launchpad input: ") => lpChannel;
intPrompt("Enter Midi Channel for Wiimote input: ") => wiimoteChannel;
MidiIn wiimoteIn;
if(!wiimoteIn.open(wiimoteChannel)) me.exit();

SinOsc @ oscBank[8][8];
// that's columns, rows, column step, row step, base frequency, and tones per
// octave.  If you change the first two, shit will break.  The others you can
// change freely.  I set it so that it moves chromatically along the horizontal
// axis (3rd parameter is 1) and in tritones along the vertical axis (4th
// parameter is 6).  Changing the last parameter is not for the faint of heart.
ToneCalc.grid(8, 8, 1, 5, 55.0, 12.0) @=> float toneMap[][];

Gain g => OnePole f => dac;
0.2 => f.a1;
0.1 => f.b0;
0.3 => f.pole;

0.20 => float targetGain;
targetGain => g.gain;

for(0 => int i; i < 8; i++) {
    for(0 => int j; j < 8; j++) {
        SinOsc s;
        toneMap[i][j] => s.freq;
        0.2 => s.gain;
        s @=> oscBank[i][j];
    }
}

fun void leftHand(Launchpad @ lp) {
    while(true) {
        lp.e => now;

        // ignore button presses that are not on the grid
        if(lp.e.column < 0 || lp.e.column > 7) continue;
        if(lp.e.row < 0 || lp.e.row > 7) continue;

        if(lp.e.velocity == 127) {
            oscBank[lp.e.column][lp.e.row] => g;
        } else if (lp.e.velocity == 0) {
            oscBank[lp.e.column][lp.e.row] =< g;
        }

        lp.setGridLight(lp.e);
    }
}

fun float max(float x, float y) {
    if (x > y)
        return x;
    else
        return y;
}

fun void rightHand(MidiIn @ wiiIn) {
    MidiMsg msg;
    while(true) {
        wiiIn => now;
        while(wiiIn.recv(msg)) {
            if(msg.data1 == 176 && msg.data2 == 64) {
                max(0.00, (msg.data3 - 32) / 95.0)=> targetGain;
                max(0.00, targetGain) => targetGain;
                // chout <= msg.data3 <= "\t" <= targetGain <= IO.newline();
                targetGain => g.gain;
            }
        }
    }
}

fun void gainSmooth() {
    while(true) {
        1::ms => now;
        if(targetGain > g.gain()) {
            g.gain() + 0.01 => g.gain;
        } else if (targetGain < g.gain()) {
            g.gain() - 0.01 => g.gain;
        }
    }
}

Launchpad.Launchpad(lpChannel) @=> Launchpad lp;
spork ~ leftHand(lp);
spork ~ rightHand(wiimoteIn);
spork ~ gainSmooth();

while(true) {
    100::ms => now;
}
