const express = require("express");
const cors = require("cors");
require("dotenv").config();
const env = require("./env");

const app = express();

//Use CORS middleware
app.use(cors());

app.use(express.urlencoded({extended: false}));

app.use(express.json());

//connect the server to listen on port
app.listen(env.PORT).on("listening", (err) => {
    if(!err){
        console.log(`Hurray, 😊  App is listening on ${env.PORT}`);
    }
})