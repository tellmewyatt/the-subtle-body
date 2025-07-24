s.waitForBoot {
	"SERVER LISTENING ON PORT: " ++ NetAddr.langPort;
	Routine {
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
			Synth(\xyzToSpeed, [\in, position, \out, speed]);
		};
	}.play;
};
~poseLandmarker.getLandmarkSubBus('speed', 'right wrist').scope;