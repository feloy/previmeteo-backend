# Basic astronomical functions library - OpenWatcom C/C++ version

all: astcheck.exe astephem.exe calendar.exe      cosptest.exe dist.exe easter.exe get_test.exe jevent.exe jpl2b32.exe      jd.exe jsattest.exe lun_test.exe marstime.exe oblitest.exe persian.exe     phases.exe ps_1996.exe relativi.exe ssattest.exe tables.exe testprec.exe     testprec.exe uranus1.exe utc_test.exe

astephem.exe:         astephem.obj mpcorb.obj wafuncs.lib
	wcl386 -zq -k10000 astephem.obj mpcorb.obj wafuncs.lib

astcheck.exe: astcheck.obj mpcorb.obj wafuncs.lib
	wcl386 -zq -k10000 astcheck.obj mpcorb.obj wafuncs.lib

calendar.exe:         calendar.obj wafuncs.lib
	wcl386 -zq -k10000 calendar.obj wafuncs.lib

cosptest.exe:         cosptest.obj wafuncs.lib
	wcl386 -zq -k10000 cosptest.obj wafuncs.lib

dist.exe:             dist.cpp
	wcl386 -zq -k10000 dist.cpp

easter.exe:           easter.cpp
	wcl386 -zq -k10000 easter.cpp -DTEST_CODE

get_test.exe:         get_test.obj wafuncs.lib
	wcl386 -zq -k10000 get_test.obj wafuncs.lib

htc20b.exe:           htc20b.obj wafuncs.lib
	wcl386 -zq -k10000 htc20b.obj wafuncs.lib -DTEST_MAIN

jd.exe:               jd.obj wafuncs.lib
	wcl386 -zq -k10000 jd.obj wafuncs.lib

jevent.exe:           jevent.cpp wafuncs.lib
	wcl386 -zq -k10000 jevent.cpp wafuncs.lib

jpl2b32.exe:          jpl2b32.cpp
	wcl386 -zq -k10000 jpl2b32.cpp

jsattest.exe:         jsattest.obj wafuncs.lib
	wcl386 -zq -k10000 jsattest.obj wafuncs.lib

lun_test.exe:         lun_test.obj lun_tran.obj riseset3.obj wafuncs.lib
	wcl386 -zq -k10000 lun_test.obj lun_tran.obj riseset3.obj wafuncs.lib

marstime.exe:         marstime.cpp
	wcl386 -zq -k10000 marstime.cpp -DTEST_PROGRAM

oblitest.exe:         oblitest.obj obliqui2.obj spline.obj wafuncs.lib
	wcl386 -zq -k10000 oblitest.obj obliqui2.obj spline.obj wafuncs.lib

persian.exe:          persian.obj solseqn.obj wafuncs.lib
	wcl386 -zq -k10000 persian.obj solseqn.obj wafuncs.lib

phases.exe:           phases.obj wafuncs.lib
	wcl386 -zq -k10000 phases.obj wafuncs.lib

ps_1996.exe:          ps_1996.obj wafuncs.lib
	wcl386 -zq -k10000 ps_1996.obj wafuncs.lib

relativi.exe:         relativi.cpp wafuncs.lib
	wcl386 -zq -k10000 relativi.cpp wafuncs.lib -DTEST_CODE

ssattest.exe:         ssattest.obj wafuncs.lib
	wcl386 -zq -k10000 ssattest.obj wafuncs.lib

tables:           tables.o riseset3.o   alt_az.o astfuncs.o big_vsop.o classel.o com_file.o cospar.o date.o delta_t.o de_plan.o dist_pa.o eart2000.o elp82dat.o getplane.o get_time.o jsats.o lunar2.o triton.o miscell.o nutation.o obliquit.o pluto.o precess.o refract.o refract4.o rocks.o showelem.o ssats.o vislimit.o vsopson.o
	g++ -g $^ -o tables -lm

moonphase:           moonphase.o riseset3.o   alt_az.o astfuncs.o big_vsop.o classel.o com_file.o cospar.o date.o delta_t.o de_plan.o dist_pa.o eart2000.o elp82dat.o getplane.o get_time.o jsats.o lunar2.o triton.o miscell.o nutation.o obliquit.o pluto.o precess.o refract.o refract4.o rocks.o showelem.o ssats.o vislimit.o vsopson.o
	g++ -g $^ -o moonphase -lm

moonphase4:           moonphase4.o riseset3.o   alt_az.o astfuncs.o big_vsop.o classel.o com_file.o cospar.o date.o delta_t.o de_plan.o dist_pa.o eart2000.o elp82dat.o getplane.o get_time.o jsats.o lunar2.o triton.o miscell.o nutation.o obliquit.o pluto.o precess.o refract.o refract4.o rocks.o showelem.o ssats.o vislimit.o vsopson.o
	g++ -g $^ -o moonphase4 -lm

testprec.exe:         testprec.obj wafuncs.lib
	wcl386 -zq -k10000 testprec.obj wafuncs.lib

test_ref.exe:         test_ref.obj refract4.obj refract.obj
	wcl386 -zq -k10000 test_ref.obj refract4.obj refract.obj

uranus1.exe:          uranus1.obj gust86.obj
	wcl386 -zq -k10000 uranus1.obj gust86.obj

utc_test.exe:         utc_test.obj wafuncs.lib
	wcl386 -zq -k10000 utc_test.obj wafuncs.lib

wafuncs.lib: alt_az.o astfuncs.o big_vsop.o classel.o com_file.o cospar.o date.o delta_t.o de_plan.o dist_pa.o eart2000.o elp82dat.o getplane.o get_time.o jsats.o lunar2.o triton.o miscell.o nutation.o obliquit.o pluto.o precess.o refract.o refract4.o rocks.o showelem.o ssats.o vislimit.o vsopson.o
	wlib -q wafuncs.lib +alt_az.o +astfuncs.o +big_vsop.o +classel.o +com_file.o +cospar.o
	wlib -q wafuncs.lib +date.o +delta_t.o +de_plan.o +dist_pa.o
	wlib -q wafuncs.lib +eart2000.o +elp82dat.o +getplane.o +get_time.o
	wlib -q wafuncs.lib +jsats.o +lunar2.o +triton.o +miscell.o +nutation.o
	wlib -q wafuncs.lib +obliquit.o +pluto.o +precess.o +refract.o
	wlib -q wafuncs.lib +refract4.o +rocks.o +showelem.o
	wlib -q wafuncs.lib +ssats.o +vislimit.o +vsopson.o

CC=g++
CFLAGS=

.cpp.o:
	$(CC) -g -c $(CFLAGS) $<
