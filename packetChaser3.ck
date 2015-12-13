// default file
me.sourceDir() + "/SafeOotpt2.txt" => string filename;

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

string allsounds[0];

// sound file
allsounds << me.sourceDir() + "Samples/TLS0.wav";
allsounds << me.sourceDir() + "Samples/TLS1.wav";
allsounds << me.sourceDir() + "Samples/TLS2.wav";
allsounds << me.sourceDir() + "Samples/TD6-2.wav";

// load the file
allsounds[0] => TLS0buf.read; // TLS0
allsounds[1] => TLS1buf.read; // TLS1
allsounds[2] => TLS2buf.read; // TLS2
allsounds[3] => TD62buf.read; // TD62

// Testrun is about 8k large
4000 => int count;
0 => float maxvol;
400.0 => float jumpspeed;
400.0 => float topspeed;






// Loop through matrix sizes
while (count <= xvel.size())
{       
    // 1/8 Seconds
    // 125::ms => now;
    
    //Set Time to 64 Tick
    15.625::ms => now;
    //1::ms => now;
    
    // Different notes different times
    // Light Stick
    if (count%16 == 0) {
        0 => TLS2buf.pos;
        Math.random2f(.1,.3) => TLS2buf.gain;
        Math.random2f(.9,1.1) => TLS2buf.rate;
    }
    
    // Drum
    if (count%128 == 0 || count%160 == 0) {
        0 => TD62buf.pos;
        Math.random2f(.1,.3) => TD62buf.gain;
        Math.random2f(.8,1.0) => TD62buf.rate;
    }
    
    // Get velocity on the XY plane
    Math.sqrt(Math.pow(xvel[count],2) 
            + Math.pow(yvel[count],2)) => float totalspeed;
    
    // Change noise velocity
    (totalspeed / topspeed) => g1.gain;

    // Change high pass filter
    if (zvel[count] > 1 || zvel[count] < -1) {
        100.0 => f.freq;
    }
    else {
        100.0 => f.freq;
    }
     
    // Increment position in the array
    ++count;
}

<<< "Maximum velocity was " + maxvol >>>;
<<< "End of Audio Generation" >>>;
