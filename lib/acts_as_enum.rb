# EnumAttr#  == Example
#
#    acts_as_enum(attr, options)
#    attr is model attribute
#    options incldue :in, :prefix
#    :in value as Array [ [value, label], ... ] or [ [special_method_name, value, label], ... ]
#    :prefix value as true or false
#
#    table column status type is Varchar or Varchar2
#    class User < ActiveRecord::Base
#      acts_as_enum :status, :in => [ ['disable', '冻结'], ['enable', '激活'] ]
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
    def acts_as_enum(attr, options = { :in => [], :prefix => false })
      attr = attr.to_s
      plural_upcase_attr = attr.pluralize.upcase
      enum = options[:in]

      rails "Can not load Rails." unless defined?(Rails)
      rails "Options :in can not be empty." if enum.blank?
      rails "Options :in must be an object of Array or Hash." unless enum.is_a?(Array) or enum.is_a?(Hash)

      if enum.is_a?(Hash)
        enum = enum.to_a
      elsif enum.is_a?(Array) and enum.first.is_a?(String)
        enum = enum.inject([]) { |arr, obj| arr << [obj] * 2 }
      end

      is_key_value_enum = enum.first.size == 2 ? true : false

      # validates_inclusion_of attr, :in => enum.collect { |arr| arr[1] }, :allow_blank => true

      attr_options = enum.inject({}) do |hash, arr|
        hash[is_key_value_enum ? arr.first : arr[1]] = arr.last.to_s
        hash
      end
      const_set(plural_upcase_attr, attr_options)

      enum.each do |arr|
        enum_name = arr.first.to_s.downcase
        attr_value = is_key_value_enum ? arr.first : arr[1]
        method_name = options[:prefix] ? "#{attr}_#{enum_name}" : enum_name

        const_set("#{method_name}".upcase, attr_value)

        if Rails.version =~ /^4/
          scope method_name.to_sym, -> { where(["#{self.table_name}.#{attr} = ?", attr_value]) }
        elsif Rails.version =~ /^3/
          scope method_name.to_sym, where(["#{self.table_name}.#{attr} = ?", attr_value])
        else
          named_scope method_name.to_sym, :conditions => { attr.to_sym => attr_value }
        end

        class_eval(%Q{
          def #{method_name}?
            # #{attr}.to_s == #{method_name.upcase}
            #{attr}.to_s == "#{attr_value}"
          end
        })
      end

      class_eval(%Q{
        def self.#{attr}_options
          #{plural_upcase_attr}.inject([]){ |arr, obj| arr << obj.reverse }
        end

        def #{attr}_name
          return #{plural_upcase_attr}[#{attr}] if #{attr}.is_a?(FalseClass)
          #{plural_upcase_attr}[#{attr}] unless #{attr}.blank?
        end
      })
    end

    alias enum_attr acts_as_enum
  end
end

ActiveRecord::Base.send(:include, ActsAsEnum)