# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copiedbook/version'

Gem::Specification.new do |gem|
  gem.name          = "copiedbook"
  gem.version       = Copiedbook::VERSION
  gem.authors       = ["Markus Kuhnt", "Ignacio Huerta"]
  gem.email         = ["info@tridoco.com"]
  gem.description   = %q{Take a offline copy of a facebook fan page.}
  gem.summary       = %q{Take a offline copy of a facebook fan page.}
  gem.homepage      = "http://www.tridoco.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
