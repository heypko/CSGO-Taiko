// default file
me.sourceDir() + "/safeOotpt2.txt" => string filename;

// look at command line
if( me.args() > 0 ) me.arg(0) => filename;

// instantiate
FileIO fio;

// open a file
fio.open( filename, FileIO.READ );

// ensure it's ok
if( !fio.good() )
{
    cherr <= "can't open file: " <= filename <= " for reading..."
          <= IO.newline(); 
    me.exit();
}

// Create Float arrays
float xvel[0];
float yvel[0];
float zvel[0];
float xori[0];
float yori[0];

// Initialize Float Temps
//  XYZ Velocities
0 => float x;
0 => float y;
0 => float z;
//  XY Origin
0 => float xO;
0 => float yO;

// loop until end
while( fio.more() )
{
    // Read text into strings
    // New Packet ----
    fio.readLine() => string newpacket;
    // x, y, z velocities
    fio.readLine() => string xline; 
    fio.readLine() => string yline; 
    fio.readLine() => string zline;
    // x, y positions
    fio.readLine() => string xOline;
    fio.readLine() => string yOline;

    // convert strings to floats
    // x, y, z velocities
    (xline.substring(3)).toFloat() => x;
    (yline.substring(3)).toFloat() => y;
    (zline.substring(3)).toFloat() => z;    
    // x, y positions
    (xOline.substring(4)).toFloat() => xO;
    (yOline.substring(4)).toFloat() => yO;
    
    // insert values into arrays
    xvel << x;
    yvel << y;
    zvel << z; 
    
    xori << xO;
    yori << yO;
}

<<< "End of Parse" >>>;

<<< "x array size:", xvel.size() >>>;
<<< "y array size:", yvel.size() >>>;
<<< "z array size:", zvel.size() >>>;
<<< "xO array size:", xori.size() >>>;
<<< "yO array size:", yori.size() >>>;


//-----------------------------------------------------------------
// Parsing Complete
// Composition Start
// Drums.
//-----------------------------------------------------------------

<<< "Start of Audio Generation" >>>;

// dac setup
SndBuf TLS2buf => Gain g1 => HPF f => dac;
SndBuf TLS1buf => g1;
SndBuf TLS0buf => g1;
SndBuf TD62buf => g1;
SndBuf TDH116buf => g1;
SndBuf TH1buf => g1;

// Set up array of sound directories
string allsounds[0];

// sound file
allsounds << me.sourceDir() + "Samples/TLS0.wav";
allsounds << me.sourceDir() + "Samples/TLS1.wav";
allsounds << me.sourceDir() + "Samples/TLS2.wav";
allsounds << me.sourceDir() + "Samples/TD6-2.wav";
allsounds << me.sourceDir() + "Samples/TDH1-16.wav";
allsounds << me.sourceDir() + "Samples/TH1.wav";

// load the file
allsounds[0] => TLS0buf.read; // TLS0
allsounds[1] => TLS1buf.read; // TLS1
allsounds[2] => TLS2buf.read; // TLS2
allsounds[3] => TD62buf.read; // TD62
allsounds[4] => TDH116buf.read; // TDH116
allsounds[5] => TH1buf.read; // TDH116

// Testrun is about 8k large
0 => int count;
0 => float maxvol;
400.0 => float jumpspeed;
400.0 => float topspeed;

// transition Low/High for rate limits.
.95 => float transLow;
1.05 => float transHigh;


// Set gains
Math.random2f(.1,.12) => float TLS0vol => TLS0buf.gain;
Math.random2f(.1,.12) => float TLS1vol => TLS1buf.gain;
Math.random2f(.1,.12) => float TLS2vol => TLS2buf.gain;
Math.random2f(.15,.2) => float TD62vol => TD62buf.gain;
Math.random2f(.15,.2) => float TDH116vol => TDH116buf.gain;
Math.random2f(.15,.2) => float TH1vol => TH1buf.gain;

// Set array of intervals for light instruments
int intervals[0];
intervals << 8;
intervals << 16;
intervals << 24;
intervals << 32;
intervals << 40;

0 => int i;
0 => int j;
0 => int k;

// Loop through matrix sizes
while (count <= xvel.size())
{      
    //Set Time to 64 Tick
    15.625::ms => now;
    
    // Different instruments different times, arranged by frequency

    // Light Stick 2
    if (count%intervals[i] == 0) {
        0 => TLS2buf.pos;
        Math.random2f(transLow,transHigh) => TLS2buf.rate;
        Math.random2(0, 2) => i;
    }
    
    // Light Stick 1
    if (count%intervals[j] == 0) {
        0 => TLS1buf.pos;
        Math.random2f(transLow,transHigh) => TLS1buf.rate;
        Math.random2(1, 3) => j;
    }
    
    // Light Stick 0
    if (count%intervals[k] == 0) {
        0 => TLS0buf.pos;
        Math.random2f(transLow,transHigh) => TLS0buf.rate;
        Math.random2(2, 4) => k;
    }
    
    
    // Taiko Drum 6-2
    if (count%128 == 0 || count%160 == 0) {
        0 => TD62buf.pos;
        Math.random2f(transLow,transHigh) => TD62buf.rate;
    } 
    
    // Taiko Hit 1
    if (count%480 == 0 || count%496 == 0) {
        0 => TH1buf.pos;
        Math.random2f(transLow,transHigh) => TH1buf.rate;
    }
    
    // Taiko Drum Hit 1-16
    if (count%512 == 0) {
        0 => TDH116buf.pos;
        Math.random2f(transLow,transHigh) => TDH116buf.rate;
    }
    
    // Get velocity on the XY plane
    Math.sqrt(Math.pow(xvel[count],2) 
            + Math.pow(yvel[count],2)) => float totalspeed;
    
    // Check for pitch change on entering new area
    if (xori[count] < -1360) {
        if (transLow < 1.1 && transHigh < 1.3) {
            transLow + 0.01 => transLow;
            transHigh + 0.01 => transHigh;
        }
    }
    else {
        if (transLow > .95 && transHigh > 1.05) {
            transLow - 0.01 => transLow;
            transHigh - 0.01 => transHigh;
        }
    }
    
    // Change noise velocity
    (totalspeed / topspeed) => g1.gain;

    
    // Change high pass filter settings
    if (zvel[count] > 1 || zvel[count] < -1) {
        // Remove heavier hits while mid-air.
        0.0 => TH1buf.gain;
        0.0 => TD62buf.gain;
        0.0 => TDH116buf.gain;
        // Gradually increase filter frequency (to avoid clipping)
        if (f.freq() < 1337.0) {
            10.0 + f.freq() => f.freq;
        }
    }
    else {
        // Gradually bring back volume of heavier hits
        if (TD62buf.gain() < TD62vol) {
            .001 + TDH116buf.gain() => TDH116buf.gain;
            .001 + TD62buf.gain() => TD62buf.gain;
        }
        
        // Gradually decrease filter frequency
        if (f.freq() > 10.0) {
            f.freq() - 10.0 => f.freq;
        }
    }
    
    // Increment position in the array
    ++count;
}

<<< "Maximum velocity was " + maxvol >>>;
<<< "End of Audio Generation" >>>;