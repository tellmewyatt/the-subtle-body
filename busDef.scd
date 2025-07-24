~buses = ();
SynthDef(\xyzToSpeed, { | in, out, t = 0.05 |
	var sig = In.kr(in, 3);
	var delayedSig = DelayN.kr(sig, t, t);
	var speed = (sig - delayedSig).pow(2).abs.sum.pow(1/2) / t;

	Out.kr(out, speed);
}).add;
~createLandmarkerIn = { | landmarks, inpath='/pose_landmarks' |
	var getBusKey = { | key | inpath ++ "_" ++ key };
	var result = (
		landmarks: landmarks,
		buses: (),
		getLandmarkSubBus: { | self, busKey, landmarkName |
			var sizePerLandmark, index;
			sizePerLandmark = self.buses[busKey].numChannels / landmarks.size;
			sizePerLandmark.postln;
			index = self.landmarks.indexOfEqual(landmarkName) * sizePerLandmark;
			self.buses.position.subBus(index, sizePerLandmark);
		},
		addBus: { | self, key, sizePerLandmark |
			var busKey = getBusKey.(key);
			~buses[busKey] = ~buses[busKey] ? Bus.control(s, landmarks.size * sizePerLandmark);
			self.buses[key] = ~buses[busKey];
		}
	);
	result.addBus('position', 3);
	result.addBus('speed', 1);
	result.buses.postln;
	result.landmarks.do { | landmark |
		var position = result.getLandmarkSubBus('position', landmark);
		var speed = result.getLandmarkSubBus('speed', landmark);

		Synth(\xyzToSpeed, [\in, position, \out, speed]);
	};
	OSCdef(inpath, { | msg, time, addr, recvPort |
		msg.removeAt(0);
		result.buses.position.setn(msg);
	}, inpath);
	result;
};

x = ~createLandmarkerIn.([
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
	])
