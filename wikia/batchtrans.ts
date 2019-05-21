/*
批量翻译

在同目录下
npm i axios typescript ts-node
npx ts-node batchtrans.ts

*/
import axios from "axios";
const fs = require("fs") as typeof import("fs");

async function getTable() {
    let url = `https://warframe.huijiwiki.com/index.php?title=UserDict&action=raw`;
    let res = await axios.get(url)
    return res.data.Text
}

const list = fs.readFileSync("enlist.txt").toString().split(/[\r\n]+/g).filter(Boolean);

function escapeJS(src: string) {
    let dst = JSON.stringify(src)
    return dst.substr(1, dst.length - 2)
}

(async () => {
    let table = await getTable()
    let output = []
    for (let i = 0; i < list.length; i++) {
        const name = list[i];
        const cnTitle = table[name] || name;
        const cnName = cnTitle.replace(/[]/g);
        output.push(`\\[\\[(${name}|${cnName})(?:\\|[^\\]]+?)?\\]\\]`)
        output.push(`{{A|${name}}}`)
    }
    fs.writeFileSync("cnlist.txt", output.join("\n"))
})().then(() => { })