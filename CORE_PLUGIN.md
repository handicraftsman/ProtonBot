# Core Plugin
Core plugin implements features which are essential for bot to exist: hooks (including ping-response), command engine, permission system, help system etc.

Core plugin can be accessed by using `core` (or `@core`) attr-reader.

## APIs
Here you can find documentation for core-plugin's APIs. Use them in your plugins.

### Permissions
Core plugin implements permission system - it allows checking user's permissions, editing them, preventing users from running stuff without permission.

Permissions are stored and checked by hostname - so ensure that target user has stable hostmask (static IP address or freenode-like host cloak)

Checking permissions is done by using `ProtonBot::Hook#perm!(*perms_to_check)` after defining hook. For example:

```ruby
cmd(cmd: 'sample_command') do |dat| # Defining hook. This time - command.
  # Do something...
end.perm!('perm1') # Applying #perm! method which adds permission 
                   # checks before running hook.

# You can also request more than one permission by simply passing more arguments

cmd(cmd: 'whatever_command') do |dat|
  dat.reply 'Foo!'
end.perm!('foo', 'bar') # This command requires both `foo` and `bar` permissions

```

There's no need to define new permissions, but you may want to have own permission group where you'll find all your permissions. These act like normal permissions, but they are expanded into their members while checking permissions

```ruby
# Create permission group 'my_plugin' which will give all perms mentioned above
core.permhash['my_plugin'] = %w(perm1 foo bar)
# Add our permission group to 'admin' group so every admin will have access to these permissions
core.permhash['admin'] << 'my_plugin'
```

Default permission hash:

```ruby
{
  'owner' => %w(
    reload
    eval
    exec
    raw
    cross
    admin
    perms
  ),
  'admin' => %w(
    joinpart
    nick
    msg
    ctcp
    notice
    nctcp
    flushq
  ),
  'cross' => %w(
    crossuser
    crosschan
    crossplug
  )
}
```

### Help
Core plugin implements help system. To add help for new command, just use `core.help_add(group_name, command_name, syntax, description)`:

```ruby
core.help_add('group_name', 'hello', 'hello [nickname]', 'Say hello!')

# How arguments are marked:
# <required> 
# [optional]
# {0 or more}
# (1 or more)
```

## Commands
This is list of available commands. Use help engine for more info.

### Basic commands
1. `ping`
2. `echo {message}`

### Admin commands
1. `key [key]`
2. `nick <nick>`
3. `msg [target] <message>`
4. `notice [target] <message>`
5. `ctcp [target] <message>`
6. `nctcp [target] <message>`
7. `flushq`
8. `join (chans|sep=,) [pass]`
9. `part (chans|sep=,) [reason]`

### Owner commands
1. `rb {code}`
2. `eval {command}`
3. `raw {message}`
4. `r`

### Permission-management commands
1. `perms {groups}`
2. `uperms <+|-|?> <user> {perms}`

### Cross commands
1. `as`
2. `at`
3. `on`

### Help commands
1. `help {commands}`
2. `list {groups}` 

## Emitted events (except for `raw`, which is emitted by plug)
1. `privmsg` (parameters - `nick`, `user`, `host`, `target`, `reply_to`, `message`)`
2. `notice` (same as with `privmsg`, but without `reply_to`)
3. `ctcp` and `nctcp` (have `split` and `cmd` so you can parse them)
4. `command` (inherited from PRIVMSG; parameters - `split` (array), `cmd`)
5. `ukick`, `unick`, `upart`, `ujoin`, `uquit`
6. `utopic` (unused)
7. `ping`
