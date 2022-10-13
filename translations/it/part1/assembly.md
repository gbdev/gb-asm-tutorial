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

## Direttive

In un certo senso possiamo dire che mentre le istruzioni sono dedicate al GameBoy, mentre i commenti sono dedicati a noi programmatori.
Però ci sono righe che non sono né l'una né l'altra, che sono invece delle sorte di metadati diretti ad RGBASM.
Questo è ciò che chiamiamo _direttive_, e nel nostro programma di hello world ce ne sono già tre.

### Inserire altri file

```rgbasm,linenos
{{#include ../assets/hello-world.asm:4}}
```

Nella prima line si _include_ un file chiamato `hardware.inc`[^hw_inc_directives].
In questo modo, stai dicendo all'assembler di copiare il contenuto del file `hardware.inc` nel punto in cui è scritta la direttiva.

Così facendo, si può riciclare facilmente il codice in diversi file: se, ad esempio, due file `a.asm` e `b.asm` includono `hardware.inc` basta modificare il file perché le modifiche si applichino ad `a.asm` e `b.asm`.
Se invece copiassi il contenuto di `hardware.inc` direttamente in `a.asm` e `b.asm` dovresti modificare il contenuto di entrambi ogni volta che vuoi apportare un cambiamento, che non è solo uno spreco di tempo ma aumenta la possibilità di commettere errori.

`hardware.inc` definisce alcune costanti molto utili per interfacciarsi con l'hardware del GameBoy.
Le costanti non sono altro che dei nomi a cui è assegnato un valore: scrivere una costante equivale a scrivere il valore che le è assegnato.
Questo torna molto utile: è molto più semplice ricordare che il <abbr title="LCD Control">Registro di Controllo dell'LCD</abbr> col nome `rLCDC` piuttosto che ricordare l'indirizzo `$FF40`.

Parleremo più nel dettaglio delle varie costanti presenti nella seconda parte del tutorial.

### Sezioni

Puoi vedere una sezione ("`SECTION`") definita a riga 3, ma prima di capire cosa voglia dire dobbiamo parlare di cosa sia una sezione.

In pratica, una sezione è un'area di memoria che, di base, viene messa da _qualche parte_ che non ci è nota mentre scriviamo il codice.
Se vuoi vedere come vengono disposti, basta chiamare RGBLINK con l'opzione `-m` che farà generare un cosiddetto "file mappa":

```console
$ rgblink hello-world.o -m hello-world.map
```

...che ci permette, ad esempio, di vedere dove la sezione `"Tilemap"` sia finita:

```
  SECTION: $05a6-$07e5 ($0240 bytes) ["Tilemap"]
```

Nel creare una ROM, RGBDS non separerà mai i dati contenuti in una stessa sezione ma li terrà nell'ordine in cui li abbiamo scritti. Questo è utile ad esempio nel caso delle istruzioni, che devono essere eseguite l'una dopo l'altra (ad eccezione delle istruzioni di salto, che vedremo poi).
Si dovrebbe cercare di trovare il giusto equilibrio tra _troppe_ sezioni e _troppe poche_, ma in realtà non importa troppo finché non si introduce il concetto delle banche di memoria (che verrà fatto _molto_ più in là).

Quindi per il momento possiamo semplicemente dire che le sezioni contengono cose che devono stare insieme, e detto questo possiamo guardare una delle nostre:

```rgbasm,linenos,start=3
{{#include ../assets/hello-world.asm:6}}
```

Bene! Cosa vuol dire questa riga?
Beh non è altro che la dichiarazione di una nuova sezione; tutto il codice ed i dati che vengono inseriti da qui fino alla prossima dichiarazione di sezione saranno piazzati in questa sezione chiamata `Header`.
È importante notare che prima di questa prima dichiarazione non siamo in nessuna sezione: scrivere del codice o dei dati mentre si è in una sezione darà un errore durante l'assemblaggio ("`Cannot output data outside of a SECTION`").

Dunque, questa sezione si chiama "`Header`".
Ogni nome deve essere una combinazione unica[^sect_name], ma a parte quello non ci sono limitazioni: può contenere qualunque carattere, e può persino essere vuota.
L'opzione `ROM0` indica a quale parte della memoria appartiene la sezione ([lista completa](https://rgbds.gbdev.io/docs/v0.5.2/rgbasm.5#SECTIONS)).
Ne parleremo meglio nella seconda parte.

