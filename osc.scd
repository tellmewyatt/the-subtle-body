(
~createPoseLandmarker = { | nLandmarks = 32 |
	~poseLandmarker = (
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
		// Only create the buses if we haven't created them already
		// There are 32 possible landmarks, each with a x,y,z
		positionBus: if(~poseLandmarker == nil, {
			Bus.control(s, nLandmarks * 3)
		}, { ~poseLandmarker.positionBus }),
		// Speed is a scalar value agnostic of direction.
		speedBus: if(~poseLandmarker == nil, {
			Bus.control(s, nLandmarks)
		}, { ~poseLandmarker.speedBus }),
		time: nil,
		position: nil,
		speed: [0]!nLandmarks,
		setPosition: { | self, time, position |
			var newSpeed = self.speed, deltat;
			if (self.time == nil, {
				self.time = time;
				self.position = position;
				newSpeed = 0;
			});
			deltat = time - self.time;
			// Calculate the speeds if we have a change in time
			if(deltat > 0, {
				var prevPositionTuples = self.position.reshape(nLandmarks, 3);
				var positionTuples = position.reshape(nLandmarks, 3);
				newSpeed = (
					(positionTuples - prevPositionTuples).pow(2)
					.collect { | xyz | xyz.sum }
				).pow(1/2) / deltat;
				self.speed = newSpeed;
			});
			self.positionBus.setn(position);
			self.speedBus.setn(newSpeed);
			self.position = position;
			self.time = time;
			self;

		},
		reset: { | self |
			self.time = nil;
			self.position = nil;
			self.speed = nil;
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
		},
		free: { | self |
			self.positionBus.free;
			self.speedBus.free;
		}
	);
};
~createPoseLandmarker.();
OSCdef(\poseLandmarkIn, { | msg, time, addr, recvPort |
	msg.removeAt(0);
	~poseLandmarker.setPosition(time, msg);
}, '/pose_landmarks');
);
~poseLandmarker.getSpeedBus("right wrist").scope