package ui.color;

class RgbShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;

		@param var hue : Float;

		function fragment() {
			var sat = clamp(calculatedUV.x, 0.0, 1.0);
			var val = clamp(1.0 - calculatedUV.y, 0.0, 1.0);

			var hueColor = hsv2rgb(vec3(hue, 1.0, 1.0));
			var topColor = mix(vec3(1.0), hueColor, sat);
			var finalColor = mix(vec3(0.0), topColor, val);

			pixelColor = vec4(finalColor, 1.0);
		}

		function hsv2rgb(c:Vec3):Vec3 {
			var K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			var p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);

			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}
	}
}