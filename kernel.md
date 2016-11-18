# Build an RT patched image

## Set up
 - SSH into the builder
 - Start a container 
 - Create a new user
 - Install docker
 - Add your user to the docker group
 - Switch to your user

## Clone the repo
```
git clone --recursive https://github.com/resin-os/resin-raspberrypi.git
cd resin-raspberrypi
```

## Dry run to create the build configuration
```
./resin-yocto-scripts/build/barys --remove-build --dry-run --development-image --machine raspberrypi3
```

## Enter the build
```
source layers/poky/oe-init-build-env
```

## Apply the AUFS patch
```
MACHINE=raspberrypi3 bitbake virtual/kernel -c do_kernel_resin_aufs_fetch_and_unpack
```

## Apply the RT patch
```
cd tmp/work-shared/raspberrypi3/kernel-source
wget https://www.kernel.org/pub/linux/kernel/projects/rt/4.1/older/patch-4.1.20-rt23.patch.gz
gunzip patch-4.1.20-rt23.patch.gz
patch -p1 < patch-4.1.20-rt23.patch // Press y and enter when prompted
```

## Start the config step
```
MACHINE=raspberrypi3 bitbake virtual/kernel -c menuconfig
```
Enable RT functionality in the menu

## Start the build step
```
MACHINE=raspberrypi3 bitbake resin-image
```

## Fix issue
```
vim tmp/work-shared/raspberrypi3/kernel-source/fs/aufs/i_op.c
:%s/p->hdir->hi_inode->i_mutex.owner = task;/p->hdir->hi_inode->i_mutex.lock.owner = task;/g
:x
```

## Re-start the build step
```
MACHINE=raspberrypi3 bitbake resin-image
```

## Download the image to local machine
Run on the builder to copy the file from inside the docker container to outside the docker container
```
docker cp 92b11b790e82:/home/joe/resin-raspberrypi/build/tmp/deploy/images/raspberrypi3/resin-image-raspberrypi3-20161118122949.rootfs.resin-sdcard .
```
Run on local machine to copy the file from the builder to your local machine
```
scp joe@misc1.dev.resin.io:/home/joe/resin-image-raspberrypi3-20161118122949.rootfs.resin-sdcard .
```

## Burn image to sd card
```
sudo dd bs=4M if=resin-image-raspberrypi3-20161118122949.rootfs.resin-sdcard of=/dev/sda status=progress && sync
```

## Inject config
```
resin config generate --app copter --output config.json
sudo -E resin config inject config.json --type raspberrypi3 --drive /dev/sda
```
