# psn00b-docker

Docker image for PlayStation 1 (PSX) development based on [psn00bsdk](https://github.com/Lameguy64/PSn00bSDK).

Pre-built & pre-installed:

- Compiler: mipsel-unknown-elf-gcc
- Toolchain: [libpsn00b and tools](https://github.com/Lameguy64/PSn00bSDK)
- Extras:
  - [mkpsxiso](https://github.com/Lameguy64/mkpsxiso.git)

## Quickstart

```sh
# clone this repo
git clone https://github.com/liangchunn/psn00b-docker.git

# build the image
docker build -t psn00b .

# run and mount your dev folder
docker run -it -v <your_dev_folder_here>:/psx-dev psn00b
```

### Paths

| Type              | Path                           |
| ----------------- | ------------------------------ |
| libpsn00b include | `/psn00bsdk/libpsn00b/include` |
| libpsn00b library | `/psn00bsdk/libpsn00b`         |

## Follow-Along Guide

1. Build the image

```sh
docker build -t psn00b .
```

2. Create a dev folder, and clone PSn00bSDK into it

```sh
mkdir ~/psx-dev
cd ~/psx-dev
git clone https://github.com/Lameguy64/PSn00bSDK.git
```

3. Now we edit `PSn00bSDK/examples/sdk-common.mk` so that it points to the correct include folders

```diff
  # Include directories
- INCLUDE	 	= -I../../libpsn00b/include
+ INCLUDE	 	= -I/psn00bsdk/libpsn00b/include

  # Library directories, last entry must point toolchain libraries
- LIBDIRS		= -L../../libpsn00b
+ LIBDIRS		= -L/psn00bsdk/libpsn00b

```

4. We will use `n00bdemo` as an example. But first, we need to change `PSn00bSDK/examples/n00bdemo/makefile` to point to `lzp`'s correct include folders

```diff
- INCLUDE	 	+= -I../../libpsn00b/lzp
+ INCLUDE	 	+= -I/psn00bsdk/libpsn00b/lzp
- LIBDIRS		+= -L../../libpsn00b/lzp
+ LIBDIRS		+= -L/psn00bsdk/libpsn00b/lzp
```

5. Now we run the built image with Docker, and mount our dev folder onto the container.

```sh
docker run -it -v ~/psx-dev:/psx-dev psn00b
```

If you're already inside your dev folder, you can also do:

```sh
docker run -it -v $(pwd):/psx-dev psn00b
```

_Note: Mounting a folder in this way makes it possible to work on the project on your host machine. This essentially shares the folder between the host and the VM._

6. A console should show up, it should look something like this:

```
root@696090beec68:/#
```

7. Now, we go into the folder that we've mounted and build the project.

```sh
cd /psx-dev/PSn00bSDK/examples/n00bdemo
make
```

8. Verify that there's a `demo.exe`, you're done!

### Extras

Here are some extras which continue from above

#### Building a BIN/CUE file from PS-EXE with `mkpsxiso`

1. Create `system.cnf` inside `/psx-dev/PSn00bSDK/examples/n00bdemo` with the contents:

```
BOOT=cdrom:\demo.exe;1
TCB=4
EVENT=10
STACK=801FFFF0
```

2. Create `iso.xml` inside `/psx-dev/PSn00bSDK/examples/n00bdemo` with the contents:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<iso_project image_name="n00bdemo.bin" cue_sheet="n00bdemo.cue">
	<track type="data">
		<identifiers
			system			="PLAYSTATION"
			application		="PLAYSTATION"
			volume			="N00BDEMO"
			volume_set		="N00BDEMO"
			publisher		="MEIDOTEK"
		/>
        <!-- To 'sign' the ISO, we would need to use LICENSEA.DAT from PS\CDGEN\LCNSFILE which comes with the Psy-Q SDK (see documentation of mkpsxiso) -->
		<!--<license file="LICENSEA.DAT"/>-->
		<directory_tree>
			<file name="system.cnf"	type="data"	source="system.cnf"/>
			<file name="demo.exe" type="data" source="demo.exe"/>
			<dummy sectors="1024"/>
		</directory_tree>
	</track>
</iso_project>
```

3. Run the command inside the directory `/psx-dev/PSn00bSDK/examples/n00bdemo`, a BIN/CUE file should be created.

```sh
mkpsxiso iso.xml
```
