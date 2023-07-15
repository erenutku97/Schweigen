s.boot;
Server.killAll;
s.options.outDevice = "JackRouter"; // Ableton
s.options.outDevice = "ReaRoute"; // Reaper

// not necessary but good to have here
s.options.numWireBufs = 1024;
s.options.numWireBufs;
s.options.numWireBufs = 2048;
s.options.maxNodes = 2048;
s.options.sampleRate = 48000;
s.SampleRate
s.quit;
s.plotTree;
//////////////////////

// Time and spectral exponent arrays exported from Python
(
t = [12.88, 11.97, 11.68, 10.03, 10.3,  9.56,  9.37,  8.93,  7.93, 7.22,  6.84,  6.76,  6.44,  6.76, 6.07, 6.84,  5.42,  5.31, 5.88,  5.42,  5.15,  4.45,  4.39,  3.65,  4.13,  3.86,  3.65,  3.19, 3.35, 3.27,  3.79,  3.11,  3.03,  3.19,  3.11,  2.58, 3.72,  2.49,  2.49,  2.77,  3.03,  2.18,  2.77, 3.03, 2.39,  1.96,  1.96,  2.18,  2.39,  2.68,  2.08,  2.18,  1.73,  2.18, 2.77,  2.39,  2.18,  1.47, 1.6, 1.85,  1.6,  1.7,  1.85,  2.18,  1.96,  1.73,  1.33,  0.84,  1.01,  0.64,  1.47,  1.47,  1.96, 1.47, 1.85, 1.96,  2.29,  1.47,  1.6 ,  1.18,  2.18,  1.47,  0.84,  1.01,  1.73,  1.85,  1.85,  1.96, 1.33, 1.6 ,  2.18,  1.18,  0.84,  0.42,  2.29,  1.33,  0.42,  1.01,  1.33,  0.84,  0.42,  0.42,  1.47, 1.47, 1.73,  1.18,  0.42,  1.47,  1.6 ,  0.84,  0.84,  1.47,  0.84,  1.73,  1.47,  1.33,  1.33, 1.18, 1.18, 0.64,  1.6 , 1.01,  1.33,  1.33,  0.42,  1.18,  1.6 ,  0.84];
z = [2.7, 2.69, 2.68 , 2.67 , 2.631, 2.6  , 2.526, 2.611, 2.536, 2.533, 2.545, 2.477, 2.48 , 2.508, 2.402, 2.379, 2.371, 2.29 , 2.422, 2.314, 2.313, 2.316, 2.314, 2.3  , 2.323, 2.091, 2.318, 2.221, 2.175, 2.095, 2.178, 2.047, 1.997, 1.868, 2.11 , 1.997, 1.997, 1.965, 2.044, 2.037, 1.953, 1.958, 2.027, 1.903, 1.932, 1.984, 1.835, 1.907, 1.808, 1.746, 1.742, 1.775, 1.752, 1.759, 1.868, 1.712, 1.66 , 1.691, 1.791, 1.594, 1.518, 1.569, 1.289, 1.649, 1.487, 1.578, 1.488, 1.536, 1.401, 1.537, 1.331, 1.58 , 1.329, 1.449, 1.158, 1.226, 1.224, 1.37 , 1.233, 1.024, 1.043, 1.128, 1.07 , 0.973, 1.127, 1.087, 1.103, 1.103, 1.053, 1.057, 1.124, 1.109, 0.965, 1.096, 1.029, 0.951, 0.705, 0.843, 0.977, 0.912, 0.73 , 0.941, 0.811, 0.729, 0.845, 0.627, 0.635, 0.632, 0.344, 0.675, 0.553, 0.801, 0.621, 0.735, 0.509, 0.647, 0.452, 0.693, 0.274, 0.448, 0.365, 0.446, 0.37 , 0.394, 0.179, 0.338, 0.566, 0.125];
)

