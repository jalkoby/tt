module TT
  module Helper
    extend ::ActiveSupport::Concern

    included do
      helper_method :tt

      prepend_before_filter { instance_variable_set(:@tt, ::TT::Rails.new(controller_path, action_name)) }
    end

    private

    def tt(*args)
      args.empty? ? @tt : @tt.t(*args)
    end
  end
end

options = {}
if defined?(ActiveRecord)
  options[:prefix] = :activerecord
elsif defined?(Mongoid)
  options[:prefix] = :mongoid
end
TT.base = TT::Rails = TT.fork(options)

ActiveSupport.on_load(:action_controller) do
  include ::TT::Helper
end

ActiveSupport.on_load(:action_mailer) do
  include ::TT::Helper
end
