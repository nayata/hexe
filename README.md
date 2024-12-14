# HEXE

![HEXE](/hexe.png "HEXE")

**HEXE** (Witch) is a prefab editor and runtime library for the [Heaps](https://heaps.io/) game engine. **HEXE** is focused on 2D content and serves as a more user-friendly alternative to **Hide** (Heaps IDE).

# How It Works

Use the editor to create a prefab from your project assets and save it as a file in the `res` directory. Then, you can use the `hxe.Lib` library to load the prefab file into the game as an `hxe.Prefab` display object.

# Supported Objects

List of Heaps h2d objects that can be added to a prefab:

- [x] **Object**
- [x] **Bitmap from image file**
- [x] **Bitmap from loaded Texture Atlas**
- [x] **Text with default or loaded Font**
- [x] **Interactive**
- [x] **Graphics**
- [x] **Linked Prefab**
- [x] Anim
- [x] ScaleGrid 
- [x] Mask


# Quick Start

[Download](https://github.com/nayata/hexe/releases) the editor and create your prefab. 

Install the library from haxelib:

```
haxelib install prefab
```

Alternatively the dev version of the library can be installed from github:

```
haxelib git prefab https://github.com/nayata/prefab.git
```

Include the library in your project's `.hxml`:

```
-lib prefab
```

Use `hxe.Lib` to load and add a prefab instance to the scene. Note: the prefab name must be without extension.

```haxe
var object:hxe.Prefab = hxe.Lib.load("myPrefab", s2d);
```

# Documentation

* [Introduction](https://nayata.github.io/hexe)  
* [Quick Start](https://nayata.github.io/hexe/#quick-start)  
* [Working with editor](https://nayata.github.io/hexe/#working-with-editor)  
* [In-game implementation](https://nayata.github.io/hexe-lib)  
* [API](https://nayata.github.io/hexe-api)