////////////// Spectral chord generator
(
c = {arg fund, scal, exp, add;
	Array.fill(15, {arg n;	fund*((scal*((n+1)-1)+1).pow(exp))+add //n+1 because SC begins at 0
})};
a = Array.fill(128, {arg n; c.value(55, 1, z.at(n), 0)}).reverse;
)
// Remove high freqs (need to run many times)
(
a.do({|n|
	//var j;
	//j = 0;
	for(0, n.size-1, {
		arg j, k;
		//j.postln;
		//n.at(j).postln;
		k = [n.at(j)>4100 or:{n.at(j)==55}];//.postln;
		//k[0].postln;
		if(k[0], {n.removeAt(j)});
		j = j+1;
	})
})
)

///////////////////////////////////////////// THE SYNTH
(
SynthDef.new(\Pad, {
	var saw, modsaw, sqr, modsqr, sin, modsin, noise, envsaw, envsqr, envsin, envfsaw, envFsqr, envFsin, lpsaw, lpsqr, lpsin, sig, bass, env, hpf, fx1, fx2, fx3, fx4, sawlpfmod, sqrlpfmod, sinlpfmod;

	// Saw Wave

	modsaw = LFNoise2.kr(freq: \modsawf.kr(20), mul: \modsawmul.kr(0)).linlin(-1,1,1-\modsawrange.kr(0.4).clip(0,1), 1+\modsawrange.kr(0.4));

	saw = SawDPW.ar(freq: (\freq.kr(440.0)*modsaw*(\sawfratio.kr(1).clip(0.25,3))).clip(20,20000));

	// LPF mod
	sawlpfmod = LFNoise2.ar(
		\lpmodratesaw.kr(20),
		\lpmodmulsaw.kr(0)).linlin(-1,1,1-\lpmodrngsaw.kr(0.5).clip(0,1),1+\lpmodrngsaw.kr(0.5).clip(0,1)
	);
	// LPF Env


	// LPF Saw
	saw = RLPF.ar(saw, freq: (\lpsawf.kr(20000)*sawlpfmod).clip(300,20000)
	);

	saw = RHPF.ar(saw, freq: 20)+RLPF.ar(SawDPW.ar(freq: (\freq.kr(440.0)*modsaw*((\sawfratio.kr(1)/2).clip(0.25,3))).clip(20,20000)), freq: (\lpsawf.kr(20000)*sawlpfmod).clip(500,20000));

	// Env Saw
	envsaw = LFNoise2.kr(freq: \envsawf.kr(40), mul: \envsawmul.kr(0)).linlin(0,1,0.5,1.3);
	saw = envsaw*saw*\ampsaw.kr(1);

	// Pan
	saw = Pan2.ar(saw, LFNoise1.kr(freq: \panrate.kr(20)).linlin(-1,1, 0-\panrng.kr(0.5).clip(0,0.8), 0+\panrng.kr(0.5).clip(0,0.8)));

////////////////////////////////////////////

	// Square Wave

	modsqr = LFNoise2.ar(freq: \modsqrf.kr(20),
		mul: \modsqrmul.kr(0)).linlin(0,1,1-\modsqrrange.kr(0.4), 1+\modsqrrange.kr(0.4)
	);

	sqr = Pulse.ar(
		freq: (\freq.kr(440.0)*modsqr*\sqrfratio.kr(0.5).clip(0.25,3)).clip(20,20000),
		width: \widthSqr.kr(0.99).clip(0,1)
	);

	// LPFmod
	//sqrlpfmod = SawDPW.kr(freq: \lpmodratesqr.kr(20)*LFNoise1.kr(40).linlin(0,1,0.5,2), iphase:1, mul:\lpmodmulsqr.kr(0)).linlin(0,1,1-\lpmodrngsqr.kr(0.5).clip(0,1),1+\lpmodrngsqr.kr(0.5).clip(0,1));

	sqrlpfmod = LFNoise1.ar(
	\lpmodratesqr.kr(20),
	\lpmodmulsqr.kr(0)).linlin(0,1,1-\lpmodrngsqr.kr(0.5).clip(0,1),1+\lpmodrngsqr.kr(0.5).clip(0,1));

	// LPF Env

	// LPF Square
	sqr = RLPF.ar(sqr, freq: (\lpsqrf.kr(20000)*sqrlpfmod).clip(500,20000));

	sqr = RHPF.ar(sqr, freq: 8000);

	// Env Square
	envsqr = LFNoise2.kr(freq: \envsqrf.kr(40),
		mul: \envsqrmul.kr(0)).linlin(0,1,0.5,1);
	sqr = envsqr*sqr*\ampsqr.kr(1);

	// Pan
	sqr = Pan2.ar(sqr, LFNoise1.kr(freq: \panrate.kr(20)).linlin(-1,1, 0-\panrng.kr(0.5).clip(0,0.8), 0+\panrng.kr(0.5).clip(0,0.8)));


//////////////////////////////////////////

	// Sine Wave

	modsin = LFNoise2.ar(freq: \modsinf.kr(20),
		mul: \modsinmul.kr(0)).linlin(0,1,1-\modsinrange.kr(0.4), 1+\modsinrange.kr(0.4));

	sin = SinOsc.ar(
		freq: (\freq.kr(440.0)*modsin*(\sinfratio.kr(1).clip(0.25,3))).clip(20,20000)
	)+SinOsc.ar(
		freq: (\freq.kr(440.0)*modsin*(\sinfratio2.kr(2).clip(0.25,3))).clip(20,20000)
	); /*+SinOsc.ar(
		freq: (\freq.kr(440.0)*modsin*(\sinfratio3.kr(3).clip(0.25,3))).clip(20,20000), mul: 1/2
	)*//*+SinOsc.ar(
		freq: (\freq.kr(440.0)*modsin*(\sinfratio4.kr(4).clip(0.25,3))).clip(20,20000), mul: 1/3
	);*/

	// LPFmod
	sinlpfmod = LFNoise2.ar(
		\lpmodratesin.kr(20),
	\lpmodmulsin.kr(0)).linlin(0,1,1-\lpmodrngsin.kr(0.5).clip(0,1),1+\lpmodrngsin.kr(0.5).clip(0,1));


	// LPF Sin
	sin = RLPF.ar(sin, freq: (\lpsinf.kr(20000)*sinlpfmod).clip(500,20000));

	// Env Sin
	envsin = LFNoise2.kr(freq: \envsinf.kr(40),
		mul: \envsinmul.kr(0)).linlin(0,1,0.5,1);

	sin = envsin*sin*\ampsin.kr(0.7);

	//Pan
	sin = Pan2.ar(sin, LFNoise1.kr(freq: \panrate.kr(20)).linlin(-1,1, 0-\panrng.kr(0.5).clip(0,0.8), 0+\panrng.kr(0.5).clip(0,0.8)));

////////////////////////////////////////////

	// Noise

	noise = RLPF.ar(GrayNoise.ar(mul: \mulNoise.kr(0),
		add: \addNoise.kr(0)), 900); // can be modulated by other modulators


/////////////////////////////////////////////

	// Collect all
	sig = saw+sqr+sin+noise;

	// LoPass All

	sig = RLPF.ar(sig, freq: \lpf.kr(20000).clip(500,20000));

	// Bass Boost

	bass = RLPF.ar(sig, freq: 256, mul: \bassamp.kr(0));

	// Envelope
	env = EnvGen.kr(Env.linen(attackTime: \atkt.kr(0.01), sustainTime: \sust.kr(0.5), releaseTime: \relt.kr(0.05)), \gate.kr(1), doneAction:2);
		//Env.perc(\atkt.ir(0.01), \relt.ir(0.05), \envlvl.kr(0.5), \envcurv.kr(15)), \gate.kr(1), doneAction: 2);
		//Env.linen(attackTime: 0.5, sustainTime: \sus.kr(0.5), releaseTime: 0.5), \gate.kr(0), doneAction:2);
		//Env.sine(dur: 1), \gate.kr(0), doneAction:2);
		//Env.adsr(attackTime:0.05, releaseTime:0.8), \gate.kr(0), doneAction:2);

	// HiPass All

	sig = HPF.ar(sig, freq: \hpf.kr(20).clip(20, 500));

	sig = (bass+sig)*\amp.kr(0.5)*env;
	//

	Out.ar(\out.kr(0), sig);

}).add;
)


