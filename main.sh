#!/bin/sh

print_notfound_file() {
  printf "\033[31mError: %s not found or not readable\033[0m\n" "$1"
}

print_magenta() {
  printf "\033[95m%s\033[0m\n" "$1"
}

print_rainbow() {
  # ANSIカラーコードの定義
  colors_0=31
  colors_1=33
  colors_2=32
  colors_3=36
  colors_4=34
  colors_5=35
  colors_6=93
  colors_7=96
  colors_8=95
  size=9

  # 虹色で表示する文字列
  message="$1"

  # 文字列の各文字に色を割り当てて表示
  i=0
  for char in $(echo "$message" | fold -w1); do
    eval color=\"\$"colors_$i"\"
    printf "\033[1;%sm%s\033[0m" "$color" "$char"
    i=$(((i + 1) % size))
  done
  echo
}

main() {
  current_dir=$(dirname "$0")
  readonly current_dir

  readonly themes_path="$current_dir"'/themes.txt'

  if [ ! -r "$themes_path" ]; then
    print_notfound_file "$themes_path"
    exit 1
  fi

  # テーマ選択
  while read -r theme description; do
    echo '- '"$theme"' '"$description"
  done <"$themes_path"

  echo
  echo 'テーマを選択してください. ex) theme1'

  read -r theme
  echo

  # アイテムファイルを読み込んで重み付け抽選
  readonly gacha_path="$current_dir"'/gacha/'"$theme"'.csv'
  total_weight=0
  size=0

  if [ ! -r "$gacha_path" ]; then
    print_notfound_file "$gacha_path"
    exit 1
  fi

  # トータルの重み
  while IFS=, read -r _ _ _ weight; do
    # 1行目はヘッダーなので飛ばしたい
    if [ "$size" -gt 0 ]; then
      total_weight=$((total_weight + weight))
    fi
    size=$((size + 1))
  done <"$gacha_path"

  # 抽選
  random=$(awk 'BEGIN { srand(); print int(rand()*32768) }' /dev/null)
  readonly rand=$((random % total_weight + 1))

  total_weight=0
  result_id=
  result_name=
  result_rarity=
  is_first=0
  while IFS=, read -r id name rarity weight; do
    # ヘッダー行飛ばす
    if [ "$is_first" -eq 0 ]; then
      is_first=1
      continue
    fi

    total_weight=$((total_weight + weight))
    if [ "$total_weight" -ge "$rand" ]; then
      result_id="$id"
      result_name="$name"
      result_rarity="$rarity"
      break
    fi
  done <"$gacha_path"

  # result
  echo 'result item🚀'

  case "$result_rarity" in
  R)
    print_magenta "ID: $result_id"
    print_magenta "Name: $result_name"
    print_magenta "Rarity: $result_rarity"
    ;;
  SR)
    print_rainbow "ID: $result_id"
    print_rainbow "Name: $result_name"
    print_rainbow "Rarity: $result_rarity"
    ;;
  *)
    echo "ID: $result_id"
    echo "Name: $result_name"
    echo "Rarity: $result_rarity"
    ;;
  esac
}

main
