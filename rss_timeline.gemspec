Gem::Specification.new do |s|
  s.name = 'rss_timeline'
  s.version = '0.1.4'
  s.summary = 'An RSS aggregator which generates an RSS file'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rss_timeline.rb']
  s.add_runtime_dependency('simple-rss', '~> 1.3', '>=1.3.1')
  s.add_runtime_dependency('rss_creator', '~> 0.2', '>=0.2.3')
  s.signing_key = '../privatekeys/rss_timeline.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/rss_timeline'
end