// Preset 1
(
// Parameter Set
// OSC Amp
~ampsaw = 0.7;
~ampsqr = 0.5;
~ampsin = 0.1;

// Freq Ratio
~sawfratio = 1.985;
~sqrfratio = 2.01;
~sinfratio = 0.25;

// Pitch Mod
// Rate
~modsawf = 25;
~modsqrf = 10;
~modsinf = 15;
// Mul
~modsawmul = 1.1;
~modsrmul = 0.4;
~modsinmul = 0.4;
// Range
~modsawrange = 0.02;
~modsqrrange = 0.015;
~modsinrange = 0;

// Pre LPF
// Freq
~lpsawf = 1000; // not more than 2000
~lpsqrf = 15000; //  normally 1000
~lpsinf = 1000;

// LPF Mod
// Rate
~lpmodratesaw = 40; // 10
~lpmodratesqr = 5;
~lpmodratesin = 10;
// Mul
~lpmodmulsaw = 0.7;
~lpmodmulsqr = 1;
~lpmodmulsin = 0;
// Range
~lpmodrngsaw = 0.9;
~lpmodrngsqr = 0.9;
~lpmodrngsin = 0.5;

// OSC Env
// Rate
~envsawf = 10;
~envsqrf = 10;
~envsinf = 10;
// Mul
~envsawmul = 0.8;
~envsqrmul = 0.4;
~envsinmul = 0.7;

// Pan
// Rate
~panrate = 15;
// Range
~panrng = 0.9;

// LPF All
// Freq
~lpf = 10000;


// HPF All
// Freq
~hpf = 20;

// Bass Boost
~bassamp = 0.1;

// Volume
~amp = 0.5;
)

