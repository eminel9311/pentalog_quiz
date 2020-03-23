require 'json'
require 'pry'
require 'date'

def main
  rentals = []
  data_response = {}
  file = File.read("./data/input.json")
  data_hash = JSON.parse(file)
  data_cars = data_hash["cars"]
  data_rentals = data_hash["rentals"]
  data_rentals.each do |rental|
    obj = {}
    start_date = Date.strptime(rental["start_date"])
    end_date =  Date.strptime(rental["end_date"])
    rental_period = (end_date - start_date).to_i + 1
    car_detail = data_cars.find{|car| car["id"] == rental["car_id"]}
    price_for_day  = (rental_period * car_detail["price_per_day"]).to_i
    price_for_distance = rental["distance"].to_i * car_detail["price_per_km"].to_i
    total_price = price_for_day + price_for_distance
    obj["id"] = rental["id"]
    obj["price"] = total_price.to_i
    rentals << obj  
  end
  data_response["rentals"] = rentals
  File.write("./data/output.json", JSON.pretty_generate(data_response))
end

main
