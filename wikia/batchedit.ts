/*
批量编辑

在同目录下
yarn
npx ts-node batchedit.ts

*/
import axios, { AxiosInstance } from "axios";
import * as querystring from "querystring";

interface AskResult {
  printouts: string[];
  fulltext: string;
  fullurl: string;
  namespace: number;
  exists: string;
  displaytitle: string;
}

interface EditResult {
  result: string;
  pageid: number;
  title: string;
  contentmodel: string;
  oldrevid: number;
  newrevid: number;
  newtimestamp: string;
}

interface EditInfo {
  title?: string;
  pageid?: string;
  text: string;
  minor?: boolean;
  nominor?: boolean;
  bot?: boolean;
}

export class WikiBot {
  user: string;
  session: string;
  token: string;
  BASE = "https://warframe.huijiwiki.com/";
  API = this.BASE + "api.php";
  RAW = this.BASE + "index.php?action=raw&title=";
  client: AxiosInstance;
  constructor(user: string, session: string) {
    this.user = user;
    this.session = session;
    this.client = axios.create({
      headers: {
        common: {
          Cookie: `huijiUserID=${user}; huiji_session=${session};`
        },
        post: {
          "Content-Type": "application/x-www-form-urlencoded"
        }
      }
    });
  }
  // 获取token
  async getToken() {
    const rst = await this.client.get(this.API + `?action=query&meta=tokens&format=json`);
    return (this.token = rst.data.query.tokens.csrftoken);
  }
  // 执行ask
  async ask(ask: string, offset = 0, limit = 50) {
    const url = this.API + `?action=ask&format=json&query=${encodeURI(ask + `|limit=${limit}|offset=${offset}`)}`;
    const rst = await this.client.get(url);
    console.log("[ASK]", url);
    const results = rst.data.query.results as { [key: string]: AskResult };
    // 自动翻页
    if (rst.data["query-continue-offset"]) {
      const nextPage = await this.ask(ask, rst.data["query-continue-offset"], limit);
      const allPage = { ...results, ...nextPage } as { [key: string]: AskResult };
      return allPage;
    }
    return results;
  }

  // 编辑页面
  async edit(info: EditInfo) {
    const formdata = querystring.stringify({ action: "edit", format: "json", token: this.token, ...info });
    const rst = await this.client.post(this.API, formdata);
    return rst.data.edit as EditResult;
  }

  // 获取页面源码
  async raw(title: string) {
    const rst = await this.client.get(this.RAW + encodeURI(title));
    return rst.data as string;
  }
}
require("dotenv").config();

(async () => {
  const bot = new WikiBot(process.env.user, process.env.session);
  await bot.getToken();
  let askrst = await bot.ask("[[分类:战甲技能]]");
  const titles = Object.keys(askrst);
  for (let i = 0; i < titles.length; i++) {
    const page = titles[i];
    if (page.endsWith("/Abilities")) continue;
    const raw = await bot.raw(page);
    const matcher = /\[\[File:(.+?).png\|200px\|left]]/;
    const modname = /{{#lst:(.+?)\|intro}}/;
    const m = raw.match(matcher);
    const n = raw.match(modname);
    console.log(`页面: ${page} ${m ? "有" : "没有"}需要规范的MOD图片${n ? ` (${n[1]})` : ""}`);
    if (m && n) {
      const rpl = `[[File:{{mi|${n[1]}}}|200px|left]]`;
      console.log(`标签已替换 ${m[0]} => ${rpl}`);
      const newText = raw.replace(m[0], rpl);
      const rst = await bot.edit({ title: page, text: newText });
      if (rst.result != "Success") console.log(rst || "参数错误");
    }
  }
})();
