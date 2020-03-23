require 'json'
require 'date'
require 'pry'

def main
  rentals = []
  data_response = {}
  file = File.read("./data/input.json")
  data_hash = JSON.parse(file)
  data_cars = data_hash["cars"]
  data_rentals = data_hash["rentals"]
  data_options = data_hash["options"]
  data_rentals.each do |rental|
    obj = {}
    actions = []
    start_date = Date.strptime(rental["start_date"])
    end_date =  Date.strptime(rental["end_date"])
    rental_period = (end_date - start_date).to_i + 1
    car_detail = data_cars.find{|car| car["id"] == rental["car_id"]}
    options = data_options.select{|option| option["rental_id"] == rental["id"]}.reduce([]){|arr, i| arr << i["type"]}
    price_option = summary_option_price(options, rental_period)
    price_for_one_day  = (car_detail["price_per_day"]).to_i
    price_for_day_discount = (2..4).include?(rental_period) ? price_for_one_day + price_for_one_day*(rental_period - 1) * 0.9 \
                            : (5..10).include?(rental_period) ? price_for_one_day + price_for_one_day*(2..4).count*0.9 + price_for_one_day*(rental_period - (2..4).count - 1 )*0.7 \
                            : rental_period > 10 ? price_for_one_day + price_for_one_day*(2..4).count*0.9 + price_for_one_day*(5..10).count*0.7 +  price_for_one_day*(rental_period - (2..4).count - (5..10).count - 1 )*0.5 \
                            : price_for_one_day
    price_for_distance = rental["distance"].to_i * car_detail["price_per_km"].to_i
    total_price_origin = price_for_day_discount + price_for_distance 
    total_price_extend = options.empty? ? total_price_origin : total_price_origin.to_i + price_option.to_i
    owner_fee = (options.include?("gps") || options.include?("baby_seat")) ? (total_price_origin*0.7 + price_option).to_i : (total_price_origin*0.7).to_i
    insurance_fee = (total_price_origin*0.3*0.5).to_i
    assistance_fee = (rental_period*100).to_i
    drivy_fee = options.include?("additional_insurance") ? (total_price_origin*0.3 - total_price_origin*0.3*0.5 - assistance_fee).to_i + price_option : (total_price_origin*0.3 - total_price_origin*0.3*0.5 - assistance_fee).to_i
    actions << fill_data_action("driver", "debit", total_price_extend.to_i) << fill_data_action("owner", "credit", owner_fee) << fill_data_action("insurance", "credit", insurance_fee) << fill_data_action("assistance", "credit", assistance_fee) << fill_data_action("drivy", "credit", drivy_fee)
    obj["id"] = rental["id"]
    obj["options"] = options
    obj["actions"] = actions
    rentals << obj  
  end
  data_response["rentals"] = rentals
  File.write("./data/output.json", JSON.pretty_generate(data_response))
end

def fill_data_action(who, type, amount)
  action = {}
  action["who"] = who
  action["type"] = type
  action["amount"] = amount
  action
end

def summary_option_price(options, day)
  result = 0
  options.each do |option|
    if option == "gps"
      result += 500*day
    elsif option == "baby_seat"
      result += 200*day
    elsif option == "additional_insurance"
      result += 1000*day
    else
      result += 0
    end
  end
  result
end

main