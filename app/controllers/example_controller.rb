require 'mime/types'

class ExampleController < ApplicationController
  layout false

  def page
    # allow caching of the image if we were given a hash
    expires_in 1.month, public: true if params[:hash]

    @html = LinguaFranca.load_example(@application.path, params[:group], params[:page], params[:index])
            .gsub(/(="|\(['"]?)(?:\.\.\/){4}public\/(assets|uploads)/,
                "\\1/apps/#{params[:app]}/example-files/\\2")
              .gsub(/#{LinguaFranca::REGEX_END_TRANSLATION}/, '')
              .gsub(/#{Regexp.escape(LinguaFranca::START_TRANSLATION).gsub(LinguaFranca::KEY_MATCH_REGEX, '')}/, '')

    # convert comments to attributes
    while @html =~ /#{LinguaFranca::REGEX_START_TRANSLATION}/
      @html.gsub!(/(<[^>]+)#{LinguaFranca::REGEX_START_TRANSLATION}(.*?[^\-])>/m) { |match| "#{$1}#{$3} lingua-franca-attr=\"#{$2.split(',').first}\">" }
      @html.gsub!(/([^\-])>([^<]*)#{LinguaFranca::REGEX_START_TRANSLATION}/m) { |match| "#{$1} lingua-franca-key=\"#{$3.split(',').first}\">#{$2}" }
    end
  end

  def file
    # cache asset files for one year, they are already hashed so we don't need to worry about cache busting
    expires_in 1.year, public: true

    file = File.join(@application.path, 'public', params[:dir], params[:file])
    extension = File.extname(file)[1..-1]

    send_file(file,
              disposition: 'inline',
              type: MIME::Types.find { |type| type.extensions.include?(extension) } || 'text/plain',
              x_sendfile: true)
  end

  def screenshot
    # allow caching of the image if we were given a hash
    expires_in 1.month, public: true if params[:hash]

    file_path = LinguaFranca.example_file_path(
                  @application.path,
                  params[:group],
                  params[:page],
                  params[:index],
                  [
                    params[:group] == 'email' ? 'html' : nil,
                    params[:variant] == 'mobile' ? 'mobile' : nil,
                    'png'
                  ].compact.join('.')
                )

    send_file(File.expand_path(file_path),
              disposition: 'inline',
              type: 'image/png',
              x_sendfile: true)
  end
end
