# 48 Meters Underground

## Description



## Solution

We've give a firmware downloadable. 

```bash
file firmware.bin 
firmware.bin: Linux kernel ARM boot executable zImage (big-endian)
```

Running binwalk shows that there's squashfs filesystem present.

```bash
binwalk firmware.bin 

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Linux kernel ARM boot executable zImage (big-endian)
14419         0x3853          xz compressed data
14640         0x3930          xz compressed data
538952        0x83948         Squashfs filesystem, little endian, version 4.0, compression:xz, size: 2068482 bytes, 995 inodes, blocksize: 262144 bytes, created: 2022-05-03 12:34:33
```

We can either use `binwalk` or [firmware-mod-kit](https://github.com/rampageX/firmware-mod-kit) to extract the contents.

```bash
binwalk -e firmware.bin
```

This shows some errors but that's okay since we can still see `squashfs-root` inside `_firmware.bin.extracted`. 

```bash
ls
bin  dev  etc  lib  mnt  overlay  proc  rom  root  sbin  sys  tmp  usr  var  www
```

While analysing firmwares its common to look for hardcoded keys or passwords for wide variety of services. Let's grep the common keywords like SSH, telnetd, password etc.

```bash
grep -inR telnetd .
grep: ./etc/TZ: No such file or directory
grep: ./etc/localtime: No such file or directory
grep: ./etc/ppp/resolv.conf: No such file or directory
grep: ./etc/resolv.conf: No such file or directory
./etc/scripts/telnetd.sh:3:TELNETD=`rgdb
./etc/scripts/telnetd.sh:4:TELNETD=`rgdb -g /sys/telnetd`
./etc/scripts/telnetd.sh:5:if [ "$TELNETD" = "true" ]; then
./etc/scripts/telnetd.sh:6:     echo "Start telnetd ..." > /dev/console
./etc/scripts/telnetd.sh:9:             telnetd -l "/usr/sbin/login" -u Device_Admin:$sign      -i $lf &
./etc/scripts/telnetd.sh:11:            telnetd &
```

This highlights the presence of telnet configuration for device console access. Let's check the `/etc/scripts/telnetd.sh`. 

```bash
#!/bin/sh
sign=`cat /etc/config/sign`
TELNETD=`rgdb
TELNETD=`rgdb -g /sys/telnetd`
if [ "$TELNETD" = "true" ]; then
        echo "Start telnetd ..." > /dev/console
        if [ -f "/usr/sbin/login" ]; then
                lf=`rgbd -i -g /runtime/layout/lanif`
                telnetd -l "/usr/sbin/login" -u Device_Admin:$sign      -i $lf &
        else
                telnetd &
        fi
fi
```

We find the username as `Device_Admin` and password is stored in `$sign` variable which is the contents of `/etc/config/sign`. 

```bash
cat etc/config/sign 
w4ll_h1dd3n_p13c3_<-_->
```

