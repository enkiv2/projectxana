# Introduction #

EPL (the Enfilade Processing Language) is a programming language built into the structure of XANA's ENFS (ENfiladal File System). It is an assembly-like bytecode utilizing little-used ASCII characters, with an innovative, link-oriented format. It is written directly using the Z2 interface, without the use of a compiler or assembler.


# Details #

Every instruction takes a maximum of two arguments: **destination** and **source**. The destination is the first transclusion, and the source is the first transpointer. Other transclusions and transpointers are ignored.

The instructions are as follows:

|Opcode|Graphic|Mnemonic|Key combination|Args #|Description|
|:-----|:------|:-------|:--------------|:-----|:----------|
|3D    |=      |MOV     |=              |2     |Assigns the value of source to destination|
|2B    |+      |ADD     |+              |2     |Adds the value of source to destination|
|2D    |-      |SUB     |-              |2     |Subtracts the value of source from destination|
|2A    |`*`      |MUL     |`*`              |2     |Multiplies the value of source with destination|
|2F    |/      |DIV     |/              |2     |Divides the value of source by destination|
|1A    | |OUT     |CTRL-Z         |2     |Outputs the value in source to the port in destination|
|1B    | |IN      |CTRL-[         |2     |Reads from the port in source and stores in destination|
|0F    | |INT     |CTRL-O         |2     |Runs the library routine located in destination, passing the parameter structure found in source|
|10    | |CHUG    |CTRL-P         |1     |Iterate through the linked list stored in source|

Note that in most instructions that actually return data (such as arithmetic and assignment instructions), the data is stored in destination. Chug normally simply iterates through the first transpointer in each, doing nothing. The key is to link the chug opcode to the linked list with the threespan of the code that you wish to run (as the body of the loop).

