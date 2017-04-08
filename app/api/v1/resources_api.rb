module API
  module V1
    # Implements all the endpoints related to resources
    module ResourceAPI
      # these shenanigans are necessary because a Grape::API can be mounted
      # only once. See https://github.com/ruby-grape/grape/issues/570

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def self.included(base)
        base.instance_eval do
          include API::V1::Defaults

          helpers SharedHelpers
          helpers EnvelopeHelpers

          before_validation { normalize_envelope_community }

          resource :resources do
            desc 'Publishes a new envelope',
                 http_codes: [
                   { code: 201, message: 'Envelope created' },
                   { code: 200, message: 'Envelope updated' }
                 ]
            params do
              use :update_if_exists
              use :skip_validation
            end
            post do
              envelope, errors = EnvelopeBuilder.new(
                params,
                update_if_exists: update_if_exists?,
                skip_validation: skip_validation?
              ).build

              if errors
                json_error! errors, [:envelope,
                                     envelope.try(:resource_schema_name)]

              else
                present envelope, with: API::Entities::Envelope
                update_if_exists? ? status(:ok) : status(:created)
              end
            end

            desc 'Return a resource.'
            params do
              requires :id, type: String, desc: 'Resource id.'
            end
            after_validation do
              find_envelope
            end
            get ':id' do
              present @envelope.processed_resource
            end

            desc 'Updates an existing envelope'
            params do
              requires :id, type: String, desc: 'Resource id.'
              use :skip_validation
            end
            after_validation do
              find_envelope
            end
            put ':id' do
              sanitized_params = params.dup
              sanitized_params.delete(:id)
              envelope, errors = EnvelopeBuilder.new(
                sanitized_params,
                envelope:        @envelope,
                skip_validation: skip_validation?
              ).build

              if errors
                json_error! errors, [:envelope, envelope.try(:community_name)]
              else
                present envelope, with: API::Entities::Envelope
              end
            end

            desc 'Marks an existing envelope as deleted'
            params do
              requires :id, type: String, desc: 'Resource id.'
            end
            after_validation do
              find_envelope
              params[:envelope_id] = @envelope.envelope_id
            end
            delete ':id' do
              validator = JSONSchemaValidator.new(params, :delete_envelope)
              if validator.invalid?
                json_error! validator.error_messages, :delete_envelope
              end

              BatchDeleteEnvelopes.new([@envelope],
                                       DeleteToken.new(params)).run!

              body false
              status :no_content
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end