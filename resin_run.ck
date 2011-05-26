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

50::samp => dur gainResolution;
int rawGain;
0.01 => float noteOnGrowth;
0.0002 => float noteOffDecay;
0.0001 => float noteSustainDecay;
0.80 => float maxNoteGain;

ToneCalc.grid(8, 8, 1, 5, 55.0, 12.0) @=> float toneMap[][];
UGen @ oscBank[8][8];
for(0 => int i; i < 8; i++) {
    for(0 => int j; j < 8; j++) {
        SinOsc s;
        toneMap[i][j] => s.freq;
        0.0 => s.gain;
        s @=> oscBank[i][j] => dac;
    }
}

false => int sustain;
int keySustainStatus[8][8];


LaunchpadColor.red => int keyOnColor;
LaunchpadColor.lightRed => int keySustainColor;
int lpChannel;
intPrompt("Enter Midi Channel for Launchpad input: ") => lpChannel;
Launchpad.Launchpad(lpChannel) @=> Launchpad lp;

fun void updateGain(int column, int row, float targetGain) {
    if(sustain) {
        if(lp.keyStatus[column][row]) {
            if(targetGain > oscBank[column][row].gain()) {
                Math.min(oscBank[column][row].gain() + noteOnGrowth, maxNoteGain)
                    => oscBank[column][row].gain;
            }
        } else if(keySustainStatus[column][row]) {
            Math.max(oscBank[column][row].gain() - noteSustainDecay, 0.00)
                => oscBank[column][row].gain;
        } else {
            Math.max(oscBank[column][row].gain() - noteOffDecay, 0.00)
                => oscBank[column][row].gain;
        }
    } else {
        if(lp.keyStatus[column][row]) {
            if(targetGain > oscBank[column][row].gain()) {
                Math.min(oscBank[column][row].gain() + noteOnGrowth, maxNoteGain)
                    => oscBank[column][row].gain;
            } else if (targetGain < oscBank[column][row].gain()) {
                Math.max(oscBank[column][row].gain() - noteOnGrowth, 0.00)
                    => oscBank[column][row].gain;
            }
        } else {
            Math.max(oscBank[column][row].gain() - noteOffDecay, 0.00)
                => oscBank[column][row].gain;
        }
    }
}

fun void updateGains() {
    while(true) {
        gainResolution => now;
        rawGain => float targetGain;
        Math.max(0.0, (targetGain - 32) / 95.0) => targetGain;
        for(0 => int i; i < 8; i++) {
            for(0 => int j; j < 8; j++) {
                updateGain(i, j, targetGain);
            }
        }

    }
}

fun void launchpadListener() {
    while(true) {
        lp.e => now;

        // ignore button presses that are not on the grid
        if(lp.e.column < 0 || lp.e.column > 7) continue;
        if(lp.e.row < 0 || lp.e.row > 7) continue;

        if(lp.e.velocity == 127) {
            if(sustain) {
                true => keySustainStatus[lp.e.column][lp.e.row];
            }
            lp.setGridLight(lp.e.column, lp.e.row, keyOnColor);
            1 => oscBank[lp.e.column][lp.e.row].op;
        } else if(sustain && keySustainStatus[lp.e.column][lp.e.row]) {
            lp.setGridLight(lp.e.column, lp.e.row, keySustainColor);
            1 => oscBank[lp.e.column][lp.e.row].op;
        } else {
            lp.setGridLight(lp.e.column, lp.e.row, 0);
            0 => oscBank[lp.e.column][lp.e.row].op;
        }
    }
}

int wiimoteChannel;
intPrompt("Enter Midi Channel for Wiimote input: ") => wiimoteChannel;
MidiIn wiimoteIn;
if(!wiimoteIn.open(wiimoteChannel)) me.exit();

fun void sustainOn() {
    true => sustain;
    for(0 => int i; i < 8; i++) {
        for(0 => int j; j < 8; j++) {
            if(lp.keyStatus[i][j]) {
                true => keySustainStatus[i][j];
                1 => oscBank[i][j].op;
            }
        }
    }
}

fun void sustainOff() {
    false => sustain;
    for(0 => int i; i < 8; i++) {
        for(0 => int j; j < 8; j++) {
            false => keySustainStatus[i][j];
            if(!lp.keyStatus[i][j]) {
                0.0 => oscBank[i][j].gain;
                0 => oscBank[i][j].op;
                lp.setGridLight(i, j, 0);
            }
        }
    }
}

fun void wiiParser(MidiMsg msg) {
    if(msg.data1 == 176) {              // midi CC
        if(msg.data2 == 64) { // wiimote acceleration
            msg.data3 => rawGain;
        } else if (msg.data2 == 65) {   // wiimote button b
            if(msg.data3 == 127) {
                sustainOn();
            } else {
                sustainOff();
            }
        }
    }
}

fun void wiiListener() {
    MidiMsg msg;
    while(true) {
        wiimoteIn => now;
        while(wiimoteIn.recv(msg)) {
            wiiParser(msg);
        }
    }
}

spork ~ launchpadListener();
spork ~ wiiListener();
spork ~ updateGains();


while(true) {
    100::ms => now;
}
