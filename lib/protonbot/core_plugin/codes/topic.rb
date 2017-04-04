hook(type: :code, code: @numeric::TOPIC) do |dat|
  m = /(.+?) :(.+)/.match(dat[:extra])
  unless dat[:plug].chans[m[1]]
    dat[:plug].chans[m[1]] = {}
  end
  dat[:plug].chans[m[1]][:topic] = m[2]
end