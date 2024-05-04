# gentoo-make-initrd-overlay

This is make-initrd ebuild repository.

## Usage

1. Add this overlay:
```
$ eselect repository add make-initrd-overlay git https://github.com/osboot/gentoo-make-initrd-overlay
```
2. Mask `sys-kernel/installkernel::gentoo` to avoid accidentally
switching to the original Gentoo package.
3. Change USE flags for `sys-kernel/installkernel`:
`make-initrd -dracut`, to use make-initrd instead of dracut to generate
initrd.
4. If you use either `sys-kernel/gentoo-kernel` or
`sys-kernel/gentoo-kernel-bin` kernel pacakge, change USE flags for the
package: `-initramfs`, to avoid dependency on
`sys-kernel/installkernel[dracut]`, which exists just to ensure you do
not end up without any initrd, but doesn't make sense with this overlay.
5. Emerge `sys-kernel/installkernel::make-initrd-overlay`.
