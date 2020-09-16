conn = new Mongo("192.168.148.133:37017");
db = conn.getDB("admin");
printjson(db.createUser({user:"root",pwd:"YiZhu2018everybim!",roles:[{role:"root",db:"admin"}]}));
printjson(db.createUser({user:"everybim",pwd:"YiZhu2018everybim!",roles:[{role:"readWriteAnyDatabase",db:"admin"}]}));
printjson(db.getUsers());
printjson(db.getSiblingDB("sessiondb").createUser({user:"everybim",pwd:"YiZhu2018everybim!",roles:[{role: "readWrite",db:"sessiondb"}]}));
printjson(db.getSiblingDB("sessiondb").getUsers());
printjson(db.getSiblingDB("modeldb").createUser({user:"everybim",pwd:"YiZhu2018everybim!",roles:[{role: "readWrite",db:"modeldb"}]}));
printjson(db.getSiblingDB("modeldb").getUsers());