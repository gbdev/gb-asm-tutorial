# Primi passi in Assembly

Dunque, ora che sappiamo cosa i nostri strumenti fanno, vediamo che lingua parla RGBASM.
Ti mostro l'inizio di `hello-world.asm`, so that we agree on the line numbers, and you can get some syntax highlighting even if your editor doesn't support it.

```rgbasm,linenos,start={{#line_no_of "" ../assets/hello-world.asm:basics}}
{{#include ../assets/hello-world.asm:basics}}
```

Analizziamolo insieme.
Sappi che per il momento salteremo _molte_ delle funzionalità di RGBASM; se fossi curioso di saperne di più, dovrai aspettare fino alla seconda o terza parte oppure leggere la [documentazione](https://rgbds.gbdev.io/docs).

## Commenti

Iniziamo con la riga numero {{#line_no_of "^\s*;" ../assets/hello-world.asm:basics}}, che dovrebbe essere grigia nel riquadro qui sopra.
I punti e virgola `;` indicano un _commento_.
I commenti (che finiscono alla fine della riga) sono _ignorati_ dall'assembler, indipendentemente dal contenuto.
Come vedi alla riga {{#line_no_of "^.*\s.*;" ../assets/hello-world.asm:basics}}, puoi anche inserire commenti dopo aver scritto altro.

I commenti sono molto importanti in tutti i linguaggi di programmazione: ti aiutano a descrivere la funzione del tuo codice.
È più o meno la differenza tra "scalda il forno fino a 180°C" e "scalda il forno a 180°C, se lo scaldassi di più la torta brucerebbe".
Molto più che nella maggior parte dei linguaggi di programmazione, in Assembly i commenti sono vitali dato che il codice è molto più astratto.

## Istruzioni

Il codice sorgente in Assembly è basato completamente su righe.
Ogni riga contiene una _direttiva_, che dà istruzioni all'assembler, o un'_istruzione_, diretta al GameBoy e quindi copiata direttamente in ROM[^instr_directive].
Parleremo poi delle direttive, per il momento concentriamoci sulle istruzioni: per capirci, ignoreremo temporaneamente le righe {{#line_no_of "^\s*INCLUDE" ../assets/hello-world.asm:basics}} (`INCLUDE`), {{#line_no_of "^\s*ds" ../assets/hello-world.asm:basics}} (`ds`), e {{#line_no_of "^\s*SECTION" ../assets/hello-world.asm:basics}} (`SECTION`).

Per continuare con l'analogia della torta, ogni istruzione è un passaggio nella ricetta.
Il processore (<abbr title="Central Processing Unit">CPU</abbr>) esegue un'istruzione alla volta. Istruzione dopo istruzione... dopo un po' si arriva al risultato!
Come cuocere una torta, disegnare "Hello World", oppure mostrarti un tutorial sull'Assembly del GameBoy!
\*occhiolino\* <!-- originale: "\*wink\* \*wink\*". non mi suona bene la traduzione -->

Le istruzioni sono composte da una _mnemonica_, un nome con cui le puoi invocare, e dei _parametri_, ovvero su cosa va eseguita l'operazione.
Ad esempio: in "sciogli il cioccolato ed il burro in una padella" l'istruzione è _tutta la frase_; la mnemonica sarebbe l'_azione_, ovvero sciogli, mentre i parametri sono gli _oggetti_ della frase (cioccolato, burro, padella).

Cominciamo dall'istruzione più importante: **`ld`**.
`ld` sta per "<abbr title="LoaD in inglese">carica</abbr>", e semplicemente copia i dati contenuti nel secondo parametro ("[<abbr title="Right-Hand Side">RHS</abbr>](https://en.wikipedia.org/wiki/Sides_of_an_equation)") nel primo ("[<abbr title="Left-Hand Side">LHS</abbr>](https://en.wikipedia.org/wiki/Sides_of_an_equation)").
Per esempio, guardiamo la riga {{#line_no_of "^\s*ld a, 0" ../assets/hello-world.asm:basics}} del nostro programma, `ld a, 0`: copia ("carica") il numero zero nel registro `a`[^ld_imm_from].
Per fare un altro esempio, a riga {{#line_no_of "^\s*ld a, b" ../assets/hello-world.asm}} troviamo `ld a, b`: significa semplicemente "copia il valore di `b` in `a`.

 Istruzione | Mnemonica| Effetto
------------|----------|----------------------
Carica      | `ld`     | Copia un valore

::: tip:ℹ️

La CPU ha un numero di istruzioni limitato, quindi non tutte le combinazioni di parametri sono possibili, né per `ld` né per le altre mnemoniche. Ne parleremo meglio quando inizieremo il codice vero e proprio.

:::

::: tip:🤔

RGBDS ha una pagina di [riferimento per le istruzioni](https://rgbds.gbdev.io/docs/gbz80.7) che vale la pena salvare, e che può essere consultata localmente col comando `man 7 gbz80` se RGBDS è installato sul tuo sistema (eccetto windows...).
Le spiegazioni sono molto brevi: non è inteso come un tutorial quanto più come un promemoria.

:::

## Directives

In a way, instructions are destined to the console's CPU, and comments are destined to the programmer.
But some lines are neither, and are instead sort of metadata destined to RGBDS itself.
Those are called *directives*, and our Hello World actually contains three of those.

### Including other files

```rgbasm,linenos
{{#include ../assets/hello-world.asm:4}}
```

Line 1 *includes* `hardware.inc`[^hw_inc_directives].
Including a file has the same effect as if you copy-pasted it, but without having to actually do that.

It allows sharing code across files easily: for example, if two files `a.asm` and `b.asm` were to include `hardware.inc`, you would only need to modify `hardware.inc` once for the modifications to apply to both `a.asm` and `b.asm`.
If you instead copy-pasted the contents manually, you would have to edit both copies in `a.asm` and `b.asm` to apply the changes, which is more tedious and error-prone.

`hardware.inc` defines a bunch of constants related to interfacing with the hardware.
Constants are basically names with a value attached, so when you write out their name, they are replaced with their value.
This is useful because, for example, it is easier to remember the address of the **LCD** **C**ontrol register as `rLCDC` than `$FF40`.

We will discuss constants in more detail in Part Ⅱ.

### Sections

Let's first explain what a "section" is, then we will see what line 3 does.

A section represents a contiguous range of memory, and by default, ends up *somewhere* not known in advance.
If you want to see where all the sections end up, you can ask RGBLINK to generate a "map file" with the `-m` flag:

```console
$ rgblink hello-world.o -m hello-world.map
```

...and we can see, for example, where the `"Tilemap"` section ended up:

```
  SECTION: $05a6-$07e5 ($0240 bytes) ["Tilemap"]
```

Sections cannot be split by RGBDS, which is useful e.g. for code, since the processor executes instructions one right after the other (except jumps, as we will see later).
There is a balance to be struck between too many and not enough sections, but it typically doesn't matter much until banking is introduced into the picture—and it won't be until much, much later.

So, for now, let's just assume that one section should contain things that "go together" topically, and let's examine one of ours.

```rgbasm,linenos,start=3
{{#include ../assets/hello-world.asm:6}}
```

So!
What's happening here?
Well, we are simply declaring a new section; all instructions and data after this line and until the next `SECTION` one will be placed in this newly-created section.
Before the first `SECTION` directive, there is no "active" section, and thus generating code or data will be met with a `Cannot output data outside of a SECTION` error.

The new section's name is "`Header`".
Section names can contain any characters (and even be empty, if you want), and must be unique[^sect_name].
The `ROM0` keyword indicates which "memory type" the section belongs to ([here is a list](https://rgbds.gbdev.io/docs/v0.5.2/rgbasm.5#SECTIONS)).
We will discuss them in Part Ⅱ.

The `[$100]` part is more interesting, in that it is unique to this section.
See, I said above that:

> a section \[...\] by default, ends up *somewhere* not known in advance.

However, some memory locations are special, and so sometimes we need a specific section to span a specific range of memory.
To enable this, RGBASM provides the `[addr]` syntax, which *forces* the section's starting address to be `addr`.

In this case, the memory range $100–$14F is special, as it is the *ROM's header*.
We will discuss the header in a couple lessons, but for now, just know that we need not to put any of our code or data in that space.
How do we do that?
Well, first, we begin a section at address $100, and then we need to reserve some space.

### Reserving space

```rgbasm,linenos,start=5
{{#include ../assets/hello-world.asm:8:10}}
```

Line 7 claims to "Make room for the header", which I briefly mentioned just above.
For now, let's focus on what `ds` actually does.

`ds` is used for *statically* allocating memory.
It simply reserves some amount of bytes, which are set to a given value.
The first argument to `ds`, here `$150 - @`, is *how many bytes to reserve*.
The second (optional) argument, here `0`, is *what value to set each reserved byte to*[^ds_pattern].

We will see why these bytes must be reserved in a couple of lessons.

It is worth mentioning that this first argument here is an *expression*.
RGBDS (thankfully!) supports arbitrary expressions essentially anywhere.
This expression is a simple subtraction: $150 minus `@`, which is a special symbol that stands for "the current memory address".

::: tip

A symbol is essentially "a name attached to a value", usually a number.
We will explore the different types of symbols throughout the tutorial, starting with labels in the next section.

A numerical symbol used in an expression evaluates to its value, which must be known when compiling the ROM—in particular, it can't depend on any register's contents.

:::

Oh, but you may be wondering what the "memory addresses" I keep mentioning are.
Let's see about those!

---

[^instr_directive]:
Technically, instructions in RGBASM are implemented as directives, basically writing their encoded form to the ROM; but the distinction between the instructions in the source code and those in the final ROM is not worth bringing up right now.

[^ld_imm_from]:
The curious reader may ask where the value is copied *from*. The answer is simply that the \"immediate\" byte ($00 in this example) is stored in ROM just after the instruction's opcode byte, and it's what gets copied to `a`.
We will come back to this when we talk about how instructions are encoded later on.

[^hw_inc_directives]:
`hardware.inc` itself contains more directives, in particular to define a lot of symbols.
They will be touched upon much later, so we won't look into `hardware.inc` yet.

[^sect_name]:
Section names actually only need to be unique for "plain" sections, and function differently with "unionized" and "fragment" sections, which we will discuss much later.

[^ds_pattern]:
Actually, since RGBASM 0.5.0, `ds` can accept a *list* of bytes, and will repeat the pattern for as many bytes as specified.
It just complicates the explanation slightly, so I omitted it for now.
Also, if the argument is omitted, it defaults to what is specified using the `-p` option **to RGBASM**.
