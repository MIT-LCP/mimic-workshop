
# Important notes

* If we use LIBSVM, we should provide pre-compiled binaries for all the operating systems
    * Linux - This was easy for me on Ubuntu, but I had to change the path in the Makefile and run it from command line (running make.m did *not* work, it compiled but didn't link the library correctly)
    * Mac OSX - The lab laptop doesn't have a compiler, need to sort that out..
    * Windows - It comes with pre-compiled binaries
* Need to add `libsvm/matlab` to the path
