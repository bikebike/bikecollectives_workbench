require 'mime/types'

class ExampleController < ApplicationController
  layout false

  def page
    @html = LinguaFranca.load_example(@application.path, params[:group], params[:page], params[:index])
            .gsub(/(="|\(['"]?)(?:\.\.\/){4}public\/(assets|uploads)/,
                "\\1/apps/#{params[:app]}/example-files/\\2")
              .gsub(/#{LinguaFranca::REGEX_END_TRANSLATION}/, '')
    while @html =~ /#{LinguaFranca::REGEX_START_TRANSLATION}/
      @html.gsub!(/(<[^>]+)#{LinguaFranca::REGEX_START_TRANSLATION}(.*?[^\-])>/) { |match| "#{$1}#{$3} lingua-franca-attr=\"#{$2.split(',').first}\">"}
      @html.gsub!(/([^\-])>([^<]*)#{LinguaFranca::REGEX_START_TRANSLATION}/) { |match| "#{$1} lingua-franca-key=\"#{$3.split(',').first}\">#{$2}"}
    end
  end

  def file
    file = File.join(@application.path, 'public', params[:dir], params[:file])
    extension = File.extname(file)[1..-1]

    send_file(file,
              disposition: 'inline',
              type: MIME::Types.find { |type| type.extensions.include?(extension) } || 'text/plain',
              x_sendfile: true)
  end

  def screenshot
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
