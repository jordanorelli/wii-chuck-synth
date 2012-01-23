OscRecv recv;
6449 => recv.port;
recv.listen();
recv.event("/wii/1/accel/pry/3,f") @=> OscEvent e;
time ti;
float dt;
1000000.0 => float smallest;
while(true) {
    now => ti;
    e => now;
    (now - ti) / 1::ms => dt;
    while(e.nextMsg() != 0);
    if(dt > 0 && dt < smallest) {
        dt => smallest;
        chout <= smallest <= IO.newline();
    }
}
