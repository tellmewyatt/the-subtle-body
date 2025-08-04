~busses = ~busses ? ();
~createLandmarkerIn = { | landmarks, inpath='/pose_landmarks' |
	var getBusKey = { | key | (inpath ++ '_' ++ key).asSymbol };
	var result = (
		landmarks: landmarks,
		buses: (),
		getLandmarkSubBus: { | self, busKey, landmarkName |
			var sizePerLandmark, index;
			sizePerLandmark = self.buses[busKey].numChannels / landmarks.size;
			index = self.landmarks.indexOfEqual(landmarkName) * sizePerLandmark;
			self.buses.position.subBus(index, sizePerLandmark);
		},
		addBus: { | self, key, sizePerLandmark |
			var busKey = getBusKey.(key);
			~busses.postln;
			~busses[busKey].postln;
			~busses[busKey] = ~busses[busKey] ? Bus.control(s, landmarks.size * sizePerLandmark);
			self.buses[key] = ~busses[busKey];
		}
	);
	result.addBus('position', 3);
	OSCdef(inpath, { | msg, time, addr, recvPort |
		msg.removeAt(0);
		result.buses.position.setn(msg);
	}, inpath);
	result;
};
~keyToggles = ();
~toggleKey = { | function, keyCode, input |
	[keyCode, input].postln;
	if(input == keyCode, {
		if(~keyToggles[function].isFunction, { // Run the cleanup function
			"Running cleanup".postln;
			~keyToggles[function].();
			~keyToggles[function] = nil;
		}, { // or run the function
			var result = function.();
			result.postln;
			~keyToggles[function] = result;
		})
	});
};