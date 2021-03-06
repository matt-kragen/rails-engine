require 'rails_helper'

describe 'Merchants API' do
  context 'happy path' do
    describe 'basic requests' do
      it 'sends a list of merchants' do
        create_list(:merchant, 3)

        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(3)

        merchants[:data].each do |merchant|
          expect(merchant).to have_key(:id)
          expect(merchant[:id]).to be_an(String)

          expect(merchant).to have_key(:attributes)
          expect(merchant[:attributes]).to be_a(Hash)

          expect(merchant[:attributes]).to have_key(:name)
          expect(merchant[:attributes][:name]).to be_a(String)
        end
      end

      it 'displays specific merchant' do
        id = create(:merchant).id

        get "/api/v1/merchants/#{id}"

        expect(response).to be_successful

        merchant = JSON.parse(response.body, symbolize_names: true)

        expect(merchant[:data]).to have_key(:id)
        expect(merchant[:data][:id]).to be_a(String)

        expect(merchant[:data]).to have_key(:attributes)
        expect(merchant[:data][:attributes]).to be_a(Hash)

        expect(merchant[:data][:attributes]).to have_key(:name)
        expect(merchant[:data][:attributes][:name]).to be_a(String)
      end

      it 'displays items associated with specific merchant' do
        id = create(:merchant).id
        create_list(:item, 10, merchant_id: id)

        get "/api/v1/merchants/#{id}/items"

        expect(response).to be_successful
        data = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(data.size).to eq(10)

        data.each do |item|
          expect(item).to have_key(:id)
          expect(item[:id]).to be_a(String)

          expect(item[:attributes]).to have_key(:name)
          expect(item[:attributes][:name]).to be_a(String)

          expect(item[:attributes]).to have_key(:description)
          expect(item[:attributes][:description]).to be_a(String)

          expect(item[:attributes]).to have_key(:unit_price)
          expect(item[:attributes][:unit_price]).to be_a(Numeric)

          expect(item[:attributes]).to have_key(:merchant_id)
          expect(item[:attributes][:merchant_id]).to be_a(Numeric)
          expect(item[:attributes][:merchant_id]).to eq(id)
        end
      end
    end

    describe 'optional query parameters' do
      it 'displays default of 20 merchants per page' do
        create_list(:merchant, 30)

        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(20)
      end

      it 'displays optional number of merchants per page' do
        create_list(:merchant, 30)

        get '/api/v1/merchants', params: { per_page: 15 }

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(15)
      end

      it 'can navigate to a specific page' do
        create_list(:merchant, 30)

        get '/api/v1/merchants', params: { page: 2 }

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(10)
      end
    end
  end

  context 'sad path' do
    describe 'basic requests' do
      it 'throws custom 404 error when a record cannot be found' do
        nonexistent_merchant_id = 101
        get "/api/v1/merchants/#{nonexistent_merchant_id}"

        expected_errors = {
          errors: ["Couldn't find Merchant with 'id'=#{nonexistent_merchant_id}"],
          message: "Uh, oh... I couldn't find that record"
        }
        thrown_errors = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not be_successful
        expect(thrown_errors).to eq(expected_errors)
      end
    end
  end
end
