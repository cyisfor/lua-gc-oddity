#include "lauxlib.h"
#include <stdio.h>

#include <string.h>

#if LUA_VERSION_NUM == 501
#define setfuncs(L, l) luaL_register(L, NULL, l)
#define luaL_setmetatable(L, name) \
  luaL_getmetatable(L, name); \
  lua_setmetatable(L, -2)
#elif LUA_VERSION_NUM == 502
#define setfuncs(L, l) luaL_setfuncs(L, l, 0)
#else
#error huh?
#endif

static const char *mytype = "mytype";

static int newobj(lua_State *L) {
  size_t size = 0;
  const char* s = lua_tolstring(L, 1, &size);

  char *ud = lua_newuserdata(L, size+1);
  memcpy(ud,s,size);
  ud[size] = '\0';
  printf("new userdata=%p(%s)\n", ud, ud);
  luaL_setmetatable(L, mytype);
  return 1;
}

static int call(lua_State *L) {
    char* ud = luaL_checkudata(L, 1, mytype);
  printf("__call userdata=%p(%s)\n", ud, ud);
  return 0;
}

static int gc(lua_State *L) {
    char* ud = luaL_checkudata(L, 1, mytype);
  printf("__gc userdata=%p(%s)\n", ud, ud);
  return 0;
}

static const struct luaL_Reg mm[] = {
  {"__gc", gc},
  {"__call", call},
  {NULL, NULL}
};

int luaopen_ext(lua_State *L) {
  luaL_newmetatable(L, mytype);
  setfuncs(L, mm);
  lua_pushcfunction(L, &newobj);
  return 1;
}
