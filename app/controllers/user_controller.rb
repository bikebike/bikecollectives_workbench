class UserController < ApplicationController

  def update_user_settings
    return do_403 unless logged_in?
    current_user.firstname = params[:name]
    current_user.lastname = nil
    current_user.languages = (params[:languages] || { I18n.locale.to_s => true }).keys
    current_user.is_subscribed = params[:email_subscribe].present?
    current_user.save
    redirect_to settings_path(trailing_slash: true)
  end

  def do_confirm
    confirm_email(
        params[:email],
        params[:token],
        params[:dest] || (
          request.present? && request.referer.present? ?
            request.referer.gsub(/^.*?\/\/.*?\//, '/') :
            settings_path(trailing_slash: true)))
  end

  def user_logout
    logout()
    redirect_to (params[:url] || '/')
  end

  def login_user(u)
    auto_login(u)
  end

  def user_settings
    @conferences = Array.new
    if logged_in?
      Conference.all.each do |conference|
        @conferences << conference if conference.host? current_user
      end
    end
    @main_title = @page_title = 'page_titles.user_settings.Your_Account'
  end

  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    set_callback
    session[:oauth_last_url] = params[:dest] || request.referer
    login_at(auth_params[:provider])
  end

  def callback
    if Rails.env.test? && params[:fb_id].present?
      user_info = {
        'name'  => params[:name],
        'email' => params[:email],
        'id'    => params[:fb_id]
      }
    else
      set_callback
      user_info = (sorcery_fetch_user_hash auth_params[:provider] || {})[:user_info]
    end

    email = user_info['email']
    fb_id = user_info['id']

    # try to find the user by facebook id
    user = User.find_by_fb_id(fb_id)

    # otherwise find the user by email
    unless user.present?
      # only look if the email address is present
      user = User.find_user(email) if email.present?
    end

    # create the user if the email is not recognized
    if user.nil?
      if email.present?
        user = User.create(email: email, firstname: user_info['name'], fb_id: fb_id, locale: I18n.locale)
      else
        session[:oauth_update_user_info] = user_info
        return redirect_to oauth_update_path(trailing_slash: true)
      end
    elsif user.fb_id.blank? || user.email.blank?
      user.email = email
      user.fb_id = fb_id
      user.save!
    end
    
    if user.present? && user.email.present?
      # log in the user
      auto_login(user)
    end
    
    oauth_last_url = (session[:oauth_last_url] || home_path(trailing_slash: true))
    session.delete(:oauth_last_url)
    redirect_to oauth_last_url
  end

  def update
    @main_title = @page_title = 'articles.conference_registration.headings.email_confirm'
    @errors = { email: flash[:error] } if flash[:error].present?
    render 'application/update_user'
  end
  
  def save
    unless params[:email].present?
      return redirect_to oauth_update_path(trailing_slash: true)
    end
    
    user = User.find_user(params[:email])

    if user.present?
      flash[:error] = :exists
      return redirect_to oauth_update_path(trailing_slash: true)
    end
    
    # create the user
    user = User.new(email: params[:email], firstname: session[:oauth_update_user_info]['name'], fb_id: session[:oauth_update_user_info]['id'])
    user.save!

    # log in
    auto_login(user)

    # clear out the session
    oauth_last_url = (session[:oauth_last_url] || home_path(trailing_slash: true))
    session.delete(:oauth_last_url)
    session.delete(:oauth_update_user_info)

    # go to our final destination
    redirect_to oauth_last_url
  end

  private
  def auth_params
    params.permit(:code, :provider)
  end

  def set_callback
    # force https for prod
    protocol = Rails.env.preview? || Rails.env.production? ? 'https://' : (request.protocol || 'http://')

    # build the callback url
    Sorcery::Controller::Config.send(params[:provider]).callback_url =
        "#{protocol}#{request.env['HTTP_HOST']}/oauth/callback/?provider=facebook"
  end

end