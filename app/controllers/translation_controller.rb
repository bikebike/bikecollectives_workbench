class TranslationController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def translate_locale
    @help = :translations
    @back = { text: "Back to #{@application.name}", link: view_application_path(@application.slug) }
    add_scripts(:translate)
    @page_key = File.join(@group.to_s, @page.to_s)
    @translations = LinguaFranca.get_translations(@application.slug, @application.path, @locale)
    unless @locale == :en
      @english_translations = LinguaFranca.get_translations(@application.slug, @application.path, :en)
    end
    @language = YAML.load_file(I18n.config.languages_file)['en']['languages'][@locale.to_s]

    @vars = {}
    @keys = SortedSet.new
    keys = LinguaFranca.get_translation_info(@application.path)
    keys.each do |key, pages|
      if LinguaFranca.imported_translation?(key)
      elsif pages.values && pages.values.first['data'] && pages.values.first['data']['vars']
        @vars[key] = pages.values.first['data']['vars'].keys
        @keys << key
        # don't add arrays, they are date parts
      elsif key =~ /^(.*)\.(zero|one)$/
        @keys << $1
        @vars[$1] = ['count']
      else
        @keys << key unless key =~ /^(.*)\.other$/ && keys.has_key?("#{$1}.one")
      end
    end
  end

  def translate_page
    @help = :translations
    @back = { text: "Back to #{@page.to_s.titlecase}", link: page_path(@application.slug, @group, @page) }
    add_scripts(:translate)
    @page_key = File.join(@group.to_s, @page.to_s)
    @keys = SortedSet.new
    @translations = LinguaFranca.get_translations(@application.slug, @application.path, @locale)

    unless @locale == :en
      @english_translations = LinguaFranca.get_translations(@application.slug, @application.path, :en)
    end
    @language = YAML.load_file(I18n.config.languages_file)['en']['languages'][@locale.to_s]

    page_key = "#{@group}/#{@page}"
    @vars = {}
    LinguaFranca.get_translation_info(@application.path).each do |key, pages|
      if pages.has_key?(page_key)
        @keys << key

        if pages.values && pages.values.first['data'] && pages.values.first['data']['vars']
          @vars[key] = pages.values.first['data']['vars'].keys
        end
      end
    end
  end

  def save_translation
    translation = ActionView::Base.full_sanitizer.sanitize(params[:translation]).gsub(/[[:space:]]{2,}/, ' ').strip
    old_translation = LinguaFranca.get_translations(@application.slug, @application.path, params[:locale])[params[:key]]

    LinguaFranca.save_translation(@application.slug, @application.path, params[:locale], params[:key], translation)
    current_user.follow_translation(@application.id, params[:key])

    language = YAML.load_file(I18n.config.languages_file)['en']['languages'][params[:locale]]

    # TODO    
    # TranslationFollower.where(application_id: @application.id).each do |follower|
    #   unless follower.user_id == current_user.id
    #     UserMailer.translation_changed(current_user, language, params[:key], old_translation, translation).deliver_now
    #   end
    # end

    # make a record of the translation so we have some idea who changed it
    TranslationRecord.create(locale: params[:locale], translator_id: current_user.id, key: params[:key], value: translation)

    # render json as the output
    render json: {
      status: :success,
      key: params[:key],
      translation: translation,
      formattedValue: view_context.format_value(translation),
      watching: current_user.following_translation?(@application.id, params[:key])
    }
  end

  def watch_translation
    if params[:key].present?
      follow = [@application.id, params[:key]]
      type = :translation
    elsif params[:locale] == '-'
      follow = [@application.id, params[:group], params[:page], params[:index], params[:variant]]
      type = :page
    else
      follow = [@application.id, @locale]
      type = :locale
    end

    current_user.send("#{params[:watch] == '1' ? '' : 'un'}follow_#{type}", *follow)

    render json: {
      status: :success,
      key: params[:key],
      watching: current_user.send("following_#{type}?", *follow)
    }
  end

  def translator
    @key = @demokey = params[:key]
    @page_key = File.join(@group.to_s, @page.to_s)
    @translations = LinguaFranca.get_translations(@application.slug, @application.path, @locale)

    @translation = @translations[@key]

    if @key =~ /^(.*)\.(zero|one|other)$/
      @demokey = $1
    end

    @info = LinguaFranca.get_translation_info(@application.path)[@demokey] || {}
    if @info.has_key?(@page_key)
      @info = @info.sort_by { |k, v| k == @page_key ? "!#{k}" : "$#{k}"}.to_h
    else
      @page_key = @info.keys.first
    end

    @data = ((@info || {})[@page_key] || {})['data'] || {}
    @vars = {}
    @formats = view_context.formatters
    @button_formats = {}
    @formats.each do |fmt, values|
      @button_formats[values.first] ||= {}
      @button_formats[values.first][fmt] = values.last
    end

    if @data['vars']
      @data['vars'].each do |var_name, examples|
        if var_name == 'object' && valid_date?(examples.first)
          date = DateTime.parse(examples.first)
          @vars['_datetime'] = {}
          @formats.keys.each do |fmt|
            @vars['_datetime'][fmt] = date.strftime("%#{fmt}")
          end
        else
          @vars[var_name] = examples.first
        end
      end
    elsif @translation
      @translation.scan(/%\{(.*?)\}/m).flatten.each do |var_name|
        @vars[var_name] = nil
      end
    end

    @context = @data['context'].present? ? LinguaFranca.get_context(@data['context']) : nil
    @default = @context.present? ? nil : @data['context']
    @english = LinguaFranca.get_translations(@application.slug, @application.path, :en)[@key] unless @locale == :en

    @is_watching = current_user.following_translation?(@application.id, @key)

    render layout: false
  end

private
  def valid_date?(string)
    begin
      DateTime.parse(string)
    rescue
      return false
    end
    return true
  end
end
