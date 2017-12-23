#!/usr/bin/env node

process.title = 'eda';

const argv = require('minimist')(process.argv.slice(2));
const path = require('path');
const fs = require('fs');

function cmd() {
  // --help
  if (argv.help) {
    fs
      .createReadStream(path.resolve(__dirname, './help.txt'))
      .pipe(process.stdout);
  }
}

cmd();
