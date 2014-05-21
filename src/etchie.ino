#define WORD_SIZE 6 // size of words in packet
#define WORD_MASK 0b00111111 // mask for sending words on PORTB
#define PACKET_SIZE 32
#define PACKET_BYTES (((PACKET_SIZE-1)/WORD_SIZE)+1)
#define CLOCK_PIN 7
#define READY_PIN 6

unsigned char X, Y;

void assert(boolean cond) {/*
  if (!cond)
    Serial.println("Error");
*/}

void clock() {
  delayMicroseconds(20); // output needs to be debounced
  digitalWrite(CLOCK_PIN, HIGH);
  delayMicroseconds(20);
  digitalWrite(CLOCK_PIN, LOW);
}

void sendNOP() {
  PORTB = WORD_MASK;
  for (int i = 0; i < PACKET_BYTES+2; i++)
    clock();
  PORTB = 0;
  clock();
}

void waitReady() {
  while (!digitalRead(READY_PIN)) {
    delayMicroseconds(20);
    if(!digitalRead(READY_PIN))
      sendNOP();
  }
}

// Packets are sent in words of WORD_SIZE bits each on PORTB (masked with WORD_MASK).
// Every time a word is sent, the clock is sent high and then low again.
void sendPacket(uint32_t packet) {
  waitReady();
  for (int i = PACKET_BYTES-1; i >= 0; i--) {
    PORTB = (packet >> (i*WORD_SIZE)) & WORD_MASK;
    clock();
  }
  PORTB = 0;
  clock();
}

// constructs a packet from X, Y, R, G and B values
// since we're sending 32-bit packets, we use the type uint32_t
uint32_t consPacket(uint32_t X, uint32_t Y, uint32_t R, uint32_t G, uint32_t B) {
  assert((R|G|B) < 0x10 && X < 200 && Y < 150);
  return (X << 24) | (Y << 16) | (R << 12) | (G << 8) | (B << 4);
}

void writePixel(uint32_t X, uint32_t Y, uint32_t R, uint32_t G, uint32_t B) {
  sendPacket(consPacket(X,Y,R,G,B));
}

// setup function
void setup() {
  // initialize data port
  DDRB = WORD_MASK;
  pinMode(CLOCK_PIN, OUTPUT);
  pinMode(READY_PIN, INPUT);
  
  // Start off with a NOP
  sendNOP();
}

void updateX() {
  X = analogRead(A0) * 200. / 1024.;
}

void updateY() {
  Y = analogRead(A1) * 150. / 1024.;
}

uint8_t getColorVal(int pin) {
  return analogRead(pin) * 15. / 1024.;
}

void loop() {
  // busy wait for changes in location
  uint8_t prevX = X;
  uint8_t prevY = Y;
  updateX();
  updateY();

  if (prevX == X && prevY == Y) {
    // send a NOP if we appear to have time
    static bool sentNOP = false;
    if (!sentNOP) {
      sendNOP();
      sentNOP = true;
    }
    
    return;
  }

  // get R, G, B values
  uint8_t R = getColorVal(A2);
  uint8_t G = getColorVal(A3);
  uint8_t B = getColorVal(A4);

  // send a packet constructed from the received values
  writePixel(X,Y,R,G,B);
}
