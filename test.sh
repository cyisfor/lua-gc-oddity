echo luajit:
luajit test.lua luajit-ext || echo died
echo
echo lua 5.1:
lua5.1 test.lua lua51-ext || echo died
echo
echo lua 5.2:
lua test.lua lua52-ext || echo died
