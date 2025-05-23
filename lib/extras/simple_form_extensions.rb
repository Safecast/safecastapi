# frozen_string_literal: true

module WrappedButton
  def wrapped_button(*args, &) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    template.content_tag :div, class: 'form-actions' do
      options = args.extract_options!
      loading = object.new_record? ? I18n.t('simple_form.creating') : I18n.t('simple_form.updating')
      options[:'data-loading-text'] = [loading, options[:'data-loading-text']].compact
      options[:class] = ['btn-primary', options[:class]].compact
      args << options
      cancel = options.delete(:cancel)
      if cancel
        cancel_options = options.delete(:cancel_options)
        cancel_link = template.link_to(I18n.t('simple_form.buttons.cancel'), cancel, cancel_options)
        "#{submit(*args, &)} #{I18n.t('simple_form.buttons.or')} #{cancel_link}".html_safe
      else
        submit(*args, &)
      end
    end
  end
end
SimpleForm::FormBuilder.send :include, WrappedButton
