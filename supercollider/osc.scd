SynthDef(\xyzToSpeed, { | in, out, t = 0.05 |
	var sig = In.kr(in, 3);
	var delayedSig = DelayN.kr(sig, t, t);
	var speed = (sig - delayedSig).pow(2).abs.sum.pow(1/2) / t;

	Out.kr(out, speed);
}).add;

~poseLandmarker = nil
(
~poseLandmarker = ~poseLandmarker ? (
	landmarks: [
		"nose",
		"left eye (inner)",
		"left eye",
		"left eye (outer)",
		"right eye (inner)",
		"right eye",
		"right eye (outer)",
		"left ear",
		"right ear",
		"mouth (left)",
		"mouth (right)",
		"left shoulder",
		"right shoulder",
		"left elbow",
		"right elbow",
		"left wrist",
		"right wrist",
		"left pinky",
		"right pinky",
		"left index",
		"right index",
		"left thumb",
		"right thumb",
		"left hip",
		"right hip",
		"left knee",
		"right knee",
		"left ankle",
		"right ankle",
		"left heel",
		"right heel",
		"left foot index",
		"right foot index"
	],
	setup: { | self |
		var nLandmarks = self.landmarks.size;
		self.positionBus = self.positionBus ? Bus.control(s, nLandmarks * 3);
		if(self.speedBus == nil, {
			var bus = Bus.control(s, nLandmarks);
			self.postln;
			nLandmarks.collect { | i |
				Synth(\xyzToSpeed, [\in, self.positionBus.subBus(i * 3, 3), \out, bus.subBus(i, 1)]);
			};
			self.speedBus = bus;
			bus;
		});
		OSCdef(\poseLandmarkIn, { | msg, time, addr, recvPort |
			msg.removeAt(0);
			self.positionBus.setn(msg);
		}, '/pose_landmarks');
		self;
	},
	getLandmarkIndex: { | self, landmarkName |
		var i = 0;
		var selected = -1;
		while { i < (self.landmarks.size - 1) } {
			if(self.landmarks[i] == landmarkName, {
				selected = i;
				i = self.landmarks.size;
			});
			i = i + 1;
		};
		if(selected == -1, {
			Error("Couldn't find specified landmark!").throw
		});
		selected
	},
	getPositionBus: { | self, landmarkName |
		var i = self.getLandmarkIndex(landmarkName);
		self.positionBus.subBus(i * 3, 3);
	},
	getSpeedBus: { | self, landmarkName |
		var i = self.getLandmarkIndex(landmarkName);
		self.speedBus.subBus(i);
	}
).setup();
~poseLandmarker.setup();
)
~poseLandmarker.getSpeedBus("right wrist").scope;