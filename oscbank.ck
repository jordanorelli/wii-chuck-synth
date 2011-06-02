public class OscBank
{
    int width;
    int height;
    int columnStep;
    int rowStep;
    string currentPatch;
    float baseFreq;
    float octaveSteps;
    UGen @ bank[][];
    Gain @ gains[][];

    fun static OscBank OscBank(int width, int height, int columnStep,
                               int rowStep, float baseFreq, float octaveSteps)
    {
        return OscBank(width, height, columnStep, rowStep, baseFreq,
                       octaveSteps, true);
    }

    fun static OscBank OscBank(int width, int height, int columnStep,
                               int rowStep, float baseFreq, float octaveSteps,
                               int autoPatch)
    {
        OscBank oscBank;
        width => oscBank.width;
        height => oscBank.height;
        columnStep => oscBank.columnStep;
        rowStep => oscBank.rowStep;
        baseFreq => oscBank.baseFreq;
        octaveSteps => oscBank.octaveSteps;
        new UGen[width][height] @=> oscBank.bank;
        new Gain[width][height] @=> oscBank.gains;

        ToneCalc.grid(width, height, columnStep, rowStep,  baseFreq, octaveSteps)
            @=> float toneMap[][];

        for(0 => int i; i < width; i++)
        {
            for(0 => int j; j < height; j++)
            {
                TriOsc s;
                toneMap[i][j] => s.freq;

                Gain g;
                0 => g.gain;
                s @=> oscBank.bank[i][j] => g @=> oscBank.gains[i][j];
            }
        }

        if(autoPatch == true)
        {
            oscBank.patch();
        }

        return oscBank;
    }

    fun int checkRange(int column, int row)
    {
        return !(column < 0
            || column >= width
            || row < 0
            || row >= height);
    }

    fun int checkRange(int column, int row, string identifier)
    {
        checkRange(column, row) => int val;
        if(!val)
            cherr <= "[Out of range in OscBank." <= identifier <= "()]\t"
                <= column <= "\t" <= row <= "\t" <= IO.newline();
        return val;
    }

    fun void setPatch(string targetPatch)
    {
        for(0 => int i; i < width; i++)
            for(0 => int j; j < height; j++)
                setPatch(targetPatch, i, j);
    }

    fun void setPatch(string targetPatch, int column, int row)
    {
        if(!checkRange(column, row, "setPatch"))
            return;

        Osc s;
        if(targetPatch == "SinOsc")
        {
            new SinOsc @=> s;
        }
        else if(targetPatch == "SqrOsc")
        {
            new SqrOsc @=> s;
        }
        else if(targetPatch == "SawOsc")
        {
            new SawOsc @=> s;
        }
        else if(targetPatch == "TriOsc")
        {
            new TriOsc @=> s;
        }
        else
        {
            cherr <= "Unrecognized targetPatch supplied in OscBank.setPatch:"
                <= targetPatch <= IO.newline();
        }

        toneMap()[column][row] => s.freq;
        0 => bank[column][row].op;
        bank[column][row] =< gains[column][row];
        s @=> bank[column][row] => gains[column][row];
    }

    fun void patch()
    {
        for(0 => int i; i < bank.size(); i++)
        {
            for(0 => int j; j < bank[0].size(); j++)
            {
                gains[i][j] => dac;
            }
        }
    }

    fun void unpatch()
    {
        for(0 => int i; i < bank.size(); i++)
            for(0 => int j; j < bank[0].size(); j++)
                unpatch(i, j);
    }

    fun void unpatch(int column, int row)
    {
        gains[column][row] =< dac;
    }

    fun void rebase(float freq)
    {
        for(0 => int i; i < bank.size(); i++)
        {
            for(0 => int j; j < bank[0].size(); j++)
            {
                bank[i][j] =< dac;
            }
        }
    }

    fun float getFreq(int column, int row)
    {
        if(checkRange(column, row))
        {
            return toneMap()[column][row];
        }
        else
            return 220.0;
    }

    fun void setGain(int column, int row, int value)
    {
        if(checkRange(column, row, "setGain"))
            value => bank[column][row].gain;
    }

    fun float getGain(int column, int row)
    {
        if(checkRange(column, row, "getGain"))
            return bank[column][row].gain();
        else
            return 0.0;
    }

    fun int getOp(int column, int row)
    {
        if(checkRange(column, row, "getOp"))
            return bank[column][row].op();
        else
            return false;
    }

    fun void setOp(int value)
    {
        if(value != 0 && value != 1 && value != false && value != true)
        {
            cherr <= "Invalid value sent to OscBank.setOp():" <= value
                <= IO.newline();
            for(0 => int i; i < width; i++)
            {
                for(0 => int j; j < height; j++)
                {
                    0 => bank[i][j].op;
                }
            }
        }
        else
        {
            for(0 => int i; i < width; i++)
            {
                for(0 => int j; j < height; j++)
                {
                    value => bank[i][j].op;
                }
            }
        }
    }

    fun float[][] toneMap()
    {
        return ToneCalc.grid(width, height, columnStep, rowStep,  baseFreq, octaveSteps);
    }
}
