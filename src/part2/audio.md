# Audio

In the last few chapters we implemented the bulk of our game's interactivity, but it would be nice to add some feedback to make brick-breaking a bit more satisfying.

The Game Boy has 4 channels for producing sound: 2 pulse channels, a wave channel, and a noise channel.
Each type of channel has a unique type of sound that it can produce.
For example, the pulse channels can play notes, making them ideal for melodies, while the noise channel is less melodic, making it better for percussion.
The wave channel is unique in that it can be used to play simple waveforms.
You can almost think of this as a custom instrument, though it's very limited.

(NOTE: I think it would be nice to include the SVG from [this page](https://gbdev.io/pandocs/Audio.html))

Audio channels can be controlled through the Game Boy's large number of "NR" registers.
Each of these registers configures the behavior of a channel and can be used to play specific sounds.
In addition, channels 1, 2, and 4 have a hardware envelope, which is used to fade the channel out over time; this is very useful for simple sound effects!

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
