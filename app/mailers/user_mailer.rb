require 'redcarpet'

class UserMailer < ActionMailer::Base
  before_filter :set_host

  default from: "Bike Collectives Workbench <godwin@bikebike.org>"

  def email_confirmation(confirmation)
    @confirmation = EmailConfirmation.find(confirmation) if confirmation.present?
    @subject = 'Please confirm your email address'
    mail to: @confirmation.user.named_email, subject: @subject
  end

  def access_request(user)
    administrators = User.where(role: :administrator).map { |u| u.named_email }
    @message = markdown(user.workbench_access_request_message)
    @subject = 'Request to access Bikecollectives Workbench'
    mail to: administrators, subject: @subject, reply_to: user.named_email
  end

  def translation_changed(user, language, key, old_value, new_value)
    @user = user
    @language = language
    @key = key
    @old_value = old_value
    @new_value = new_value
    @subject = "#{'aeiou'.include?(language.first.downcase) ? 'An' : 'A'} #{locale} translation has been changed"
    mail to: user.named_email, subject: @subject
  end

  def page_comment(user, commenter, comment, page_name, page_link)
    @user = user
    @commenter = commenter
    @comment = comment
    @page_name = page_name
    @page_link = page_link
    @subject = "#{user.name} commented on the #{page_name}"
    mail to: user.named_email, subject: @subject
  end

  private
  def set_host(*args)
    @host = if Rails.env.production?
              "https://Workbench.bikecollectives.org"
            else
              @host = UserMailer.default_url_options[:host]
            end
  end

  def markdown(content)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new({
        filter_html: true,
        hard_wrap: true,
        space_after_headers: true,
        fenced_code_blocks: true,
        link_attributes: { target: "_blank" }
      }), {
        autolink: true,
        disable_indented_code_blocks: true,
        superscript: true
      })
    @markdown.render(content).html_safe
  end
end
