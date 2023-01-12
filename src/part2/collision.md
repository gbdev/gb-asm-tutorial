# Collision

Being able to move around is great, but there's still one object we need for this game: a ball!
Just like with the paddle, the first step is to create a graphic for the ball and load it into VRAM.

Add this to the bottom of your file along with the other graphics:
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ball-sprite}}
{{#include ../../unbricked/collision/main.asm:ball-sprite}}
```

Now copy it to VRAM in your initialization code.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:copy-ball}}
{{#include ../../unbricked/collision/main.asm:copy-ball}}
```

In addition, we need to initialize an entry in OAM, right after where we initialize the paddle.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:oam}}
{{#include ../../unbricked/collision/main.asm:oam}}
```

As the ball bounces around the screen its momentum will change, sending it in different directions.
Let's create two new variables to track the ball's momentum: `wBallMomentumX` and `wBallMomentumY`.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:ram}}
{{#include ../../unbricked/collision/main.asm:ram}}
```

We'll need to initialize these, so let's so do right after we write the ball to OAM.
```rgbasm,linenos,start={{#line_no_of "" ../../unbricked/collision/main.asm:init}}
{{#include ../../unbricked/collision/main.asm:init}}
```
