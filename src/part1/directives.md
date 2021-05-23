
## Including other files

Line 1 *includes* `hardware.inc`.
Including a file has the same effect as if you copy-pasted it, but without having to actually do that.
It allows sharing the same file: if `a.asm` and `b.asm` include `hardware.inc`, you only need to modify `hardware.inc` once, instead of both `a.asm` and `b.asm` if you actually copy-pasted the contents.
