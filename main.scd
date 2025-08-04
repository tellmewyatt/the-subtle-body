(~patches = (
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
		var a = Synth(\crushing)
		.map(\rateMod, ~busses.handDistance);
		{ a.release; }
	}
);
~createWindow = {
	var active = [];
	w = Window.new("Keystrokes");

	w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
		keycode.postln;
		~toggleKey.(~patches[\swipes], 49, keycode);
		~toggleKey.(~patches[\supersaw], 50, keycode);
		~toggleKey.(~patches[\crushing], 51, keycode);

	};
	w.front;
};
s.waitForBoot {
	"SERVER LISTENING ON PORT: " ++ NetAddr.langPort;
	Routine {

		~buffers = ~buffers ? (
			water: Buffer.read(s, "./audio/water-pour.wav".resolveRelative),
			coffeeSustain: Buffer.readChannel(s, "./audio/coffee-cup_Sustains.wav".resolveRelative, channels:[0]),
			paperCrumple: Buffer.readChannel(s, "./audio/paper-crumple.wav".resolveRelative, channels:[0]),
			plasticCrumple: Buffer.readChannel(s, "./audio/plastic-bag-crumple.wav".resolveRelative, channels:[0]),
			paperTear: Buffer.readChannel(s, "./audio/paper-tear-1.wav".resolveRelative, channels:[0]),
		);
		this.executeFile("./synthdefs.scd".resolveRelative);
		this.executeFile("./functions.scd".resolveRelative);
		s.sync;
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
)
~poseLandmarker.getLandmarkSubBus('position', 'right wrist').scope