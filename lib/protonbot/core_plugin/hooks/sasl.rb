hook(type: :cap_ack, cap_sasl: true) do |dat|
  dat[:plug].write_ 'AUTHENTICATE PLAIN'
end

hook(type: :auth_ok) do |dat|
  conf = dat[:plug].conf
  hash = Base64.strict_encode64(conf['sasl_user'] + "\0" + 
    conf['sasl_user'] + "\0" +
    conf['pass'])
  dat[:plug].write_("AUTHENTICATE #{hash}")
end

hook(type: :code, code: '903') do |dat|
  dat[:plug].write_('CAP END')
end