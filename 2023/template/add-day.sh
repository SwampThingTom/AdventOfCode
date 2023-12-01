#!/usr/bin/env bash

# Sets up the directory for a new day of Advent of Code
#
# Usage:
# add-day <day-num> <name>

day=$1
name=$2

target_dir="$day-$name"

day_num=`expr $day + 0`
mkdir $target_dir

cp template/Code.rs $target_dir/$name.rs
sed -i '' "s/<day>/$day_num/g" $target_dir/$name.rs
sed -i '' "s/<name>/$name/g" $target_dir/$name.rs

cp template/Makefile $target_dir
sed -i '' "s/<day>/$day_num/g" $target_dir/Makefile
sed -i '' "s/<name>/$name/g" $target_dir/Makefile

echo "$name" > $target_dir/.gitignore
touch $target_dir/input.txt
