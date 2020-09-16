conn = new Mongo("127.0.0.1:PORT");
db = conn.getDB("admin");
printjson(db.createUser({user:"root",pwd:"YiZhu2018everybim!",roles:[{role:"root",db:"admin"}]}));
