it's a synthesizer.  Depends on [OSCulator](http://www.osculator.net/) to get Wiimote input from bluetooth -> ChucK using OSC packets.

    echo - echos MIDI input back to the device that sent it.  On the Novation
    Launchpad, that means that every button that you press is lit up while you
    are pressing it.

    print - prints MIDI input message to the console.  Helpful for discovering
    key codes.

    osc_rcv - print OSC input messages to the console, for debugging.

    osc_resolution - listens for OSC input messages and prints the amount of
    time, in milliseconds between subsequent messages.  Used for finding the
    resolution of a timing device.

    resin - the actual synth.

to run:  Open up the osc-settings.oscd file in Osculator, discover your
Wiimote, and turn that sucker on.  Run osc\_rcv (`chuck osc_rcv`) to see if you
have communication.  Connect a Novation Launchpad and run the print program
(`chuck print`) to make sure you're receiving control data from the Launchpad.
Once you've got the two input devices working, run the actual synth with `chuck
resin`.
