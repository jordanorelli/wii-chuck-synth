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
public class LaunchpadEvent extends Event
{
    int column;
    int row;
    int velocity;

    fun static LaunchpadEvent LaunchpadEvent(int column, int row, int velocity)
    {
        if(column < 0 || column > 8) {
            cherr <= "Parameter out of range in LaunchpadEvent.LaunchpadEvent."
                <=  "  Supplied column value: " <= column <= ".  Maximum is 8."
                <= IO.newline();
            me.exit();
        }

        if(row < 0 || row > 8) {
            cherr <= "Parameter out of range in LaunchpadEvent.LaunchpadEvent."
                <=  "  Supplied column value: " <= column <= ".  Maximum is 8."
                <= IO.newline();
            me.exit();
        }

        if(velocity < 0 || velocity > 127) {
            cherr <= "Parameter out of range in LaunchpadEvent.LaunchpadEvent."
                <=  "  Supplied velocity value: " <= column
                <= ".  Maximum is 127." <= IO.newline();
            me.exit();
        }

        LaunchpadEvent e;
        column => e.column;
        row => e.row;
        velocity => e.velocity;
        return e;
    }

    fun static LaunchpadEvent fromMidi(MidiMsg m)
    {
        LaunchpadEvent e;
        if(m.data1 == 176) {
            8 => e.row;
            m.data2 - 104 => e.column;
        } else if(m.data1 == 144) {
            if(m.data2 % 16 == 8) {
                m.data2 / 16 => e.row;
            } else {
                7 - (m.data2 / 16) => e.row;
            }
            m.data2 % 16 => e.column;
        } else {
            cherr <= "Received request to parse unrecognized Midi message "
                <= "format.  Could not generate LaunchpadEvent."
                <= IO.newline();
        }
        m.data3 => e.velocity;
        return e;
    }

    fun void copyInto(LaunchpadEvent @ e)
    {
        column => e.column;
        row => e.row;
        velocity => e.velocity;
    }

    fun MidiMsg toMidi()
    {
        MidiMsg m;

        if(row == 8) {
            176 => m.data1;
            104 + column => m.data2;
        } else {
            144 => m.data1;
            if(column == 8) {
                16 * row + column => m.data2;
            } else {
                16 * (7 - row) + column => m.data2;
            }
        }

        velocity => m.data3;
        return m;
    }
}
