MidiIn            wm;
Launchpad         lp;

false    =>   int prompt;
50::samp =>   dur gainResolution;
0.0016   => float releaseDecay;
0.00001   => float sustainDecay;
0.00001   => float sostenutoDecay;
0.01     => float pressAttack;
0.80     => float maxNoteGain;
0        =>   int rawGain;
             UGen @ oscBank[8][8];
             Gain @ patchBank[8][8];
0        =>   int currentTone;
false    =>   int sustain;
              int sustainStatus[8][8];
false    =>   int sostenuto;
              int sostenutoStatus[8][8];
0        =>   int lpChannel;
1        =>   int wiimoteChannel;

LaunchpadColor.red => int keyOnColor;
LaunchpadColor.lightRed => int keySustainColor;
LaunchpadColor.lightRed => int keySostenutoColor;
LaunchpadColor.red => int toneChoiceColor;
ToneCalc.grid(8, 8, 1, 5,  82.4068867, 12.0) @=> float toneMap[][];

fun void setup()
{

    if(prompt)
    {
        intPrompt("Enter Midi Channel for Launchpad input: ") => lpChannel;
        intPrompt("Enter Midi Channel for Wiimote input: ") => wiimoteChannel;

        Launchpad.Launchpad(lpChannel) @=> lp;
        connectWiimote(wiimoteChannel);
    }
    else
    {
        Launchpad.Launchpad(0) @=> lp;
        connectWiimote(1);
    }


    lp.clear();
    lp.setGridLight(8, currentTone, toneChoiceColor);

    chout <= "Create oscillators" <= IO.newline();
    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            SinOsc s;
            toneMap[i][j] => s.freq;
            0.0 => s.gain;
            chout <= ".";

            Gain g;
            1.0 => g.gain;

            s @=> oscBank[i][j] => g @=> patchBank[i][j] => dac;
        }
    }
    chout <= "done." <= IO.newline();

    spork ~ launchpadListener();
    spork ~ wiiListener();
    spork ~ updateGains();
}

fun UGen toneChoiceFactory(int toneChoice, UGen @ sourceUGen, float freq)
{
    if(toneChoice == 0)
    {
        SinOsc s;
        freq => s.freq;
        sourceUGen.op() => s.op;
        sourceUGen.gain() => s.gain;
        return s;
    }
    else if(toneChoice == 1)
    {
        TriOsc s;
        freq => s.freq;
        sourceUGen.op() => s.op;
        sourceUGen.gain() => s.gain;
        return s;
    }
    else if(toneChoice == 2)
    {
        SqrOsc s;
        freq => s.freq;
        sourceUGen.op() => s.op;
        sourceUGen.gain() => s.gain;
        return s;
    }
    else if(toneChoice == 3)
    {
        SawOsc s;
        freq => s.freq;
        sourceUGen.op() => s.op;
        sourceUGen.gain() => s.gain;
        return s;
    }
    else
    {
        cherr <= "Unrecognized input fed to toneChoiceFactory: " <= toneChoice
            <= IO.newline();
        SinOsc s;
        freq => s.freq;
        sourceUGen.op() => s.op;
        sourceUGen.gain() => s.gain;
        return s;
    }
}

fun void setTone(int toneChoice)
{

    if(toneChoice == currentTone)
    {
        return;
    }

    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            UGen u;
            toneChoiceFactory(toneChoice, oscBank[i][j], toneMap[i][j]) @=> u;
            0 => oscBank[i][j].op;
            oscBank[i][j] =< patchBank[i][j];
            u @=> oscBank[i][j] => patchBank[i][j];
        }
    }

    lp.setGridLight(8, currentTone, 0);
    lp.setGridLight(8, toneChoice, toneChoiceColor);
    toneChoice => currentTone;
}

fun void sostenutoOn()
{
    true => sostenuto;
    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            if(lp.keyDown[i][j])
            {
                true => sostenutoStatus[i][j];
            }
        }
    }
}

fun void sostenutoOff()
{
    false => sostenuto;
    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            false => sostenutoStatus[i][j];
            if(!lp.keyDown[i][j])
            {
                lp.setGridLight(i, j, 0);
            }
        }
    }
}

fun void sustainOn()
{
    true => sustain;
    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            if(lp.keyDown[i][j])
            {
                true => sustainStatus[i][j];
            }
        }
    }
}

