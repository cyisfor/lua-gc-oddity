all: lua51-ext.so lua52-ext.so luajit-ext.so

lua51-ext.so: lua51-ext.os
	gcc -shared -o$@ $< -llua5.1

lua51-ext.os: ext.c
	gcc -fPIC -shared -I /usr/include/lua5.1 -c -o $@ $<

luajit-ext.so: luajit-ext.os
	gcc -shared -o$@ $< -lluajit-5.1

luajit-ext.os: ext.c
	gcc -fPIC -shared -I /usr/include/luajit-2.0 -c -o $@ $<

lua52-ext.so: lua52-ext.os
	gcc -shared -o$@ $< -llua

lua52-ext.os: ext.c
	gcc -fPIC -shared -c -o $@ $<
