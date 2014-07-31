#!/bin/bash

basedir=$(dirname ${BASH_SOURCE[0]})

mkdir -p ${basedir}/0file
mkdir -p ${basedir}/1arch
mkdir -p ${basedir}/2back/work
mkdir -p ${basedir}/3back/work

touch ${basedir}/0file/foreach_$(date +%Y%m%d%H%M%S).txt
touch ${basedir}/0file/aggregate_1.txt
touch ${basedir}/0file/aggregate_2.txt
