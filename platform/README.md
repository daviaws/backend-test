# Platform

---

## Dependencies
* docker == 19.03.6
* docker-compose == 1.29.2
* IEx == 1.11.2 (asdf manager recommended)
* Erlang/OTP == 23

---

## Build
To build the project:
  * Give permission to build script `chmod +x script/build`
  * Run the build script to setup docker `script/build`

---

## Run on Docker
To run everything on Docker:
  * Run `docker-compose up -d`

---

## Run local Phoenix
To start your Phoenix server locally:
  * Add to `/etc/hosts` the alias to local host `127.0.0.1    db`
  * Run the database docker `docker-compose up -d postgres`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

---

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
