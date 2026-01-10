#!/bin/sh

rgbasm -o sio.o sio.asm
rgbasm -o main.o main.asm
rgblink -o unbricked.gb main.o sio.o
rgbfix -v -p 0xFF unbricked.gb