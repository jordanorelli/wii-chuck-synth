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
public class Launchpad
{
    LaunchpadEvent e;
    MidiOut out;
    MidiIn in;
    int lightStatus[9][9];

    /*--------------------------------------------------------------------------

    Mock Constructor.  Creates a Launchpad object and initializes its input and
    output channels based on the supplied integer.

    --------------------------------------------------------------------------*/
    fun static Launchpad Launchpad(int midiChannel)
    {
        Launchpad lp;
        if(!lp.in.open(midiChannel)) me.exit();

        chout <= "Midi device: " <= midiChannel <= " -> " <= lp.in.name()
            <= IO.newline();
        if(!lp.out.open(midiChannel)) me.exit();

        chout <= "Midi device: " <= midiChannel <= " <- " <= lp.out.name()
            <= IO.newline();

        for(0 => int i; i < 9; i++) {
            for(0 => int j; j < 9; j++) {
                -1 => lp.lightStatus[i][j];
            }
        }

        lp.clear();
        spork ~ lp.midiListener();
        return lp;
    }

    fun void midiListener()
    {
        MidiMsg m;
        while(true) {
            in => now;
            while(in.recv(m)) {
                LaunchpadEvent.fromMidi(m).copyInto(e);
                e.signal();
                me.yield();
            }
        }
    }

    fun void setGridLight(int column, int row, int velocity)
    {
        setGridLight(LaunchpadEvent.LaunchpadEvent(column, row, velocity));
    }

    fun void setGridLight(LaunchpadEvent e)
    {
        if(lightStatus[e.column][e.row] == e.velocity) {
            return;
        }

        e.velocity => lightStatus[e.column][e.row];
        e.toMidi() @=> MidiMsg m;
        out.send(m);
    }

    fun void clear()
    {
        for(0 => int i; i < 9; i++) {
            for(0 => int j; j < 9; j++) {
                setGridLight(i, j, 0);
                10::ms => now;
            }
        }
    }
}
