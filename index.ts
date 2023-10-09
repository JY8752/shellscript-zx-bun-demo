#!/usr/bin/env bun

import { path, chalk } from "zx";
import inquirer from "inquirer";
import { BunFile } from "bun";
import Papa from "papaparse";

type Rarity = "N" | "R" | "SR";

type GachaCsvData = {
  id: number;
  name: string;
  rarity: Rarity;
  weight: number;
};

const main = async () => {
  const args = Bun.argv;
  const baseDir = path.dirname(args[1]);

  // themes.txt読み込み
  const themesFile = await openFile(`${baseDir}/themes.txt`);
  const themesTxt = await themesFile.text();
  const choices = themesTxt.split("\n").filter((row) => row.length !== 0);
  if (choices.length < 1) {
    throw new Error("fail to read theme from themes.txt.");
  }

  // テーマ選択肢表示
  const { choiced } = await inquirer.prompt<{ choiced: string }>([
    {
      type: "list",
      name: "choiced",
      message: "テーマを選択してください.",
      choices,
    },
  ]);

  // 選択されたテーマからガチャデータファイル読み込み
  const theme = choiced.split(" ").shift() || "";
  const gachaFile = await openFile(`${baseDir}/gacha/${theme}.csv`);

  // csvを扱いやすいように変換
  const results = Papa.parse<GachaCsvData>(await gachaFile.text(), {
    header: true,
    dynamicTyping: true,
    skipEmptyLines: true,
  });
  const gachaFileData = results.data;

  // トータルの重みを計算
  const totalWeight = gachaFileData.reduce((previous, current) => {
    return previous + current.weight;
  }, 0);

  // 疑似乱数の取得
  const rand = Math.floor(Math.random() * totalWeight) + 1;

  // 重み付け抽選
  let currentWeight = 0;
  let result: GachaCsvData | undefined;
  for (const data of gachaFileData) {
    currentWeight += data.weight;
    if (currentWeight >= rand) {
      result = data;
      break;
    }
  }

  // result

  if (!result) {
    throw new Error("The gacha lottery failed.");
  }

  console.log("result item🚀");

  const msg = JSON.stringify(result, null, 2);
  switch (result.rarity) {
    case "R":
      console.log(chalk.magenta(msg));
      break;
    case "SR":
      console.log(rainbow(msg));
      break;
    default:
      console.log(msg);
      break;
  }
};

const openFile = async (filepath: string): Promise<BunFile> => {
  const file = Bun.file(filepath);
  if (!(await file.exists())) {
    throw new Error(`not found file. ${filepath}`);
  }
  return file;
};

const rainbow = (msg: string): string => {
  const rainbowColors = [
    chalk.red,
    chalk.yellow,
    chalk.green,
    chalk.blue,
    chalk.cyan,
    chalk.magenta,
    chalk.white,
  ];

  let coloredText = "";
  for (let i = 0; i < msg.length; i++) {
    // Apply rainbow colors in sequence to each character
    coloredText += rainbowColors[i % rainbowColors.length](msg[i]);
  }
  return coloredText;
};

await main();
