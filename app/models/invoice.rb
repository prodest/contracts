class Invoice
  include Mongoid::Document


  field :name, type: String
  field :value, type: Float
  field :expiration_date, type: Date
  field :emission_date, type: Date
  field :status, type: Boolean
  field :comments, type: String

before_save :update_total_executed

# só quem pode emitir uma nota é um Fornecedor, e está será sempre vinculada
# a um contrato. Normalmente um contrato é executado por meio de várias notas
# Caso um contrato seja deletado, assim como fornecedor suas notas também serão,
# pois não haverá a quem vuncular e não será permitido notas soltas.

  belongs_to :vendor, dependent: :destroy
  belongs_to :contract, dependent: :destroy

# TODO binding contrato e já vincular automaticamente ao fornecedor.
# Sem que o usuário faça. Por enquanto esta manual.
# Tem que entender como funciona as referencias em mongo

  rails_admin do

      navigation_label 'Fiscal'

      list do
        exclude_fields :_id, :created_at, :updated_at, :comments

        field :status, :toggle
      end

      edit do
        exclude_fields :created_at, :updated_at, :vendor
        field :contract do
          # associated_collection_cache_all false
          associated_collection_scope do
            # bindings[:object] & bindings[:controller] are available, but not in scope's block!
            user_now = bindings[:controller].current_user.id

            Proc.new { |scope|
              #Rodrigo = bindings[:view].current_user
              #Contract.includes(:accountability).where(user_id: bindings[:view].current_user.id)
              # scope = scope.where(league_id: team.league_id) if team.present?
              #scope = Contract.includes(:accountability).where(user_id: bindings[:view].current_user.id)
              scope = Contract.where(user_id: user_now)
            }

    end
        end
      end

      show do
        exclude_fields :id, :created_at, :updated_at
      end
      # object_label_method do
      #   :custom_label_method
      # end

  end

  def associate_vendor

  end

  def update_total_executed
    idContrato = self.contract._id
    contrato = Contract.where(id: idContrato).first
    contrato.total_executed = contrato.invoices.sum(:value) + self.value
    contrato.save
  end


end
