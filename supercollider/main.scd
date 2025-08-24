~createWindow = {
	var active = [];
	"creating window";

	w = w ? ( isClosed: true );
	if(w.isClosed, {
		var image;
		"Restarting";
		w = Window.new("Keystrokes");
		image = Image.openSVG("score/title-page.svg".resolveRelative, Size(2048, 2048));
		w.drawFunc_({
			var wh = min(w.bounds.width, w.bounds.height);
			image.drawInRect(Rect(0, 0, wh, wh))
		});
	});
	w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
		// Use alphabet keys for each page
		var alphabetical = keycode - 97;
		keycode.postln;
		if(alphabetical <= 25, {
			~score.playPage(alphabetical);
		});
		// Escape key
		if(keycode == 65307, {
			~score.cleanUp();
		});
		if(keycode == ~config.incrementScoreKeyCode, {
			~score.incrementPage();
		});

	};
	w.front;
};
// SETUP
s.options.memSize = s.options.memSize * 40;
s.waitForBoot {
	("SERVER LISTENING ON PORT: " ++ NetAddr.langPort).postln;
	this.executeFile("./config.scd".resolveRelative);
	~createWindow.();
	this.executeFile("./score.scd".resolveRelative);
	Routine {
		// Setup
		~buffers = ~buffers ?? { (
			water: Buffer.read(s, "./audio/water-pour.wav".resolveRelative),
			coffeeSustain: Buffer.readChannel(s,
				"./audio/coffee-cup_Sustains.wav".resolveRelative, channels:[0]),
			paperCrumple: Buffer.readChannel(s,
				"./audio/paper-crumple.wav".resolveRelative, channels:[0]),
			plasticCrumple: Buffer.readChannel(s,
				"./audio/plastic-bag-crumple.wav".resolveRelative, channels:[0]),
			paperTear: Buffer.readChannel(s,
				"./audio/paper-tear-1.wav".resolveRelative, channels:[0]),
			voiceImpulse: Buffer.readChannel(s,
				"./audio/voice-impulse.wav".resolveRelative, channels:[0]),
			badPiano: Buffer.readChannel(s, "./audio/bad-piano.flac".resolveRelative, channels:[0])
		)
		};
		~convolutionBuffers = ~convolutionBuffers ??  {
			40.collect {
				var buf = Buffer.alloc(s, 1024, 1);
				buf;
			}
		};
		// Import necessary files
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
		~busses.handDistance =  ~busses.handDistance ?? { Bus.control(s, 1) };
		Synth(\xyzsToDistance, [
			\in1, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist'),
			\in2, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist'),
			\out, ~busses.handDistance
		]);
	}.play;
};