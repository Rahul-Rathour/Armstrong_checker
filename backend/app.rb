# Load necessary libraries
require 'sinatra'                # Sinatra framework for web routes
require 'sinatra/cross_origin'  # To handle cross-origin requests (CORS)
require 'json'                  # To work with JSON data
require 'mongo'                 # MongoDB client
require 'digest'                # For hashing passwords

include Mongo

# ===================== Enable Cross-Origin Requests =======================
configure do
  enable :cross_origin  # Allow other apps (like frontend) to talk to this backend
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Origin, Content-Type, Accept, Authorization, Token"
  200
end

# =====================  Connect to MongoDB =======================
client = Mongo::Client.new(['127.0.0.1:27017'], database: 'armstrong_db')
users_collection = client[:users]          # Collection to store user data
numbers_collection = client[:numbers]      # Collection to store number submissions

# =====================  Set Response Type =======================
before do
  content_type :json  # All responses will be JSON format
end

# ===================== Password Hashing Function =======================
def hash_password(password)
  Digest::SHA256.hexdigest(password)  # Hash the password securely
end

# ===================== Armstrong Number Checker =======================
def armstrong?(num)
  num_str = num.to_s         # Convert number to string
  len = num_str.length       # Get number of digits
  sum = 0

  # Loop through each digit, raise it to the power of length and add to sum
  for i in 0...len
    digit = num_str[i].to_i
    sum += digit ** len
  end

  return sum == num  # If sum equals original number → it's Armstrong
end

# ===================== 1. Register User =======================
post '/register' do
  data = JSON.parse(request.body.read)
  email = data["email"]
  password = data["password"]

  if email.nil? || password.nil?
    status 400
    return { error: "Email and password are required." }.to_json
  end

  # Check if user already exists
  existing = users_collection.find({ email: email }).first
  if existing
    status 409
    return { error: "User already exists." }.to_json
  end

  # Save new user with hashed password
  users_collection.insert_one({
    email: email,
    password: hash_password(password)
  })

  { message: "User registered successfully!" }.to_json
end

# ===================== 2. Login User =======================
post '/login' do
  data = JSON.parse(request.body.read)
  email = data["email"]
  password = data["password"]

  if email.nil? || password.nil?
    status 400
    return { error: "Email and password are required." }.to_json
  end

  # Find user with matching email & hashed password
  user = users_collection.find({ email: email, password: hash_password(password) }).first

  if user
    { message: "Login successful", email: email }.to_json
  else
    status 401
    { error: "Invalid credentials" }.to_json
  end
end

# ===================== 3. Submit Armstrong Number =======================
post '/submit' do
  data = JSON.parse(request.body.read)
  email = data["email"]
  number = data["number"]

  if email.nil? || number.nil?
    status 400
    return { error: "Email and number are required." }.to_json
  end

  # Check if user exists
  user = users_collection.find({ email: email }).first

  if user.nil?
    status 401
    return { error: "User not found." }.to_json
  end

  # Check if number is Armstrong
  is_armstrong = armstrong?(number)

  if (!is_armstrong)
    return {message: "Given number is not armstrong number..."}.to_json
  end

  # Save number with user_id and timestamp
  numbers_collection.insert_one({
    number: number,
    armstrong: is_armstrong,
    user_id: user[:_id], 
    timestamp: Time.now
  })

  return {
    number: number,
    armstrong: is_armstrong,
    message: "Stored successfully!"
  }.to_json
end

# ===================== 4. Get Armstrong Numbers for Specific User =======================
post '/my_numbers' do
  data = JSON.parse(request.body.read)
  email = data["email"]

  if email.nil? || email.empty?
    status 400
    return { error: "Email is required." }.to_json
  end

  user = users_collection.find({ email: email }).first

  if user.nil?
    status 404
    return { error: "User not found." }.to_json
  end

  # Find all numbers submitted by the user
  numbers = numbers_collection.find({ user_id: user[:_id] }).map do |doc|
    {
      number: doc[:number],
      armstrong: doc[:armstrong],
      submitted_at: doc[:timestamp]
    }
  end

  { user: email, outputs: numbers }.to_json
end

# ===================== 5. Get Global Armstrong Numbers (From All Users) =======================
get '/global_numbers' do
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
end
