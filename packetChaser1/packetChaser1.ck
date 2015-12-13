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

0 => float x;
0 => float y;
0 => float z;

// loop until end
while( fio.more() )
{
    fio.readLine() => string newpacket;
    fio.readLine() => string xline; 
    fio.readLine() => string yline; 
    fio.readLine() => string zline; 

    (xline.substring(3)).toFloat() => x;
    (yline.substring(3)).toFloat() => y;
    (zline.substring(3)).toFloat() => z;
    
    xvel << x;
    yvel << y;
    zvel << z; 
}

<<< "End of Parse" >>>;

<<< "x array size:", xvel.size() >>>;
<<< "y array size:", yvel.size() >>>;
<<< "z array size:", zvel.size() >>>;

<<< "Start of Audio Generation" >>>;

Noise n => Gain g1 => dac;

0 => int count;
0 => float maxvol;
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
    
    // For Logging Purposes
    
    if (totalspeed > maxvol)
        totalspeed => maxvol;
    <<< totalspeed >>>;
    
    
    // Change noise velocity
    (totalspeed / topspeed) => g1.gain;
    
    // Increment position in the array
    ++count;       
}

<<< "Maximum velocity was " + maxvol >>>;
<<< "End of Audio Generation" >>>;
