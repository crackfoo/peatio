# encoding: UTF-8
# frozen_string_literal: true

module TIDIdentifiable
  extend ActiveSupport::Concern

  included do
    validates :tid, presence: true, uniqueness: { case_sensitive: false }

    before_validation do
      next unless tid.blank?
      begin
        self.tid = TIDIdentifiable.generate
      end while self.class.where(tid: tid).any?
    end
  end

  def self.generate
    "TID#{SecureRandom.hex(5).upcase}"
  end
end
