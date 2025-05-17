var setupServer = {
	~instrGroup = Group.head;
	~effectsGroup = Group.tail;
	~effectsBus = Bus.audio(s,2);
	// Samples
	~buffers = (
		waterPour: Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "audio/water-pour.wav"),
		coffeeCupSustains: Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname +/+ "audio/coffee-cup_Sustains.wav", channels: [0])
	);
	SynthDef(\primeMover, { | out=0, pitchRatio=1.0, amp=0, bufnum |
		var freqMod = LFNoise0.kr(50, BufRateScale.ir(bufnum) * 0.5, 1);
		var sound = PitchShift.ar(
			Mix.ar(PlayBuf.ar(
				1,
				bufnum,
				BufRateScale.ir(bufnum)* Rand(0.1,1.0 ! 10) * freqMod, 1, loop: 1)) * amp,
			0.2, 1 + pitchRatio * 2.0
		);
		Out.ar(out,sound ! 2);
	}).add;
	SynthDef(\reverb, { | out=0, in, mix=0.5, room=0.5, damp=0.5 |
		var result = FreeVerb.ar(In.ar(in, 2), mix, room, damp);
		Out.ar(out, result);
	}).add;
};
s.waitForBoot({
	Routine({
		setupServer.value();
		s.sync;
		Synth(\primeMover, [\out, ~effectsBus, \bufnum, ~buffers.waterPour], target: ~instrGroup)
		.map(\amp, ~poseLandmarker.getSpeedBus("right wrist"))
		.map(\pitchRatio, ~poseLandmarker.getPositionBus("right wrist").subBus(0, 1));
		Synth(\primeMover, [\out, ~effectsBus, \bufnum, ~buffers.coffeeCupSustains], target: ~instrGroup)
		.map(\amp, ~poseLandmarker.getSpeedBus("left wrist"))
		.map(\pitchRatio, ~poseLandmarker.getPositionBus("left wrist").subBus(0, 1));
		~reverb = Synth(\reverb, [\in, ~effectsBus, \out, 0, \mix, 0.15], target: ~effectsGroup, addAction:'addToTail');
	}).play;
})