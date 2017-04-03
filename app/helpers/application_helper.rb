require 'redcarpet'

module ApplicationHelper
  def format_key(key, subkey = nil)
    result = ''
    key_parts = key.split('.')
    key_parts.each_with_index do |k,i|
      result += content_tag(:div,
        (i.zero? ? '' : content_tag(:span, ("  " * i), class: 'indent')).html_safe + k,
        class: "key-part#{i == key_parts.count - 1 ? ' primary' : ''}")
    end

    if subkey.present?
      result += content_tag(:div,
        content_tag(:span, ("  " * key_parts.count), class: 'indent').html_safe + subkey,
        class: 'key-part sub-key')
    end

    result.html_safe
  end

  def format_value(value)
    return '<em class="no-value">NULL</em>'.html_safe unless value.present?

    if value.is_a?(Array)
      return ('<ul class="value-list">' +
              (value.collect { |v| "<li>#{format_value(v)}</li>" }).join +
              '</ul>').html_safe
    end

    val = value.gsub(/%\{(.*?)\}/, '<span class="variable">\1</span>')

    if val.match(/%(\w)(\b)/)
      val.gsub!(/%(\w)(\b)/) { |match| "<span class=\"formatter\" name=\"#{$1}\">#{formatters[$1].first}[#{formatters[$1].last}]</span>#{$2}" }
    end

    return val.html_safe
  end

  def formatters
    {
      'Y'    => ['Year',      'Four digit year'],
      'C'    => ['Year',      'First two digits'],
      'y'    => ['Year',      'Two digit year'],
      'm'    => ['Month',     'Two digit month'],
      '_m'   => ['Month',     'Padded number'],
      '-m'   => ['Month',     'Number'],
      'B'    => ['Month',     'Full month name'],
      'b'    => ['Month',     'Month abbr'],
      'h'    => ['Month',     'Abbr'],
      'd'    => ['Day',       'Two digit'],
      '-d'   => ['Day',       'Day'],
      'e'    => ['Day',       'Padded'],
      'j'    => ['Day',       'Day of year'],
      'H'    => ['Hour',      '24h 0-padded'],
      'k'    => ['Hour',      '24h padded'],
      'I'    => ['Hour',      '12h 0-padded'],
      'l'    => ['Hour',      '12h padded'],
      'P'    => ['Hour',      'am/pm'],
      'p'    => ['Hour',      'AM/PM'],
      'M'    => ['Minute',    'Minute'],
      'S'    => ['Second',    'Second'],
      'L'    => ['Second',    'Milliseconds'],
      'N'    => ['Second',    'Fractional seconds'],
      'z'    => ['Time zone', 'HM offset'],
      ':z'   => ['Time zone', 'HM offset from UTC'],
      '::z'  => ['Time zone', 'HMS offset from UTC'],
      'Z'    => ['Time zone', 'Abbr'],
      'A'    => ['Weekday',   'Full'],
      'a'    => ['Weekday',   'Abbr'],
      'u'    => ['Weekday',   '1-7'],
      'w'    => ['Weekday',   '0-6']
      # 'G' => 'The week-based year',
      # 'g' => 'The last 2 digits of the week-based year (00..99)',
      # 'V' => 'Week number of the week-based year (01..53)',
      # 'U' => 'Week number of the year.  The week starts with Sunday.  (00..53)',
      # 'W' => 'Week number of the year.  The week starts with Monday.  (00..53)',
      # 's' => 'Number of seconds since 1970-01-01 00:00:00 UTC.',
      # 'Q' => 'Number of microseconds since 1970-01-01 00:00:00 UTC.',
      # 'c' => 'date and time (%a %b %e %T %Y)',
      # 'D' => 'Date (%m/%d/%y)',
      # 'F' => 'The ISO 8601 date format (%Y-%m-%d)',
      # 'v' => 'VMS date (%e-%b-%Y)',
      # 'r' => '12-hour time (%I:%M:%S %p)',
      # 'R' => '24-hour time (%H:%M)',
      # 'T' => '24-hour time (%H:%M:%S)',
    }
  end

  def plurals(translation, locale)
    # this will eventually need to change for other languages
    {zero: nil, one: nil, other: nil}.merge(translation || {})
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
