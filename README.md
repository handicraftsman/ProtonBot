# Protonbot


## Making basic bot

This small guide covers making working bot with YAML config

Create Gemfile with next content:

```ruby
ruby '2.4.0'
source 'https://rubygems.org'
gem 'protonbot'
# gem 'protonbot-chanop' # If you want channel-operator commands
```

Execute `bundler install`

Create `main.rb` with next content:

```ruby
#!/usr/bin/env ruby

require 'protonbot'
require 'yaml'

ProtonBot::Bot.new do
  configure do
    gset YAML.load_file(File.expand_path('./conf.yml'))
  end

  plugin_loader do
    # gem 'protonbot-chanop' # If you want channel-operator commands
  end
end
```

Create `conf.yml` with content like next: (just remove first 3 lines and omit `port` to disable SSL connection)

```yaml
servers:
  servername:
    ssl: true
    ssl_crt: ./example.crt
    ssl_key: ./example.key
    host: irc.example.net
    port: 6697
    autojoin:
      - "#channel"
```

If you need an SSL certificate, just run `protonbot-gencert <name>`. You need OpenSSL executable for that.

Start bot by doing `bundler exec ./main.rb`

## Usage

After you have started your bot, you need to gain permissions.

1. Ensure that your hostname is not dynamic. If you have no static IP for that,
  get a host cloak on your NickServ account.
2. Send `\key` command to your bot (where `\` - your command char).
3. Check your terminal to find key there.
4. Send `\key <key>` to your bot, where `<key>` - generated key.
5. Now you have owner permissions. To receive help, send `\help` to your bot.

## Development

After checking out the repo, run `bundler` to install dependencies. `bottest` directory is .gitignored, so you can make test bot there.

To install this gem onto your local machine, run `bundler exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundler exec rake release\[origin\]`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/handicraftsman/protonbot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

