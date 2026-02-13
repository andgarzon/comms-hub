# app/helpers/icon_helper.rb
module IconHelper
  # Render an SVG icon from the sprite
  # 
  # Usage:
  #   <%= icon('email') %>
  #   <%= icon('email', class: 'icon-lg icon-primary') %>
  #   <%= icon('users', size: 'lg', color: 'primary') %>
  #
  def icon(name, options = {})
    # Size classes
    size_class = case options[:size]
                 when 'sm', :sm then 'icon-sm'
                 when 'md', :md then 'icon-md'
                 when 'lg', :lg then 'icon-lg'
                 when 'xl', :xl then 'icon-xl'
                 else ''
                 end
    
    # Color classes
    color_class = case options[:color]
                  when 'primary', :primary then 'icon-primary'
                  when 'success', :success then 'icon-success'
                  when 'warning', :warning then 'icon-warning'
                  when 'danger', :danger then 'icon-danger'
                  when 'muted', :muted then 'icon-muted'
                  else ''
                  end
    
    # Additional classes
    additional_classes = options[:class].to_s
    
    # Combine all classes
    classes = ['icon', size_class, color_class, additional_classes].reject(&:blank?).join(' ')
    
    content_tag(:svg, class: classes, **options.except(:size, :color, :class)) do
      content_tag(:use, nil, 'xlink:href' => "#icon-#{name}")
    end
  end
  
  # Common icon shortcuts
  def email_icon(options = {})
    icon('email', options)
  end
  
  def slack_icon(options = {})
    icon('slack', options)
  end
  
  def announcement_icon(options = {})
    icon('megaphone', options)
  end
  
  def users_icon(options = {})
    icon('users', options)
  end
  
  def settings_icon(options = {})
    icon('settings', options)
  end
  
  def search_icon(options = {})
    icon('search', options)
  end
  
  def calendar_icon(options = {})
    icon('calendar', options)
  end
  
  def check_icon(options = {})
    icon('check', options)
  end
  
  def clock_icon(options = {})
    icon('clock', options)
  end
  
  def edit_icon(options = {})
    icon('edit', options)
  end
  
  def delete_icon(options = {})
    icon('trash', options)
  end
  
  def plus_icon(options = {})
    icon('plus', options)
  end
  
  def bell_icon(options = {})
    icon('bell', options)
  end
end