// Preset 2
(
// Parameter Set
// OSC Amp
~ampsaw = 0.7;
~ampsqr = 0.5;
~ampsin = 0.1;

// Freq Ratio
~sawfratio = 1.985;
~sqrfratio = 2.01;
~sinfratio = 0.25;

// Pitch Mod
// Rate
~modsawf = 25;
~modsqrf = 10;
~modsinf = 15;
// Mul
~modsawmul = 1.1;
~modsrmul = 0.4;
~modsinmul = 0.4;
// Range
~modsawrange = 0.02;
~modsqrrange = 0.015;
~modsinrange = 0;

// Pre LPF
// Freq
~lpsawf = 1000; // not more than 2000
~lpsqrf = 15000; //  normally 1000
~lpsinf = 1000;

// LPF Mod
// Rate
~lpmodratesaw = 40; // 10
~lpmodratesqr = 5;
~lpmodratesin = 10;
// Mul
~lpmodmulsaw = 0.7;
~lpmodmulsqr = 0.87;
~lpmodmulsin = 1;
// Range
~lpmodrngsaw = 0.9;
~lpmodrngsqr = 0.9;
~lpmodrngsin = 0.5;

// OSC Env
// Rate
~envsawf = 30;
~envsqrf = 50;
~envsinf = 70;
// Mul
~envsawmul = 0.8;
~envsqrmul = 0.4;
~envsinmul = 0.7;

// Pan
// Rate
~panrate = 15;
// Range
~panrng = 0.9;

// LPF All
// Freq
~lpf = 10000;


// HPF All
// Freq
~hpf = 20;

// Bass Boost
~bassamp = 0.1;

// Volume
~amp = 0.5;
)

