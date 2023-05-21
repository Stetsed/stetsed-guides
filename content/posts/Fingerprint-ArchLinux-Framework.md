---
title: "Fingerprint ArchLinux Framework"
date: 2023-05-18T13:46:45+02:00
draft: false
tags: ["Framework Laptop 13", "Linux", "Security"]
---

This guide will show you how to enable fingerprint scanning on Archlinux using fprintd. Firstly run [Appimage](https://drive.google.com/file/d/1CJqHfYatO80xI-DoOgs357ubin0UH2dR/view?usp=sharing) to clear the current fingerprint device and make sure we don't get errors later.

After this install the fprintd package

```bash
pacman -Syu fprintd
```

Then go ahead and enroll your fingerprint
```bash
fprintd-enroll
```

This will allow you to enroll the right index finger, to do other fingers do.
```bash
fprintd-enroll -f left-thumb/left-middle-finger
```
And just replace the finger with the finger you want to enroll.

Now if you want to make sudo use it you want to edit /etc/pam.d/sudo to include the below snippet at the top

```
auth        sufficient      pam_fprintd.so
```

Now for swaylock we want to use a diffrent combo because we still want to allow password entry, as the above will only allow password entry after 3 failed attempts at finger auth. Please add the below snippet to the top.

```
auth sufficient pam_unix.so try_first_pass likeauth 
nullok
auth sufficient pam_fprintd.so
```

To use fingerprint authentication with SDDM add the below snippet, you can also find the explanation on the [Arch Wiki](https://wiki.archlinux.org/title/SDDM#Using_a_fingerprint_reader).

```
auth [success=1 new_authtok_reqd=1 default=ignore] pam_unix.so try_first_pass likeauth 
nullok
auth sufficient pam_fprintd.so
```
