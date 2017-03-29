hook(type: :code, code: @numeric::WELCOME) do |dat|
  if dat[:plug].conf['autojoin']
    dat[:plug].conf['autojoin'].map do |e|
      dat[:plug].join(e.to_s)
    end
  end
end
