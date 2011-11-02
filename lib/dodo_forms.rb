
module ActionView
  module Helpers

    module FormOptionsHelper
      def account_select_field(object, method, options = {}, html_options = {})
        return select(object, method, (options[:company] ||  @me.current_company).accounts.map{|it| [it.name, it.id]}, options, html_options)
      end
    end

    class FormBuilder 
      def account_select_field(method, options = {}, html_options = {})
        @template.account_select_field(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end
    end
  end
end
