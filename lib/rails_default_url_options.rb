#
# getting relative links in rails mailers is not hard, although people love to
# make it out to be.  the basic concept is quite easy:
#
# 1) start with some reasonable defaults.  these will be used in testing and
# from the console.
#
# 2) dynamically configure these defaults on the first request seen.
#
# all we require to do this is a smart hash and simple before_action.  save
# this file as 'config/intiializers/deafult_url_options.rb' and add this
# before filter to your application_controller.rb
#
# class ApplicationController < ActionController::Base
#
#   before_action :configure_default_url_options!
#
#   protected
#     def configure_default_url_options!
#       DefaultUrlOptions.configure!(request)
#     end
# end
#
# with this approach you will always generate absolute links for mailers and,
# when those emails are triggered from an http request they will be sent
# pointing back to that server.  note that this also means emails sent in
# development will correctly point back to http://127.0.0.1:3000, etc.

unless defined?(DefaultUrlOptions)

  DefaultUrlOptions = Hash.new

  def DefaultUrlOptions.version
    '6.0.1'
  end

  def DefaultUrlOptions.dependencies
    {}
  end


  def DefaultUrlOptions.configure(request = {}, &block)
    default_url_options = DefaultUrlOptions

    default_url_options.clear

    if request.is_a?(Hash)
      protocol = request[:protocol] || request['protocol']
      host = request[:host] || request['host']
      port = request[:port] || request['port']
    else
      protocol = request.protocol
      host = request.host
      port = request.port
    end

    default_url_options[:protocol] = protocol
    default_url_options[:host] = host
    default_url_options[:port] = port

    normalize!

  # force action_mailer to not suck so bad 
  #
    Rails.configuration.action_mailer.default_url_options = default_url_options

    if ActionMailer::Base.respond_to?('default_url_options=')
      ActionMailer::Base.default_url_options = default_url_options
    end

    default_url_options
  end

  def DefaultUrlOptions.configure!(request = {})
    configure(request) unless configured?
  ensure
    configured!
  end

  def DefaultUrlOptions.configured!
    @configured = true
  end

  def DefaultUrlOptions.configured?
    defined?(@configured) and @configured
  end

  def configured
    @configured
  end

  def configured=(configured)
    @configured = !!configured
  end

  def DefaultUrlOptions.normalize!(&block)
    if block
      @normalize = block
      return
    end

    if @normalize
      return instance_eval(&@normalize)
    end

    case protocol.to_s
      when /https/i
        delete(:port) if port.to_s == '443'

      when /http/i
        delete(:port) if port.to_s == '80'
    end

    keys.each do |key|
      if self[key].nil?
        delete(key)
        next
      end

      if key.is_a?(Symbol)
        next
      end

      self[key.to_s.to_sym] = self.delete(key)
    end

    self
  end

  def DefaultUrlOptions.protocol
    DefaultUrlOptions[:protocol]
  end

  def DefaultUrlOptions.host
    DefaultUrlOptions[:host]
  end

  def DefaultUrlOptions.port
    DefaultUrlOptions[:port]
  end

  def DefaultUrlOptions.domain
    case host
      when '0.0.0.0', '127.0.0.1'
        'localhost'
      when /\A[\d.]+\Z/iomx
        host
      else
        host.split('.').last(2).join('.')
    end
  end

  def DefaultUrlOptions.to_yaml(*args, &block)
    Hash.new.update(self).to_yaml(*args, &block)
  end

  def DefaultUrlOptions.callbacks
    @callbacks ||= []
  end
end


if defined?(Rails)
  def DefaultUrlOptions.autoconfigure!(&block)
    unless DefaultUrlOptions.configured?
      DefaultUrlOptions.configure(
        :host => 'localhost',
        :port => 3000
      )
    end

    if block
      DefaultUrlOptions.callbacks.push(block)
    end

    DefaultUrlOptions.install_before_action!
  end

  def DefaultUrlOptions.autoconfigure(&block)
    DefaultUrlOptions.autoconfigure!(&block)
  end

  def DefaultUrlOptions.install_before_action!
    if defined?(::ActionController::Base)
      ::ActionController::Base.module_eval do
        def configure_default_url_options!
          unless DefaultUrlOptions.configured?
            if Rails.env.production?
              DefaultUrlOptions.configure!(request)
            else
              DefaultUrlOptions.configure(request)
            end

            DefaultUrlOptions.callbacks.each do |block|
              block.call
            end

            DefaultUrlOptions.callbacks.clear
          end
        end

        prepend_before_action = respond_to?(:prepend_before_filter) ? :prepend_before_filter : :prepend_before_action

        send(prepend_before_action, :configure_default_url_options!)
      end
    end
  end

=begin
#
  if defined?(Rails::Engine)
    class Engine < Rails::Engine
      config.before_initialize do
        ActiveSupport.on_load(:action_controller) do
          DefaultUrlOptions.install_before_action!
        end
      end
    end
  else
    DefaultUrlOptions.install_before_action!
  end
=end

end

::Rails_default_url_options = ::DefaultUrlOptions

BEGIN {
  Object.send(:remove_const, :DefaultUrlOptions) if defined?(::DefaultUrlOptions)
  Object.send(:remove_const, :Rails_default_url_options) if defined?(::Rails_default_url_options)
}
