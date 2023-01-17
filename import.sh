echo "Creating server.js file"
sudo echo "
const express = require(\"express\");
const app = express();
const cors = require(\"cors\");
require(\"dotenv\").config({ path: \"./config.env\" });
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
sudo echo "
const express = require(\"express\");
 
// recordRoutes is an instance of the express router.
// We use it to define our routes.
// The router will be added as a middleware and will take control of requests starting with path \/record.
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
   console.log(\"1 document deleted\");
   response.json(obj);
 });
});
 
module.exports = recordRoutes;" > routes/record.js

sudo node server.js
