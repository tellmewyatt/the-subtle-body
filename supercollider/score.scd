~patches = (
	// These are the patches for the piece, Each Patch is a function that is executed and
	// Returns a cleanup funcion that frees the assets.
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
			var difference = elbows[1]
			- wrists[1]
			- ~config.sensitivity.handsOverElbows;
			difference;
		}.play(outbus: handOverElbow);
		var crushing = Synth(\crushing)
		.map(\rateMod, ~busses.handDistance)
		.map(\envGate, handOverElbow);
		{ crushing.free; diffSynth.free; handOverElbow.free; }
	},
	distortedPianoCues: {
		// createCue: landmarkName, axis, multiplier, sensitivity, function
		var xsensitivity = ~config.sensitivity.wristOutward;
		var ysensitivity = ~config.sensitivity.wristUpward;
		var downsensitivity = ~config.sensitivity.wristDownward;
		var transpose = -12;
		// The following synths free themselves so there is no cleanup function
		var triggers = [
			~poseLandmarker.createCue('right wrist', 1, 1, downsensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (36 + transpose).midicps, \amp, 0.1]);
			}),
			~poseLandmarker.createCue('right wrist', 0, -1, xsensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (48 + transpose).midicps, \amp, 0.1]);
			}),
			~poseLandmarker.createCue('left wrist', 0, 1, xsensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (49 + transpose).midicps, \amp, 0.1]);
			}),
			~poseLandmarker.createCue('right wrist', 1, -1, ysensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (56 + transpose).midicps, \amp, 0.1]);
			}),
			~poseLandmarker.createCue('left wrist', 1, -1, ysensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (58 + transpose).midicps, \amp, 0.1]);
			}),
			~poseLandmarker.createCue('left wrist', 1, 1, downsensitivity, {
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (53 + transpose).midicps, \amp, 0.1]);
			}),
		];
		{
			"cleaning up".postln;
			triggers.collect { | t | t.(); } };
	},
	mysteriousMelody: {
		// createCue: landmarkName, axis, multiplier, sensitivity, function
		var sensitivity = ~config.sensitivity.wristOutward;
		var index = 0;
		var seq = [
			68, 70, 60, // Phrase 1
			68, 70, 72, // Phrase 2
			73, 75, 77, 82, 79, // Phrase 3
			73, 75, 77, 82, 85, // Phrase 3
			85, 80, 77, // Phrase 4
			85, 80, 79, // Phrase 5
			84, 80, 79, // Phrase 6
			79, 72, 77, // Phrase 7
		];
		var synths = [];
		var rightWristXTrigger = ~poseLandmarker.createCue('right wrist', 0, -1, sensitivity, {
			synths = synths
			.add(
				Synth(\mysteriousPad, [\freq, seq[index].midicps, \amp, 0.3, \ampModMul, -1])
				.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			)
			.add(
				Synth(\mysteriousPad, [\freq, seq[index].midicps * 2, \amp, 0.3, \ampModMul, -1])
				.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			);
			index = index +1 % seq.size;
		});
		var leftWristXTrigger = ~poseLandmarker.createCue('left wrist', 0, 1, sensitivity, {
			synths.collect { | s | s.release };
			synths = [];
		});
		{
			synths.collect { | s | s.release };
			rightWristXTrigger.();
			leftWristXTrigger.();
		}
	},
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
~score = (
	part: ~config.player,
	pageIndex: 0,
	images: if(~score != nil,
		{
			~score.images
		},
		{
			PathName("score/svgs".resolveRelative).entries.sort{
				| a, b | a.absolutePath < b.absolutePath;
			}
			.collect { | path |
				Image.openSVG(path.absolutePath, Size(2048, 2048));
			}
		}
	),
	displayPage: { | self, pgIndex |
		w.drawFunc_({
			var wh = min(w.bounds.width, w.bounds.height);
			self.images[pgIndex].drawInRect(Rect(0, 0, wh, wh))
		});
		w.refresh;
	},
	parts: ( // Players 1, 2 or 3
		// Each part should return a cleanup function
		1: [{
			~patches[\mysteriousMelody].();
		}],
		2: [{
			~patches[\distortedPianoCues].();
		}
		],
		3: []
	),
	playPage: { | self, page |
		self.cleanUp.();
		self.pageIndex = page;
		self.displayPage(page);
		self.cleanUp = self.parts[self.part][page].();
	},
	incrementPage: { | self |
		self.playPage(self.pageIndex + 1);
	}
);