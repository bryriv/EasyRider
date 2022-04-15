# EasyRider
Basic WoW addon to summon random mount

When I'm in a location that does not allow flying (the Maw, Korthia, etc), I want to use ground-only mounts.
This addon tries to help with that. It defaults to using Favorites as the source of mounts.

- When in a location that allows flying, it will choose from flying mounts.
- Calling the addon while flying will **not** do a dismount
- Calling the addon while mounted on the ground will dismount

## Usage
To summon mounts, simply create a Macro with default command:

`/easyrider`


## Additional console commands

- Enable all mounts as source for summons
 
  `/easyrider all`

- Enable only favorite mounts as source for summons

  `/easyrider favs`

- Shut up Easy Rider

  `/easyrider quiet`

- Let Easy Rider say stuff when mounting

  `/easyrider chatty`

- Check what source is being used, all or favs

  `/easyrider src`

