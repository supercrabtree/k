const execa = require('execa');
const {readFileSync} = require('fs');
const stripAnsi = require('strip-ansi');

const kcommand = readFileSync('../k.sh', 'utf-8');

function k() {
  return execa('eval', [kcommand, 'k'], {shell: '/bin/zsh'})
    .then(({stdout}) => stdout)
    .then(stdout => stdout.split('\n'));
}

k.stripColors = function () {
  return k().then(lines => lines.map(line => stripAnsi(line)));
}

module.exports = k;
