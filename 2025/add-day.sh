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

cp template/Code.jl $target_dir/$name.swift
sed -i '' "s/<day>/$day_num/g" $target_dir/$name.swift
sed -i '' "s/<name>/$name/g" $target_dir/$name.swift

cp template/Makefile $target_dir
sed -i '' "s/<day>/$day_num/g" $target_dir/Makefile
sed -i '' "s/<name>/$name/g" $target_dir/Makefile

touch $target_dir/sample_input.txt
