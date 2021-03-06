# EnumAttr#  == Example
#
#    acts_as_enum(attr, options)
#    attr is model attribute
#    options incldue :in, :prefix
#    :in value as Array [ [value, label], ... ] or [ [special_method_name, value, label], ... ]
#    :prefix value as true or false
# 
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => %w(disable, enable)
#    end
#
#    table column status type is Varchar or Varchar2
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => [ ['disable', '冻结'], ['enable', '激活'] ]
#    end
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => { 'disable' => '冻结', 'enable' => '激活' }
#    end
#
#    and type is Integer or number of string
#    NOTE: table column value must be match type, i.e. varchar: '1'; integer: 1
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => [ ['disable', 0, '冻结'], ['enable', 1, '激活'] ]
#    end
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => [ ['disable', '0', '冻结'], ['enable', '1', '激活'] ]
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
#      Instance methods: user.status_name, user.enable?, user.disable?, user.enable!(update user.status to 1) and user.disable!(update user.status to 1)
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
    def acts_as_enum(attr, options = { :in => [], :prefix => false })
      attr = attr.to_s
      plural_upcase_attr = attr.pluralize.upcase
      enum = options[:in]

      raise "Can not load Rails." unless defined?(Rails)
      raise "Options :in can not be empty." if enum.blank?
      raise "Options :in must be an object of Array or Hash." unless enum.is_a?(Array) or enum.is_a?(Hash)

      if enum.is_a?(Hash)
        enum = enum.to_a
      elsif enum.is_a?(Array) and enum.first.is_a?(String)
        enum = enum.inject([]) { |arr, obj| arr << [obj] * 2 }
      end

      attr_options = enum.each_with_object({}) do |arr, hash|
        if arr.count == 2
          hash[arr.last.to_s] = arr.last.to_s
        else
          hash[arr[-2]] = arr.last.to_s
        end
      end
      const_set(plural_upcase_attr, attr_options)

      enum.each do |arr|
        enum_name = arr.first.to_s.downcase
        attr_value = arr[-2]
        method_name = options[:prefix] ? "#{attr}_#{enum_name}" : enum_name

        const_set(method_name.upcase, attr_value)

        if Rails.version.to_i > 2
          scope method_name.to_sym, -> { where(attr => attr_value) }
        else
          named_scope method_name.to_sym, :conditions => { attr.to_sym => attr_value }
        end

        class_eval do
          define_method "#{method_name}?" do
            public_send(attr) == attr_value
          end

          define_method "#{method_name}!" do
            update_attribute(attr, attr_value) # use update_attribute method to skip validations
          end
        end
      end

      class_eval(%Q{
        def self.#{attr}_options
          #{plural_upcase_attr}.inject([]){ |arr, obj| arr << obj.reverse }
        end

        def self.#{attr}_options_i18n
          #{plural_upcase_attr}.inject([]) do |arr, obj|
            #{enum}.each do |a|
              obj[1] = ::ActsAsEnum::ClassMethods.translate_enum_symbol("#{self}", "#{attr}", a[0]) if a[1] == obj[0]
            end
            arr << obj.reverse
          end
        end

        def #{attr}_name
          return #{plural_upcase_attr}[#{attr}] if #{attr}.is_a?(FalseClass)
          #{plural_upcase_attr}[#{attr}] unless #{attr}.blank?
        end

        def #{attr}_name_i18n
          #{plural_upcase_attr}.each do |k, v|
            #{enum}.each do |a|
              #{plural_upcase_attr}[k] = ::ActsAsEnum::ClassMethods.translate_enum_symbol("#{self}", "#{attr}", a[0]) if a[1] == k
            end
          end
          return #{plural_upcase_attr}[#{attr}] if #{attr}.is_a?(FalseClass)
          #{plural_upcase_attr}[#{attr}] unless #{attr}.blank?
        end
      })
    end

    def self.translate_enum_symbol(klass, attr_name, enum_symbol)
      ::I18n.t("activerecord.attributes.#{klass.to_s.underscore.gsub('/', '.')}.#{attr_name.to_s.pluralize}.#{enum_symbol}", default: enum_symbol.humanize)
    end

    alias enum_attr acts_as_enum
  end
end

ActiveRecord::Base.send(:include, ActsAsEnum)
