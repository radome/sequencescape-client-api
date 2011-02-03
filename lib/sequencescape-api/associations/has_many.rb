require 'sequencescape-api/finder_methods'
require 'sequencescape-api/associations/base'
require 'sequencescape-api/actions'

module Sequencescape
  class Api
    module Associations
      module HasMany
        class AssociationProxy < ::Sequencescape::Api::Associations::Base
          include ::Sequencescape::Api::FinderMethods
          extend  ::Sequencescape::Api::Actions
        end

        class InlineAssociationProxy 
          include Enumerable

          def initialize(owner, association, options)
            @owner   = owner
            @model   = options[:class_name].constantize
            @objects = @owner.attributes_for(association).map(&method(:new))
          end

          attr_reader :model
          delegate :api, :to => :@owner
          private :api, :model
          delegate :each, :first, :last, :empty?, :to => :all

          def find(uuid)
            @objects.detect { |o| o.uuid == uuid }
          end

          def all
            @objects
          end

          def new(json, &block)
            model.new(api, json, true, &block)
          end
          private :new
        end

        def has_many(association, options, &block)
          association = association.to_sym
          ivar        = :"@#{association}"

          proxy = Class.new(
            case options[:disposition].try(:to_sym)
            when :inline then InlineAssociationProxy
            else AssociationProxy
            end
          )
          proxy.instance_eval(&block) if block_given?
          class_eval do
            define_method(association) do |*args|
              instance_variable_set(ivar, nil) if !!args.first
              instance_variable_get(ivar) || instance_variable_set(ivar, proxy.new(self, association, options))
            end
          end
        end
      end
    end
  end
end