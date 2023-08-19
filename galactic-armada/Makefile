# You can set the name of the .gb ROM file here
PROJECTNAME    	= GalacticArmada
SRCDIR      	= src
LIBDIR      	= libs
OBJDIR      	= obj
DSTDIR      	= dist
RESDIR      	= $(SRCDIR)/resources
ASMDIR          = $(SRCDIR)/main
RESSPRITES      = $(RESDIR)/sprites
RESBACKGROUNDS  = $(RESDIR)/backgrounds
GENDIR	    	= $(SRCDIR)/generated
GENSPRITES	    = $(GENDIR)/sprites
GENBACKGROUNDS	= $(GENDIR)/backgrounds
BINS	    	= $(DSTDIR)/$(PROJECTNAME).gb

# From: https://stackoverflow.com/questions/3774568/makefile-issue-smart-way-to-scan-directory-tree-for-c-files
# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# How to recursively find all files that match a pattern
ASMSOURCES := $(call rwildcard,src/,*.asm)  $(call rwildcard,libs/,*.asm)
ASMSOURCES_COLLECTED = $(foreach dir,$(OBJDIR),$(notdir $(wildcard $(dir)/*.ASM)))

OBJS       = $(ASMSOURCES_COLLECTED:%.asm=$(OBJDIR)/%.o)

all:	clean prepare generate-graphics copy $(BINS)

# use RGBGFX to create files from pngs
# ANCHOR: generate-graphics
generate-graphics: 
	rgbgfx -c "#FFFFFF,#cfcfcf,#686868,#000000;" --columns 	-o $(GENSPRITES)/player-ship.2bpp 	$(RESSPRITES)/player-ship.png
	rgbgfx -c "#FFFFFF,#cfcfcf,#686868,#000000;" --columns 	-o $(GENSPRITES)/enemy-ship.2bpp 	$(RESSPRITES)/enemy-ship.png
	rgbgfx -c "#FFFFFF,#cfcfcf,#686868,#000000;" --columns 	-o $(GENSPRITES)/bullet.2bpp 		$(RESSPRITES)/bullet.png
	rgbgfx -c "#FFFFFF,#cbcbcb,#414141,#000000;" 			-o $(GENBACKGROUNDS)/text-font.2bpp $(RESBACKGROUNDS)/text-font.png
	rgbgfx -c "#FFFFFF,#cbcbcb,#414141,#000000;" --tilemap $(GENBACKGROUNDS)/star-field.tilemap --unique-tiles -o $(GENBACKGROUNDS)/star-field.2bpp $(RESBACKGROUNDS)/star-field.png
	rgbgfx -c "#FFFFFF,#cbcbcb,#414141,#000000;" --tilemap $(GENBACKGROUNDS)/title-screen.tilemap --unique-tiles  -o $(GENBACKGROUNDS)/title-screen.2bpp $(RESBACKGROUNDS)/title-screen.png

# ANCHOR_END: generate-graphics

compile.bat: Makefile
	@echo "REM Automatically generated from Makefile" > compile.bat
	@make -sn | sed y/\\//\\\\/ | grep -v make >> compile.bat


# copy all ASM sources to the obj directory so the ASMSOURCES_COLLECTED variable can be used
copy: 
	cp $(ASMSOURCES) $(OBJDIR)

# Compile .asm assembly files in "src/" to .o object files
$(OBJDIR)/%.o:	$(OBJDIR)/%.asm
	rgbasm -L -o  $@ $<

# Link the compiled object files into a .gb ROM file
$(BINS):	$(OBJS)
	rgblink  -o $(BINS) $(OBJS)
	rgbfix -v -p 0xFF $(BINS)

prepare:
	mkdir -p $(OBJDIR)
	mkdir -p $(GENSPRITES)
	mkdir -p $(GENBACKGROUNDS)
	mkdir -p $(DSTDIR)

clean:
#	rm -f  *.gb *.ihx *.cdb *.adb *.noi *.map
	rm -f  $(OBJDIR)/*.*
	rm -f  $(GENSPRITES)/*.*
	rm -f  $(GENBACKGROUNDS)/*.*
	rm -f  $(DSTDIR)/*.*

