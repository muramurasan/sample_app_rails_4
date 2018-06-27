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
      OBSERVE_METHODS = {
        'UsersHelper' => ['#gravatar_for'],
        'SessionsController' => ['#new'],
        'SessionsHelper' => ['#signed_in?']
      }

      class Railtie < ::Rails::Railtie
        config.before_initialize do
          okuribito = Okuribito::Request.new do |method_name, _obj_name, _caller_info, class_name, symbol, _args|
            Rails.logger.info("#### Called ------ #{class_name}#{symbol}#{method_name}")
          end

          TracePoint.trace(:end) do |tp|
            load_class = tp.binding.eval('self.to_s')
            if OBSERVE_METHODS.has_key?(load_class)
              OBSERVE_METHODS[load_class].each do |method|
                okuribito.apply_one(load_class + method)
                Rails.logger.info("#### Observe start ------ #{load_class}#{method}")
              end
            end
          end
        end
      end
    end
