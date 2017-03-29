Full-fledged config-hash looks like that:

```ruby
{
  # Global section. Basically sets default values for server-hashes
  'global': {
    'user' => 'ProtonBot',
    'nick' => 'YetAnotherBot',
    'rnam' => 'An IRC bot in Ruby' # `rnam` is shortened version of `realname`
  },
  # Define servers here
  'servers' => {
    'server1' => {}, # Will use default config
    'server2' => {
      'host' => 'irc.foo.bar.ru',
      'port' => 6697,
      'pass' => 'example_password',
      'encoding' => 'koi-8r',
      'cmdchar' => '%',
      'autojoin' => ['#protonbot'],
      'ssl' => true, # This is how you can use SSL
      'ssl_crt' => './server2.crt',
      'ssl_key' => './server2.key'
    }
  }
}
```

Server-Hashes are merged in next way: `default.merge(global).merge(server)`

Default server-hash:

```ruby
{
  'host' => '127.0.0.1',
  'port' => 6667,
  'user' => 'ProtonBot',
  'nick' => 'ProtonBot',
  'rnam' => 'An IRC bot in Ruby',
  'queue_delay' => 0.7,
  'cmdchar' => '\\',
  'encoding' => 'UTF-8',
  'autojoin' => []
}
```
