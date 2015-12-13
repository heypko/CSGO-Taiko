// sound file
me.sourceDir() + "Samples/TLS2.wav" => string TLS2filename;
me.sourceDir() + "Samples/TD6-2.wav" => string TD62filename;
if( me.args() ) me.arg(0) => TLS2filename;

125.0 => float TLS2time;
500.0 => float TD62time;

// the patch 
SndBuf TLS2buf => SndBuf TD62buf => dac;
// load the file
TLS2filename => TLS2buf.read;
TD62filename => TD62buf.read;

// time loop
while( true )
{
    //256::ms => dur d;
    256::ms => now;
    0 => TLS2buf.pos;
    Math.random2f(.2,.4) => TLS2buf.gain;
    Math.random2f(1,1.2) => TLS2buf.rate;
    
    0 => TD62buf.pos;
    Math.random2f(.2,.4) => TD62buf.gain;
    Math.random2f(1,1.2) => TD62buf.rate;
    <<< TLS2buf.length >>>;
    
}