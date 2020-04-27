# frozen_string_literal: true

module ApplicationHelper
  def link_to_switch_locale
    if I18n.locale == :'en-US'
      link_to 'JA', locale: 'ja'
    else
      link_to 'EN', locale: 'en-US'
    end
  end

  def current_page_api_example(url)
    render partial: 'layouts/current_page_api_example', locals: { url: url }
  end

  def human_label(model_name, attr_name)
    I18n.t(
      "activerecord.attributes.#{model_name}.#{attr_name}_tooltip",
      default: t(
        "activerecord.attributes.#{model_name}.#{attr_name}",
        default: t(attr_name)
      )
    )
  end

  def datetime_picker(model_name, attr_name)
    render partial: 'layouts/datetime_picker', locals: {
      model_name: model_name,
      attr_name: attr_name
    }
  end

  def dropdown_field(model_name, attr_name, values)
    render partial: 'application/drop_down_field', locals: {
      model_name: model_name,
      attr_name: attr_name,
      values: values
    }
  end

  def filter_field(model_name, attr_name, options = {})
    render partial: 'layouts/filter_field', locals: {
      model_name: model_name,
      attr_name: attr_name,
      options: options
    }
  end

  def filter_tag(model_name, attr_name)
    render partial: 'layouts/filter_tag', locals: {
      model_name: model_name,
      attr_name: attr_name
    }
  end

  def summarize_results(collection)
    render partial: 'layouts/summarize_results', locals: {
      collection: collection
    }
  end

  def show_filters(model_name, attr_names)
    render partial: 'layouts/show_filters', locals: {
      model_name: model_name,
      attr_names: attr_names
    }
  end

  def filter_modal(name, &block)
    render partial: 'layouts/filter_modal', locals: {
      name: name,
      form: capture(&block)
    }
  end

  def table_sort_header(model_name, attr_name) # rubocop:disable Metrics/MethodLength
    current_sort_field, current_sort_direction = params[:order].to_s.split(' ', 2)

    new_order = params[:order] == "#{attr_name} asc" ? "#{attr_name} desc" : "#{attr_name} asc"
    direction = params[:order] == "#{attr_name} desc" ? 'up' : 'down'

    render partial: 'layouts/table_sort_header', locals: {
      model_name: model_name,
      attr_name: attr_name,
      current_sort_field: current_sort_field,
      current_sort_direction: current_sort_direction,
      new_order: new_order,
      direction: direction
    }
  end

  def flash_class(level)
    case level
    when :notice then 'alert-success'
    when :error, :alert then 'alert-error'
    end
  end
end
