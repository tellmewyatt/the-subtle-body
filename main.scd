~patches = (
	swipes: { | test |
		var a, b;
		a = Synth(\primeMover, [\bufnum, ~buffers.water])
		.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'right wrist'))
		.map(\pitchRatio, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0))
		.map(\bufRateMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
		.map(\noiseRateMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1));
		b = Synth(\primeMover, [\bufnum, ~buffers.coffeeSustain])
		.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'left wrist'))
		.map(\pitchRatio, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(0))
		.map(\bufRateMod, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(1))
		.map(\noiseRateMod, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(1));
		{ a.release; b.release; }
	},
	supersaw: {
		var a = Synth(\superSaw)
		.map(\ampMod, ~busses.handDistance)
		.map(\freqSpreadMod, ~busses.handDistance)
		.map(\verbMix, ~busses.handDistance);
		{ a.release; }
	},
	crushing: {
		var pl = ~poseLandmarker;
		var handOverElbow = Bus.control;
		var diffSynth = {
			var wrists = In.kr(pl.getLandmarkSubBus('position', 'right wrist'), 3)
			+ In.kr(pl.getLandmarkSubBus('position', 'left wrist'), 3);
			var elbows = In.kr(pl.getLandmarkSubBus('position', 'right elbow'), 3)
			+ In.kr(pl.getLandmarkSubBus('position', 'left elbow'),3);
			// We only care about y dimension
			var difference = elbows[1] - wrists[1];
			difference;
		}.play(outbus: handOverElbow);
		var crushing = Synth(\crushing)
		.map(\rateMod, ~busses.handDistance)
		.map(\envGate, handOverElbow);
		{ crushing.free; diffSynth.free; handOverElbow.free; }
	},
	/*crossCue: {
		var seq = [0, 5, 7, 5, 4, 5, 3, 2, 1].collect { | n |
			Scale.minor.degreeToFreq(n);
		};
		var crossTell = {
			var amp = 0.2;
			var sensitivity = 0.3;
			var waitTime = 0.1;
			var rightWrist = In.kr(
				~poseLandmarker.getLandmarkSubBus('position', 'right wrist'));
			SendTrig.kr((rightWrist + sensitivity).neg, 0, 1);
			var tLeft = Trig1.kr(, waitTime);
			var leftWrist = In.kr(
				~poseLandmarker.getLandmarkSubBus('position', 'left wrist'));
			SendTrig.kr(leftWrist.neg + sensitivity).neg;
		}.play;

		{ crossTell.free; };
	},*/
	squareGrains: {
		var synths = [];
		var routine = r {
			loop {
				synths = synths.add(
					Synth(\squareGrain, [
						\kernel, ~convolutionBuffers.choose,
						\freq, ([60, 65, 69, 80]).choose.midicps,
						\dur, exprand(0.1, 4),
						\amp, rrand(0.15, 0.2)]
				));
				0.05.yield;
			}
		};
		routine.play;
		{ routine.stop; };
	},
	sawPulses: {
		var synths = [];
		var routine = r {
			var freq = 40.midicps;
			var y = 15.do { | i |
				var res = [3,4].midiratio * freq;
				synths = synths.add(Synth(\sawPulse, [\freq, res[0]]));
				synths = synths.add(Synth(\sawPulse, [\freq, res[1]]));
				freq = res[1];
				1.12.yield;
			};

		}.play;
		{
			routine.stop;
			synths.collect { | synth | synth.release; };
		}
	}

);
~createWindow = {
	var active = [];
	"creating window";
	w = w ? ( isClosed: true );
	if(w.isClosed, {
		"Restarting";
		w = Window.new("Keystrokes");
	});

	w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
		keycode.postln;
		~toggleKey.(~patches[\swipes], 49, keycode);
		~toggleKey.(~patches[\supersaw], 50, keycode);
		~toggleKey.(~patches[\crushing], 51, keycode);
		~toggleKey.(~patches[\crossCue], 52, keycode);

	};
	w.front;
};
// SETUP
s.options.memSize = s.options.memSize * 40;
s.waitForBoot {
	("SERVER LISTENING ON PORT: " ++ NetAddr.langPort).postln;
	Routine {
		// Setup
		~buffers = ~buffers ? (
			water: Buffer.read(s, "./audio/water-pour.wav".resolveRelative),
			coffeeSustain: Buffer.readChannel(s, "./audio/coffee-cup_Sustains.wav".resolveRelative, channels:[0]),
			paperCrumple: Buffer.readChannel(s, "./audio/paper-crumple.wav".resolveRelative, channels:[0]),
			plasticCrumple: Buffer.readChannel(s, "./audio/plastic-bag-crumple.wav".resolveRelative, channels:[0]),
			paperTear: Buffer.readChannel(s, "./audio/paper-tear-1.wav".resolveRelative, channels:[0]),
			voiceImpulse: Buffer.readChannel(s, "./audio/voice-impulse.wav".resolveRelative, channels:[0]),
			badPiano: Buffer.readChannel(s, "./audio/bad-piano.flac".resolveRelative, channels:[0])
		);
		~convolutionBuffers = 40.collect {
			var buf = Buffer.alloc(s, 1024, 1);
			buf;
		};
		this.executeFile("./synthdefs.scd".resolveRelative);
		this.executeFile("./functions.scd".resolveRelative);
		// Wait for all the synthdefs and buffers to be created on the server
		s.sync;
		// Set the value of the convolution buffers
		~convolutionBuffers.collect { | buf |
			buf.setn(0, 1024.collect { rrand(0, 1) }).normalize;
		};
		~poseLandmarker = ~createLandmarkerIn.([
			'nose',
			'left eye (inner)',
			'left eye',
			'left eye (outer)',
			'right eye (inner)',
			'right eye',
			'right eye (outer)',
			'left ear',
			'right ear',
			'mouth (left)',
			'mouth (right)',
			'left shoulder',
			'right shoulder',
			'left elbow',
			'right elbow',
			'left wrist',
			'right wrist',
			'left pinky',
			'right pinky',
			'left index',
			'right index',
			'left thumb',
			'right thumb',
			'left hip',
			'right hip',
			'left knee',
			'right knee',
			'left ankle',
			'right ankle',
			'left heel',
			'right heel',
			'left foot index',
			'right foot index'
		], '/pose_landmarks');
		~poseLandmarker.addBus('speed', 1);
		~poseLandmarker.landmarks.do { | landmark |
			var position = ~poseLandmarker.getLandmarkSubBus('position', landmark);
			var speed = ~poseLandmarker.getLandmarkSubBus('speed', landmark);
			Synth(\xyzToSpeed, [\in, position, \out, speed, \min, 0.2]);
		};
		~busses.handDistance =  ~busses.handDistance ? Bus.control(s, 1);
		Synth(\xyzsToDistance, [
			\in1, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist'),
			\in2, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist'),
			\out, ~busses.handDistance
		]);
	}.play;
	~createWindow.();
};
