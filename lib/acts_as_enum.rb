# EnumAttr#  == Example
# 
#    acts_as_enum(attr, options)
#    attr is model attribute
#    options incldue :in, :prefix
# 
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ]
#    end
# 
#    Also can usage alias enum_attr
#    enum_attr :status, :in => [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ]
#    
#    Will generate bellow:
#    
#      Constants: User::STATUSES(return hash { 0 => "冻结", 1 => "激活" }), User::DISABLE, User::ENABLE
#      
#      Named scopes: User.enable, User.disable
# 
#      Class methods: User.status_options => [["冻结", 0], ["激活", 1]] 
# 
#      Instance methods: user.status_name, user.enable?, user.disable?
#      
#      
#    If with option prefix is true: 
#      acts_as_enum :status, :in => [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ], :prefix => true
#      
#    Will generate bellow:
#      User::STATUS_DISABLE, User::STATUS_ENABLE, User.status_enable, User.status_disable, user.status_enable?, user.status_disable?
    
module ActsAsEnum
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def acts_as_enum(attr, opts = { :in => [], :prefix => false })
      attr = attr.to_s
      plural_upcase_attr = attr.pluralize.upcase
      enum = opts[:in]
      
      rails "Can not load Rails" unless defined?(Rails)
      rails "Options in can not be empty" if enum.blank?
      rails "Options in must be an array object" unless enum.is_a?(Array)
      
      # validates_inclusion_of attr, :in => enum.collect { |arr| arr[1] }, :allow_blank => true

      const_set(plural_upcase_attr, enum.inject({}) { |hash, arr| hash[arr[1]] = arr[2].to_s; hash })
      
      enum.each do |arr|
        enum_name, attr_value = arr[0].to_s, arr[1]
        method_name = opts[:prefix] ? "#{attr}_#{enum_name}" : enum_name
        
        const_set("#{method_name}".upcase, attr_value)
        
        if Rails.version =~ /^2/
          named_scope method_name.to_sym, :conditions => { attr.to_sym => attr_value }
        else
          scope method_name.to_sym, where(["#{attr} = ?", attr_value])
        end
        
        class_eval(%Q{
          def #{method_name}?
            #{attr}.to_s == #{attr_value}.to_s
          end
        })
      end
        
      class_eval(%Q{
        def self.#{attr}_options
          #{plural_upcase_attr}.inject([]){ |arr, obj| arr << obj.reverse }
        end
        
        def #{attr}_name
          # #{plural_upcase_attr}.detect { |arr| arr[1] == #{attr} }[0] unless #{attr}.blank?
          #{plural_upcase_attr}[#{attr}] unless #{attr}.blank?
        end
      })
    end
    
    alias enum_attr acts_as_enum
  end
end

ActiveRecord::Base.send(:include, ActsAsEnum)