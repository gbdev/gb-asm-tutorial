> Preparazione
   * it_IT

Setup

***
> Prima di tutto dobbiamo preparare il nostro ambiente di sviluppo\.
> Abbiamo bisogno di\:
   * it_IT

First, we should set up our dev environment\.
We will need\:

***
> Un ambiente POSIX
   * it_IT

A POSIX environment

***
> [RGBDS](<https://rgbds.gbdev.io/install>) v0.5.1 \(v0.5.0 dovrebbe comunque essere compatibile\)
   * it_IT

[RGBDS](<https://rgbds.gbdev.io/install>) v0.5.1 \(though v0.5.0 should be compatible\)

***
> GNU Make \(meglio se una versione recente\)
   * it_IT

GNU Make \(preferably a recent version\)

***
> Un editor di codice
   * it_IT

A code editor

***
> Un emulatore con debugger
   * it_IT

A debugging emulator

***
> \:\:\: tip\:❓😕
   * it_IT

\:\:\: tip\:❓😕

***
> Cerchiamo di dare queste istruzioni in modo che funzionino per la maggior parte delle persone, ma potrebbero essere datate o non funzionare sul tuo computer in particolare\.
> Ma non ti preoccupare\: [chiedi su GBDev](<../index.md#feedback>) per qualunque difficoltà, e ti aiuteremo ad installare tutto ciò che ti serve\!
   * it_IT

The following install instructions are provided on a \"best\-effort\" basis, but may be outdated, or not work for you for some reason\.
Don\'t worry, we\'re here to help\: [ask away in GBDev](<../index.md#feedback>), and we\'ll help you with installing everything\!

***
> \:\:\:
   * it_IT

\:\:\:

***
> Strumenti necessari
   * it_IT

Tools

***
> Linux \& macOS
   * it_IT

Linux \& macOS

***
> Ottime notizie\: hai già completato il primo passo\!
> Hai solo bisogno di [installare RGBDS](<https://rgbds.gbdev.io/install>), ed al massimo aggiornare GNU Make\.
   * it_IT

Good news\: you\'re already fulfilling step 1\!
You just need to [install RGBDS](<https://rgbds.gbdev.io/install>), and maybe update GNU Make\.

***
> macOS
   * it_IT

macOS

***
> Le release di macOS fino alla 11\.0 \(l\'ultima rilasciata nel momento in cui scrivo\) viene installata con una versione molto vecchia di GNU make\.
> Puoi vedere la versione scrivendo `make --version` nel terminale, che dovrebbe scrivere come risultato \"GNU Make\" ed una data, più altre informazioni\.
   * it_IT

At the time of writing this, macOS \(up to 11\.0, the current latest release\) ships a very outdated GNU Make\.
You can check it by opening a terminal, and running `make --version`, which should indicate \"GNU Make\" and a date, among other things\.

***
> Se la versione di make dovesse essere troppo vecchia puoi usare la formula [`make`](<https://formulae.brew.sh/formula/make#default>) di [Homebrew](<https://brew.sh>) per installarlo\.
> Dovrebbe uscire \(al momento della stesura del testo\) un avviso che la versione aggiornata è stata installata come `gmake`, non come `make`\; puoi seguire il suggerimento sullo schermo che dice di usarlo come `make` di default, oppure semplicemente usare `gmake` al posto di `make` mentre segui il tutorial\.
   * it_IT

If your Make is too old, you can update it using [Homebrew](<https://brew.sh>)\'s formula [`make`](<https://formulae.brew.sh/formula/make#default>)\.
At the time of writing, this should print a warning that the updated Make has been installed as `gmake`\; you can either follow the suggestion to use it as your \"default\" `make`, or use `gmake` instead of `make` in this tutorial\.

***
> Linux
   * it_IT

Linux

***
> Installato RGBDS, scrivi `make --version` nel terminale per controllare la versione di make \(che sarà probabilmente GNU Make\).
   * it_IT

Once RGBDS is installed, open a terminal and run `make --version` to check your Make version \(which is likely GNU Make\).

***
> Se ti esce un errore e il tuo computer non trova `make`, installa i `build-essentials` della tua distro.
   * it_IT

If `make` cannot be found, you may need to install your distribution\'s `build-essentials`.

***
> Windows
   * it_IT

Windows

***
> Purtroppo Windows è un sistema operativo terribile come ambiente di sviluppo. Per fortuna, però, puoi installare altri ambienti per contrastare il problema.
   * it_IT

The sad truth is that Windows is a terrible OS for development\; however, you can install environments that solve most issues.

***
> Per Windows 10 il migliore è [WSL](<https://docs.microsoft.com/en-us/windows/wsl>), che permette di fare come se stessi usando Linux in Windows\.
> Installa WSL 1 o WSL 2, scegli una qualsiasi distribuzione, e poi ripeti questi passaggi per la distro che hai installato\.
   * it_IT

On Windows 10, your best bet is [WSL](<https://docs.microsoft.com/en-us/windows/wsl>), which sort of allows running a Linux distribution within Windows\.
Install WSL 1 or WSL 2, then a distribution of your choice, and then follow these steps again, but for the Linux distribution you installed\.

***
> Come alternativa a WSL puoi usare [MSYS2](<https://www.msys2.org>) o [Cygwin](<https://www.cygwin.com>)\; poi leggi le [istruzioni di installazione di RGBDS su Windows](<https://rgbds.gbdev.io/install>)\.
> Che io sappia, questi metodi daranno una versione di GNU make abbastanza aggiornata per poter essere usata in questo tutorial\.
   * it_IT

If WSL is not an option, you can use [MSYS2](<https://www.msys2.org>) or [Cygwin](<https://www.cygwin.com>) instead\; then check out [RGBDS\' Windows install instructions](<https://rgbds.gbdev.io/install>)\.
As far as I\'m aware, both of these provide a sufficiently up\-to\-date version of GNU Make\.

***
> \:\:\: tip
   * it_IT

\:\:\: tip

***
> Se hai già provato a programmare per altre console, tipo il GBA MSYS2 potrebbe essere già installato\:
> molti ambienti di sviluppo per le console, come devkitpro, includono MSYS2\.
   * it_IT

If you have programmed for other consoles, such as the GBA, check if MSYS2 isn\'t already installed on your machine\.
This is because devkitPro, a popular homebrew development bundle, includes MSYS2\.

***
> Editor per codice
   * it_IT

Code editor

***
> Qualunque editor va bene\; personalmente uso [Sublime Text](<https://www.sublimetext.com>) con il [pacchetto sintassi RGBDS](<https://packagecontrol.io/packages/RGBDS>) ma qualunque editor va bene, persino il blocco note se ti vuoi davvero male\.
> GBDev ha [una sezione su tutti gli editor che supportano la sintassi di RGBDS](<https://gbdev.io/resources#syntax-highlighting-packages>), perciò guarda se l\'editor che usi supporta RGBDS\.
   * it_IT

Any code editor is fine\; I personally use [Sublime Text](<https://www.sublimetext.com>) with its [RGBDS syntax package](<https://packagecontrol.io/packages/RGBDS>)\; however, you can use any text editor, including Notepad, if you\'re crazy enough\.
Awesome GBDev has [a section on syntax highlighting packages](<https://gbdev.io/resources#syntax-highlighting-packages>), see there if your favorite editor supports RGBDS\.

***
> Emulatore
   * it_IT

Emulator

***
> C\'è una grande differenza tra un emulatore che usi per giocare ed uno che usi per programmare\.
> Perché un emulatore sia un buon ambiente di sviluppo deve avere\:
   * it_IT

Using an emulator to play games is one thing\; using it to program games is another\.
The two aspects an emulator must fulfill to allow an enjoyable programming experience are\:

***
> __Un supporto al debug__\:
> Se il tuo programma va in palla sulla console è pressoché impossibile capire cosa sia andato storto\:
> non puoi più usare l\'output, non puoi usare `gdb`, non hai nulla\.
> Un emulatore, al contrario, può avere strumenti per aiutare il debug, ad esempio dandoti controllo sull\'esecuzione leggere e mdoificare la memoria, e molto altro\.
> Senza di questi strumenti lo sviluppo sarà tutto meno che _divertente_, fidati!
   * it_IT

__Debugging tools__\:
When your code goes haywire on an actual console, it\'s very difficult to figure out why or how\.
There is no console output, no way to `gdb` the program, nothing\.
However, an emulator can provide debugging tools, allowing you to control execution, inspect memory, etc\.
These are vital if you want GB dev to be _fun_, trust me!

***
> __Accuratezza__\:
> Per accuratezza si intende quanto riproduca bene il comportamento della console reale\.
> Un emulatore poco accurato andrà anche bene per giocare \(seppur spesso con un esperienza poco fluida\.\.\.\), ma se vuoi _programmare_, hai bisogno di sapere se il tuo gioco sia effettivamente compatibile con la console\.
> Se sei interessto puoi leggere di più a riguardo con [questo articolo di Ars Technica](<https://arstechnica.com/?post_type=post&p=44524>) (inglese) \(in particolare la sezione <q>An emulator for every game</q> in cima alla seconda pagina\)\.
> Il [GB\-emulator\-shootout](<https://daid.github.io/GBEmulatorShootout/>) di Daid è un tabella con diversi test per alcuni emulatori, che ti permette di vedere i più accurati\.
   * it_IT

__Good accuracy__\:
Accuracy means \"how faithful to the original console something is\"\.
Using a bad emulator for playing games can work \(to some extent, and even then\.\.\.\), but using it for _developing_ a game makes it likely to accidentally render your game incompatible with the actual console\.
For more info, read [this article on Ars Technica](<https://arstechnica.com/?post_type=post&p=44524>) \(especially the <q>An emulator for every game</q> section at the top of page 2\)\.
You can compare GB emulator accuracy on [Daid\'s GB\-emulator\-shootout](<https://daid.github.io/GBEmulatorShootout/>)\.

***
> Nel tutorial usaremo [BGB](<https://bgb.bircd.org>) \(versione 1\.5\.9 al momento della stesura del testo\)\.
> Funziona solo su Windows, ma gli utenti di Linux e macOS possono usare Wine per farlo funzionare\.
> Puoi usare un qualsiasi altro emulatore \(per esempio SameBoy funziona su macOS\), ma quando nel tutorial spiegherò come se usassi BGB\.
   * it_IT

The emulator I will be using for this tutorial is [BGB](<https://bgb.bircd.org>) \(1\.5\.9 when I\'m writing this\)\.
It\'s Windows\-only, but macOS and Linux users can install Wine to be able to run it, and macOS users will additionally have to use the 64\-bit version\.
Other debugging emulators are possible \(such as SameBoy on macOS\), but I will be giving directives for and including screenshots of BGB\.

***