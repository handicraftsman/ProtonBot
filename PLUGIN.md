# Plugin-development-tutorial

## Preparing environment
You have 2 ways of creating plugins:

### Gem. This way is recommended.
Create gem by doing `bundler gem <gemname>`. Ensure that this name is not taken on https://rubygems.org.

Create `lib/<gemname>/plugin.rb` file, where `gemname` - name of your gem with `-` replaced with `/`:

```ruby
# Your requires here...

ProtonBot::Plugin.new do
  @name = 'My first plugin'
  @version = MyAmazingGem::VERSION
  @description = 'Yay! First plugin!'

  # Adding permissions using permission API (described in core_plugin.md)
  core.permhash['admin'] << 'my_new_plugin'
  core.permhash['my_new_plugin'] = %w(
    my_sample_permission
  )

  # Hooking to `001` (WELCOME) code:
  hook(type: :code, code: @numeric::WELCOME) do |dat|
    # Do something...
  end

  # Hooking to command `ohaider`. This command cannot be run by users without
  # permission 'my_sample_permission'
  cmd(cmd: 'ohaider') do |dat|
    dat.reply "Ohaider! Your nickname: #{dat[:nick]}. " +
      "Your username: #{dat[:plug].getuser(dat[:nick])}. " +
      "Your hostname: #{dat[:plug].gethost(dat[:nick])}. "
  end.perm!('my_sample_permission')
end
```

Command arguments can always be accessed by `dat[:split]` array.

Now you just need to install your gem (`rake install`) and add it to bot by writing `gem 'gemname'` in `plugin_loader` statement

### Folder in plugins/ directory
Same as above, but instead of creating new gem, you are just creating folder `plugins/folder_name` and adding `plugin('folder_name')` to `plugin_loader` statement
