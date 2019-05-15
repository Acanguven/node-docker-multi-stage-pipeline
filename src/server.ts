import express from "express";
import {calculator} from "./index";

const app = express();

app.get('/', (req, res) => {
    calculator(res, 20);
    res.end();
});

app.listen(4444, () => {
    console.log('Application listening on port 4444');
});
