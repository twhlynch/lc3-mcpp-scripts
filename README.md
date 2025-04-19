# LC3 MCPP Scripts
Scripts I wrote using LC3 with mcpp for.. fun?

**Requires**
- [mcpp](https://github.com/rozukke/mcpp)
- [lc3-vm-mcpp](https://github.com/rozukke/lc3-vm-mcpp)
- [laser-mcpp](https://github.com/rozukke/laser-mcpp)
- [MC 1.19.4 server](https://github.com/rozukke/minecraft_tools)

**Compile**
```
laser -a file.asm
```

**Run**
- run server
- join server in Minecraft
```
lc3 file.obj
```

## chat_coords
outputs the players coordinates to the chat by manually creating a character array from each digit

## sphere
creates a sphere by looping over a cube and placing blocks when less than the radius distance from the center

## scan_blocks
scans a 10x10 area under the player and prints out the block ids

## grid
generate a grid of every block id 0 - 252

## stairs
builds stairs by, looping moving up or across based on whether i is odd or even

## fibonacci
place blocks in the fibonacci sequence

## cube
builds a cube
