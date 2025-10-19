# db/seeds.rb
# Populates database with demo data for testing and development

require "open-uri"

puts "🌱 Seeding database..."

# === Clear existing data ===
Order.destroy_all
Bid.destroy_all
Product.destroy_all
User.destroy_all

puts "🧹 Old records cleared!"

# === Users ===
users_data = [
  {
    name: "Luka Developer",
    email: "luka@example.com",
    password: "password1234",
    profile_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/user2.jpg",
    wallet_balance: 1000,
    address: "742 Evergreen Terrace",
    country: "United States",
    postal_code: "90001",
    phone_number: "+1-310-555-0147",
    city: "Los Angeles"
  },
  {
    name: "Jane Buyer",
    email: "jane@example.com",
    password: "password1234",
    wallet_balance: 1000,
    profile_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/user3.png",
    address: "221B Baker Street",
    country: "United States",
    postal_code: "10001",
    phone_number: "+1-646-555-0192",
    city: "New York"
  },
  {
    name: "Mike Seller",
    email: "mike@example.com",
    password: "password1234",
    wallet_balance: 1000,
    profile_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/user1.jpg",
    address: "1600 Pennsylvania Avenue NW",
    country: "United States",
    postal_code: "20500",
    phone_number: "+1-202-555-0100",
    city: "Washington"
  }
]

users = users_data.map do |u|
  user = User.create!(
    name: u[:name],
    email: u[:email],
    password: u[:password],
    address: u[:address],
    country: u[:country],
    postal_code: u[:postal_code],
    phone_number: u[:phone_number],
    city: u[:city],
    wallet_balance: u[:wallet_balance],
  )

  # Attach profile image
  begin
    file = URI.open(u[:profile_image])
    user.profile_image.attach(io: file, filename: "#{u[:name].parameterize}.jpg", content_type: "image/jpeg")
  rescue OpenURI::HTTPError => e
    puts "⚠️ Failed to attach profile image for #{u[:name]}: #{e.message}"
  end

  user
end

puts "👤 Created #{User.count} users."

# === Products ===
products_data = [
  {
    title: "Vintage Watch",
    description: "A classic Swiss-made vintage watch in excellent condition.",
    starting_bid: 120,
    auction_duration: "12_hours",
    product_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/watch.png",
    user: users.find { |u| u.email == "mike@example.com" }
  },
  {
    title: "Gaming Laptop",
    description: "High-end gaming laptop with RTX GPU and 16GB RAM.",
    starting_bid: 800,
    auction_duration: "72_hours",
    product_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/laptop.png",
    user: users.find { |u| u.email == "luka@example.com" }
  },
  {
    title: "Antique Vase",
    description: "A rare hand-painted antique vase from the 19th century.",
    starting_bid: 300,
    auction_duration: "24_hours",
    product_image: "https://realbid-bucket.s3.us-east-1.amazonaws.com/seeds/vase.png",
    user: users.find { |u| u.email == "luka@example.com" }
  }
]

products = products_data.map do |p|
  product = Product.create!(
    title: p[:title],
    description: p[:description],
    starting_bid: p[:starting_bid],
    auction_duration: p[:auction_duration],
    user: p[:user]
  )

  # Attach product image
  begin
    file = URI.open(p[:product_image])
    product.product_image.attach(io: file, filename: "#{p[:title].parameterize}.jpg", content_type: "image/jpeg")
  rescue OpenURI::HTTPError => e
    puts "⚠️ Failed to attach product image for #{p[:title]}: #{e.message}"
  end

  if product.ended?
    product.update!(created_at: Time.current)
  end

  product
end

puts "📦 Created #{Product.count} products."

# === Bids ===
bids_data = [
  {
    amount: 130,
    user: users.find { |u| u.email == "jane@example.com" },
    product: products[0] # Vintage Watch
  },
  {
    amount: 850,
    user: users.find { |u| u.email == "jane@example.com" },
    product: products[1] # Gaming Laptop
  },
  {
    amount: 320,
    user: users.find { |u| u.email == "mike@example.com" },
    product: products[2] # Antique Vase
  }
]

bids_data.each { |b| Bid.create!(b) }

puts "💰 Created #{Bid.count} bids."

puts "✅ Seeding completed successfully!"
