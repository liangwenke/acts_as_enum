# EnumAttr#  == Example
#
#    class User < ActiveRecord::Base
#      enum_attr :status, [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ]
#    end
#    
#    Will generate bellow:
#    
#      Constants: User::ENUMS_STATUS, User::DISABLE, User::ENABLE
#      
#      Named scope: User.enable, User.disable
#      
#      Instance method: user.status_name, user.enable?, user.disable?
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
      
      validates_inclusion_of attr, :in => enums.collect { |enum| enum[1] }, :allow_blank => true
      
      const_set("enums_#{attr}".upcase, enums.collect { |enum| [enum[2].to_s, enum[1]] })
      
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
        def #{attr}_name
          ENUMS_#{attr.upcase}.detect { |enum| enum[1] == #{attr} }[0] unless #{attr}.blank?
        end
      })
    end
  end
  
end

ActiveRecord::Base.send(:include, EnumAttr)
