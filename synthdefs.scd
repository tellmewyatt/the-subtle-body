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
SynthDef(\threshCue, { | sensitivity=0.3, waitTime=0.1, in, gate=1, inputMultiplier=1 |
	// Will trigger if the sensitivity is crossed
	var input, trig;
	input = In.kr(in) * inputMultiplier;
	trig = input - sensitivity;
	SendTrig.kr(trig);
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
SynthDef(\noiseWind, { | out=0, pan = 0, amp = 0.2, pos=0 |
	var buffers, sig1, bufferNumber, bufferIndex, balancePos, sig2, sig;
	buffers = ~convolutionBuffers;
	sig1 = WhiteNoise.ar(0.05);
	bufferNumber = (buffers.size * (pos + 1) / 2);
	bufferIndex = bufferNumber.floor;
	balancePos =((bufferNumber - bufferNumber.trunc) * 2 - 1);
	sig2 = Balance2.ar(
		PlayBuf.ar(1, Select.kr(bufferIndex, buffers), 1, 1, loop: 1),
		PlayBuf.ar(1, Select.kr(bufferIndex + 1 % buffers.size, buffers) , 1, 1, loop: 1),
		balancePos
	).sum;
	sig = Convolution.ar(sig1, sig2, framesize: 1024) * 0.4;
	sig = HPF.ar(sig, 40);
	sig = Convolution.ar(sig, sig, framesize: 1024) * 0.1;
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;
SynthDef(\crackly, { | out = 0, speed=1, amp=0.2, pan=0, triggerThresh=0.05, bufnum, gate=1 |
	var sig, trigger, noiseSig, convolvedSig, env;
	env = EnvGen.kr(Env.asr(0.001, 1, 0.001));
	sig = Mix.ar(PlayBuf.ar(1, bufnum, speed * Rand(0.8, 4 ! 20), loop: 1));
	trigger = Amplitude.ar(sig) - triggerThresh;
	noiseSig = EnvGen.ar(Env.asr(0.001, 1, 0.001), trigger) * WhiteNoise.ar(0.4);
	convolvedSig = Convolution.ar(sig, noiseSig, 128);
	sig = HPF.ar(noiseSig + sig + convolvedSig, 1000);
	Out.ar(out, Pan2.ar(sig, pan, amp))
}).add;
SynthDef(\phatLead, { |
	out = 0,
	freq=200,
	amp=0.1,
	gate=1,
	pan=0,
	distortionBalance = -1,
	vibRate=2,
	vibAmount=0.1,
	fmAmount=1,
	sawLPCutoff=20000,
	portAmount=0.2,
	modIndex=20,
	modRatio = 2.5
	|
	var env, vib, modIndexMod, mod, sig, subOsc;
	// Add portamento
	freq = Lag.kr(freq, 0.2, 1);
	// Smooth out changes cutoff
	sawLPCutoff = Lag.kr(sawLPCutoff, 0.1);
	env = EnvGen.kr(Env.adsr(0.01, 0.3, 0.9, 0.1), gate, doneAction: 2);
	vib = SinOsc.ar(vibRate, 0, vibAmount).midiratio;
	modIndexMod = LFNoise2.kr(0.4).range(0.1, 1.9) * modIndex * fmAmount;
	mod = SinOsc.ar(freq * modRatio, 0, modIndexMod * freq);
	sig = SinOsc.ar(freq + mod * vib, 0);
	subOsc = Mix.ar(
		Saw.ar(freq / 4 * Rand(-0.1, 0.1 ! 10).midiratio * vib) + Saw.ar(freq / 2 * Rand(-0.1, 0.1 ! 10).midiratio * vib)) * 0.5;
	subOsc = LPF.ar(subOsc, sawLPCutoff);
	sig = sig + subOsc;
	sig = Mix.ar(Balance2.ar(sig, (sig * 4).softclip, distortionBalance));
	Out.ar(
		out,
		Pan2.ar(sig, pan,amp * env)
	)
}).add;
SynthDef(\dangerousTapDelay, { | tapMul = 2, tapDelay = 0.05, delayPitchRatio=1.4, grainRate=2, freq=300, out=0, gate=1, amp =0.2, pan=0.2, lpfCutoff=8000, hpfCutoff=20 |
	var trigger = Impulse.ar(grainRate);
	var env = EnvGen.kr(Env.asr, gate, doneAction:2);
	var buf = LocalBuf(s.sampleRate, 1).clear;
	var source = SinOsc.ar(freq) * 0.5 * EnvGen.kr(Env.perc, trigger);
	var cursor = Phasor.ar(0, 1, 0, BufFrames.ir(buf),1);
	var delay = Tap.ar(buf, 1, tapDelay);
	var sig = PitchShift.ar(delay * tapMul, 0.2, delayPitchRatio);
	sig = sig + source;
	sig = HPF.ar(sig, hpfCutoff);
	sig = Normalizer.ar(sig, 0.99);
	sig = Limiter.ar(sig, 0.6) * env;
	sig = LPF.ar(sig, lpfCutoff);
	BufWr.ar(sig, buf, cursor);
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;
SynthDef(\distortedPiano, { | amp=0.2, gate=1, freq=200, out=0, bufnum |
	var freqRatio = (freq / 43.midicps); // This is a G played on piano
	var attackTime = 1.5 / freqRatio;
	var env = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime
		),
		gate,
		doneAction: 2);
	var sig = Splay.ar(
		PlayBuf.ar(
			1,
			bufnum,
			BufRateScale.kr(bufnum) * Rand(0.98, 1.02 ! 4) * freqRatio
		)
	);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = sig +HPF.ar(Convolution2.ar(sig, ~convolutionBuffers.choose, 0, 1024) * 0.1, 100);
	sig = sig * 0.5 * amp * env;
	Out.ar(out, sig);
}).add;