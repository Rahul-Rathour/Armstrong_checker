require 'sinatra'
require 'json'
require 'mongo'
require 'dotenv/load'
require 'digest'

include Mongo

# ===================== Enable Cross-Origin Requests =======================
before do
  content_type :json
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Accept, Authorization, Token'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  puts "CORS Headers Set: #{response.headers}" # Debugging
end

options "*" do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Accept, Authorization, Token'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  puts "OPTIONS Request Handled for #{request.path}" # Debugging
  200
end

# ===================== Connect to MongoDB =======================
client = Mongo::Client.new(ENV['MONGODB_URI'], database: 'armstrong_app')
users_collection = client[:users]
numbers_collection = client[:numbers]

# ===================== Password Hashing Function =======================
def hash_password(password)
  Digest::SHA256.hexdigest(password)
end

# ===================== Armstrong Number Checker =======================
def armstrong?(num)
  num_str = num.to_s
  len = num_str.length
  sum = 0

  for i in 0...len
    digit = num_str[i].to_i
    sum += digit ** len
  end

  sum == num
end

# ===================== 1. Register User =======================
post '/register' do
  begin
    data = JSON.parse(request.body.read)
    email = data["email"]
    password = data["password"]

    puts "Processing /register for email: #{email}" # Debugging

    if email.nil? || password.nil?
      status 400
      return { error: "Email and password are required." }.to_json
    end

    existing = users_collection.find({ email: email }).first
    if existing
      status 409
      return { error: "User already exists." }.to_json
    end

    users_collection.insert_one({
      email: email,
      password: hash_password(password)
    })

    { message: "User registered successfully!" }.to_json
  rescue JSON::ParserError => e
    puts "JSON Parse Error: #{e.message}" # Debugging
    status 400
    { error: "Invalid JSON payload" }.to_json
  rescue StandardError => e
    puts "Server Error: #{e.message}" # Debugging
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end

# ===================== 2. Login User =======================
post '/login' do
  begin
    data = JSON.parse(request.body.read)
    email = data["email"]
    password = data["password"]

    puts "Processing /login for email: #{email}" # Debugging

    if email.nil? || password.nil?
      status 400
      return { error: "Email and password are required." }.to_json
    end

    user = users_collection.find({ email: email, password: hash_password(password) }).first

    if user
      { message: "Login successful", email: email }.to_json
    else
      status 401
      { error: "Invalid credentials" }.to_json
    end
  rescue JSON::ParserError => e
    puts "JSON Parse Error: #{e.message}" # Debugging
    status 400
    { error: "Invalid JSON payload" }.to_json
  rescue StandardError => e
    puts "Server Error: #{e.message}" # Debugging
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end

# ===================== 3. Submit Armstrong Number =======================
post '/submit' do
  begin
    data = JSON.parse(request.body.read)
    email = data["email"]
    number = data["number"]

    puts "Processing /submit for email: #{email}, number: #{number}" # Debugging

    if email.nil? || number.nil?
      status 400
      return { error: "Email and number are required." }.to_json
    end

    user = users_collection.find({ email: email }).first

    if user.nil?
      status 401
      return { error: "User not found." }.to_json
    end

    is_armstrong = armstrong?(number)

    unless is_armstrong
      return { message: "Given number is not an Armstrong number..." }.to_json
    end

    numbers_collection.insert_one({
      number: number,
      armstrong: is_armstrong,
      user_id: user[:_id],
      timestamp: Time.now
    })

    {
      number: number,
      armstrong: is_armstrong,
      message: "Stored successfully!"
    }.to_json
  rescue JSON::ParserError => e
    puts "JSON Parse Error: #{e.message}" # Debugging
    status 400
    { error: "Invalid JSON payload" }.to_json
  rescue StandardError => e
    puts "Server Error: #{e.message}" # Debugging
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end

# ===================== 4. Get Armstrong Numbers for Specific User =======================
post '/my_numbers' do
  begin
    data = JSON.parse(request.body.read)
    email = data["email"]

    puts "Processing /my_numbers for email: #{email}" # Debugging

    if email.nil? || email.empty?
      status 400
      return { error: "Email is required." }.to_json
    end

    user = users_collection.find({ email: email }).first

    if user.nil?
      status 404
      return { error: "User not found." }.to_json
    end

    numbers = numbers_collection.find({ user_id: user[:_id] }).map do |doc|
      {
        number: doc[:number],
        armstrong: doc[:armstrong],
        submitted_at: doc[:timestamp]
      }
    end

    { user: email, outputs: numbers }.to_json
  rescue JSON::ParserError => e
    puts "JSON Parse Error: #{e.message}" # Debugging
    status 400
    { error: "Invalid JSON payload" }.to_json
  rescue StandardError => e
    puts "Server Error: #{e.message}" # Debugging
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end

# ===================== 5. Get Global Armstrong Numbers (From All Users) =======================
get '/global_numbers' do
  begin
    puts "Processing /global_numbers" # Debugging
    all_numbers = numbers_collection.find.map do |doc|
      user = users_collection.find({ _id: doc[:user_id] }).first
      {
        number: doc[:number],
        armstrong: doc[:armstrong],
        submitted_at: doc[:timestamp],
        user_email: user ? user[:email] : "Unknown"
      }
    end

    { global_submissions: all_numbers }.to_json
  rescue StandardError => e
    puts "Server Error: #{e.message}" # Debugging
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end

# ===================== Server Configuration =======================
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'
