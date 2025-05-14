(/*
Water Wizard
By Wyatt Cannon
2024/12/09

To Run this patch click Language > Evaluate File or Command/Ctrl-Enter. To Stop Ctrl-.
Gestures:
1.	Open palm: make sound
2.	Closed palm: don’t make sound / stop making sound.
3.	Circle: keep doing whatever you are doing without the wizard’s guidance.
4.	Hands together: unified ensemble gesture – all warlocks should play together.

*/
var setupServer = {
	~instrGroup = Group.head;
	~effectsGroup = Group.tail;
	~effectsBus = Bus.audio(s,2);
	// Mouse Control Setup
	~mouseBus = Bus.control(s, 2);
	~mouseVelocityBus = Bus.control(s, 2);
	~mouseSpeedBus = Bus.control(s, 1);
	SynthDef.new(\mousePosition, { | out |
		Out.kr(out, [MouseX.kr(0, 1), MouseY.kr(0, 1)])
	}).add;
	~mouseSchedule = Routine{
		var prevPosition = [0,0];
		var interval = 0.02;
		loop {
			~mouseBus.getn(2, { | position |
				var newV = (position - prevPosition) / interval;
				var newSpeed = newV.pow(2).sum.pow(0.5);
				prevPosition = position;
				newV = newV.max(-1*2.pow(0.5)/2).min(2.pow(0.5)/2);
				~mouseVelocityBus.setn(newV);
				~mouseSpeedBus.set(newSpeed);
			});
			interval.yield;
		}
	}.play;
	// Samples
	~waterPour = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "./audio/water-pour.wav");
	~waterPitchDef = SynthDef.new(\waterPitch, { | out=0, pitchRatio=1.0, amp=0 |
		var freqMod = LFNoise0.kr(50, MouseY.kr(0, 1) * BufRateScale.ir(~waterPour) * 0.5, 1);
		var sound = PitchShift.ar(
			Mix.ar(PlayBuf.ar(
				1,
				~waterPour,
				BufRateScale.ir(~waterPour)* Rand(0.1,1.0 ! 10) * freqMod, 1, loop: 1)) * amp,
			0.2, pitchRatio * 2.0
		);
		Out.ar(out,sound ! 2);
	}).add;
	SynthDef.new(\filterbank, { | out, in |
		var input = In.ar(in, 2);
		var mod = MouseX.kr(-1, 1) * MouseY.kr(-1, 1);
		Out.ar(out, BBandPass.ar(input, Rand(200, 1000), 0.01, 100 * mod))
	}).add;
	SynthDef.new(\reverb, { | out=0, in, mix=0.5, room=0.5, damp=0.5 |
		var result = FreeVerb.ar(In.ar(in, 2), mix, room, damp);
		Out.ar(out, result);
	}).add;
};
s.waitForBoot({
	Routine({
		setupServer.value();
		s.sync;
		//~mouseSynth = Synth.new(\mousePosition, [\out, ~mouseBus]);
		~waterSynth = Synth.new(\waterPitch, [\out, ~effectsBus], target: ~instrGroup);
		~waterSynth.map(\amp, ~mouseSpeedBus );
		~waterSynth.map(\pitchRatio, ~mouseBus);
		//~filterbank = Synth.new(\filterbank, [\in, ~effectsBus, \out, ~effectsBus], target: ~effectsGroup, addAction:'addToHead');
		~reverb = Synth.new(\reverb, [\in, ~effectsBus, \out, 0, \mix, 0.15], target: ~effectsGroup, addAction:'addToTail');
	}).play;
})
)