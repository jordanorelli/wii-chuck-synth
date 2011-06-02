OscRecv recv;
6449 => recv.port;
recv.listen();

fun void printOscInt(string oscPath, string leader)
{
    recv.event(oscPath) @=> OscEvent e;
    while(true)
    {
        e => now;
        while(e.nextMsg() != 0)
        {
            chout <= leader <= e.getInt() <= IO.newline();
        }
    }
}

fun void printOscFloat(string oscPath, string leader)
{
    recv.event(oscPath) @=> OscEvent e;
    while(true)
    {
        e => now;
        while(e.nextMsg() != 0)
        {
            chout <= leader <= e.getFloat() <= IO.newline();
        }
    }
}

fun void pitch()
{
    printOscFloat("/wii/1/accel/pry/0,f", "");
}

fun void roll()
{
    printOscFloat("/wii/1/accel/pry/1,f", "\t");
}

fun void yaw()
{
    printOscFloat("/wii/1/accel/pry/2,f", "\t\t");
}

fun void accel()
{
    printOscFloat("/wii/1/accel/pry/3,f", "\t\t\t");
}

fun void A()
{
    printOscInt("/wii/1/button/A,i", "\t\t\t\t\t");
}

fun void B()
{
    printOscInt("/wii/1/button/B,i", "\t\t\t\t\t\t");
}

spork ~ pitch();
spork ~ roll();
spork ~ yaw();
spork ~ accel();
spork ~ A();
spork ~ B();

while(true)
{
    1::second => now;
}
