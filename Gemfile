source 'https://rubygems.org'

gemspec

if (ARGV.each {|str| str.gsub!(/^:source$/, 'source') } & (excep = ["--without", "source"]) != excep)
  group :source do
    if File.exists?("../vigilem-support")
      gem "vigilem-support", :path => "../vigilem-support"
    else
      gem "vigilem-support", :git => "https://github.com/jtzero/vigilem-support.git"
    end
  end
end
