require 'mime/types'

class ApplicationController < BaseController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def default_url_options
    { host: "#{request.protocol}#{request.host_with_port}" }
  end

  before_filter :load_app

  def home
    @applications = Application.all
  end

  def confirmation_sent(user)
    do_403 'login_confirmation_sent'
  end

  def access_request
    current_user.workbench_access_request_date = DateTime.now
    current_user.workbench_access_request_message = params[:message]
    current_user.save!
    UserMailer.access_request(current_user).deliver_now!
    redirect_to :home
  end

  def help
    @page = params[:page]
    @pages = [:application,
              :application_group,
              :page,
              :page_preview,
              :translations,
              :users,
              :edit_user] unless @page
  end

private

  def send_confirmation(confirmation)
    UserMailer.email_confirmation(confirmation.id).deliver_now!
  end

  def load_app
    unless logged_in? && current_user.has_workbench_access
      case "#{params[:controller]}##{params[:action]}"
      when 'application#home'
        do_403 if logged_in?
      when 'application#access_request', 'user#do_confirm', 'user#confirm', 'user#oauth', 'user#callback'
        # this is a public page
      else
        do_403
      end
    end

    ActionMailer::Base.default_url_options[:host] = "#{request.protocol}#{request.host_with_port}"

    @pages = {}

    if params[:app].present?
      @application = Application.find_by_slug(params[:app].to_sym)

      if @application.present?
        LinguaFranca.get_translation_info(@application.path).each do |key, pages|
          pages.keys.sort.each do |page|
            controller, action = page.split(/[\/\\]/)
            @pages[controller] ||= []
            @pages[controller] |= [action]
          end
        end
      end

      @enabled_locales = LinguaFranca.enabled_locales(@application.slug, @application.path)
    end

    @locale = params[:locale].to_sym if params[:locale].present?
    @group = params[:group].to_sym if params[:group].present? && params[:group] != '-'
    @page = params[:page].to_sym if params[:page].present? && params[:page] != '-'
    @languages = YAML.load_file(I18n.config.languages_file)['en']['languages']
  end


  def add_scripts(*scripts)
    @javascripts ||= Set.new
    @javascripts += scripts
  end

  def javascripts
    return '' unless @javascripts

    html = ''
    @javascripts.each do |js|
      html += view_context.javascript_include_tag js
    end

    html.html_safe
  end

  def time(datetime)
    add_scripts(:comments, 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js')
    "<time datetime=\"#{datetime}\">on #{datetime}</time>".html_safe
  end

  helper_method :javascripts, :time

end
