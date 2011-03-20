# encoding: utf-8

version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name = 'acts_as_enum'
  s.version = version
  s.author = "LiangWenKe"
  s.email = "liangwenke8@gmail.com"
  s.homepage = "http://github.com/wenke/acts_as_enum"
  s.summary = 'Enum Attribute for Rails ActiveRecord'
  s.description = '主要应用于有枚举类型属性的Model，这个插件会帮我们生成一些常用到的方法。'
  
  s.files        = Dir["{lib,test}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
