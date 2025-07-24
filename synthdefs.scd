SynthDef(\primeMover, { | out=0, pitchRatio=1.0, amp=0.2, bufnum, ampMod=1, bufRateMod = 1, noiseRateMod=1 |
	var freqMod = LFDNoise0.kr(noiseRateMod.min(1).max(0) * 50, BufRateScale.ir(bufnum) * 0.5, 1);
	var bufRate = bufRateMod.min(1).max(0) + 1;
	var sound = PitchShift.ar(
		Mix.ar(PlayBuf.ar(
			1,
			bufnum,
			BufRateScale.ir(bufnum)* Rand(0.1,1.0 ! 10) * freqMod * bufRate, 1, loop: 1)) * amp,
		0.2, 1 + pitchRatio * 2.0
	) * ampMod.max(0).min(1);
	Out.ar(out,sound ! 2);
}).add;
SynthDef(\reverb, { | out=0, in, mix=0.5, room=0.5, damp=0.5 |
	var result = FreeVerb.ar(In.ar(in, 2), mix, room, damp);
	Out.ar(out, result);
}).add;
SynthDef(\superSaw, { | out = 0, freq = 200, spreadSemitones = 40, ampLFORate = 10, gate = 1, verbMix = 1, amp = 0.2, ampMod=1, freqSpreadMod=1 |
	var env = EnvGen.kr(Env.adsr(0.01, 1, 0.9, 0.01), gate, doneAction: 2);
	var sig = Saw.ar( (freq * (Rand(-1, 1 ! 40) * spreadSemitones * freqSpreadMod).midiratio).fold(30, 15000));
	sig = Splay.ar(sig * SinOsc.kr(Rand(0, 1 ! 40) * ampLFORate));
	sig = FreeVerb.ar(sig, verbMix, 1, 0.5);
	sig = env * sig / 2;
	sig = sig * amp;
	sig = sig * ampMod;
	Out.ar(out, sig);
}).add;
SynthDef(\comb, { | out = 0, in, freq = 60, decayTime=10, amp = 0 |
	var input = In.ar(in);
	var sig = Splay.ar(CombC.ar(input, 0.2, 10.collect { | i | 1/(freq * i +1) }, decayTime));
	Out.ar(out, sig * amp);
}).add;
SynthDef(\xyzToSpeed, { | in, out, t = 0.05 |
	var sig = LPF.kr(In.kr(in, 3), 1);
	var delayedSig = DelayN.kr(sig, t, t);
	var speed = (sig - delayedSig).pow(2).abs.sum.pow(1/2) / t;
	speed = LPF.kr(speed, 1);
	Out.kr(out, speed);
}).add;
SynthDef(\xyzsToDistance, { | in1, in2, out, min=0.15, max=1.0 |
	var input1 = In.kr(in1, 3);
	var input2 = In.kr(in2, 3);
	var distance = (input1 - input2).pow(2).abs.sum.pow(1/2) - min;
	distance = Gate.kr(distance, distance);
	Out.kr(out, distance.min(1).max(0));
}).add;