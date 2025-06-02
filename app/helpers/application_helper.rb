module ApplicationHelper
  def bootstrap_class_for_flash(type)
    case type.to_sym
    when :notice then "success"
    when :alert  then "danger"
    when :error  then "danger"
    else "info"
    end
  end
end
