module Api
  module V1
    module Merchants
      class SearchController < ApplicationController
        def index
          render json: MerchantSerializer.new(
            Merchant.find_all(params[:name])
          )
        end

        def show
          render json: MerchantSerializer.new(
            Merchant.find_one(params[:name])
          )
        end
      end
    end
  end
end
