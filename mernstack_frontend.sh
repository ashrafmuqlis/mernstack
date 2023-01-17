echo "Setting up React Frontend"
cd MERN/client
sudo npm install bootstrap react-router-dom

echo "Creating index.js"
sudo rm -r src/
sudo mkdir src/
sudo echo "
import React from \"react\";
import ReactDOM from \"react-dom\";
import App from \"./App\";
import { BrowserRouter } from \"react-router-dom\";

ReactDOM.render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
  document.getElementById(\"root\")
);" > src/index.js

echo "Creating Components - create.js"
sudo mkdir src/components
sudo echo "
import React, { useState } from \"react\";
import { useNavigate } from \"react-router\";
 
export default function Create() {
 const [form, setForm] = useState({
   name: \"\",
   position: \"\",
   level: \"\",
 });
 const navigate = useNavigate();
 
 // These methods will update the state properties.
 function updateForm(value) {
   return setForm((prev) => {
     return { ...prev, ...value };
   });
 }
 
 // This function will handle the submission.
 async function onSubmit(e) {
   e.preventDefault();
 
   // When a post request is sent to the create url, we'll add a new record to the database.
   const newPerson = { ...form };
 
   await fetch(\"http://localhost:5000/record/add\", {
     method: \"POST\",
     headers: {
       \"Content-Type\": \"application/json\",
     },
     body: JSON.stringify(newPerson),
   })
   .catch(error => {
     window.alert(error);
     return;
   });
 
   setForm({ name: \"\", position: \"\", level: \"\" });
   navigate(\"/\");
 }
 
 // This following section will display the form that takes the input from the user.
 return (
   <div>
     <h3>Create New Record</h3>
     <form onSubmit={onSubmit}>
       <div className=\"form-group\">
         <label htmlFor=\"name\">Name</label>
         <input
           type=\"text\"
           className=\"form-control\"
           id=\"name\"
           value={form.name}
           onChange={(e) => updateForm({ name: e.target.value })}
         />
       </div>
       <div className=\"form-group\">
         <label htmlFor=\"position\">Position</label>
         <input
           type=\"text\"
           className=\"form-control\"
           id=\"position\"
           value={form.position}
           onChange={(e) => updateForm({ position: e.target.value })}
         />
       </div>
       <div className=\"form-group\">
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionIntern\"
             value=\"Intern\"
             checked={form.level === \"Intern\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionIntern\" className=\"form-check-label\">Intern</label>
         </div>
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionJunior\"
             value=\"Junior\"
             checked={form.level === \"Junior\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionJunior\" className=\"form-check-label\">Junior</label>
         </div>
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionSenior\"
             value=\"Senior\"
             checked={form.level === \"Senior\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionSenior\" className=\"form-check-label\">Senior</label>
         </div>
       </div>
       <div className=\"form-group\">
         <input
           type=\"submit\"
           value=\"Create person\"
           className=\"btn btn-primary\"
         />
       </div>
     </form>
   </div>
 );
}" > src/components/create.js

echo "Creating Components - edit.js"
sudo echo "
import React, { useState, useEffect } from \"react\";
import { useParams, useNavigate } from \"react-router\";
 
export default function Edit() {
 const [form, setForm] = useState({
   name: \"\",
   position: \"\",
   level: \"\",
   records: [],
 });
 const params = useParams();
 const navigate = useNavigate();
 
 useEffect(() => {
   async function fetchData() {
     const id = params.id.toString();
     const response = await fetch(\`http://localhost:5000/record/\${params.id.toString()}\`);
 
     if (!response.ok) {
       const message = \`An error has occurred: \${response.statusText}\`;
       window.alert(message);
       return;
     }
 
     const record = await response.json();
     if (!record) {
       window.alert(`Record with id \${id} not found`);
       navigate(\"/\");
       return;
     }
 
     setForm(record);
   }
 
   fetchData();
 
   return;
 }, [params.id, navigate]);
 
 // These methods will update the state properties.
 function updateForm(value) {
   return setForm((prev) => {
     return { ...prev, ...value };
   });
 }
 
 async function onSubmit(e) {
   e.preventDefault();
   const editedPerson = {
     name: form.name,
     position: form.position,
     level: form.level,
   };
 
   // This will send a post request to update the data in the database.
   await fetch(\`http://localhost:5000/update/\${params.id}\`, {
     method: \"POST\",
     body: JSON.stringify(editedPerson),
     headers: {
       \'Content-Type\': \'application/json\'
     },
   });
 
   navigate(\"/\");
 }
 
 // This following section will display the form that takes input from the user to update the data.
 return (
   <div>
     <h3>Update Record</h3>
     <form onSubmit={onSubmit}>
       <div className=\"form-group\">
         <label htmlFor=\"name\">Name: </label>
         <input
           type=\"text\"
           className=\"form-control\"
           id=\"name\"
           value={form.name}
           onChange={(e) => updateForm({ name: e.target.value })}
         />
       </div>
       <div className=\"form-group\">
         <label htmlFor=\"position\">Position: </label>
         <input
           type=\"text\"
           className=\"form-control\"
           id=\"position\"
           value={form.position}
           onChange={(e) => updateForm({ position: e.target.value })}
         />
       </div>
       <div className=\"form-group\">
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionIntern\"
             value=\"Intern\"
             checked={form.level === \"Intern\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionIntern\" className=\"form-check-label\">Intern</label>
         </div>
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionJunior\"
             value=\"Junior\"
             checked={form.level === \"Junior\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionJunior\" className=\"form-check-label\">Junior</label>
         </div>
         <div className=\"form-check form-check-inline\">
           <input
             className=\"form-check-input\"
             type=\"radio\"
             name=\"positionOptions\"
             id=\"positionSenior\"
             value=\"Senior\"
             checked={form.level === \"Senior\"}
             onChange={(e) => updateForm({ level: e.target.value })}
           />
           <label htmlFor=\"positionSenior\" className=\"form-check-label\">Senior</label>
       </div>
       </div>
       <br />
 
       <div className=\"form-group\">
         <input
           type=\"submit\"
           value=\"Update Record\"
           className=\"btn btn-primary\"
         />
       </div>
     </form>
   </div>
 );
}" > src/components/edit.js

echo "Creating Components - RecordList.js"
sudo echo "
import React, { useEffect, useState } from \"react\";
import { Link } from \"react-router-dom\";
 
const Record = (props) => (
 <tr>
   <td>{props.record.name}</td>
   <td>{props.record.position}</td>
   <td>{props.record.level}</td>
   <td>
     <Link className=\"btn btn-link\" to={\`/edit/\${props.record._id}\`}>Edit</Link> |
     <button className=\"btn btn-link\"
       onClick={() => {
         props.deleteRecord(props.record._id);
       }}
     >
       Delete
     </button>
   </td>
 </tr>
);
 
export default function RecordList() {
 const [records, setRecords] = useState([]);
 
 // This method fetches the records from the database.
 useEffect(() => {
   async function getRecords() {
     const response = await fetch(\`http://localhost:5000/record/\`);
 
     if (!response.ok) {
       const message = \`An error occurred: \${response.statusText}\`;
       window.alert(message);
       return;
     }
 
     const records = await response.json();
     setRecords(records);
   }
 
   getRecords();
 
   return;
 }, [records.length]);
 
 // This method will delete a record
 async function deleteRecord(id) {
   await fetch(\`http://localhost:5000/\${id}\`, {
     method: \"DELETE\"
   });
 
   const newRecords = records.filter((el) => el._id !== id);
   setRecords(newRecords);
 }
 
 // This method will map out the records on the table
 function recordList() {
   return records.map((record) => {
     return (
       <Record
         record={record}
         deleteRecord={() => deleteRecord(record._id)}
         key={record._id}
       />
     );
   });
 }
 
 // This following section will display the table with the records of individuals.
 return (
   <div>
     <h3>Record List</h3>
     <table className=\"table table-striped\" style={{ marginTop: 20 }}>
       <thead>
         <tr>
           <th>Name</th>
           <th>Position</th>
           <th>Level</th>
           <th>Action</th>
         </tr>
       </thead>
       <tbody>{recordList()}</tbody>
     </table>
   </div>
 );
}" > src/components/recordList.js

echo "Creating Components - navbar.js"
sudo echo "
import React from \"react\";
 
// We import bootstrap to make our application look better.
import \"bootstrap/dist/css/bootstrap.css\";
 
// We import NavLink to utilize the react router.
import { NavLink } from \"react-router-dom\";
 
// Here, we display our Navbar
export default function Navbar() {
 return (
   <div>
     <nav className=\"navbar navbar-expand-lg navbar-light bg-light\">
       <NavLink className=\"navbar-brand\" to=\"/\">
       <img style={{\"width\" : 25 + '%'}} src=\"https://d3cy9zhslanhfa.cloudfront.net/media/3800C044-6298-4575-A05D5C6B7623EE37/4B45D0EC-3482-4759-82DA37D8EA07D229/webimage-8A27671A-8A53-45DC-89D7BF8537F15A0D.png\" alt=\"navbar img\"></img>
       </NavLink>
       <button
         className=\"navbar-toggler\"
         type=\"button\"
         data-toggle=\"collapse\"
         data-target=\"#navbarSupportedContent\"
         aria-controls=\"navbarSupportedContent\"
         aria-expanded=\"false\"
         aria-label=\"Toggle navigation\"
       >
         <span className=\"navbar-toggler-icon\"></span>
       </button>
 
       <div className=\"collapse navbar-collapse\" id=\"navbarSupportedContent\">
         <ul className=\"navbar-nav ml-auto\">
           <li className=\"nav-item\">
             <NavLink className=\"nav-link\" to=\"/create\">
               Create Record
             </NavLink>
           </li>
         </ul>
       </div>
     </nav>
   </div>
 );
}" > src/components/navbar.js

echo "Creating Apps.js"
sudo echo "
import React from \"react\";
 
// We use Route in order to define the different routes of our application
import { Route, Routes } from \"react-router-dom\";
 
// We import all the components we need in our app
import Navbar from \"./components/navbar\";
import RecordList from \"./components/recordList\";
import Edit from \"./components/edit\";
import Create from \"./components/create\";
 
const App = () => {
 return (
   <div>
     <Navbar />
     <Routes>
       <Route exact path=\"/\" element={<RecordList />} />
       <Route path=\"/edit/:id\" element={<Edit />} />
       <Route path=\"/create\" element={<Create />} />
     </Routes>
   </div>
 );
};
 
export default App;" > src/App.js

echo "Starting React Frontend"
sudo npm start
