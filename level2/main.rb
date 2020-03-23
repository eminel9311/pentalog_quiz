require 'json'
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
    price_for_one_day  = (car_detail["price_per_day"]).to_i
    price_for_day_discount = (2..4).include?(rental_period) ? price_for_one_day + price_for_one_day*(rental_period - 1) * 0.9 \
                            : (5..10).include?(rental_period) ? price_for_one_day + price_for_one_day*(2..4).count*0.9 + price_for_one_day*(rental_period - (2..4).count - 1 )*0.7 \
                            : rental_period > 10 ? price_for_one_day + price_for_one_day*(2..4).count*0.9 + price_for_one_day*(5..10).count*0.7 +  price_for_one_day*(rental_period - (2..4).count - (5..10).count - 1 )*0.5 \
                            : price_for_one_day
    price_for_distance = rental["distance"].to_i * car_detail["price_per_km"].to_i
    total_price = price_for_day_discount + price_for_distance
    obj["id"] = rental["id"]
    obj["price"] = total_price.to_i
    rentals << obj  
  end
  data_response["rentals"] = rentals
  File.write("./data/output.json", JSON.pretty_generate(data_response))
end

main
