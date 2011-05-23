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


false => int sustain;
int keySustainStatus[8][8];
LaunchpadColor.red => int keyOnColor;
LaunchpadColor.lightRed => int keySustainColor;
int lpChannel;
intPrompt("Enter Midi Channel for Launchpad input: ") => lpChannel;
Launchpad.Launchpad(lpChannel) @=> Launchpad lp;

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
        } else if(sustain && keySustainStatus[lp.e.column][lp.e.row]) {
            lp.setGridLight(lp.e.column, lp.e.row, keySustainColor);
        } else {
            lp.setGridLight(lp.e.column, lp.e.row, 0);
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
                lp.setGridLight(i, j, 0);
            }
        }
    }
}

fun void wiiParser(MidiMsg msg) {
    if(msg.data1 == 176) {              // midi CC
        if(msg.data2 == 64) {           // wiimote acceleration
            // msg.data3 => rawGain;
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

while(true) {
    100::ms => now;
}
