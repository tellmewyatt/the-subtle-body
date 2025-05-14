(OSCdef(\right_wrist_x, {
	| msg |
	var val = msg[1] + 1;
	val.postln;
	~mouseBus.subBus(0, 1).set(val)
}, '/right_wrist_x');
OSCdef(\right_wrist_y, { | msg |
	var val = msg[1] + 1;
	val.postln;msg[1].postln;
	~mouseBus.subBus(1, 1).set(val)
}, '/right_wrist_y');
)