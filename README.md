minetest-australopithecus-auto-drops
====================================

A system which drops all drops from a dug node as items.


Usage
=====

The system activates itself, you just need to add the mod to the subgame.


Configuration
=============

The system can be configured by adding settings to the `minetest.conf`:

    # If the system should be activated, defaults to true.
    autodrops_activate = true.
    
    # If the stacks that are split in some way, defaults to single.
    # Possible values are:
    #  random: The dropped stacks are split randomly.
    #  single: The dropped stacks are split into every single item.
    #  stack: The dropped stacks are dropped as they are.
    autodrops_split = single
    
    # The maximum velocity of newly dropped items, defaults to "2, 4, 2".
    autodrops_velocity = 2, 4, 2

