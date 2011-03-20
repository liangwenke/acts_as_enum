# EnumAttr#  == Example
#
#    class User < ActiveRecord::Base
#      enum_attr :status, [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ]
#    end
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
#      enum_attr :status, [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ], :prefix => true
#      
#    Will generate bellow:
#      User::STATUS_DISABLE, User::STATUS_ENABLE, User.status_enable, User.status_disable, user.status_enable?, user.status_disable?
    
module EnumAttr
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def enum_attr(attr, enums, options = { :prefix => false })
      attr = attr.to_s
      plural_upcase_attr = attr.pluralize.upcase
      
      validates_inclusion_of attr, :in => enums.collect { |enum| enum[1] }, :allow_blank => true
      
      # This code will return a Array object [["冻结", 0], ["激活", 1]]
      # const_set(plural_upcase_attr, enums.collect { |enum| [enum[2].to_s, enum[1]] })
      # This code will return a Hash object { 0 => "冻结", 1 => "激活" }
      const_set(plural_upcase_attr, enums.inject({}) { |hash, enum| hash[enum[1]] = enum[2].to_s; hash })
      
      enums.each do |enum|
        enum_name, attr_value = enum[0].to_s, enum[1]
        method_name = options[:prefix] ? "#{attr}_#{enum_name}" : enum_name
        
        const_set("#{method_name}".upcase, attr_value)
        
        named_scope method_name.to_sym, :conditions => { attr.to_sym => attr_value }
        
        class_eval(%Q{
          def #{method_name}?
            #{attr} == #{attr_value}
          end
        })
      end
        
      class_eval(%Q{
        def self.#{attr}_options
          #{plural_upcase_attr}.inject([]){ |arr, obj| arr << obj.reverse }
        end
        
        def #{attr}_name
          # #{plural_upcase_attr}.detect { |enum| enum[1] == #{attr} }[0] unless #{attr}.blank?
          #{plural_upcase_attr}[#{attr}] unless #{attr}.blank?
        end
      })
    end
  end
  
end

ActiveRecord::Base.send(:include, EnumAttr)
