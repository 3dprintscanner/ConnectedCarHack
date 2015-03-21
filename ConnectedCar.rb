require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
# require 'bundler/setup'


set :database, {adapter: "sqlite3", database: "connectedcar.sqlite3"}

get '/' do
	'Hello World'
end	

post '/apisubmit' do
	# if request.body.content_type  == json
	# 	# Pressuredata.create(parse_request_body(request_body))
	# 	request_body
	# end

	content_type :json
	'Hello World'
	# request.body.to_json

	# class Bodyrequest
	# 	def initialize(data)
	# 		@data = JSON.parse(data)
	# 	end

	# end
	request.body.to_json

	# file = Bodyrequest.new(request.body)

	 # puts file
	# request_body

	# request.path
	# thebody = JSON.parse request.body
	request.body.each  do |entry|
 		newentry = Pressuredata.new({user_id: entry['user'], vehicle_id: entry ['vehicle_id'], tyre_pressure: entry['tyre_pressure'], time: entry['time']})
		if newentry.save
			Pressuredata.find(entry['user'])
			puts "Added to database"
			Logger.info("Saved #{newentry}")
		else
			puts "Not saved! #{newentry}"
		end
			
	end
end

get '/apisubmit' do
	"Send your request in post format"
end

class Pressuredata < ActiveRecord::Base

	validates_presence_of :user_id
	validates_presence_of :vehicle_id
	validates_presence_of :tyre_pressure

end

