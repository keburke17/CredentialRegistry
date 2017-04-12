describe API::V1::Resources do
  let!(:ec)       { create(:envelope_community, name: 'ce_registry') }
  let!(:envelope) { create(:envelope, :from_cer, :with_cer_credential) }
  let!(:resource) { envelope.processed_resource }
  let!(:id)       { resource['@id'] }

  context 'CREATE /resources' do
    before do
      post '/resources', attributes_for(:envelope, :from_cer,
                                        envelope_community: ec.name)
    end

    it 'returns a 201 Created http status code' do
      expect_status(:created)
    end

    context 'returns the newly created envelope' do
      it { expect_json_types(envelope_id: :string) }
      it { expect_json(envelope_community: 'ce_registry') }
      it { expect_json(envelope_version: '0.52.0') }
    end
  end

  context 'GET /resources/:id' do
    before(:each) do
      get "/resources/#{id}"
    end

    it { expect_status(:ok) }

    it 'retrieves the desired resource' do
      expect_json('@id': id)
    end

    context 'invalid id' do
      let!(:id) { '9999INVALID' }

      it { expect_status(:not_found) }
    end

    context 'full URL as ID' do
      let!(:id) { 'http://example.com/resources/ctid:id-123412312313' }
      before do
        res = resource.merge('@id' => id, 'ceterms:ctid' => 'ctid:id-312313')
        create(:envelope, :from_cer, :with_cer_credential,
               resource: jwt_encode(res), envelope_community: ec)
        get "/resources/#{CGI.escape(id)}"
      end

      it { expect_status(:ok) }

      it 'retrieves the desired resource' do
        expect_json('@id': id)
      end
    end
  end

  context 'PUT /resources/:id' do
    before(:each) do
      update  = jwt_encode(resource.merge('ceterms:name': 'Updated'))
      payload = attributes_for(:envelope, :from_cer, :with_cer_credential,
                               resource: update,
                               envelope_community: ec.name)
      put "/resources/#{id}", payload
      envelope.reload
    end

    it { expect_status(:ok) }

    it 'updates some data inside the resource' do
      expect(envelope.processed_resource['ceterms:name']).to eq('Updated')
    end
  end

  context 'DELETE /resources/:id' do
    before(:each) do
      payload = attributes_for(:delete_token, envelope_community: ec.name)
      delete "/resources/#{id}", payload
      envelope.reload
    end

    it { expect_status(:no_content) }

    it 'marks the envelope as deleted' do
      expect(envelope.deleted_at).not_to be_nil
    end
  end
end
