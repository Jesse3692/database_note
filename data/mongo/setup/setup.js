db = db.getSiblingDB('newDB'); // 创建一个DB

db.createUser( // 创建一个用户并赋予权限
    {
        user: "jesse",
        pwd: "qweasd123",
        roles: [
            { role: "dbOwner", db: "newDB"}
        ]
    }
);

db.createCollection("newCollention"); // newDB中创建一个Collection