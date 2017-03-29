hook(type: :ping) do |dat|
  dat[:plug].write_("PONG :#{dat[:server]}")
end
