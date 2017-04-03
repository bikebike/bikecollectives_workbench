class ApplicationsController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    @applications = Application.all
  end

  def view
    @help = :application
    @locales = {}
    @enabled_locales.each do |locale|
      stats = LinguaFranca.locale_stats(@application.slug, @application.path, locale)
      @locales[locale] = {
        completion: stats[:complete] / stats[:total].to_f
      }
    end
  end

  def edit
  end

  def new
    @application = Application.new
    render 'edit'
  end

  def save
    @application = if params[:id].present?
                     Application.find(params[:id].to_i)
                   else
                     Application.new
                   end

    @application.name = params[:name]
    @application.slug = params[:slug]
    @application.path = params[:path]
    @application.url = params[:url]
    @application.description = params[:description]

    @application.save

    redirect_to home_path
  end

end