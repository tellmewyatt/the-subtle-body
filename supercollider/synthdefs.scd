// Control
SynthDef(\xyzToSpeed, { | in, out, t = 0.05, min =0, scale=0.2 |
	var sig = LPF.kr(In.kr(in, 3), 10);
	var delayedSig = DelayN.kr(sig, t, t);
	var speed = (sig - delayedSig).pow(2).abs.sum.pow(1/2) / t;
	speed = LPF.kr(speed, 10);
	speed = Gate.kr(speed - min, speed - min) * scale;
	speed = speed.min(1).max(0);
	Out.kr(out, speed);
}).add;
SynthDef(\xyzSum, { | in1, in2, out, in1mul=1, in2mul=1, outmul=1 |
	// A sum function that can be used to add or subtract two inputs
	var input1 = In.kr(in1, 3) * in1mul;
	var input2 = In.kr(in2, 3) * in2mul;
	var sum = (input1 + input2) * outmul;
	Out.kr(
		out,
		sum
	)
}).add;
SynthDef(\xyzsToDistance, { | in1, in2, out, min=0.15, max=1.0 |
	var input1 = In.kr(in1, 3);
	var input2 = In.kr(in2, 3);
	var distance = (input1 - input2).pow(2).abs.sum.pow(1/2) - min;
	distance = Gate.kr(distance, distance);
	Out.kr(out, distance.min(1).max(0));
}).add;
SynthDef(\threshCue, { | sensitivity=0.3, waitTime=0.2, in, gate=1, inputMultiplier=1 |
	// Will trigger if the sensitivity is crossed
	var input, trig;
	input = In.kr(in) * inputMultiplier;
	trig = Trig.kr(input - sensitivity, waitTime);
	SendTrig.kr(trig);
}).add;
SynthDef(\inwardAmpMod, { | in, out, max=0.9 |
	// Takes hand distance in as input and maps it to the range (0, 1), with distances closer to 0 being larger
	var input = In.kr(in, 1);
	var ampMod = ((1 - input).linexp(0, max, 0.01, 1.05) - 0.05).max(0);
	Out.kr(out, ampMod);
}).add;
SynthDef(\valueMinusInputScaled, { | value=1, in, out |
	// Returns (value - input).value, clipped to (0,1). Input is always negated
	Out.kr(out,
		((value - In.kr(in, 1).abs) * (1 / value)).min(1).max(0)
	)
}).add;
SynthDef(\busMul, { | in1, in2, out |
	// Multiplies two buses
	ReplaceOut.kr(out,
		In.kr(in1) * In.kr(in2)
	);
}).add;
SynthDef(\bufferControl, { | in, out, bufnum |
	// Scales an input signal based on a buffer (for example, a hanning window
	var value = BufRd.kr(
		1, bufnum,
		(In.kr(in).abs * BufFrames.kr(bufnum))
		.min(BufFrames.kr(bufnum))
		.max(0)
	);
	ReplaceOut.kr(out, value);
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
SynthDef(\primeMover2, { | out=0, amp=1, ampMod=1, pan=0, grainRate=20, bufnum,  playbackRate=1, playbackRateSpread=0, grainOverlap=4, gate = 1 |
       var trig = Impulse.ar(grainRate);
       var env = EnvGen.kr(Env.asr, gate, doneAction: 2);
       var sig = GrainBuf.ar(
               1,
               trig,
               grainOverlap/grainRate, // Grain duration
               bufnum,
               (playbackRate + (TRand.ar(-1, 1) * playbackRateSpread) * BufRateScale.kr(bufnum)), // playback rate
               TRand.ar(0, 1, trig) // Position
       );
       Out.ar(
               out,
               Pan2.ar(sig,
                       pan,
                       amp * ampMod * env)
       );
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
SynthDef(\superSin, { | out = 0, freq = 200, spreadSemitones = 40, ampLFORate = 10, gate = 1, verbMix = 1, amp = 0.4, ampMod=0, freqSpreadMod=1 |
	var env = EnvGen.kr(Env.adsr(0.01, 1, 0.9, 0.01), gate, doneAction: 2);
	var sig = SinOsc.ar( (freq * (Rand(-1, 1 ! 40) * spreadSemitones * freqSpreadMod).midiratio).fold(30, 15000));
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
SynthDef(\crushing, { | out = 0, amp = 0.8, rateMod = 1, gate=1, envGate=0, envGateMul= -1, envGateThresh=0.3, ampMod=1, spread=1, pan=0, panMul=1 |
	var freeEnv = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction: 2);
	var env = EnvGen.kr(Env.asr(1, 1, 0.1), envGateMul * envGate - envGateThresh);
	var rateModScaled = rateMod.min(1).max(0.4);
	var tear = Splay.ar(
		PlayBuf.ar(
			1,
			~buffers.paperTear,
			BufRateScale.ir(~buffers.paperTear) * Rand(0.6, 1 ! 3) * rateModScaled, loop: 1),
		spread,
		1,
		pan * panMul
	) * 0.8;
	var plasticCrumple = Splay.ar(
		PlayBuf.ar(
			1,
			~buffers.plasticCrumple,
			BufRateScale.ir(~buffers.plasticCrumple) * Rand(0.6, 1 ! 3) * rateModScaled, loop: 1
		),
		spread,
		1,
		pan * panMul
	);

	var paperCrumple = Splay.ar(
		PlayBuf.ar(1, ~buffers.paperCrumple, BufRateScale.ir(~buffers.paperCrumple) * Rand(0.5, 1 ! 3) * rateModScaled, loop: 1),
		spread,
		1,
		pan * panMul
	) * 2;

	var sig;
	sig = tear + plasticCrumple + paperCrumple;
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
SynthDef(\squareGrain, { | out = 0, gate=1, kernel, freq=400, amp=0.2, pan=0, grainDur=2, ampMod=1 |
	var sig = EnvGen.kr(Env.perc(0.01,grainDur), gate, doneAction: 2) * Pulse.ar(freq, 0.5, 0.1);
	sig = Convolution2.ar(sig, kernel, framesize:1024) * 0.2;
	sig = HPF.ar(sig, freq);
	ampMod = ampMod.min(1).max(0);
	Out.ar(out, Pan2.ar(sig, pan, amp * ampMod))
}).add;
SynthDef(\sawGrain, { | out = 0, gate=1, kernel, freq=400, amp=0.2, pan=0, grainDur=2, ampMod=1 |
	var sig = EnvGen.kr(Env.perc(0.01,grainDur), gate, doneAction: 2) * Mix.ar(20.collect { | i |
		DelayN.ar(Saw.ar(freq * Rand(0.99, 1.01), 0.1, 0.1), 0.2, Rand(0, 1 / freq))
	});
	sig = Convolution2.ar(sig, kernel, framesize:1024) * 0.2;
	sig = LPF.ar(sig, EnvGen.kr(Env.perc(0.01,grainDur /2), gate).range(100, 10000));
	sig = HPF.ar(sig, freq);
	ampMod = ampMod.min(1).max(0);
	Out.ar(out, Pan2.ar(sig, pan, amp * ampMod))
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
SynthDef(\noiseWind, { |
	out=0,
	pan = 0,
	amp = 0.2,
	pos=0,
	centerFreq=500,
	rq=1 ,
	ampMod = 1,
	gate=1,
	panMultiplier=1,
	posMultiplier=1,
	rqMultiplier=1,
	envGate=0,
	envGateMul= -1,
	envGateThresh=0.3
	|
	var buffers, sig1, bufferNumber, bufferIndex, balancePos, sig2, sig, env, freeEnv;
	rq = (rqMultiplier * rq).max(0.1);
	pos = (posMultiplier * pos).max(-1).min(1);
	env = EnvGen.kr(Env.asr(1, 1, 1), envGateMul * envGate - envGateThresh);
	freeEnv = EnvGen.kr(Env.asr, gate, doneAction: 2);
	buffers = ~convolutionBuffers;
	sig1 = BPF.ar(WhiteNoise.ar(0.05), centerFreq, rq);
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
	Out.ar(out, Pan2.ar(sig, pan * panMultiplier, amp * env * ampMod * freeEnv));
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
	ampMod=1,
	ampModMul=1,
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
		Pan2.ar(sig, pan,amp * ampMod * ampModMul * env)
	)
}).add;
SynthDef(\dangerousTapDelay, { | tapMul = 2, tapDelay = 0.05, delayPitchRatio=1.4, delayPitchRatioMul =1, delayPitchRatioAdd=0, grainRate=2, freq=300, out=0, gate=1, amp =0.2, pan=0.2, lpfCutoff=8000, hpfCutoff=20, release=7 |
	var trigger = Impulse.ar(grainRate);
	var env = EnvGen.kr(Env.perc(0.01, release), gate, doneAction:2);
	var buf = LocalBuf(s.sampleRate, 1).clear;
	var source = SinOsc.ar(freq) * 0.5 * EnvGen.kr(Env.perc, trigger);
	var cursor = Phasor.ar(0, 1, 0, BufFrames.ir(buf),1);
	var delay = Tap.ar(buf, 1, tapDelay);
	var sig = PitchShift.ar(delay * tapMul, 0.2, delayPitchRatio * delayPitchRatioMul + delayPitchRatioAdd);
	sig = sig + source;
	sig = HPF.ar(sig, hpfCutoff);
	sig = Normalizer.ar(sig, 0.99);
	sig = Limiter.ar(sig, 0.6) * env;
	sig = LPF.ar(sig, lpfCutoff);
	BufWr.ar(sig, buf, cursor);
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;
SynthDef(\distortedPiano, { |
	amp=0.2,
	gate=1,
	freq=200,
	out=0,
	bufnum, // Buffer to play
	startPosSeconds=0 // Position to play the buffer from
	pan=0,
	panSpread=1,
	panMultiplier=1, // Scales the pan input so that this can accept inputs from ranges of less than -1, 1
	attackTime=200,
	ampMod=1
	|
	var freqRatio = (freq / 43.midicps); // This is a G played on piano
	var sig, env;
	attackTime = min(1.5 / freqRatio, attackTime);
	env = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime
		),
		gate,
		doneAction: 2);
	sig = PlayBuf.ar(
		1,
		bufnum,
		BufRateScale.kr(bufnum) * Rand(0.98, 1.02 ! 4) * freqRatio,
		1,
		startPosSeconds * BufSampleRate.kr(bufnum)
	);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = Splay.ar(
		sig,
		panSpread,
		1,
		pan * panMultiplier);
	sig = sig +HPF.ar(Convolution2.ar(sig, ~convolutionBuffers.choose, 0, 1024) * 0.1, 100);
	sig = sig * 0.5 * amp * env;
	Out.ar(out, sig);
}).add;
SynthDef(\sinNoiseGrains, { | out=0, freq = 400, amp = 0.2, pan=0, gate=1, grainRate=4 |
	var env = EnvGen.kr(Env.adsr, gate);
	var trigger = Dust.kr(grainRate);
	var grainEnvs = EnvGen.kr(Env([0,1,1,0], [0.01, 0.05, 0.01]), trigger);
	var sig = SinOsc.ar(freq) + WhiteNoise.ar(0.1);
	sig = sig * grainEnvs;
	sig = FreeVerb.ar(sig, 0.4, 0.5, 0.9);
	Out.ar(out,
		Pan2.ar(sig, pan, amp * env);
	);

}).add;
SynthDef(\mysteriousPad, { | out=0, freq = 900, amp =0.1, pan=0, gate=1, freqSpreadSemitones=0.6, releaseTime=2, ampMod=1.0, ampModMul=1, bpfRQAdd = 0, attack=2 |
	var env, sig, filterEnv, diminuendoEnv;
	ampMod = (ampMod * ampModMul).max(0).min(1);
	env = EnvGen.kr(Env.adsr(attack, attack, 0.7, releaseTime), gate, doneAction: 2);
	sig = Mix.ar(20.collect { | i |
		var lfo = SinOsc.ar(Rand(0.1, 1), 0, 1);
		var spread = (lfo * Rand(freqSpreadSemitones.neg, freqSpreadSemitones)).midiratio;
		Saw.ar(
			freq * spread,
			Rand(0.1, 1))
	});
	filterEnv = EnvGen.kr(Env.triangle(8));
	sig = BPF.ar(sig, freq, 0.2 + filterEnv + bpfRQAdd);
	sig = sig + Mix.ar(
		SinOsc.ar([freq, freq * 2], 0, 0.1)
	);
	sig = FreeVerb.ar(sig, 0.8, 0.9);
	Out.ar(
		out,
		Pan2.ar(sig , pan, amp * env * ampMod )
	);

}).add;
SynthDef(\unstableSin, { | amp = 0.2, out=0, releaseTime=15, gate=1, panRate=0.7, panSpread=0.2, freq=400 |
	Out.ar(out,
		EnvGen.kr(Env.perc(1, releaseTime), gate, doneAction: 2) *
		Splay.ar(
			SinOsc.ar(
				freq * 20.collect {
					SinOsc.ar(Rand(0.1, 0.1), Rand(0, 1), Rand(-0.4, 0.4)).midiratio
			},0, 0.1),
			panSpread,
			1,
			LFNoise2.ar(panRate)
		) * amp
	)
}).add;
SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, releaseTime=1 |
	var sig = Pan2.ar(
		SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi).mean * amp * EnvGen.kr(Env.perc(0.001, releaseTime), 1, doneAction: 2),
		0);
	Out.ar(out, sig);
}).add;
SynthDef(\screams, { |
	rateScale = 1,
	rateScaleAdd = 0.5,
	rateScaleMul = -1,
	out=0,
	grainRate=20,
	amp=0.2,
	ampMod=1,
	envGate=1,
	gate=1,
	envGateThresh=0,
	envGateMul= -1,
	spread=0,
	pan = 0,
	panMul=1|
	var bufnums = NamedControl.kr(\bufnums, 0 ! 10, 0.01);
	var gateEnv = EnvGen.kr(Env.asr(0.2,1,1), envGateMul * envGate - envGateThresh);
	var env = EnvGen.kr(Env.asr(0.01, 1, 1), gate, doneAction: 2);
	var sig =
	Splay.ar(bufnums.collect { | bufnum |
		var rate = Rand(0.75, 1.25) * grainRate;
		if(bufnum > 0,
			GrainBuf.ar(1,
				Impulse.kr(rate) + Dust.kr(rate),
				8 / grainRate, bufnum,
				BufRateScale.kr(bufnum) * (rateScale * rateScaleMul + rateScaleAdd),
				LFNoise1.kr(1).range(0, 1));
		, 0);
	}, spread, 1, pan * panMul) * amp * ampMod * gateEnv * env;
	Out.ar(out, sig);
}).add;