module DeviseTokenAuth::Concerns::ResourceFinder
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  def get_case_insensitive_field_from_resource_params(field)
    # honor Devise configuration for case_insensitive keys
    q_value = resource_params[field.to_sym]

    if resource_class.case_insensitive_keys.include?(field.to_sym)
      q_value.downcase!
    end
    q_value
  end

  def find_resource(field, account_id, value)
    # If user is admin, account_id is not relevant
    @resource = resource_class.where(email: value, is_admin: true).first

    unless @resource
      @resource = resource_class.of_account(account_id).provider(provider).where(email: value).first
    end

    @resource
  end

  def resource_class(m=nil)
    if m
      mapping = Devise.mappings[m]
    else
      mapping = Devise.mappings[resource_name] || Devise.mappings.values.first
    end

    mapping.to
  end

  def provider
    'email'
  end
end
