// mongo-init/init.js

db = db.getSiblingDB('SimCard'); // create/use the database

db.createCollection('SimCards');
db.createCollection('Payments');
db.createCollection('Expenses');
db.createCollection('BalanceRecords');

