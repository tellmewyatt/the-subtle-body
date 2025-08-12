// Control
SynthDef(\xyzToSpeed, { | in, out, t = 0.05, min =0 |
	var sig = LPF.kr(In.kr(in, 3), 10);
	var delayedSig = DelayN.kr(sig, t, t);
	var speed = (sig - delayedSig).pow(2).abs.sum.pow(1/2) / t;
	speed = LPF.kr(speed, 10);
	speed = Gate.kr(speed - min, speed - min);
	speed = speed.min(1).max(0);
	Out.kr(out, speed);
}).add;
SynthDef(\xyzSubtract, { | in1, in2, out |
	Out.kr(
		out,
		In.kr(in1, 3) - In.kr(in2, 3)
	);
}).add;

SynthDef(\xyzsToDistance, { | in1, in2, out, min=0.15, max=1.0 |
	var input1 = In.kr(in1, 3);
	var input2 = In.kr(in2, 3);
	var distance = (input1 - input2).pow(2).abs.sum.pow(1/2) - min;
	distance = Gate.kr(distance, distance);
	Out.kr(out, distance.min(1).max(0));
}).add;
// Sounds

SynthDef(\primeMover, { | out=0, pitchRatio=1.0, amp=0.4, bufnum, ampMod=1, bufRateMod = 1, gate=1 |
	var env = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate);
	var freqMod = LFDNoise0.kr(50, BufRateScale.ir(bufnum) * 0.5, 1);
	var bufRate = bufRateMod.min(1).max(0) + 1;
	var sound = PitchShift.ar(
		Mix.ar(PlayBuf.ar(
			1,
			bufnum,
			BufRateScale.ir(bufnum)* Rand(0.1,1.0 ! 10) * freqMod * bufRate, 1, loop: 1)) * amp,
		0.2, 1 + pitchRatio * 2.0
	) * ampMod.max(0).min(1) * env;
	Out.ar(out,sound ! 2);
}).add;
SynthDef(\reverb, { | out=0, in, mix=0.5, room=0.5, damp=0.5 |
	var result = FreeVerb.ar(In.ar(in, 2), mix, room, damp);
	Out.ar(out, result);
}).add;
SynthDef(\superSaw, { | out = 0, freq = 200, spreadSemitones = 40, ampLFORate = 10, gate = 1, verbMix = 1, amp = 0.4, ampMod=0, freqSpreadMod=1 |
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
SynthDef(\crushing, { | out = 0, amp = 0.8, rateMod = 1, gate=1, envGate=0 |
	var freeEnv = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction: 2);
	var env = EnvGen.kr(Env.asr(1, 1, 0.1), envGate);
	var rateModScaled = rateMod.min(1).max(0.4);
	var tear = Splay.ar(PlayBuf.ar(1, ~buffers.paperTear, BufRateScale.ir(~buffers.paperTear) * Rand(0.6, 1 ! 3) * rateModScaled, loop: 1)) * 0.8;
	var plasticCrumple = Splay.ar(PlayBuf.ar(1, ~buffers.plasticCrumple, BufRateScale.ir(~buffers.plasticCrumple) * Rand(0.6, 1 ! 3) * rateModScaled, loop: 1));
	var ampMod = ((1 - rateMod).linexp(0, 1, 0.01, 1.05) - 0.05).max(0);
	var paperCrumple = Splay.ar(PlayBuf.ar(1, ~buffers.paperCrumple, BufRateScale.ir(~buffers.paperCrumple) * Rand(0.5, 1 ! 3) * rateModScaled, loop: 1)) * 2;

	var sig;
	sig = tear + plasticCrumple;
	Out.ar(out, sig * amp * ampMod * env * freeEnv);
}).add;
SynthDef(\sawPulse, { | out=0, freq = 200, in, bufnum, gate=1, amp = 0.2 |
	// saw plulse
	var env = EnvGen.kr(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	var trig = Impulse.kr(10);
	var grainEnv = EnvGen.kr(Env.perc(0.01, 0.2, TRand.kr(0.5, 1)), trig);
	var sig = WhiteNoise.ar(1) * grainEnv;
	sig = CombC.ar(sig, 1, 1/freq, 0.2) ! 2 * 0.1;
	sig = Compander.ar(sig, sig, 0.5, 1, 0.1);
	sig = sig + Saw.ar(freq, grainEnv * 0.2);
	sig = LPF.ar(sig, 4000);
	Out.ar(out, sig * env * amp);
}).add;
SynthDef(\fmBell, { | out=0, freq = 800, gate=1, pan=0, amp=0.2, decayTime=5 |
	var env = EnvGen.kr(Env.perc(0, decayTime), gate, doneAction: 2);
	var modIndex = 10;
	var modRatio = Rand(0.98, 1.02) * 1.28;
	var freqModEnv = EnvGen.kr(Env.perc(0.01, decayTime * Rand(0.9, 1.1)));
	var freqMod = SinOsc.ar(freq * modRatio, 0, modIndex * freq * freqModEnv);
	var sig = SinOsc.ar(freq + freqMod);
	sig = FreeVerb.ar(sig, 0.1, 0.1) * env;
	Out.ar(out, Pan2.ar(
		sig,
		pan,
		amp
	));
}).add;
SynthDef(\grainConvolver, { | out = 0, amp=0.2, position=0, bufnum, pan=0, gate=1 |
	var env = EnvGen.kr(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	var sig = GrainBuf.ar(1, Impulse.kr(20), 0.1, bufnum, BufRateScale.kr(bufnum), position) * env * 0.5;
	sig = Convolution.ar(sig, sig) + sig;
	Out.ar(out,
		Pan2.ar(sig, pan, amp));
}).add;
SynthDef(\squareGrain, { | out = 0, gate=1, kernel, freq=400, amp=0.2, pan=0, dur=2 |
	var sig = EnvGen.kr(Env.perc(0.01,dur), gate, doneAction: 2) * Pulse.ar(freq, 0.5, 0.1);
	sig = Convolution2.ar(sig, kernel, framesize:1024) * 0.2;
	sig = HPF.ar(sig, freq);
	Out.ar(out, Pan2.ar(sig, pan, amp))
}).add;
SynthDef(\weightedGrainSynth, { | out = 0, amp=0.2, position=0, bufnum, pan=0, gate=1, prefer |
	var env = EnvGen.kr(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	var sig = GrainBuf.ar(
		1, // Channels
		Impulse.kr(200), //  Trigger
		0.1, // Duration
		TWChoose.kr(Impulse.kr(10), ~buffers.values, [1,2,3,4], normalize: 1), // Buffer
		BufRateScale.kr(bufnum), // Speed
		LFNoise1.kr(1)) * env * 0.5;
	Out.ar(out, sig  ! 2);
}).add;