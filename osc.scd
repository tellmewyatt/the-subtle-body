(OSCdef(\right_wrist_x, {
	| msg |
	msg[1].postln;
}, '/right_wrist_x');
OSCdef(\right_wrist_y, { | msg |
	msg[1].postln;
}, '/right_wrist_y');
)