# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{solr_mapper}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Umbel"]
  s.date = %q{2010-10-29}
  s.description = %q{Object Document Mapper for the Apache Foundation's Solr search platform}
  s.email = %q{chrisu@dvdempire.com}
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc", "lib/solr_mapper.rb", "lib/solr_mapper/calculations.rb", "lib/solr_mapper/locators.rb", "lib/solr_mapper/relations.rb", "lib/solr_mapper/solr_document.rb"]
  s.files = ["LICENSE.txt", "README.rdoc", "Rakefile", "lib/solr_mapper.rb", "lib/solr_mapper/calculations.rb", "lib/solr_mapper/locators.rb", "lib/solr_mapper/relations.rb", "lib/solr_mapper/solr_document.rb", "solr_mapper.gemspec", "spec/base.rb", "spec/calculations_spec.rb", "spec/facets_spec.rb", "spec/locators_spec.rb", "spec/misc_spec.rb", "spec/paginated_spec.rb", "spec/query_spec.rb", "spec/relation_spec.rb", "spec/solr/stuff/config/schema.xml", "spec/solr/thing/config/schema.xml", "spec/solr/widget/conf/schema.xml", "spec/url_spec.rb", "Manifest"]
  s.homepage = %q{http://github.com/skunkworx/solr_mapper}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Solr_mapper", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{solr_mapper}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Object Document Mapper for the Apache Foundation's Solr search platform}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<uuid>, [">= 0"])
      s.add_runtime_dependency(%q<will_paginate>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<uuid>, [">= 0"])
      s.add_dependency(%q<will_paginate>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<uuid>, [">= 0"])
    s.add_dependency(%q<will_paginate>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end
