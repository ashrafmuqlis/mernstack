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
sudo mkdir server
cd server
sudo npm init -y
sudo npm install mongodb express cors dotenv

echo "Creating server.js file"
sudo echo "
const express = require(\"express\");
const app = express();
const cors = require(\"cors\");
require("dotenv").config({ path: \"./config.env\" });
const port = process.env.PORT || 5000;
app.use(cors());
app.use(express.json());
app.use(require(\"./routes/record\"));
// get driver connection
const dbo = require(\"./db/conn\");
 
app.listen(port, () => {
  // perform a database connection when server starts
  dbo.connectToServer(function (err) {
    if (err) console.error(err);
 
  });
  console.log(\`Server is running on port: \${port}\`);
});" > server.js

echo "Creating config.env file (MongoDB)"
sudo echo "
MONGODB_LOCAL=mongodb://localhost:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.6.2
PORT=5000" > config.env

echo "Creating conn.js file (MongoDB Connection)"
sudo mkdir db
sudo touch db/conn.js
sudo echo "
const { MongoClient } = require(\"mongodb\");
const Db = process.env.MONGODB_LOCAL;
const client = new MongoClient(Db, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
 
var _db;
 
module.exports = {
  connectToServer: function (callback) {
    client.connect(function (err, db) {
      // Verify we got a good \"db\" object
      if (db)
      {
        _db = db.db(\"employees\");
        console.log(\"Successfully connected to MongoDB.\"); 
      }
      return callback(err);
         });
  },
 
  getDb: function () {
    return _db;
  },
};" > db/conn.js

echo "Creating Server API Endpoints"
sudo mkdir routes
touch routes/record.js
sudo echo "
const express = require(\"express\");
 
// recordRoutes is an instance of the express router.
// We use it to define our routes.
// The router will be added as a middleware and will take control of requests starting with path /record.
const recordRoutes = express.Router();
 
// This will help us connect to the database
const dbo = require(\"../db/conn\");
 
// This help convert the id from string to ObjectId for the _id.
const ObjectId = require(\"mongodb\").ObjectId;
 
 
// This section will help you get a list of all the records.
recordRoutes.route(\"/record\").get(function (req, res) {
 let db_connect = dbo.getDb(\"employees\");
 db_connect
   .collection(\"records\")
   .find({})
   .toArray(function (err, result) {
     if (err) throw err;
     res.json(result);
   });
});
 
// This section will help you get a single record by id
recordRoutes.route(\"/record/:id\").get(function (req, res) {
 let db_connect = dbo.getDb();
 let myquery = { _id: ObjectId(req.params.id) };
 db_connect
   .collection(\"records\")
   .findOne(myquery, function (err, result) {
     if (err) throw err;
     res.json(result);
   });
});
 
// This section will help you create a new record.
recordRoutes.route(\"/record/add\").post(function (req, response) {
 let db_connect = dbo.getDb();
 let myobj = {
   name: req.body.name,
   position: req.body.position,
   level: req.body.level,
 };
 db_connect.collection(\"records\").insertOne(myobj, function (err, res) {
   if (err) throw err;
   response.json(res);
 });
});
 
// This section will help you update a record by id.
recordRoutes.route(\"/update/:id\").post(function (req, response) {
 let db_connect = dbo.getDb();
 let myquery = { _id: ObjectId(req.params.id) };
 let newvalues = {
   $set: {
     name: req.body.name,
     position: req.body.position,
     level: req.body.level,
   },
 };
 db_connect
   .collection(\"records\")
   .updateOne(myquery, newvalues, function (err, res) {
     if (err) throw err;
     console.log(\"1 document updated\");
     response.json(res);
   });
});
 
// This section will help you delete a record
recordRoutes.route(\"/:id\").delete((req, response) => {
 let db_connect = dbo.getDb();
 let myquery = { _id: ObjectId(req.params.id) };
 db_connect.collection("records").deleteOne(myquery, function (err, obj) {
   if (err) throw err;
   console.log("1 document deleted");
   response.json(obj);
 });
});
 
module.exports = recordRoutes;" > routes/record.js

sudo node server.js

