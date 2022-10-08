# Preparazione

Prima di tutto dobbiamo preparare il nostro ambiente di sviluppo.
Abbiamo bisogno di:

1. Un ambiente POSIX
2. [RGBDS](https://rgbds.gbdev.io/install) v0.5.1 (v0.5.0 dovrebbe comunque essere compatibile)
3. GNU Make (meglio se una versione recente)
4. Un editor di codice
5. Un emulatore con debugger

::: tip:❓😕

Cerchiamo di dare queste istruzioni in modo che funzionino per la maggior parte delle persone, ma potrebbero essere datate o non funzionare sul tuo computer in particolare.
Ma non ti preoccupare: [chiedi su GBDev](../index.md#feedback) per qualunque difficoltà, e ti aiuteremo ad installare tutto ciò che ti serve!

:::

## Strumenti necessari

### Linux & macOS

Ottime notizie: hai già completato il primo passo!
Hai solo bisogno di [installare RGBDS](https://rgbds.gbdev.io/install), ed al massimo aggiornare GNU Make.

#### macOS

Le release di macOS fino alla 11.0 (l'ultima rilasciata nel momento in cui scrivo) viene installata con una versione molto vecchia di GNU make.
Puoi vedere la versione scrivendo `make --version` nel terminale, che dovrebbe scrivere come risultato \"GNU Make\" ed una data, più altre informazioni.

Se la versione di make dovesse essere troppo vecchia puoi usare la formula [`make`](https://formulae.brew.sh/formula/make#default) di [Homebrew](https://brew.sh) per installarlo.
Dovrebbe uscire (al momento della stesura del testo) un avviso che la versione aggiornata è stata installata come `gmake`, non come `make`; puoi seguire il suggerimento sullo schermo che dice di usarlo come `make` di default, oppure semplicemente usare `gmake` al posto di `make` mentre segui il tutorial.

#### Linux

Installato RGBDS, scrivi `make --version` nel terminale per controllare la versione di make (che sarà probabilmente GNU Make).

Se ti esce un errore e il tuo computer non trova `make`, installa i `build-essentials` della tua distro.

### Windows

Purtroppo Windows è un sistema operativo terribile come ambiente di sviluppo. Per fortuna, però, puoi installare altri ambienti per contrastare il problema.

Su Windows 10 il migliore è [WSL](https://docs.microsoft.com/en-us/windows/wsl), che permette di fare come se stessi usando Linux in Windows.
Installa WSL 1 o WSL 2, scegli una qualsiasi distribuzione, e poi ripeti questi passaggi per la distro che hai installato.

Come alternativa a WSL puoi usare [MSYS2](https://www.msys2.org) o [Cygwin](https://www.cygwin.com); poi leggi le [istruzioni di installazione di RGBDS su Windows](https://rgbds.gbdev.io/install).
Che io sappia, questi metodi daranno una versione di GNU make abbastanza aggiornata per poter essere usata in questo tutorial.

::: tip

Se hai già provato a programmare per altre console, come il GBA, MSYS2 potrebbe essere già installato:
molti ambienti di sviluppo per le console, come devkitpro, includono MSYS2.

:::

## Editor per il codice

Qualunque editor va bene; io uso [Sublime Text](https://www.sublimetext.com) con il [pacchetto sintassi RGBDS](https://packagecontrol.io/packages/RGBDS) ma qualunque editor va bene, persino il blocco note se proprio ti vuoi fare male.
GBDev ha [una sezione su tutti gli editor che supportano la sintassi di RGBDS](https://gbdev.io/resources#syntax-highlighting-packages), perciò guarda se l'editor che usi supporta RGBDS.

## Emulatore

C'è una grande differenza tra un emulatore che usi per giocare ed uno che usi per programmare.
Perché un emulatore sia un buon ambiente di sviluppo deve avere:
- __Un supporto al debug__:
  Se il tuo programma va in palla sulla console è pressoché impossibile capire cosa sia andato storto:
  non puoi più usare l'output, non puoi usare `gdb`, non hai nulla.
  Un emulatore, al contrario, può avere strumenti per aiutare il debug, ad esempio dandoti controllo sull'esecuzione leggere e mdoificare la memoria, e molto altro.
  Senza di questi strumenti lo sviluppo sarà tutto meno che _divertente_, fidati!
- __Accuratezza__:
  Per accuratezza si intende quanto riproduca bene il comportamento della console reale.
  Un emulatore poco accurato andrà anche bene per giocare (seppur spesso con un esperienza poco fluida...), ma se vuoi _programmare_, hai bisogno di sapere se il tuo gioco sia effettivamente compatibile con la console.
  Se sei interessto puoi leggere di più a riguardo con [questo articolo di Ars Technica](https://arstechnica.com/?post_type=post&p=44524) (inglese) (in particolare la sezione <q>An emulator for every game</q> in cima alla seconda pagina).
  Il [GB-emulator-shootout](https://daid.github.io/GBEmulatorShootout/) di Daid è un tabella con diversi test per alcuni emulatori, che ti permette di vedere i più accurati.

Nel tutorial usaremo [BGB](https://bgb.bircd.org) (versione 1.5.9 al momento della stesura del testo) che però, purtroppo, è solo in inglese.
Funziona solo su Windows, ma se sei su Linux e macOS puoi usare Wine per farlo funzionare.
Puoi usare un qualsiasi altro emulatore (per esempio SameBoy funziona su macOS), ma quando nel tutorial spiegherò come se usassi BGB.
