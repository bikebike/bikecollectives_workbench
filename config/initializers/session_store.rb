# Be sure to restart your server when you modify this file.

if Rails.env == 'production' || Rails.env == 'preview'
  Rails.application.config.session_store :active_record_store, :domain => :all
else
  Rails.application.config.session_store :active_record_store
end