// Sustained Pad with time and chords
(
var freq, dur;
freq = Routine({
	a.do({ |p| p.yield });
});
dur = Routine({
    t.do({ |dur| dur.yield });
});
r = Task({
    var delta;
		p.postln;
    while {
        delta = dur.next;
        delta.notNil
    } {
		freq.next.do({|n|
				Synth.new(
		\Pad,
		[
			\freq, n,
			\gate, 1,
			// Freq
			//\freq, nn.midicps,

			// OSC Amp
			\ampsaw, ~ampsaw,
			\ampsqr, ~ampsqr,
			\ampsin, ~ampsin,

			// Freq Ratio
			\sawfratio, ~sawfratio,
			\sqrfratio, ~sqrfratio,
			\sinfratio, ~sinfratio,

			// Pitch Mod
			// Rate
			\modsawf, ~modsawf,
			\modsqrf, ~modsqrf,
			\modsinf, ~modsinf,
			// Mul
			\modsawmul, ~modsawmul,
			\modsqrmul, ~modsqrmul,
			\modsinmul, ~modsinmul,
			// Range
			\modsawrange, ~modsawrange,
			\modsqrrange, ~modsqrrange,
			\modsinrange, ~modsinrange,

			// Pre LPF
			// Freq
			\lpsawf, ~lpsawf,
			\lpsqrf, ~lpsqrf,
			\lpsinf, ~lpsinf,

			// LPF Mod
			// Rate
			\lpmodratesaw, ~lpmodratesaw,
			\lpmodratesqr, ~lpmodratesqr,
			\lpmodratesin, ~lpmodratesin,
			// Mul
			\lpmodmulsaw, ~lpmodmulsaw,
			\lpmodmulsqr, ~lpmodmulsqr,
			\lpmodmulsin, ~lpmodmulsin,
			// Rng
			\lpmodrngsaw, ~lpmodrngsaw,
			\lpmodrngsqr, ~lpmodrngsqr,
			\lpmodrngsin, ~lpmodrngsin,

			// OSC Env
			// Rate
			\envsawf, ~envsawf,
			\envsqrf, ~envsqrf,
			\envsinf, ~envsinf,
			// Mul
			\envsawmul, ~envsawmul,
			\envsqrmul, ~envsqrmul,
			\envsinmul, ~envsinmul,

			// Pan
			// Rate
			\panrate, ~panrate,
			// Range
			\panrng, ~panrng,

			// LPF All
			// Freq
			\lpf, ~lpf,

			// HPF All
			// Freq
			\hpf, ~hpf,

			// Bass Boost
			\bassamp, ~bassamp,

			// Volume
			\amp, 0.25,

			//\atkt,
			//\sust
			\sust, delta
			]);
			//delta.yield;
			//n.yield;
		};
		);
			//p.next;
			delta.yield;
	};
	};
))


