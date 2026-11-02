# hello_world_crackmes

A collection of reverse-engineering writeups and a handful of small
hand-written x86 assembly "crackmes" used to practice binary analysis.

## Contents

- `crackme_00/` to `crackme_05/` — small assembly source files (`.s`)
  used as self-made practice targets.
- `writeups/` — detailed writeups documenting the analysis of various
  crackme binaries (see list below).
- `decodeXOR.py` — small Python helper script used to brute-force / decode
  XOR-encoded flags found while reversing some of the binaries.

## Methodology

Each writeup generally follows the same approach:

1. **Reconnaissance** — `file`, `strings`, `nm` to identify the binary
   format, check whether it is stripped, and spot readable strings or
   symbol names (e.g. `encoded_flag`, `xor_key`).
2. **Static analysis** — `objdump -d` to disassemble and locate relevant
   instructions (comparisons, XOR operations, loops).
3. **Dynamic analysis** — `gdb` to set breakpoints, inspect registers and
   memory, and observe the flag-checking logic at runtime.
4. **Decoding** — when the flag is obfuscated (e.g. XOR-encoded), the
   decoding logic is reproduced in Python (`decodeXOR.py`) to recover it
   without manual byte-by-byte computation.
5. **Validation** — the recovered flag/password is fed back into the
   binary to confirm it is accepted.

## Writeups

| Writeup | Description |
|---|---|
| [Intro](writeups/Intro.md) | Introductory crackme: XOR-based comparison logic. |
| [FIRSTCRACKME](writeups/FIRSTCRACKME.md) | First pass on the "Birth of the URSSAF" crackme (non-stripped binary, symbol inspection). |
| [Birth_of_the_URSSAF](writeups/Birth_of_the_URSSAF.md) | Extended writeup on the same crackme, with full static/dynamic analysis. |
| [Entry](writeups/Entry.md) | Longer writeup covering a more involved entry-point analysis. |
| [MonkeydXOR](writeups/MonkeydXOR.md) | XOR-encoded flag recovered via static analysis and scripted decoding. |
| [Crackme_CS](writeups/Crackme_CS.md) | Analysis of the Crackme_CS binary. |
| [easycrackmecrazy](writeups/easycrackmecrazy.md) | Analysis of the easycrackmecrazy binary. |
| [easy1](writeups/easy1.md) | Flag readable directly in the binary's strings. |
| [easy2](writeups/easy2.md) | Slightly more involved variant of easy1. |
| [simple_basic](writeups/simple_basic.md) | Basic comparison-based crackme. |
| [Fait_Toi_Confiance](writeups/Fait_Toi_Confiance.md) | Short writeup on the Fait_Toi_Confiance crackme. |
| [Krasý_sa_2](writeups/Krasý_sa_2.md) | Short writeup on the Krasý_sa_2 crackme. |

## Tools used

`file`, `strings`, `nm`, `objdump`, `gdb`, and Python for scripted decoding.

## Authors

- Margotte STORME
- Rakulan SIVATHASAN

See [AUTHORS.md](AUTHORS.md).
