// default file
me.sourceDir() + "/SafeOotpt.txt" => string filename;

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

// Initialize Float Temps
//  XYZ Velocities
0 => float x;
0 => float y;
0 => float z;

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

    // convert strings to floats
    // x, y, z velocities
    (xline.substring(3)).toFloat() => x;
    (yline.substring(3)).toFloat() => y;
    (zline.substring(3)).toFloat() => z;    

    
    // insert values into arrays
    xvel << x;
    yvel << y;
    zvel << z;    
}

<<< "End of Parse" >>>;

<<< "x array size:", xvel.size() >>>;
<<< "y array size:", yvel.size() >>>;
<<< "z array size:", zvel.size() >>>;

<<< "Start of Audio Generation" >>>;

Noise n => Gain g1 => HPF f => dac;

// Testrun is about 8k large
0 => int count;
0 => float maxvol;
400.0 => float jumpspeed;
500.0 => float topspeed;

// loop with time
while (count <= xvel.size())
{
    // Set Time to 64 Tick
    15.625::ms => now;
    //1::ms => now;
    
    // Get velocity on the XY plane
    Math.sqrt(Math.pow(xvel[count],2) 
            + Math.pow(yvel[count],2)) => float totalspeed;
    
    // Change noise velocity
    (totalspeed / topspeed) => g1.gain;

    // Change high pass filter
    if (zvel[count] > 1 || zvel[count] < -1) {
        5000.0 => f.freq;
    }
    else {
        100.0 => f.freq;
    }
     
    // Increment position in the array
    ++count;
}

<<< "Maximum velocity was " + maxvol >>>;
<<< "End of Audio Generation" >>>;
