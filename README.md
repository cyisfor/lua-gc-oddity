The technique of finalizers in lua might not be working right. In particular, functions that have upvalues can end up using those upvalues AFTER the upvalues have been finalized! 

It’s basically this:

	function scope()
	    local a
	    b = function()
	        a.somemethod()
	    end
	    a = somevalue()
	    return b
	end
	
	b = scope()
	-- a can be finalized at this point!
	b()
	-- now a.somemethod() gets called,

The bizarre and arbitrary part about this is, if you assign `somevalue()` to a before defining the function, then `a` cannot be finalized until the function itself is collected, but if you assign `somevalue()` to `a` after defining the function, then the function retains the upvalue, but `a` is still finalized in ignorance of that.

The test script demonstrates this by assigning after if `buggy=1` and assigning before if buggy is unset in the environment. To use said script run make, then `sh test.sh` to see the results. `__call` should come before `__gc` in any case.

Functions will never be called on upvalues that have been collected. But for some reason, for purposes of finalization, upvalues lose their reference when they are assigned positionally after the function has been created. That can have nasty consequences for userdata objects, if they have to free up any memory on the C side of things. An object with a forgotten reference to that userdata could then attempt to use freed memory!

This is true of lua 5.1, lua 5.2 and luajit. It seems to be an error by design, but I cannot find the logic behind this behavior. It seems to me a simple error that needs to be accounted for instead of treated as intentional or beneficial.

The current workaround to deal with it is to have userdata objects contain a “finalized” flag and fail on all operations with an informative message if they are called after having been finalized. Though the userdata is never freed until all functions that can reach that object are collected, regardless of finalizers, any pointers within the user data that might lead to dynamically allocated memory can only be freed in finalizers. Furthermore any operating system resources, such as descriptors or file locks can only be released in finalizers (or explicitly). The current behavior is for them to do so, unless you use them in a particular kind of assignment statement, in which case they finalize early.

I don’t think this is correct however, because neither userdata nor lua objects should be finalized until there are no references to them, reference loops excepted. If there is a reference to an object, made obvious by the fact that the function can use that object, call its methods and retrieve its values, then that reference should not be considered nonexistent by the finalization process.
