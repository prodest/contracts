class Addition

  include Mongoid::Document

  field :name, type: String
  field :object, type: String
  field :description, type: String
  field :adjustment_percentage, type: Float
  field :start_date, type: Date
  field :adjustment_total_value, type: Float

  belongs_to :contract

  before_create :calc_total_value_addition

  rails_admin do

      navigation_label 'Eventos'

      list do
        field :name
        field :object
        field :start_date
      end

      edit do
        field :contract do
          inline_add false
          inline_edit false
        end

        field :name, :string
        field :object
        field :description
        field :adjustment_percentage
        field :start_date
        field :adjustment_total_value
      end

      show do
      end

      object_label_method do
         :custom_label_method
      end


  end

  def custom_label_method
    "#{self.name}"
  end

  def object_enum
    [ 'Reajuste',
      'Alteração de Dotação Orçamentária',
      'Substituição do Fiscal',
      'Outros']
  end

  def calc_total_value_addition
      if (adjustment_percentage)
        contrato = self.contract
        self.adjustment_total_value = (self.adjustment_percentage) * contrato.total_value
        contrato.total_value = contrato.total_value + self.adjustment_total_value
        contrato.save!
      end
  end


end
