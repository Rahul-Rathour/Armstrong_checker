# 📘 Armstrong Number App

A simple full-stack application to:
- Register/Login users
- Submit numbers to check if they are Armstrong numbers
- View submitted numbers (personal + global)

---

## 🧠 Tech Stack

- **Frontend:** React + Tailwind CSS
- **Backend:** Ruby (Sinatra) + MongoDB
- **Database:** MongoDB (Local)

---

## 📦 Requirements

Before starting, make sure you have:

- [Node.js](https://nodejs.org/) installed  
- [Ruby](https://www.ruby-lang.org/) installed  
- [MongoDB](https://www.mongodb.com/) installed and running locally on `mongodb://127.0.0.1:27017`

---

##  Installation & Running

### 1️Clone the repository

```bash
git clone https://github.com/Rahul-Rathour/Armstrong_checker.git
cd armstrong-app
```

---

### 2️⃣ Backend Setup

```bash
cd backend
bundle install   # Install Ruby gems
ruby app.rb      # Start the Sinatra server at http://localhost:4567
```

>  Make sure MongoDB is running in the background.

---

### 3️⃣ Frontend Setup

Open a new terminal window:

```bash
cd frontend
npm install       # Install dependencies
npm start         # Run frontend at http://localhost:3000
```

---

## 🔗 Available Routes

### Auth
- `POST /register` — Register a new user
- `POST /login` — Login with email/password

### Submit
- `POST /submit` — Submit number for checking Armstrong

### View
- `POST /my_numbers` — View your own submitted numbers
- `GET /global_numbers` — View all submitted numbers with user emails

---

## Usage

- Go to `http://localhost:3000`
- Register/Login
- Submit numbers
- View your submissions or global submissions

---

## Folder Structure

```
armstrong-app/
│
├── backend/         # Ruby Sinatra backend
│   ├── app.rb
│   └── ...
│
├── frontend/        # React frontend
│   ├── src/
│   └── ...
│
└── README.md
```
