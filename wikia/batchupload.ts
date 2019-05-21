/*
批量搬运图片

在同目录下
npm i axios querystring typescript ts-node dotenv
npx ts-node batchupload.ts

*/
import axios from "axios";
const fs = require("fs") as typeof import("fs");
const qs = require("querystring") as typeof import("querystring");
require("dotenv").config();

// 需要搬运的文件列表 每行一个
const list = fs
  .readFileSync("list.txt")
  .toString()
  .split(/[\r\n]+/g)
  .filter(Boolean);
// 替换成自己的id和session [登录后在F12 -> Application -> Cookie下找]
const userid = process.env.user;
const usersession = process.env.session;

axios.defaults.headers.common["Cookie"] = `huijiUserID=${userid}; huiji_session=${usersession};`;
axios.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";

async function getToken() {
  let url = `https://warframe.huijiwiki.com/api.php?action=query&meta=tokens&format=json`;
  let res = await axios.get(url);
  return res.data.query.tokens.csrftoken;
}
async function getFile(filename: string) {
  let url = `https://warframe.fandom.com/api.php?action=query&titles=File:${filename}&prop=imageinfo&&iiprop=url&format=json`;
  let res = await axios.get(url);
  let page = res.data.query.pages[Object.keys(res.data.query.pages)[0]];
  return page.imageinfo[0].url;
}
async function transferFile(filename: string, fileurl: string, token: string) {
  let url = `https://warframe.huijiwiki.com/api.php`;
  let res = await axios.post(
    url,
    qs.stringify({
      format: "json",
      action: "upload",
      url: fileurl,
      filename,
      comment: `从https://warframe.wikia.com搬运文件：${filename}。(via nodejs)`,
      text: "",
      token
    }),
    { timeout: 5e3 }
  );
  return res.data;
}

async function batchUpload(token: string, filename: string) {
  let fn = await getFile(filename);
  // console.log("filename", fn)
  let rst = await transferFile(filename, fn, token);
  if (rst.upload) return rst.upload.result;
  else if (rst.error) return rst.error.code;
  return JSON.stringify(rst);
}

function delay(ms: number) {
  return new Promise((r, j) => {
    setTimeout(r, ms);
  });
}

function log(...params: any[]) {
  console.log(`[${new Date().toTimeString().substr(0, 8)}]`, ...params);
}

(async () => {
  let token = await getToken();
  log("token", token);
  let workers = [],
    workerid = 0;
  const MAX_WORKERS = 5;
  for (let i = 0; i < list.length; ) {
    const name = list[i];
    let doWork = async (id: number) => {
      while (1) {
        try {
          let rst = await batchUpload(token, name);
          workers = workers.filter(v => v != id);
          return rst;
        } catch (e) {
          log(`ERROR [WS:${workers}]`, name, e.Error);
        }
      }
    };
    if (workers.length < MAX_WORKERS) {
      let jobid = ++workerid;
      workers.push(jobid);
      // log(`UPLOADING [WS:${jobid % MAX_WORKERS}/${workers.length}]`, name)
      doWork(jobid).then(rst => log(`UPLOADED [WS:${jobid % MAX_WORKERS}/${workers.length}] [FILE:${i}/${list.length}]`, name, rst));
      ++i;
    }
    await delay(1e3);
  }
})().then(() => {});
