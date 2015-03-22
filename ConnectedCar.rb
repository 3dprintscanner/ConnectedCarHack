# require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'logger'
require 'json'
# require 'bundler/setup'

class App < Sinatra::Base
  register Sinatra::AssetPack
  set :root, File.dirname(__FILE__)

    # read on
    assets do
      # serve '/js', from: 'js'
      # serve '/js', from: 'bower_components'

      js :chart, [
        'js/*.js'
      ]
    end

  end

module Rack
  class Lint
    def call(env = nil)
      @app.call(env)
    end
  end
end

set :database, {adapter: "sqlite3", database: "connectedcar.sqlite3"}

get '/' do
	'Hello World'
end	

post '/apisubmit' do
	
	logger = Logger.new('logfile.log')
	logger.level = Logger::DEBUG
	content_type :json
	'Hello World'

	request.body.rewind
  	@request_payload = JSON.parse request.body.read
	logger.info(request.body)
	[200,{"Content-Type" => "text/plain"}, ["Hello World"]]
	@request_payload.each  do |entry|
 		newentry = Pressuredata.new({user_id: entry['user'], vehicle_id: entry ['vehicle_id'], tyre_pressure: entry['tyre_pressure'], time: entry['time']})
		"This is an entry"
		if newentry.save
			puts "Added to database"
			logger.info("Saved ")
		else
			puts "Not saved! #{newentry}"
			logger.error("Not Saved ")
		end
		
	end
	"this is an after entry"
	# request
end

get '/apisubmit' do
	"Send your request in post format"
end

get '/viewdata' do
	@vehicle_data = Pressuredata.all
	@create_datasets == true
	#here can we return an array of objects of each vehicle_id????
	erb :viewdata
end

get '/viewdata/:vehicle_id' do
	@vehicle_data = Pressuredata.where(vehicle_id: params[:vehicle_id])
	erb :viewdata
end

get '/viewdata/:vehicle_id/:days' do
	@vehicle_data = Pressuredata.where(vehicle_id: params[:vehicle_id]).where("time" == params[:days].to_i.days.ago)
	erb :viewdata
end

def get_different_vehicle_data
	@different_vehicle_data = Pressuredata.group(:vehicle_id)
end

def build_chart_datasets(vehicle_id)

	innergroup = Pressuredata.where(vehicle_id: vehicle_id).order(:time)
	puts innergroup
	pressurearray = innergroup.order(:time).map { |data| [data.tyre_pressure, data.time] }

	# dataset = %Q({fillColor : "rgba(220,3,5,0.5)", strokeColor : "rgba(220,220,220,0.8)", highlightFill: "rgba(220,220,220,0.75)", highlightStroke: "rgba(220,220,220,1)", data : #{pressurearray.map {|element| (element[0]).to_i}} },)
	pressurearray.map {|element| (element[0]).to_i}
	# return dataset
end

class Pressuredata < ActiveRecord::Base

	validates_presence_of :user_id
	validates_presence_of :vehicle_id
	validates_presence_of :tyre_pressure

end

__END__

@@ layout


<html>
<head>
<title>Super Simple Chat with Sinatra</title>
<meta charset="utf-8" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.js"></script>
<link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
</head>
<nav class="navbar navbar-default" role="navigation">
	<!-- Brand and toggle get grouped for better mobile display -->
	<div class="navbar-header">
		<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		</button>
		<a class="navbar-brand" href="#">Title</a>
	</div>

	<!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse navbar-ex1-collapse">
		<ul class="nav navbar-nav">
			<li class="active"><a href="#">Link</a></li>
			<li><a href="#">Link</a></li>
		</ul>
		<form class="navbar-form navbar-left" role="search">
			<div class="form-group">
				<input type="text" class="form-control" placeholder="Search">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
		</form>
		<ul class="nav navbar-nav navbar-right">
			<li><a href="#">Link</a></li>
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <b class="caret"></b></a>
				<ul class="dropdown-menu">
					<li><a href="#">Action</a></li>
					<li><a href="#">Another action</a></li>
					<li><a href="#">Something else here</a></li>
					<li><a href="#">Separated link</a></li>
				</ul>
			</li>
		</ul>
	</div><!-- /.navbar-collapse -->
</nav>
<body><%= yield %></body>
</html>

@@ viewdata
<% if @vehicle_data %>
		<% pressurearray = @vehicle_data.order(:time).all.to_a.map { |data| [data.tyre_pressure, data.time] } %>
	<% else %>	
		<% pressurearray = Pressuredata.order(:time).all.to_a.map { |data| [data.tyre_pressure, data.time] } %>
	<% end %>
<%= build_chart_datasets(5) %>
<div class="container">
	<canvas id="myChart" max-width="1000" max-height="900"></canvas>	
</div>
<div class="row">
	<div class="jumbotron">
		<div class="container">
			<h1>Your Data</h1>
			<p>Your Average Pressure is: <%= (pressurearray.inject(pressurearray.first.first) {|sum, x| sum + x.first}/pressurearray.size).round(3) %></p>
			<p>Your Peak Pressure is: <%= pressurearray.sort.last.first.to_i %> </p>
			<p>Your Lowest Pressure is: <%= pressurearray.sort.first.first.to_i %></p>
				<a class="btn btn-primary btn-lg">Learn more</a>
			</p>
		</div>
	</div>
</div>
	<% get_different_vehicle_data.each do |group| %>
		The vehicle id is<%= group.vehicle_id %>
		<%  innergroup = Pressuredata.where(vehicle_id: group.vehicle_id).order(:time).each do |ingroup| %>
			The tyre pressure is<%= ingroup.tyre_pressure %>
			The time is <%= ingroup.time %>
		<% end %>
	<% end %> 
<script> 

	var barChartData = {
		labels : <%= pressurearray.map {|element| element[1].to_s} %>,
		datasets : [
			{
				fillColor : "rgba(220,220,220,0.5)",
				strokeColor : "rgba(220,220,220,0.8)",
				highlightFill: "rgba(220,220,220,0.75)",
				highlightStroke: "rgba(220,220,220,1)",
				data : <%= pressurearray.map {|element| (element[0]).to_i} %>
			},



		]

	}
	window.onload = function(){
		console.log(barChartData);
		var ctx = document.getElementById("myChart").getContext("2d");
		window.myBar = new Chart(ctx).Line(barChartData, {
			responsive : true,
			showScale : true
		});
		window.myBar.addData(<%= build_chart_datasets(5) %>, "5");
	}

	
</script>