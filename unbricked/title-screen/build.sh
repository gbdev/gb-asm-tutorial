#!/bin/sh

rgbasm -o main.o main.asm
rgbasm -o input.o input.asm
rgblink -o unbricked.gb main.o input.o
rgbfix -v -p 0xFF unbricked.gb
