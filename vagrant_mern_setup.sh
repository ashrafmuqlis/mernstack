#!/bin/bash

echo "Setting Up VM for Vagrant Box"
sudo apt update

echo "Configuring SSH for Vagrant VM"
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > ~/.ssh/authorized_keys

sudo chmod 0700 ~/.ssh/ && chmod 0600 ~/.ssh/authorized_keys

sudo sed -ie '$a UseDNS no' /etc/ssh/sshd_config

echo "Configuring Vagrant User Privileges"
sudo sed -i '45 s/ */vagrant ALL=(ALL) NOPASSWD:ALL \n/' /etc/sudoers

echo "Configuring Root Password"
sudo passwd root

echo "Installing MongoDB 6"
sudo wget -q -O - https://www.mongodb.org/static/pgp/server-6.0.pub | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod.service
sudo systemctl status mongod
sudo systemctl enable mongod

echo "Installing Node JS 19"
sudo curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

sudo mkdir MERN
cd MERN

echo "Creating React Client (Frontend) Environtment"
sudo npx create-react-app client

echo "Creating React Server (Backend) Environtment"
mkdir server
cd server
sudo npm init -y
sudo npm install mongodb express cors dotenv

echo "Creating server.js file"
sudo echo -e "const express = require("express");\n
const app = express();\n
const cors = require("cors");\n
require("dotenv").config({ path: "./config.env" });\n
const port = process.env.PORT || 5000;\n
app.use(cors());\n
app.use(express.json());\n
app.use(require("./routes/record"));\n
// get driver connection\n
const dbo = require("./db/conn");\n
 \n
app.listen(port, () => {\n
  // perform a database connection when server starts\n
  dbo.connectToServer(function (err) {\n
    if (err) console.error(err);\n
 \n
  });\n
  console.log(`Server is running on port: ${port}`);\n
});" > server.js
