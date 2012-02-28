#
# getting relative links in rails mailers is not hard, although people love to
# make it out to be.  the basic concept is quite easy:
#
# 1) start with some reasonable defaults.  these will be used in testing and
# from the console.
#
# 2) dynamically configure these defaults on the first request seen.
#
# all we require to do this is a smart hash and simple before_filter.  save
# this file as 'config/intiializers/deafult_url_options.rb' and add this
# before filter to your application_controller.rb
#
# class ApplicationController < ActionController::Base
#
#   before_filter :configure_default_url_options!
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
# development will correctly point back to http://0.0.0.0:3000, etc.

unless defined?(DefaultUrlOptions)

  DefaultUrlOptions = defined?(HashWithIndifferentAccess) ? HashWithIndifferentAccess.new : Hash.new

  def DefaultUrlOptions.version
    '1.3.0'
  end

  def DefaultUrlOptions.configure(request = {})
    default_url_options = DefaultUrlOptions

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

  # force action_mailer to not lick balls
  #
    Rails.configuration.action_mailer.default_url_options = default_url_options
    ActionMailer::Base.default_url_options = default_url_options

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

    if host.to_s =~ /^www\./
      self[:host] = host.to_s.gsub(/^www\./, '')
    end

    keys.each{|key| delete(key) if self[key].nil?}

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

  def DefaultUrlOptions.to_yaml(*args, &block)
    Hash.new.update(self).to_yaml(*args, &block)
  end

end


if defined?(Rails)
## sane defaults
#
  DefaultUrlOptions.configure(
    :host => '0.0.0.0',
    :port => 3000
  )

##
#
  def DefaultUrlOptions.install_before_filter!
    if defined?(::ActionController::Base)
      ::ActionController::Base.module_eval do
        prepend_before_filter do |controller|
          unless controller.respond_to?(:configure_default_url_options!)
            unless DefaultUrlOptions.configured?
              request = controller.send(:request)
              DefaultUrlOptions.configure!(request)
            end
          end
        end
      end
    end
  end

##
#
  if defined?(Rails::Engine)
    class Engine < Rails::Engine
      config.before_initialize do
        ActiveSupport.on_load(:action_controller) do
          DefaultUrlOptions.install_before_filter!
        end
      end
    end
  else
    DefaultUrlOptions.install_before_filter!
  end
end

::Rails_default_url_options = ::DefaultUrlOptions

BEGIN {
  Object.send(:remove_const, :DefaultUrlOptions) if defined?(::DefaultUrlOptions)
  Object.send(:remove_const, :Rails_default_url_options) if defined?(::Rails_default_url_options)
}
