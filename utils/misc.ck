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
public class Misc
{
    fun static string sprint(MidiMsg m)
    {
        string data1;
        string data2;
        string data3;

        if(m.data1 < 10) {
            "  " + m.data1 => data1;
        } else if(m.data1 < 100) {
            " " + m.data1 => data1;
        } else {
            "" + m.data1 => data1;
        }

        if(m.data2 < 10) {
            "  " + m.data2 => data2;
        } else if(m.data2 < 100) {
            " " + m.data2 => data2;
        } else {
            "" + m.data2 => data2;
        }

        if(m.data3 < 10) {
            "  " + m.data3 => data3;
        } else if(m.data3 < 100) {
            " " + m.data3 => data3;
        } else {
            "" + m.data3 => data3;
        }

        return m.toString() + "\t" + data1 + " " + data2 + " " + data3;
    }

    fun static void print(MidiMsg m)
    {
        chout <= sprint(m) <= IO.newline();
    }
}
