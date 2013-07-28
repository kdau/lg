# Makefile for lg library
# GCC in MinGW32

.SUFFIXES:
.SUFFIXES: .o .cpp

srcdir = .

SH = sh

HOST = x86_64-linux-gnu
TARGET = i686-w64-mingw32

ifdef TARGET
CC = $(TARGET)-g++
ifneq (,$(findstring linux-gnu,$(HOST)))
AR = $(TARGET)-ar
DLLWRAP = $(TARGET)-dllwrap
else # !linux-gnu
AR = $(TARGET)-gcc-ar
DLLWRAP = dllwrap
endif
else # !TARGET
CC = g++
AR = ar
DLLWRAP = dllwrap
endif

# _DARKGAME is not used here. The implementation of lgLib is universal
DEFINES = -DWINVER=0x0400 -D_WIN32_WINNT=0x0400 -DWIN32_LEAN_AND_MEAN

ARFLAGS = rc
LDFLAGS = -mwindows -L.
LIBS = -luuid
INCLUDEDIRS = -I. -I$(srcdir)
# If you care for this... # -Wno-unused-variable
# A lot of the callbacks have unused parameters, so I turn that off.
CXXFLAGS =  -W -Wall -Wno-unused-parameter -masm=intel $(INCLUDEDIRS)
LDFLAGS = -mwindows -L. -llg
DLLFLAGS = --def script.def --add-underscore --target i386-mingw32

# Linux MinGW uses AT&T assembly to implement InterlockedXXX methods
ifneq (,$(findstring linux-gnu,$(HOST)))
REFCNT_CXXFLAGS = -masm=att
else
REFCNT_CXXFLAGS =
endif

ifdef DEBUG
CXXDEBUG = -g -DDEBUG
LDDEBUG = -g
else
CXXDEBUG = -O2 -DNDEBUG
LDDEBUG =
endif

LG_HEADERS = lg/actreact.h \
	lg/ai.h \
	lg/config.h \
	lg/convict.h \
	lg/data.h \
	lg/defs.h \
	lg/dlgs.h \
	lg/dynarray.h \
	lg/dynarray.hpp \
	lg/editor.h \
	lg/gen.h \
	lg/graphics.h \
	lg/iiddef.h \
	lg/iids.h \
	lg/input.h \
	lg/interface.h \
	lg/interfaceimp.h \
	lg/lg.h \
	lg/links.h \
	lg/loop.h \
	lg/malloc.h \
	lg/miss16.h \
	lg/net.h \
	lg/objects.h \
	lg/objstd.h \
	lg/propdefs.h \
	lg/properties.h \
	lg/quest.h \
	lg/res.h \
	lg/script.h \
	lg/scrmanagers.h \
	lg/scrmsgs.h \
	lg/scrservices.h \
	lg/shock.h \
	lg/sound.h \
	lg/tools.h \
	lg/types.h \
	lg/win.h

LG_SRCS = lg.cpp scrmsgs.cpp refcnt.cpp iids.cpp

LG_LIB = liblg.a
LG_OBJS = lg.o scrmsgs.o refcnt.o iids.o

LG_LIBD = liblg-d.a
LG_OBJSD = lg-d.o scrmsgs-d.o refcnt-d.o iids.o

%.o: %.cpp
	$(CC) $(CXXFLAGS) $(CXXDEBUG) $(DEFINES) -o $@ -c $<

%-d.o: %.cpp
	$(CC) $(CXXFLAGS) $(CXXDEBUG) $(DEFINES) -o $@ -c $<


ALL:	$(LG_LIB) $(LG_LIBD)

clean:
	$(RM) $(LG_OBJS) $(LG_OBJSD) $(LG_LIB) $(LG_LIBD)

stamp: $(LG_SRCS) $(LG_HEADERS)
	$(RM) lg/stamp-*
	$(SH) timestamp.sh lg lg $(LG_SRCS)

$(LG_LIB): $(LG_OBJS)
	$(AR) $(ARFLAGS) $@ $?

$(LG_LIBD): CXXDEBUG = -g -DDEBUG
$(LG_LIBD): LDDEBUG = -g
$(LG_LIBD): $(LG_OBJSD)
	$(AR) $(ARFLAGS) $@ $?

lg.o: lg.cpp $(LG_HEADERS)
scrmsgs.o: scrmsgs.cpp lg/scrmsgs.h lg/defs.h lg/types.h lg/interfaceimp.h lg/interface.h lg/iiddef.h lg/objstd.h lg/config.h
refcnt.o: refcnt.cpp lg/interfaceimp.h lg/iiddef.h lg/objstd.h lg/config.h
	$(CC) $(CXXFLAGS) $(REFCNT_CXXFLAGS) $(CXXDEBUG) $(DEFINES) -o $@ -c $<

lg-d.o: lg.cpp $(LG_HEADERS)
scrmsgs-d.o: scrmsgs.cpp lg/scrmsgs.h lg/defs.h lg/types.h lg/interfaceimp.h lg/interface.h lg/iiddef.h lg/objstd.h lg/config.h
refcnt-d.o: refcnt.cpp lg/interfaceimp.h lg/iiddef.h lg/objstd.h lg/config.h
	$(CC) $(CXXFLAGS) $(REFCNT_CXXFLAGS) $(CXXDEBUG) $(DEFINES) -o $@ -c $<
