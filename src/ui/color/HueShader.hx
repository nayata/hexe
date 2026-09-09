package ui.color;

class HueShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;

		@param var innerRadius:Float = 0.4;
		@param var outerRadius:Float = 0.5;

		function fragment() {
			var p = calculatedUV - vec2(0.5);

			var dist = length(p);
			var aa = 1.0 / 256;
			
			var outer = 1.0 - smoothstep(outerRadius - aa, outerRadius + aa, dist);
			var inner = smoothstep(innerRadius - aa, innerRadius + aa, dist);
			
			var alpha = outer * inner;
			var h = atan(p.y, p.x);

			h = h / (2.0 * 3.14159265);
			h = fract(h);

			var rgb = hsv2rgb(vec3(h, 1.0, 1.0));
			pixelColor = vec4(rgb, alpha);
		}

		function hsv2rgb(c:Vec3):Vec3 {
			var K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			var p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);

			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}
	}
}