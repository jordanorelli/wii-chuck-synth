import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress inbound;

boolean[] enabled = new boolean[64];

void setup() {
  size(410, 410);
  oscP5 = new OscP5(this, 9000);
}

void draw() {
  background(0);
  fill(255);
  stroke(128);
  for (int x = 0; x < 64; x++) {
    if (enabled[x]) {      
      rect(x % 8 * 50 + 10, height - (x / 8 * 50 + 50), 40, 40);
    }
  }
}

void oscEvent(OscMessage m) {
  int val = m.get(0).intValue();
  String pat = m.addrPattern();
  print(pat + " ");
  println(val);
  if (pat.equals("/grid/noteOn")) {
    rect(val % 8 * 50 + 10, height - (val / 8 * 50 + 50), 40, 40);
    enabled[val] = true;
  } else {
    enabled[val] = false;
  }
}

