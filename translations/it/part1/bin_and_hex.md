# Binary and hexadecimal

Prima di passare al codice dobbiamo introdurre alcuni concetti.

Quando si programma ad un basso livello è fondamentale capire bene i sistemi _[binario](https://it.wikipedia.org/wiki/Sistema_numerico_binario)_ ed _[esadecimale](https://it.wikipedia.org/wiki/esadecimale)_.
Se già conoscessi questi concetti, in fondo alla pagina ci sono delle informazioni specifiche all'uso di RGDBS.

Cos'è il binario?
È semplicemente un modo alternativo di rappresentare i numeri, in _base 2_.
Noi contiamo in [base 10](https://it.wikipedia.org/wiki/decimale), ovvero con 10 cifre: 0, 1, 2, 3, 4, 5, 6, 7, 8, e 9.
Le cifre hanno una funzione ben specifica:

```
  42 =                       4 × 10   + 2
     =                       4 × 10^1 + 2 × 10^0
                                  ↑          ↑
    	qui usiamo 10 perché contiamo in base 10!

1024 = 1 × 1000 + 0 × 100  + 2 × 10   + 4
     = 1 × 10^3 + 0 × 10^2 + 2 × 10^1 + 4 × 10^0
       ↑          ↑          ↑          ↑
 e qui vediamo le cifre che compongono il numero!
```

::: tip:ℹ️

`^` è una notazione per indicare l'elevamento a potenza, quindi `X^N` significa moltiplicare `X` per se stesso `N` volte (ricordando che `X ^ 0 = 1`).

:::

Quindi, il sistema **deci**male è una scomposizione del numero in potenze di dieci.
A questo punto, perché non usare altre basi?
Potremmo usare, ad esempio, la base 2
(non scegliamo questo numero a caso, spiegheremo poi meglio il perché).

La base 2 è chiamata **bi**nario. Ha due cifre, chiamate bit: 0 e 1.
Possiamo generalizzare quanto mostrato sopra, e scrivere i numeri di prima con le cifre binarie:

```
  42 =                                                    1 × 32  + 0 × 16  + 1 × 8   + 0 × 4   + 1 × 2   + 0
     =                                                    1 × 2^5 + 0 × 2^4 + 1 × 2^3 + 0 × 2^2 + 1 × 2^1 + 0 × 2^0
                                                              ↑         ↑         ↑         ↑         ↑         ↑
                                     e visto che stiamo usando la base 2 usiamo dei due al posto dei dieci di prima!

1024 = 1 × 1024 + 0 × 512 + 0 × 256 + 0 × 128 + 0 × 64  + 0 × 32  + 0 × 16  + 0 × 8   + 0 × 4   + 0 × 2   + 0
     = 1 × 2^10 + 0 × 2^9 + 0 × 2^8 + 0 × 2^7 + 0 × 2^6 + 0 × 2^5 + 0 × 2^4 + 0 × 2^3 + 0 × 2^2 + 0 × 2^1 + 0 × 2^0
       ↑          ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑         ↑
```

Quindi, seguendo questo principio, scopriamo che 42 in binario si scrive `101010` e 1024 `10000000000`.
C'è un problema però: come facciamo a distinguere dieci (in decimale `10`) e due (in binario `10`)? Per farlo, RGBDS usa dei prefissi ai numeri: % indica un numero binario, quindi %10 è due, mentre senza un prefisso si ha un numero decimale e quindi 10 è dieci.

Quindi, perché proprio la base due?
Secondo la convenzione un bit può essere solo zero o uno, spento o acceso, vuoto o pieno, etc!
Per esempio, potremmo avere una scatola e trasformarla in una memoria ad un bit:
se è vuota rappresenta uno zero, se è piena rappresenta un uno.
I computer, nelle loro operazioni, manipolano elettricità e quindi fanno uso di questo principio: uno vuol dire che c'è elettricità, e zero niente elettricità. Quindi i computer manipolano numeri binari, che come vedremo ha diverse conseguenze.

## Esadecimale

Quindi: i computer faticano ad usare il sistema decimale, perciò devono usare il binario.
Certo, ma per _noi_ è faticoso usare il binario.
Se per esempio ti volessi dire %10000000000 mi servirebbero 12 cifre, quando in decimale (= 2048) ne basterebbero quattro!
E poi ti sei accorto che ho saltato uno zero?
Per fortuna in nostro soccorso arriva il sistema esadecimale! 🦸

In esadecimale ci sono sedici cifre (chiamate _nibble_ in inglese): 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, ed F.

```
  42 =            2 × 16   + 10
     =            2 × 16^1 + A × 16^0

1024 = 4 × 256  + 0 × 16   + 0
     = 4 × 16^2 + 0 × 16^1 + 0 × 16^0
```

Come per il binario useremo un prefisso, stavolta `$`, per distinguerlo dal decimale.
Quindi 42 = $2A e 1024 = $400.
Questi numeri sono _estremamente_ più compatti di un numero binario, e persino leggermente più del decimale; ma la proprietà più interessante dell'esadecimale è che una cifra corrisponde sempre a quattro bit!

 Nibble | Bit
:------:|:----:
     $0 | %0000
     $1 | %0001
     $2 | %0010
     $3 | %0011
     $4 | %0100
     $5 | %0101
     $6 | %0110
     $7 | %0111
     $8 | %1000
     $9 | %1001
     $A | %1010
     $B | %1011
     $C | %1100
     $D | %1101
     $E | %1110
     $F | %1111

Quindi è facilissimo convertire da ed a binario, ma allo stesso tempo sono più semplici da leggere.
Proprio per questo l'esadecimale è così diffuso, soprattutto in programmazione di basso livello.
Ma non preoccuparti, si può sempre usare il decimale 😜

(qualcuno potrebbe dire che si potrebbe usare anche il sistema ottale (base 8); però noi avremo per lo più insiemi di 8 bit, per cui l'esadecimale funziona _molto_ meglio. RGBDS ti permette comunque di usarlo col prefisso `&`, ma non l'ho mai visto usato)

::: tip:💡

Se hai problemi a convertire tra i vari sistemi numerici, non disperare! È molto probabile che la tua calcolatrice abbia una "modalità programmatore" che aiuti proprio in questo lavoro. Altrimenti, è pieno di calcolatori del genere online!

:::

## Punti chiave

- In RGBDS, il prefisso `$` indica un numero esadecimale mentre `%` uno binario.
- Esadecimale può essere usato come versione più compatta del sistema binario.
- Binario ed esadecimale sono molto utili quando bisogna enfatizzare i singoli bit, altrimenti il classico decimale va bene.
- Quando un numero è troppo lungo RGBDS permette di "spezzettarlo" con dei trattini bassi (`123_465`, `%10_1010`, `$B_EF_FA`, etc.)
