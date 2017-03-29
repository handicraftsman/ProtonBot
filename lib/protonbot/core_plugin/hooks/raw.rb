hook(type: :raw) do |dat|
  if    m = /^PING :(.+)/.match(dat[:raw_data])
    emit(dat.merge(type: :ping, server: m[1]))
  elsif m = /^:.+ (\d\d\d) .+? (.+)/.match(dat[:raw_data])
    emit(dat.merge(type: :code, code: m[1], extra: m[2]))
  elsif m = /^:(.+?)!(.+?)@(.+?) PRIVMSG (.+?) :(.+)/.match(dat[:raw_data])
    rto =
      if %w(! # & +).include? m[4][0]
        m[4]
      else
        m[1]
      end
    emitt(dat.merge(type: :privmsg, nick: m[1], user: m[2], host: m[3],
                    target: m[4], message: m[5], reply_to: rto))
  elsif m = /^:(.+?)!(.+?)@(.+?) NOTICE (.+?) :(.+)/.match(dat[:raw_data])
    emitt(dat.merge(type: :notice, nick: m[1], user: m[2], host: m[3],
                    target: m[4], message: m[5]))
  elsif m = /^:(.+?)!(.+?)@(.+?) TOPIC (.+?) :(.+)/.match(dat[:raw_data]) # NYI
    emit(dat.merge(type: :utopic, nick: m[1], user: m[2], host: m[3],
                   channel: m[4], topic: m[5]))
  elsif m = /^:(.+?)!(.+?)@(.+?) JOIN :(.+)/.match(dat[:raw_data])
    emit(dat.merge(type: :ujoin, nick: m[1], user: m[2], host: m[3], channel: m[4]))
  elsif m = /^:(.+?)!(.+?)@(.+?) PART (.+) :(.*)/.match(dat[:raw_data])
    emit(dat.merge(type: :upart, nick: m[1], user: m[2], host: m[3], channel: m[4], message: m[5]))
  elsif m = /^:(.+?)!(.+?)@(.+?) QUIT :.*/.match(dat[:raw_data])
    emit(dat.merge(type: :uquit, nick: m[1], user: m[2], host: m[3]))
  elsif m = /^:(.+?)!(.+?)@(.+?) NICK :(.+)/.match(dat[:raw_data])
    emit(dat.merge(type: :unick, nick: m[1], user: m[2], host: m[3], to: m[4]))
  elsif m = /^:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) :.*/.match(dat[:raw_data])
    emit(dat.merge(type: :ukick, nick: m[1], user: m[2], host: m[3], channel: m[4], target: m[5]))
  end
end
