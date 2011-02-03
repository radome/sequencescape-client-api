require 'sequencescape-api/resource'

module Sequencescape
  class AssetGroup < ::Sequencescape::Api::Resource
    belongs_to :submission, :class_name => 'Sequencescape::Submission'
    belongs_to :study,      :class_name => 'Sequencescape::Study'
    has_many   :assets,     :class_name => 'Sequencescape::Asset'
  end
end