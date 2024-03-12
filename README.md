# gentoo-make-initrd-overlay

This is make-initrd ebuild repository.

# Usage
## Add this overlay.
```
$ eselect repository add make-initrd-overlay git https://github.com/osboot/gentoo-make-initrd-overlay
```

## Mask sys-kernel/installkernel::gentoo
To avoid accidentally switching to the original Gentoo package.

## Change USE flags for sys-kernel/installkernel: make-initrd -dracut
To use make-initrd instead of dracut to generate initrd.

## Change USE flags for sys-kernel/gentoo-kernel package: -initramfs
To avoid dependency on sys-kernel/installkernel[dracut], which exists just to
ensure you do not end up without any initrd.
