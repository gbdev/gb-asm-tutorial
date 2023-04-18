# Audio

In the last few chapters we implemented the bulk of our game's interactivity, but it would be nice to add some feedback to make brick-breaking a bit more satisfying.

The Game Boy has 4 channels for producing sound: 2 pulse channels, a wave channel, and a noise channel.
Each type of channel has a unique type of sound that it can produce.
For example, the pulse channels can play notes, making them ideal for melodies, while the noise channel is less melodic, making it better for percussion.
The wave channel is unique in that it can be used to play simple waveforms.
You can almost think of this as a custom instrument, though it's very limited.

Here's a diagram from [this page](https://gbdev.io/pandocs/Audio.html) of the Pandocs showing each channel.
<svg viewBox="0 0 480 220" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style type="text/css">
      text {
        fill: var(--fg);
        dominant-baseline: middle;
      }
      .centered { text-anchor: middle; }
      .right    { text-anchor: end; }
      rect, path, use {
        stroke: var(--fg);
        fill: var(--fg);
      }
      .inverted {
        stroke: var(--bg);
        fill: var(--bg);
      }
      .unfilled {
        fill: none !important;
      }
      .no-stroke {
        stroke: none !important;
      }
    </style>
    <path d="M 0,-5
             v 10
             l 10,-5
             z" id="arrow-head"></path>
  </defs>
  <text x="85" y="36" class="right">Channel 1</text>
  <rect x="95" y="15" width="40" height="40"></rect>
  <path d="M 95,45
           h 10
           v -20
           h 10
           v 20
           h 10
           v -20
           h 10" class="inverted unfilled"></path>
  <text x="85" y="86" class="right">Channel 2</text>
  <rect x="95" y="65" width="40" height="40"></rect>
  <path d="M 95,95
           h 10
           v -20
           h 10
           v 20
           h 10
           v -20
           h 10" class="inverted unfilled"></path>
  <text x="85" y="136" class="right">Channel 3</text>
  <rect x="95" y="115" width="40" height="40"></rect>
  <path d="M 95,141
           h 2
           v -2
           h 2
           v -3
           h 2
           v -3
           h 2
           v -3
           h 2
           v -2
           h 2
           v -1
           h 2
           v 1
           h 2
           v 2
           h 2
           v 5
           h 2
           v 4
           h 2
           v 2
           h 2
           v 1
           h 4
           v -10
           h 2
           v -5
           h 2
           v 15
           h 2
           v -14
           h 2
           v 7
           h 2
           v 4
           h 2
           v 2
           h 4
           v 1
           h 4
           v -1
           h 2
           v -1
           h 2
           v -2
           h 2
           v -2
           h 2
           v -3
           h 2
           v -2
           h 2
           v -2
           h 2" class="inverted unfilled"></path>
  <text x="85" y="186" class="right">Channel 4</text>
  <rect x="95" y="165" width="40" height="40"></rect>
  <path d="M 95,195
           h 2
           v -20
           h 2
           v 20
           h 5
           v -20
           h 2
           v 20
           h 1
           v -20
           h 6
           v 20
           h 3
           v -20
           h 2
           v 20
           h 1
           v -20
           h 2
           v 20
           h 5
           v -20
           h 1
           v 20
           h 4
           v -20
           h 2
           v 20
           h 1
           v -20
           h 1" class="inverted unfilled"></path>
  <path d="M 135,35
           h 30
           m -30,50
           h 30
           m -30,50
           h 30
           m -30,50
           h 30
           v -150
           m 0,75
           h 30" class="unfilled"></path>
  <use x="185" y="110" href="#arrow-head"></use>
  <rect x="195" y="95" width="60" height="30"></rect>
  <text x="225" y="110" class="centered inverted no-stroke">Mixer</text>
  <path d="M 255,102
           h 30" class="unfilled"></path>
  <use x="275" y="102" href="#arrow-head"></use>
  <path d="M 255,118
           h 30" class="unfilled"></path>
  <use x="275" y="118" href="#arrow-head"></use>
  <rect x="285" y="95" width="80" height="30"></rect>
  <text x="325" y="110" class="centered inverted no-stroke">Amplifier</text>
  <path d="M 365,102
           h 30" class="unfilled"></path>
  <use x="385" y="102" href="#arrow-head"></use>
  <path d="M 365,118
           h 30" class="unfilled"></path>
  <use x="385" y="118" href="#arrow-head"></use>
  <rect x="395" y="95" width="80" height="30"></rect>
  <text x="435" y="110" class="centered inverted no-stroke">Output</text>
</svg>

Audio channels can be controlled through the Game Boy's large number of "NR" registers.
Each of these registers configures the behavior of a channel and can be used to play specific sounds.
In addition, channels 1, 2, and 4 have a hardware envelope, which is used to fade the channel out over time; this is very useful for simple sound effects!

::: tip

If you'd like a more in-depth look at the audio registers, check out the [audio articles](https://gbdev.io/pandocs/Audio.html) on the Pandocs.

:::

For the simple sound effects in our game, all we need to do is write a few values to the NR registers, and the Game Boy will handle the rest.
We can use a tool like [gbsfx studio](https://daid.github.io/gbsfx-studio/) to create a sound we like, and then copy the code into our game to play it.

We'll start with a "bounce" sound effect. Let's use channel 2, which is a pulse channel, and play a short note.
The following code is a sample bounce sound, but feel free to play around and find a sound you like.

```rgbasm
ld a, $85
ld [rNR21], a
ld a, $70
ld [rNR22], a
ld a, $0d
ld [rNR23], a
ld a, $c3
ld [rNR24], a
```

To use this in our game, we'll put it within a short function which we can call any time a bounce sound needs to be played.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/audio/main.asm:bounce-sound}}
{{#include ../../unbricked/audio/main.asm:bounce-sound}}
```

Now just call this function at the end of each of our bouncing checks.
Don't forget the paddle!

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/audio/main.asm:updated-bounce}}
{{#include ../../unbricked/audio/main.asm:updated-bounce}}
```

A sound effect would make destroying bricks a lot more satisfying.
This time, let's use the noise channel to play a sound.
Since we're using a different channel, the "bounce" and "break" sounds can overlap without any issue!

This is an example sound, but feel free to create your own.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/audio/main.asm:break-sound}}
{{#include ../../unbricked/audio/main.asm:break-sound}}
```

And just like with the bouncing sound, we'll need to call this function in our brick-breaking code.

```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/audio/main.asm:check-for-brick}}
{{#include ../../unbricked/audio/main.asm:check-for-brick}}
```

Now the game has some audiotory feedback!
