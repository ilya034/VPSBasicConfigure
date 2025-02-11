#!/bin/bash

while getopts u: flag
do
    case "${flag}" in
        u) arg=${OPTARG};;
    esac
done

echo "$arg"
