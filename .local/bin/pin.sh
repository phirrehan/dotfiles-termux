#!/bin/sh

min=1000
max=10000
number=$(expr $min + $RANDOM % $max)
printf "%04d\n" $number
