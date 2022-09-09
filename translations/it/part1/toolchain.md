# Gli strumenti

Nella lezione precedente abbiamo dato vita a una ROM di "Hello World", ma cosa abbiamo fatto esattamente?
È quello che affronteremo in questa lezione.

## RGBASM e RGBLINK

Per cominciare, cosa sono `rgbasm` e `rgblink`?

RGBASM è un _assembler_.
Il suo compito è leggere il codice sorgente (nel nostro caso `hello-world.asm` e `hardware.inc`) e generare un file di codice che però è incompleto:
RGBASM non sempre ha tutte le informazioni che gli servono a generare una ROM, quindi produce dei _file oggetto_ che fanno da intermediari (con estensione `.o`).

RGBLINK è il *linker*.
Il suo compito è usare le informazioni dei file oggetto (che nel nostro caso è solo uno) ed unirli (in inglese "link") in una ROM.
RGBLINK potrebbe non sembrare necessario, ma è solo perché la ROM che abbiamo guardato è davvero piccola: quando nella seconda parte il nostro progetto crescerà, la sua utilità sarà più apparente.

Quindi: codice sorgente → `rgbasm` → file oggetto → `rgblink` → ROM; giusto?
Non proprio.

## RGBFIX

RGBLINK produce sì una ROM, ma se la provassimo su un GameBoy non funzionerebbe.
Nelle ROM deve sempre essere presente qualcosa chiamato _header_:
questa sezione contiene [informazioni sulla ROM](https://gbdev.io/pandocs/The_Cartridge_Header.html), come il nome del gioco, il nome dell'autore, se sia compatibile con il GameBoy Color ed altro.
Per il momento abbiamo impostato tutti i valori a zero nel programma per semplicità, ma ne riparleremo nella seconda parte del tutorial.

Ma nell'header ci sono anche delle componenti importantissime:
- il [logo Nintendo](https://gbdev.io/pandocs/The_Cartridge_Header.html#0104-0133---nintendo-logo),
- la [dimensione della ROM](https://gbdev.io/pandocs/The_Cartridge_Header.html#0148---rom-size),
- e [due valori di controllo](https://gbdev.io/pandocs/The_Cartridge_Header.html#014d---header-checksum) ([checksum](https://it.wikipedia.org/wiki/Checksum)).

Quando la console viene accesa viene eseguito [un programma](https://github.com/ISSOtm/gb-bootroms) chiamato _ROM di avvio_ (boot ROM) responsabile, tra l'altro, dell'animazione di avvio leggendo il logo di Nintendo dalla ROM.
Alla fine dell'animazione, però, la ROM di avvio controlla che il logo di Nintendo sia corretto, e interrompe l'esecuzione se non lo è:
in pratica, se non azzecchiamo il logo il nostro gioco non partirà mai... 😦
Questo meccanismo era per evitare la pirateria; per nsotra fortuna, però, [non è più valida](https://en.wikipedia.org/wiki/Sega_v._Accolade) perciò non dobbiamo preoccuparci! 😄

La ROM di avvio si occupa anche di calcolare dei valori di controllo dell'header, per assicurarsi che sia integro e che non sia dannoso eseguire la ROM.
Nell'header c'è uhna copia di questi valori, e se non corrispondono la ROM **blocca l'esecuzione del GameBoy!**

Nell'header c'è un'altra checksum, che controlla l'intera ROM, che però non è mai usata né controllata.
Non costa niente usarla comunque, però.

Infine, nell'header è contenuta la dimensione della ROM, senza cui il GameBoy non sa leggerla.

RGBFIX serve proprio a compilare l'header in automatico, in particolare questi tre campi senza i quali il GameBoy non farà funzionare il gioco.
L'opzione `-v` dice a RGBFIX di rendere **v**alido l'header, inserendo il logo e calcolando le checksum.
L'opzione `-p 0xFF` invece aggiunge dei byte alla ROM finché non raggiunge una dimensione valida (in inglese **p**ading), per poi scriverla nell'header.

Perfetto!
Quindi, per riassumere: <br>
codice sorgente → `rgbasm` → file oggetto → `rgblink` → ROM "vera" → `rgbfix` → ROM funzionante

A questo punto ti potresti chiedere: perché non si uniscono tutti questi programmi in uno solo?
Ci sono ragioni nella storia di questi programmi, ma soprattutto RGBLINK può fare altro (per esempio usando `-x`), e a volte RGBFIX è usato senza che RGBLINK sia minimamente necessario.

## I nomi dei file

A RGBDS, come alla maggior parte dei programmi, non importa come chiami i file né l'estensione che gli dai: l'importante è il contenuto.
Per esempio molti usano l'estensione `.s` per il sorgente, oppure `.obj` per gli oggetti.
