import haxe.*;
import haxe.io.*;
import sys.*;
import sys.io.*;

typedef Version = {version:String, tag:String, sha256:Dynamic, win64:Bool, exclude:Array<String>};
typedef Variant = {variant:String, suffix:Array<String>};

class Update {
	static var HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';

	static public var versions:Array<Version> = [
		{
			"version": "3.4.4",
			"tag": "3.4.4",
			"win64": true,
			"sha256": {"win": "fac48d13f50f625709a88226b9f946b3fb8e2f673de856eecd98331aa1830a02"},
			"exclude": []
		},
		{
			"version": "3.3.0-rc.1",
			"tag": "3.3.0-rc1",
			"win64": false,
			"sha256": {"win": "fa51621132432328a47e5e0416ab3b9f2f734b217a2bc9b650826aae2f12c6f4"},
			"exclude": []
		},
		{
			"version": "3.2.1",
			"tag": "3.2.1",
			"win64": false,
			"sha256": {"win": "af57d42ca474bba826426e9403b2cb21c210d56addc8bbc0e8fafa88b3660db3"},
			"exclude": []
		},
		{
			"version": "3.1.3",
			"tag": "3.1.3",
			"win64": false,
			"sha256": {"win": "4cf84cdbf7960a61ae70b0d9166c6f9bde16388c3b81e54af91446f4c9e44ae4"},
			"exclude": ["alpine3.6", "alpine3.7"]
		},
	];

	static public var variants:Array<Variant> = [
		{
			"variant": "stretch",
			"suffix": ["stretch", ""]
		},
		{
			"variant": "jessie",
			"suffix": ["jessie"]
		},
		{
			"variant": "onbuild",
			"suffix": ["onbuild"]
		},
		{
			"variant": "windowsservercore",
			"suffix": ["windowsservercore"]
		},
		// neko and haxelib are still 32-bit only
		// {
		// 	"variant": "nanoserver",
		// 	"suffix": ["nanoserver"]
		// },
		{
			"variant": "alpine3.7",
			"suffix": ["alpine3.7", "alpine"]
		},
		{
			"variant": "alpine3.6",
			"suffix": ["alpine3.6"]
		},
	];

	static public function verMajorMinor(version:String):String {
		return version.split(".").slice(0, 2).join(".");
	}

	static public function verMajorMinorPatch(version:String):String {
		return version.split("-")[0];
	}

	static public function dockerfilePath(version:Version, variant:Variant):String {
		var majorMinor = verMajorMinor(version.version);
		return if (variant.suffix[0] == "")
			Path.join([majorMinor, "Dockerfile"]);
		else
			Path.join([majorMinor, variant.suffix[0], "Dockerfile"]);
	}

	static function main():Void {
		for (variant in variants) {
			var tmpl = new Template(File.getContent('Dockerfile-${variant.variant}.template'));
			for (version in versions) {
				if (version.exclude.indexOf(variant.variant) >= 0)
					continue;
				switch ([variant.variant, version.win64]) {
					case ["nanoserver", false]:
						continue;
					case _:
						//pass
				}
				var vars = {
					HAXE_VERSION: version.version,
					HAXE_TAG: version.tag,
					HAXE_FILE: switch(variant.variant) {
						case "windowsservercore"|"nanoserver":
							'https://github.com/HaxeFoundation/haxe/releases/download/${version.tag}/haxe-${version.version}-win${version.win64 ? "64" : ""}.zip';
						case _:
							null;
					},
					HAXE_SHA256: switch(variant.variant) {
						case "windowsservercore"|"nanoserver":
							version.sha256.win;
						case _:
							null;
					},
					NEKO_VERSION: "2.2.0",
					NEKO_TAG: "v2-2-0",
					NEKO_SHA256: switch(variant.variant) {
						case "windowsservercore"|"nanoserver":
							"93d7ca96698a6825f38ca8eea49e2e6b691c0849270174f6c1bd531290db8d69";
						case _:
							"cf101ca05db6cb673504efe217d8ed7ab5638f30e12c5e3095f06fa0d43f64e3";
					},
					HEADER: HEADER,
				};
				var path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
