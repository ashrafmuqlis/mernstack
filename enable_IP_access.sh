#!bin/bash

file1="127.0.0.1"
file2=`hostname -I | xargs`

echo $file1, $file2

echo "sudo sed -ie '21 s/"$file1/$file1, $file2"/' /etc/mongod.conf" > mongo_script.sh

sudo bash ./mongo_script.sh

sudo systemctl restart mongod.service

echo "sudo sed -i 's/localhost/"$file2"/' MERN/server/config.env" > mongo_script.sh

sudo bash ./mongo_script.sh

echo "sudo sed -i 's/localhost/"$file2"/' MERN/client/src/components/create.js" > mongo_script.sh

sudo bash ./mongo_script.sh

echo "sudo sed -i 's/localhost/"$file2"/' MERN/client/src/components/edit.js" > mongo_script.sh

sudo bash ./mongo_script.sh

echo "sudo sed -i 's/localhost/"$file2"/' MERN/client/src/components/recordList.js" > mongo_script.sh

sudo bash ./mongo_script.sh
