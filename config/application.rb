    require File.expand_path('../boot', __FILE__)

    # Pick the frameworks you want:
    require "active_record/railtie"
    require "action_controller/railtie"
    require "action_mailer/railtie"
    require "sprockets/railtie"
    # require "rails/test_unit/railtie"

    # Assets should be precompiled for production (so we don't need the gems loaded then)
    Bundler.require(*Rails.groups(assets: %w(development test)))

    module SampleApp
      class Application < Rails::Application
        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        # config.time_zone = 'Central Time (US & Canada)'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de
        # I18n.enforce_available_locales = true
        I18n.enforce_available_locales = true

        config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
      end
    end

    module ObserveClassLoad
      OBSERVE_CLASS = Set.new(['StaticPagesController, UsersController'])

      class Railtie < ::Rails::Railtie
        config.after_initialize do
          indent = ''
          TracePoint.trace(:class) do |tp_class|
            load_class = tp_class.binding.eval('self.to_s')
            if OBSERVE_CLASS.include?(load_class)
              Rails.logger.info("#{indent}---- Loading: #{load_class}")
              indent << '  '
              TracePoint.trace(:end) do |tp_end|
                if load_class == tp_end.binding.eval('self.to_s')
                  indent.slice!(-2, 2)
                  Rails.logger.info("#{indent}---- Loaded:  #{load_class}")
                  tp_end.disable
                end
              end
            else
              Rails.logger.info("#{indent}#{load_class}")
            end
          end
        end
      end
    end
