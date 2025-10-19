# README

Realbid 🚀

Realbid is a live auction web application that allows users to buy and sell products in real-time. Users can place bids,
sell products to the highest bidder, manage their accounts, and make payments securely.




https://github.com/user-attachments/assets/91c8db2f-9321-40cb-baec-357048b6ead2


🌟 Features

User Authentication: signup, login, logout

Product Management: create, edit, and delete products

Live Bidding: place bids on products in real-time

Sell to Highest Bidder: automatic assignment of the product to the highest bidder

Search & Pagination: easily browse products

Account Management: delete account, update profile

Image Upload: upload product images and profile pictures using AWS S3

Payments: securely pay for products using Stripe

Dockerized: ready for development environment

🛠 Tech Stack

Backend: Ruby on Rails 8

Frontend: Hotwire (Turbo + Stimulus)

Database: Postgres

File Storage: AWS S3

Payments: Stripe

Real-time Features: Turbo Streams for live updates

⚙️ Setup Instructions

    Clone the repository:
    git clone https://github.com/yourusername/realbid.git
    cd realbid

Install dependencies:

    bundle install
    yarn install

Set up the database:

    rails db:create db:migrate db:seed

Run the Rails server:

    rails server

Build the development Docker image:

    docker-compose -f docker-compose.dev.yml build

Start the development environment:

    docker-compose -f docker-compose.dev.yml up

Run database migrations:

    docker-compose -f docker-compose.dev.yml run web rails db:create db:migrate db:seed

Open http://localhost:3000
in your browser.

📄 License

This project is licensed under the [Apache 2.0 License](LICENSE).

🔗 Live Demo
https://realbid-67ta.onrender.com
