%w{SECRET_KEY_BASE}.each do |var|
  if ENV[var].blank?
    $stderr.puts "Please set #{var} in your environment."
    exit 1
  end
end
