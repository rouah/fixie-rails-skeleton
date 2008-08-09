module ApplicationHelper
  def page_id
    "#{controller.controller_name}_#{controller.action_name}"
  end

  def page_class
    controller.controller_name
  end

  # Common code to display errors from flash/object errors
  def flash_messages(object_name=nil, options = {})
    if flash[:error].is_a?(Array)
      style = 'error'
      msgs = error_box(flash[:error])

    elsif flash[:error]
      style = 'error'
      msgs = %{<img src="/images/icons/error.gif" alt="Error" class="vtop" />
                <strong>#{flash[:error]}</strong>}

    elsif flash[:notice]
      style = 'success'
      msgs = %{<img src="/images/icons/success.gif" alt="Successful" class="vtop" />
                <strong>#{flash[:notice]}</strong>}

    elsif object_name
      style = 'error'
      options = options.symbolize_keys
      object = instance_variable_get("@#{object_name}")
      if object && !object.errors.empty?
        msgs = error_box(object.errors.full_messages)
      end
    end

    %Q{<div id="message_box" class="#{style}">#{msgs}</div>} if msgs
  end

  # Message to display to user
  def error_box(messages)
    %{<img src="/images/icons/error.gif" alt="Error" class="vtop" />
       <strong>The following problems were encountered:</strong>
       <ol id="err_msgs">#{messages.collect {|msg| content_tag("li", msg) }}</ol>
       <div id="err_fix">Please correct the above issues and try again.</div>}
  end

  # calculate range of current items in paginator
  def pagination_range(collection)
    first = (collection.current_page - 1) * collection.per_page + 1
    last  = first + (collection.per_page - 1)
    last  = last > collection.total_entries ? collection.total_entries : last

    collection.total_entries > 0 ? "#{first} - #{last}" : "0"
  end
end
