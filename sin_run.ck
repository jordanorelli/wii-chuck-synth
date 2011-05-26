/*------------------------------------------------------------------------------

Utility shit.

------------------------------------------------------------------------------*/
fun float within(float min, float max, float val) {
    if(val < min) {
        return min;
    } else if (val > max) {
        return max;
    } else {
        return val;
    }
}

fun float round(float x) {
    if(x < 0.05) {
        return 0.0;
    } else if(x < 0.15) {
        return 0.1;
    } else if(x < 0.25) {
        return 0.2;
    } else if(x < 0.35) {
        return 0.3;
    } else if(x < 0.45) {
        return 0.4;
    } else if(x < 0.55) {
        return 0.5;
    } else if(x < 0.65) {
        return 0.6;
    } else if(x < 0.75) {
        return 0.7;
    } else if(x < 0.85) {
        return 0.8;
    } else if(x < 0.95) {
        return 0.9;
    } else {
        return 1.0;
    }
}

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

fun float max(float x, float y) {
    if (x > y)
        return x;
    else
        return y;
}
/*------------------------------------------------------------------------------

Sustain

------------------------------------------------------------------------------*/

false => int sustain;
SinOsc @ oscBank[8][8];
int sustainKeyStates[8][8];
ToneCalc.grid(8, 8, 1, 5, 55.0, 12.0) @=> float toneMap[][];

for(0 => int i; i < 8; i++) {
    for(0 => int j; j < 8; j++) {
        SinOsc s;
        toneMap[i][j] => s.freq;
        0.0 => s.gain;
        s @=> oscBank[i][j];
        oscBank[i][j] => dac;
    }
}

fun void sustainOff() {
    false => sustain;
    for(0 => int i; i < 8; i++) {
        for(0 => int j; j < 8; j++) {
            false => sustainKeyStates[i][j];
        }
    }
}

sustainOff();

fun void sustainOn() {
    true => sustain;
}


/*------------------------------------------------------------------------------

Gain Control

------------------------------------------------------------------------------*/

int targetGains[8][8];
for(0 => int i; i < 8; i++) {
    for(0 => int j; j < 8; j++) {
        -1 => targetGains[i][j];
    }
}

fun void updateGain(Launchpad @ lp, int column, int row, float targetGain) {
    // oscBank[column][row] @=> UGen targetOsc;
    // oscBank[column][row].gain() => float currentGain;
    // lp.keyStatus[column][row] => int targetKeyPressed;
    // sustainKeyStates[column][row] => int targetKeySustain;
    // 0.05 => float gainAttack;
    // 0.01 => float keyPressedDecay;
    // 0.02 => float sustainDecay;
    // 0.20 => float keyOffDecay;

    // if the key is pressed, the oscillator's gain should approach the target
    // gain no matter what.
    if(lp.keyStatus[column][row] > 0) {
        if(0.20 != oscBank[column][row].gain()) {
            0.20 => oscBank[column][row].gain;
        }
        // 0.20 => oscBank[column][row].gain;
        chout <= column <= row <= IO.newline();
    }
    /*
    if(targetKeyPressed > 0)
    {
        if(currentGain < targetGain)
        {
            currentGain + gainAttack => float mrGain;
            within(0.0, 1.0, mrGain) => mrGain;
            chout <= "1111111111111111111111111111111111111111" <= mrGain <= IO.newline();
            mrGain => oscBank[column][row].gain;
        }
        else
        {
            currentGain - keyPressedDecay => float mrGain;
            within(0.0, 1.0, mrGain) => mrGain;
            chout <= "2222222222222222222222222222222222222222" <= mrGain <= IO.newline();
            mrGain => oscBank[column][row].gain;
        }
    }

    else if(sustain && targetKeySustain)
    {
        currentGain - sustainDecay => float mrGain;
        within(0.0, 1.0, mrGain) => mrGain;
        chout <= "3333333333333333333333333333333333333333" <= mrGain <= IO.newline();
        mrGain => oscBank[column][row].gain;
    }

    else
    {
        currentGain - keyOffDecay => float mrGain;
        within(0.0, 1.0, mrGain) => mrGain;
        // chout <= "4444444444444444444444444444444444444444" <= IO.newline();
        mrGain => oscBank[column][row].gain;
    }
    */
}

float rawGain;
fun void updateGains(Launchpad @ lp) {
    while(true) {
        4::ms => now;
        float targetGain;
        max(0.00, (rawGain - 32) / 95.0) => targetGain;
        round(targetGain) => targetGain;
        for(0 => int i; i < 8; i++) {
            for(0 => int j; j < 8; j++) {
                updateGain(lp, i, j, targetGain);
            }
        }
    }
}

/*------------------------------------------------------------------------------

Launchpad

------------------------------------------------------------------------------*/

int lpChannel;
intPrompt("Enter Midi Channel for Launchpad input: ") => lpChannel;
Launchpad.Launchpad(lpChannel) @=> Launchpad lp;

fun void launchpadListener(Launchpad @ lp) {
    while(true) {
        lp.e => now;

        // ignore button presses that are not on the grid
        if(lp.e.column < 0 || lp.e.column > 7) continue;
        if(lp.e.row < 0 || lp.e.row > 7) continue;

        if(lp.e.velocity == 127) {
            // oscBank[lp.e.column][lp.e.row] => dac;
            true => sustainKeyStates[lp.e.column][lp.e.row];
        } else if (lp.e.velocity == 0) {
            // oscBank[lp.e.column][lp.e.row] =< dac;
        }

        lp.setGridLight(lp.e);
    }
}

spork ~ launchpadListener(lp);

/*------------------------------------------------------------------------------

WiiMote

------------------------------------------------------------------------------*/

int wiimoteChannel;
intPrompt("Enter Midi Channel for Wiimote input: ") => wiimoteChannel;
MidiIn wiimoteIn;
if(!wiimoteIn.open(wiimoteChannel)) me.exit();

fun void wiiParser(MidiMsg msg) {
    if(msg.data1 == 176) {              // midi CC
        if(msg.data2 == 64) {           // wiimote acceleration
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
spork ~ updateGains(lp);

fun void wiiListener(MidiIn @ wiiIn) {
    MidiMsg msg;
    while(true) {
        wiiIn => now;
        while(wiiIn.recv(msg)) {
            wiiParser(msg);
        }
    }
}

spork ~ wiiListener(wiimoteIn);


while(true) {
    100::ms => now;
}
