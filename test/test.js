import test from 'ava';
import {default as execa, spawn} from 'execa';
import {readFileSync} from 'fs';
import stripAnsi from 'strip-ansi';

const kcommand = readFileSync('../k.sh', 'utf-8');

function k(path='') {
  return execa('eval', [kcommand + 'k ' + path], {shell: '/bin/zsh'})
    .then(({stdout}) => stdout)
    .then(res => res.split('\n'));
}

k.stripColors = function (path) {
  return k(path).then(res => res.map(line => stripAnsi(line)));
}

test('First proof of concept test', t => {
  return k.stripColors()
    .then(lines => {
      t.is(lines[0], 'total 8');
    });
});
