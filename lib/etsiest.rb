require "sinatra/base"
require "etsy"
require "pry"

require "etsiest/version"

module Etsiest
  # Your code goes here...
  class App < Sinatra::Base
  	attr_reader :search
  	set :logging, true

		Etsy.api_key = ENV['ETSY_KEY']

  	def search(keywords)
  		Etsy::Request.get('/listings/active', :includes => ['Images', 'Shop'], :keywords => keywords)
  	end

  	get "/" do
  		erb :index
  	end

  	get "/search" do
  		keywords = params["keywords"]
  		response = search(keywords)
  		data = set_data(response)
  		erb :index, locals: { data: data, keywords: keywords, results_count: response.to_hash["count"].to_s }
  	end

  	def set_data(response)
  		listings = response.result
  		listings.map { |listing| build_data(listing) }
  	end

  	def build_data(listing)
  		title = get_value_for("title", listing)
  		price = get_value_for("price", listing)
  		currency_code = get_value_for("currency_code", listing)
  		item_url = get_value_for("url", listing)
  		image = get_image(listing)
  		login_name = get_shop_value("login_name", listing)
  		shop_url = get_shop_value("url", listing)

  		{ :title => title, :price => price, 
  			:currency_code => currency_code, 
  			:item_url => item_url, :image => image,  
  			:login_name => login_name, 
  			:shop_url => shop_url
  		}
  	end

  	def get_value_for(key, listing)
  		listing[key]
  	end

  	def get_shop_value(key, listing)
  		listing["Shop"][key]
  	end

  	def get_image(listing)
  		listing["Images"].first["url_570xN"]
  	end

#binding.pry

    run! if app_file == $0
  

  end

end