fun void sustainOff()
{
    false => sustain;
    for(0 => int i; i < 8; i++)
    {
        for(0 => int j; j < 8; j++)
        {
            false => sustainStatus[i][j];
            if(!lp.keyDown[i][j])
            {
                lp.setGridLight(i, j, 0);
            }
        }
    }
}

fun void release(int column, int row)
{
    Math.max(oscBank[column][row].gain() - releaseDecay, 0.00)
        => oscBank[column][row].gain;
}

fun void updateSustain(int column, int row, float targetGain)
{
    if(sustain && sustainStatus[column][row])
    {
        Math.max(oscBank[column][row].gain() - sustainDecay, 0.00)
            => oscBank[column][row].gain;
    }
    else
    {
        release(column, row);
    }
}

fun void updateSostenuto(int column, int row, float targetGain)
{
    if(sostenuto && sostenutoStatus[column][row])
    {
        Math.max(oscBank[column][row].gain() - sostenutoDecay, 0.00)
            => oscBank[column][row].gain;
    }
    else
    {
        updateSustain(column, row, targetGain);
    }
}

fun void update(int column, int row, float targetGain)
{
    if(lp.keyDown[column][row] && targetGain > oscBank[column][row].gain())
    {
        Math.min(oscBank[column][row].gain() + pressAttack, maxNoteGain)
            => oscBank[column][row].gain;
    }
    else
    {
        updateSostenuto(column, row, targetGain);
    }
}

fun void updateGains()
{
    float targetGain;
    while(true) {
        Math.max(0.0, (rawGain - 32) / 95.0) => targetGain;

        for(0 => int i; i < 8; i++)
        {
            for(0 => int j; j < 8; j++)
            {
                update(i, j, targetGain);
            }
        }

        gainResolution => now;
    }
}

fun int intPrompt(string msg)
{
    int in;
    ConsoleInput cin;
    StringTokenizer tok;
    cin.prompt(msg) => now;
    while(cin.more())
    {
        tok.set(cin.getLine());
        while(tok.more())
        {
            Std.atoi(tok.next()) => in;
        }
    }
    return in;
}

fun void launchpadListener()
{
    while(true)
    {
        lp.e => now;

        // ignore button presses that are not on the grid
        if(lp.e.column < 0 || lp.e.column > 8) continue;
        if(lp.e.row < 0 || lp.e.row > 8) continue;

        if(lp.e.column == 8)
        {
            if(lp.e.velocity == 127)
            {
                setTone(lp.e.row);
            }
        }
        else if(lp.e.velocity == 127)
        {
            if(sustain)
            {
                true => sustainStatus[lp.e.column][lp.e.row];
            }
            lp.setGridLight(lp.e.column, lp.e.row, keyOnColor);
            1 => oscBank[lp.e.column][lp.e.row].op;
        }
        else if(sostenuto && sostenutoStatus[lp.e.column][lp.e.row])
        {
            lp.setGridLight(lp.e.column, lp.e.row, keySostenutoColor);
        }
        else if(sustain && sustainStatus[lp.e.column][lp.e.row])
        {
            lp.setGridLight(lp.e.column, lp.e.row, keySustainColor);
        }
        else
        {
            lp.setGridLight(lp.e.column, lp.e.row, 0);
        }
    }
}

fun void wiiParser(MidiMsg msg)
{
    if(msg.data1 == 176) // midi CC
    {
        if(msg.data2 == 64)
        { // wiimote acceleration
            msg.data3 => rawGain;
        }
        else if (msg.data2 == 65)
        {   // wiimote button b
            if(msg.data3 == 127)
            {
                sustainOn();
            }
            else
            {
                sustainOff();
            }
        }
        else if (msg.data2 == 66)
        {   // wiimote button a
            if(msg.data3 == 127)
            {
                sostenutoOn();
            }
            else
            {
                sostenutoOff();
            }
        }
    }
}

fun void connectWiimote(int midiChannel)
{
    if(!wm.open(midiChannel)) me.exit();

    chout <= "Midi device: " <= midiChannel <= " -> " <= wm.name()
        <= IO.newline();
}

fun void wiiListener()
{
    MidiMsg msg;
    while(true)
    {
        wm => now;
        while(wm.recv(msg))
        {
            wiiParser(msg);
        }
    }
}

setup();

while(true)
{
    100::ms => now;
}