Ma la parte più interessante è quel `[$100]`: questa parte è unica a questa sezione.
Se ricordi, prima ho detto:

> una sezione \[...\] viene messa da _qualche parte_ che non ci è nota \[...\]

Ma questo non vuol dire che non possiamo sceglierlo in alcun modo: ci sono aree del programma che abbiamo bisogno stiano in un certo punto della memoria.
Per questo RGBASM ti permette di scrivere `[indirizzo]` dopo il tipo di memoria, che fa sì che quella sezione si trovi _per forza_ all'`indirizzo` specificato.

E perché ci serve che questa sezione sia in questo indirizzo? La memoria dagli indirizzi $100 a $14F è particolare, visto che contiene _un'<abbr title="header">intestazione</abbr>_ (di cui abbiamo parlato nell'introduzione all'assembler) che contiene informazioni importanti sulla ROM.
Parleremo di questa zona di memoria tra poche lezioni, ma per il momento è cruciale che niente del nostro codice ci finisca dentro.
Come si fa?
Ci basta definire una sezione che inizi a $100, e poi lasciare dello spazio.

### Riservare dello spazio

```rgbasm,linenos,start=5
{{#include ../assets/hello-world.asm:8:10}}
```

Proprio a riga 7, un commento parla di "lasciare spazio".
Per capire meglio come farlo, guardiamo la direttiva `ds`.

`ds` serve ad allocare memoria _staticamente_.
In parole povere, salta un certo numero di byte che vengono poi impostati ad un dato valore.
Il primo parametro (`$150 - @` in questo caso) sarebbe il _numero_ di byte da lasciare.
La seconda opzione invece è facoltativa: se si specifica un valore, tutti i byte saltati andranno impostati a quel valore[^ds_pattern].

In qualche lezione potremo facilmente vedere a cosa serve lasciare spazio.

Come potresti avere notato, il primo parametro in questo caso non è un valore singolo ma una _espressione_.
RGBDS infatti ti consente di inserire espressioni ovunque tu possa mettere un valore costante (e meno male!).
In questo caso è una semplice sottrazione: $150 meno `@`, un simbolo speciale che indica la posizione attuale in memoria. In questo modo diciamo di lasciare spazio fino all'indirizzo $150.

::: tip

Un simbolo è, fondamentalmente, un nome a cui è assegnato un valore (di solito un numero).
Ci sono vari tipi di simboli, e ne parleremo in varie parti del tutorial (ad esempio, nella prossima sezione parleremo di etichette).

Quando si usa un simbolo in un espressione, il suo valore _deve_ essere noto all'assembler mentre crea la ROM: non può dipendere dal valore di un registro ad esempio.

:::

Ma in tutto questo continuiamo a parlare di "memoria" ed "indirizzi", e potresti non sapere ancora di cosa stiamo parlando:
vediamolo subito!

---

[^instr_directive]:
Se si vuole essere specifici, RGBASM tratta internamente ogni istruzione come fosse una direttiva, senza fare distinzioni tra le due; questo discorso però è complicato e non vale la pena discuterne per questo tutorial.

[^ld_imm_from]:
Potresti starti chiedendo _da dove_ venga letto questo valore, visto che non è in nessun registro. La risposta è semplice: il byte (si parla di valore _immediato_), in questo caso $00, è scritto nella ROM subito dopo il codice dell'istruzione LD; al momento dell'esecuzione, viene letto per poi essere copiato in `a`.
Se l'argomento sembra interessante, bene! In una delle prossime lezioni parleremo proprio di come siano codificate le istruzioni nella ROM.

[^hw_inc_directives]:
`hardware.inc` contiene moltissime direttive, per esempio definisce molti simboli.
Per il momento non guarderemo il contenuto di `hardware.inc`, ne parleremo solo molto più in là.

[^sect_name]:
I nomi devono essere unici solo in una sezione "normale"; nelle sezioni "unite" e "frammentate", di cui parleremo solo più in là, funzionano diversamente.

[^ds_pattern]:
Da RGBASM 0.5.0 `ds` può ricevere una _lista_ di valori come secondo parametro, e ripeterà quella sequenza riempiendo lo spazio richiesto.
Visto che complicava solo la spiegazione, non ho voluto inserirlo nella spiegazione principale.
Come ho detto nella spiegazione, il secondo parametro è opzionale: se non viene specificato viene usato il valore dell'opzione `-p` **di RGBASM**.