// Arpeggiator
(
var chords, dur, arp;
chords = Pseq(a, 1).asStream;
dur = Pseq(t, 1).asStream;
//~notes = Array.newClear(128);
r = Task({
	var delta, ch, c;
	while {
		delta = dur.next;
		ch = chords.next;
		delta.notNil;
	} {
		~time = delta;
		ch.postln;
		c = Pbind(
			\instrument, \Pad,
			\freq, Pxrand(ch, inf).poll,//Ptime(delta)).poll,
			//\gate, 1,
			// Freq
			//\freq, nn.midicps,
			\ampsaw, 0.5,
			\ampsqr, 1,
			\ampsin, 0.8,

			// Freq Ratio
			\sawfratio, 1.99,
			\sqrfratio, 2.01,
			\sinfratio, 0.99,

			// Pitch Mod
			// Rate
			\modsawf, 5,
			\modsqrf, 10,
			\modsinf, 15,
			// Mul
			\modsawmul, 0,
			\modsrmul, 0.4,
			\modsinmul, 0.4,
			// Range
			\modsawrange, 0.02,
			\modsqrrange, 0.015,
			\modsinrange, 0.01,

			// Pre LPF
			// Freq
			\lpsawf, 600, // not more than 2000
			\lpsqrf, 1700, //  normally 1000
			\lpsinf, 1000,

			// LPF Mod
			// Rate
			\lpmodratesaw, 15, // 10
			\lpmodratesqr, 5,
			\lpmodratesin, 5,
			// Mul
			\lpmodmulsaw, 0.2,
			\lpmodmulsqr, 0.87,
			\lpmodmulsin, 0.5,
			// Range
			\lpmodrngsaw, 0.2,
			\lpmodrngsqr, 0.9,
			\lpmodrngsin, 0.5,

			// OSC Env
			// Rate
			\envsawf, 30,
			\envsqrf, 50,
			\envsinf, 70,
			// Mul
			\envsawmul, 0.8,
			\envsqrmul, 0.8,
			\envsinmul, 0.7,

			// Pan
			// Rate
			\panrate, 15,
			// Range
			\panrng, 0.7,

			// LPF All
			// Freq
			\lpf, 10000,


			// HPF All
			// Freq
			\hpf, 20,

			// Bass Boost
			\bassamp, 0.1,

			// Volume
			\amp, 0.4,

			// Envelope
			\atkt, 0.4,
			\sust, 0,
			\relt, 0.01,
			\envlvl, 0.5,
			\envcurv, 20,

			\amp, 0.5,

			\dur, Pxrand([1/6, 0.2, 0.1], inf).poll//Ptime(delta)),
		);
		Psync(c, maxdur: delta).play;
		delta.yield; // Duration of chords
		//c.free;
	}
})
)

//////////////////////////// Pitch Shifter

// Allocations & Bus
(
b = Buffer.alloc(s, s.sampleRate * 5 /* this duration is arbitrary */, 1);
~micBus = Bus.audio(s,1);
~ptrBus = Bus.audio(s,1);
)

// Input, Pointer, Record Buffer
(
SynthDef.new(\mic, {
	arg in=0, out=0, amp=1;
	var sig;
	sig=SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\ptr, {
	arg out=0, buf=0, rate=1; // rate is for granular freeze
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf)*rate, 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

SynthDef.new(\rec, {
	arg ptrIn=0, micIn=0, buf=0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add; // there's no out since it only records the buffer
)


/// PitchShifter SynthDef
(
SynthDef.new(\PitchShift, {
	var sig, env, ptr;

	ptr = SoundIn.ar(\in.ir(0));

	sig = PitchShift.ar(in: ptr, windowSize: 0.1, pitchRatio: \ratio.kr(1)*LFNoise2.ar(\pitchmodf.kr(30)).linlin(-1,1,0.8,1.2));

	env = EnvGen.ar(envelope: Env.adsr(attackTime:0.01, releaseTime:0.5), gate: \gate.kr(1), doneAction: 2);

	sig = sig * env * \amp.kr(0.8) * LFNoise2.kr(freq:\ampmodf.kr(10)).linlin(-1,1,0.4,1);

	sig = Pan2.ar(in: sig, pos: LFNoise2.kr(30).linlin(-1,1,-0.7, 0.7));
	Out.ar(\out.kr(0), sig);
}).add;
)

// Run Reaper and set ReaRoute as input
(
~pitchShift = [-1.5, 1.2, 1.9, 2.4, 2.8].collect({
	arg n;
	Synth(\PitchShift, [\in, 0, \ratio, n.midiratio, \ampmodf, 40, \amp, 1.3], ~granGrp)
});
)


///////////////////// Quantum Bass Wavetable
(
SynthDef(\qTable, { |buf = 0, freq = 250.0, gain = 0.25, out = 0|
	var sig, env;
	sig = Osc.ar(buf, freq);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, \lp.kr(300));
	env = EnvGen.ar(Env.linen(attackTime: \atkt.ir(0.01), sustainTime: \sust.ir(0.2), releaseTime: \relt.ir(0.05)), \gate.kr(1), doneAction:2);
	Out.ar(out, sig*env*gain!2);
}).store;
)