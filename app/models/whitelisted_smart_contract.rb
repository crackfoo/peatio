# encoding: UTF-8
# frozen_string_literal: true

class WhitelistedSmartContract < ApplicationRecord
  # == Relationships ========================================================

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :id, presence: true, uniqueness: true

  validates :address, presence: true, uniqueness: true

  validates :blockchain_key,
            presence: true,
            uniqueness: true,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } }

  validates :state,  inclusion: { in: %w[active disabled] }

  # == Scopes ===============================================================

  scope :active, -> { where(state: active) }
  scope :ordered, -> { order(kind: :asc) }

  def explorer_url
    blockchain.explorer_address.gsub('#{address}', address) if blockchain
  end
end
