fun void foo(dur rate) {
    SinOsc s => dac;
    while(true) {
        rate => now;
        Math.rand2f(5..0, 2000.0) => s.freq;
    }
}

spork ~ foo(0.5::second);
spork ~ foo(0.1::second);

while(true){ 1::second => now; }
