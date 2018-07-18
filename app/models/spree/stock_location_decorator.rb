Spree::StockLocation.class_eval do
  validates_presence_of :address1, :city, :zipcode,
                        :country_id, unless: proc { |a| a.name == 'Default' }
  validate :state_id_or_state_name_is_present,
           unless: proc { |a| a.name == 'Default' }

  def state_id_or_state_name_is_present
    if state_id.nil? && state_name.nil?
      errors.add(:state_name, "can't be blank")
    end
  end
end
