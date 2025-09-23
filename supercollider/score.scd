~openingPhrase = [
	68, 70, 60, // Phrase 1
	68, 70, 72, // Phrase 2
	73, 75, 77, 82, 79, // Phrase 3
	73, 75, 77, 82, 85, // Phrase 3
	85, 80, 77, // Phrase 4
	85, 80, 79, // Phrase 5
	84, 80, 79, // Phrase 6
	79, 72, 77, // Phrase 7
];
~patches = (
	// These are the patches for the piece, Each Patch is a function that is executed and
	// Returns a cleanup funcion that frees the assets.
	swipesP2: { | test |

		var synths = [
			Synth(\primeMover2, [\bufnum, ~buffers.water, \amp, 2, \playbackRateSpread, 0.2, \grainOverlap, 16, \grainRate, 30, \playbackRateAdd, 0.2, \posMul, -1])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'right wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1)),
			Synth(\primeMover2, [\bufnum, ~buffers.water, \amp, 2, \playbackRateSpread, 0.4, \grainOverlap, 16, \grainRate, 30, \playbackRateAdd, 0.2])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'left wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(0))
		];
		{ synths.collect { | s | s.release }; }
	},
	swipesP1: {
		var synths = [
			Synth(\primeMover2, [\bufnum, ~buffers.noiseWind, \amp, 1.8, \playbackRateSpread, 0.1, \grainOverlap, 16, \grainRate, 20, \playbackRateAdd, 1.3, \playbackRateMul, 3])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'right wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1)),
			Synth(\primeMover2, [\bufnum, ~buffers.noiseWind, \amp, 1.8, \playbackRateSpread, 0.4, \grainOverlap, 16, \grainRate, 20, \playbackRateAdd, 0.5, \playbackRateMul, 3])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'left wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(0))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(1)),
		];
		{ synths.collect { | s | s.release }; }
	},
	swipesP0: {
		var synths = [
			Synth(\primeMover2, [\bufnum, ~buffers.plasticCrumple, \amp, 1.8, \playbackRateSpread, 0, \grainOverlap, 16, \grainRate, 20, \playbackRateAdd, 1.3, \playbackRateMul, 3])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'right wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1)),
			Synth(\primeMover2, [\bufnum, ~buffers.plasticCrumple, \amp, 1.8, \playbackRateSpread, 0, \grainOverlap, 16, \grainRate, 20, \playbackRateAdd, 0.5, \playbackRateMul, 3])
			.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('speed', 'left wrist'))
			.map(\playbackRate, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(0))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(1)),
		];
		{ synths.collect { | s | s.release }; }
	},
	superSaw: {
		var a = Synth(\superSaw)
		.map(\ampMod, ~busses.handDistance)
		.map(\freqSpreadMod, ~busses.handDistance)
		.map(\verbMix, ~busses.handDistance);
		{ a.release; }
	},
	superSin: {
		var a = Synth(\superSin, [\freq, 800])
		.map(\ampMod, ~busses.handDistance)
		.map(\freqSpreadMod, ~busses.handDistance)
		.map(\verbMix, ~busses.handDistance);
		{ a.release; }
	},
	crushing: {
		var pl = ~poseLandmarker;
		var busses = (
			ampMod: Bus.control
		);
		var ampMod = Synth(\inwardAmpMod, [\in, ~busses.handDistance, \out, busses.ampMod]);
		var crushing = Synth(\crushing, [\envGateThresh, ~config.sensitivity.wristAboveWaist, \amp, 1])
		.map(\rateMod, ~busses.handDistance)
		.map(\envGate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
		.map(\ampMod, busses.ampMod);
		{ crushing.free; busses.entries.collect { | b | b.free; } }
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
		var seq = ~openingPhrase;
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
	mysteriousMelodyLow: {
		// createCue: landmarkName, axis, multiplier, sensitivity, function
		var sensitivity = ~config.sensitivity.wristOutward;
		var index = 0;
		var seq = ~openingPhrase - 26;
		var synths = [];
		var rightWristXTrigger = ~poseLandmarker.createCue('right wrist', 0, -1, sensitivity, {
			if(synths.size == 0, {
				synths = synths
				.add(
					Synth(\mysteriousPad, [\freq, seq[index].midicps, \amp, 0.3, \ampModMul, -1, \bpfRQAdd, 10])
					.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
				)
				.add(
					Synth(\mysteriousPad, [\freq, seq[index].midicps * 2, \amp, 0.3, \ampModMul, -1, \bpfRQAdd, 10])
					.map(\ampMod, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
				);
			}, {
				synths[0].set(\freq,seq[index].midicps);
				synths[1].set(\freq,seq[index].midicps * 2);
			});
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
	pulsyCresc: {
		var xsensitivity=~config.sensitivity.wristOutward;
		var synths = [];
		var routine = r {
			var freq = 40.midicps;
			var y = 15.do { | i |
				var res = [3,4].midiratio * freq;
				synths = synths.add(Synth(\sawPulse, [\freq, res[0], \amp, 0.4]));
				synths = synths.add(Synth(\sawPulse, [\freq, res[1], \amp, 0.4]));
				freq = res[1];
				1.12.yield;
			};

		};
		var cleanup = { | triggers |
			routine.stop;
			routine.reset;
			synths.collect { | synth | synth.release; };
			triggers.collect { | t | t.() };
		};
		var triggers = [
			~poseLandmarker.createCue('right wrist', 0, -1, xsensitivity, {
				routine.next;
			}),
			~poseLandmarker.createCue('left wrist', 0, 1, xsensitivity, {
				routine.next;
			}),
			~poseLandmarker.createCue('right wrist', 1, 1, ~config.sensitivity.wristAboveWaist.neg, {

				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (24).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (36).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (48).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
				Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (60).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
				Synth(\bassDrum, [\freq, 30, \releaseTime, 10]);
				Synth(\unstableSin, [\freq, (88.midicps)]);
				Synth(\unstableSin, [\freq, (84.midicps), \amp, 0.1]);
				// Release this synth, we should only be able to play one note.
				cleanup.(triggers);
			})
		];
		cleanup;
	},
	squareGrains: {
		var pdef, routine;
		pdef = Pbindef(\squareGrains,
			\instrument, \squareGrain,
			\kernel, Prand(~convolutionBuffers, inf),
			\freq, Prand([60, 65, 69, 80].midicps, inf),
			\grainDur, Pexprand(0.1,4),
			\amp, Pwhite(0.15, 0.2),
			\dur, 0.05
		);
		pdef.quant = 0;
		routine = r {
			loop {
				~busses.handDistance.get({ | value |
					Pbindef(\squareGrains, \ampMod, value);
				});
				0.05.yield;
			}
		}.play;
		pdef.play;
		{ routine.stop; pdef.stop; };
	},
	melodicSquareGrains: { | instrument |
		var notes, weights, pdef, pdefL, routine, routineL, transpose;
		transpose = -2;
		notes = (
			~openingPhrase - 12 + transpose
			++ (~openingPhrase + transpose)
			++ (~openingPhrase + transpose)
		).asSet.asArray;
		weights = notes.size.collect { | i | 0 };
		pdef = Pbindef(\melodicSquareGrains,
			\instrument, instrument,
			\kernel, Prand(~convolutionBuffers, inf),
			\freq, Pwrand(notes.midicps, weights.normalizeSum, inf),
			\dur, 0.1
		);
		pdef.quant = 0;
		pdefL = Pbindef(\melodicSquareGrainsL,
			\instrument, instrument,
			\kernel, Prand(~convolutionBuffers, inf),
			\freq, Pwrand(notes.midicps, weights.normalizeSum, inf),
			\dur, 0.1
		);
		pdef.quant = [0, 0.5];
		pdef.play;
		pdefL.play;
		routine = r {
			loop {
				~poseLandmarker.getLandmarkSubBus('position', 'right wrist').get({ | value |
					var x, y, weights;
					x = (value[0] + 0.5).abs.min(1).max(0);
					y = value[1].neg;
					weights = notes.size.collect { | i | 0 };
					weights[(x * notes.size).trunc.asInteger] = 1;
					Pbindef(\melodicSquareGrains, \freq, Pwrand(notes.midicps, weights.normalizeSum, inf), \ampMod, y);
				});
				0.05.yield;
			}
		}.play;
		routineL = r {
			loop {
				~poseLandmarker.getLandmarkSubBus('position', 'left wrist').get({ | value |
					var x, y, weights;
					x = (value[0] + 0.5).abs.min(1).max(0);
					y = value[1].neg;
					weights = notes.size.collect { | i | 0 };
					weights[(x * notes.size).trunc.asInteger] = 1;
					Pbindef(\melodicSquareGrainsL, \freq, Pwrand(notes.midicps, weights.normalizeSum, inf), \ampMod, y);
				});
				0.05.yield;
			}
		}.play;
		{ pdef.stop; pdefL.stop; routine.stop; routineL.stop; }
	},
	triggeredSwooshes: {
		var upsensitivity = ~config.sensitivity.wristUpward;
		var downsensitivity = ~config.sensitivity.wristDownward;
		var samples = [\water, \coffeeSustain, \paperCrumple, \paperTear].collect { | key |
			~buffers[key];
		};
		var createSynth = { | landmark |
			~poseLandmarker.getLandmarkSubBus('speed', landmark).get({ | speed |
				Synth(\distortedPiano, [\bufnum, samples.choose, \amp, speed * 0.5, \panSpread, 0, \panMultiplier, ~config.sensitivity.pan])
				.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(0, 1));
			});
		};
		// The following synths free themselves so there is no cleanup function
		var triggers = [
			~poseLandmarker.createCue('right wrist', 1, 1, downsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('right wrist', 1, -1, upsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, -1, upsensitivity, {
				createSynth.('left wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, 1, downsensitivity, {
				createSynth.('left wrist')
			})
		];
		{
			"cleaning up".postln;
			triggers.collect { | t | t.(); };
		};
	},
	triggeredSwooshesP2: {
		var upsensitivity = ~config.sensitivity.wristUpward;
		var downsensitivity = ~config.sensitivity.wristDownward;
		var createSynth = { | landmark |
			~poseLandmarker.getLandmarkSubBus('speed', landmark).get({ | speed |
				Synth(\dangerousTapDelay, [
					\amp, 0.2 * speed,
					\panMultiplier, ~config.sensitivity.pan,
					\freq, rrand(40, 400),
					\delayPitchRatioAdd, 1,
					\delayPitchRatioMul, -1,
					\release, 4
				])
				.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(0, 1))
				.map(\delayPitchRatio, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(1));
			});


		};
		// The following synths free themselves so there is no cleanup function
		var triggers = [
			~poseLandmarker.createCue('right wrist', 1, 1, downsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('right wrist', 1, -1, upsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, -1, upsensitivity, {
				createSynth.('left wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, 1, downsensitivity, {
				createSynth.('left wrist')
			})
		];
		{
			"cleaning up".postln;
			triggers.collect { | t | t.(); };
		};
	},
	triggeredSwooshesP1: {
		var upsensitivity = ~config.sensitivity.wristUpward;
		var downsensitivity = ~config.sensitivity.wristDownward;
		var createSynth = { | landmark |
			~poseLandmarker.getLandmarkSubBus('speed', landmark).get({ | speed |
				Synth(\dangerousTapDelay, [
					\amp, 0.2 * speed,
					\panMultiplier, ~config.sensitivity.pan,
					\freq, rrand(3000, 8000),
					\delayPitchRatioAdd, 1,
					\delayPitchRatioMul, 1,
					\release, 4
				])
				.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(0, 1))
				.map(\delayPitchRatio, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(1));
			});


		};
		// The following synths free themselves so there is no cleanup function
		var triggers = [
			~poseLandmarker.createCue('right wrist', 1, 1, downsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('right wrist', 1, -1, upsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, -1, upsensitivity, {
				createSynth.('left wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, 1, downsensitivity, {
				createSynth.('left wrist')
			})
		];
		{
			"cleaning up".postln;
			triggers.collect { | t | t.(); };
		};
	},
	moveTheWind: {
		var busses, synths, controls;
		busses = (
			inwardAmp: Bus.control,
			crushingAmp: Bus.control,
			screamAmp: Bus.control
		);
		controls = LinkedList();
		controls
		// Map inward motion to bus
		.add(
			Synth(\inwardAmpMod, [\in, ~busses.handDistance, \out, busses.inwardAmp])
		)
		// Map Raising hands to decreasing crushingAmp
		.add(
			Synth(\valueMinusInputScaled, [
				\value, 0.5,
				\in, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1),
				\out, busses.crushingAmp
			], controls.last, \addAfter)
		)
		.add(
			Synth(\busMul,[
				\in1, busses.inwardAmp,
				\in2, busses.crushingAmp,
				\out, busses.crushingAmp
			], controls.last, \addAfter)
		)
		// Map middling hands to screamAmp
		.add(
			Synth(\bufferControl, [
				\bufnum, ~hanningBuffer,
				\in, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1),
				\out, busses.screamAmp
		], controls.last, \addAfter)
		)
		.add(
			Synth(\busMul,[
				\in1, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1),
				\in2, busses.inwardAmp,
				\out, busses.screamAmp
			], controls.last, \addAfter)
		);
		synths = [
			Synth(\noiseWind, [
				\panMultiplier, ~config.sensitivity.pan,
				\posMultiplier, ~config.sensitivity.pan,
				\rqMultiplier, -10,
				\amp, 0.6,
				\centerFreq, rrand(200, 2000),
				\envGateThresh, ~config.sensitivity.wristAboveWaist
			])
			.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0, 1))
			.map(\pos, ~poseLandmarker.getLandmarkSubBus('position', 'left wrist').subBus(0, 1))
			.map(\ampMod, busses.inwardAmp)
			.map(\envGate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			.map(\rq, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1, 1)),

			Synth(\crushing, [
				\envGateThresh, ~config.sensitivity.wristAboveWaist,
				\amp, 1,
				\spread, 0,
				\panMul, ~config.sensitivity.pan])
			.map(\rateMod, ~busses.handDistance)
			.map(\envGate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			.map(\ampMod, busses.crushingAmp)
			.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0, 1)),
			Synth(\screams, [
				\bufnums, 10.collect { ~buffers.screams.choose },
				\grainRate, 20,
				\amp, 0.3,
				\envGateThresh, ~config.sensitivity.wristAboveWaist,
				\rateScaleAdd, 0.5,
				\panMul, ~config.sensitivity.pan,
			])
			.map(\ampMod, busses.screamAmp)
			.map(\envGate, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			.map(\rateScale, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(1))
			.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', 'right wrist').subBus(0, 1))
		];
		{
			controls.collect { | synth | synth.free; };
			synths.collect { | synth |
				synth.release;

			};
			busses.collect { | b |  b.free; };
		}
	},
	dangerousTapDelay: {
		var upsensitivity = ~config.sensitivity.wristUpward;
		var downsensitivity = ~config.sensitivity.wristDownward;
		var xsensitivity = ~config.sensitivity.wristOutward;
		var createSynth = { | landmark |
			~poseLandmarker.getLandmarkSubBus('speed', landmark).get({ | speed |
				Synth(\dangerousTapDelay, [
					\amp, 0.2 * speed,
					\panMultiplier, ~config.sensitivity.pan,
					\freq, rrand(40, 400),
					\delayPitchRatioAdd, 1,
					\delayPitchRatioMul, -1
				])
				.map(\pan, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(0, 1))
				.map(\delayPitchRatio, ~poseLandmarker.getLandmarkSubBus('position', landmark).subBus(1));
			});
		};
		var triggers = [
			~poseLandmarker.createCue('right wrist', 1, 1, downsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('right wrist', 1, -1, upsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, -1, upsensitivity, {
				createSynth.('left wrist')
			}),
			~poseLandmarker.createCue('left wrist', 1, 1, downsensitivity, {
				createSynth.('left wrist')
			}),
			~poseLandmarker.createCue('right wrist', 0, -1, xsensitivity, {
				createSynth.('right wrist')
			}),
			~poseLandmarker.createCue('left wrist', 0, 1, xsensitivity, {
				createSynth.('left wrist')
			}),
		];
		{
			triggers.collect { | t | t.() }
		}
	},
	endDistortedPiano: {
		var trigger = ~poseLandmarker.createCue('right wrist', 1, 1, ~config.sensitivity.wristDownward, {

			Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (24).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
			Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (36).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
			Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (48).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
			Synth(\distortedPiano, [\bufnum, ~buffers.badPiano, \freq, (60).midicps, \amp, 0.2, \startPosSeconds, 1.35, \attackTime, 0.01]);
			Synth(\bassDrum, [\freq, 30, \releaseTime, 10]);
			Synth(\unstableSin, [\freq, (88.midicps)]);
			Synth(\unstableSin, [\freq, (84.midicps), \amp, 0.1]);
			// Release this synth, we should only be able to play one note.
			trigger.();
		});
	}

);

/** Score order
1. mysteriousMelody, DistortedPiano
2. Crushing, superSaw
3. distortedPiano with swiping.
4. Swiping - pass fight. Start to play together. Use distortedPiano synth with different buffers. - use LR for panning.
6, Noise wind - pass to each other.
5. mysteriousMelodyLow, melodicSquareGrains
6. dangerousTapDelay, sawPulses, squareGrains
7. distortedPiano again
*/
~score = (
	part: ~config.player,
	pageIndex: -1,
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
	pages: [
		[ // A
			~patches[\mysteriousMelody],
			~patches[\distortedPianoCues],
			{}
		],
		[ // B
			~patches[\superSin],
			~patches[\superSaw],
			~patches[\crushing]
		],
		[ // C
			~patches[\distortedPianoCues],
			~patches[\swipesP1],
			~patches[\swipesP2],
		],
		[ // D
			~patches[\swipesP0],
			~patches[\swipesP1],
			~patches[\swipesP2]
		],
		[ // E
			~patches[\triggeredSwooshes],
			~patches[\triggeredSwooshesP1],
			~patches[\triggeredSwooshesP2]
		],
		[ // F
			~patches[\moveTheWind],
			~patches[\moveTheWind],
			~patches[\moveTheWind]
		],
		[ // G
			~patches[\moveTheWind],
			{ ~patches[\melodicSquareGrains].(\squareGrain) } ,
			~patches[\mysteriousMelodyLow]
		],
		[ // H
			~patches[\dangerousTapDelay],
			{ ~patches[\melodicSquareGrains].(\sawGrain) },
			~patches[\squareGrains]

		],
		[ // I
			{},
			~patches[\pulsyCresc],
			{}
		],
		[ // J
			{},
			{},
			{}
		]
	],
	playPage: { | self, page |
		self.cleanUp.();
		self.pageIndex = page;
		self.cleanUp = self.pages[page][self.part].();
	},
	incrementPage: { | self |
		self.playPage(self.pageIndex + 1);
	}
);
OSCdef(\patch_change, { | msg, time, addr, recvPort |
	var cues = "abcdefghij";
	var index = cues.find(msg[1].asString);
	index.postln;
	~score.playPage(index);
}, \patch_change);
OSCdef(\patch_stop, { | msg, time, addr, recvPort |
	~score.cleanUp();
}, \patch_stop);