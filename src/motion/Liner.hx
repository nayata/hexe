package motion;

import motion.dopesheet.Track;


class Liner extends h2d.Graphics {
	public var list:Array<Marker> = [];

	
	public function add(track:Marker) {
		list.push(track);
	}


	public function update() {
		if (list == null || list.length < 2) return;

		list.sort(cmp);
		list.sort(cmt);

		clear();
		lineStyle(6, 0x35517b);

		for (i in 0...list.length - 1) {
			var a = list[i];
			var b = list[i + 1];

			if (a.track != b.track) continue;

			moveTo(a.x, a.track);
			lineTo(b.x, b.track);
		}
	}


	public function reset() {
		list.resize(0);
		clear();
	}

	
	inline function cmp(a:h2d.Object, b:h2d.Object):Int {
		if (a.x < b.x) return -1;
		if (a.x > b.x) return 1;
		return 0;
	}


	inline function cmt(a:Marker, b:Marker):Int {
		if (a.track < b.track) return -1;
		if (a.track > b.track) return 1;
		return 0;
	}
}