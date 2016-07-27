import test from 'ava';
import execa from 'execa';
import {readFileSync} from 'fs';
import stripAnsi from 'strip-ansi';

const kcommand = readFileSync('../k.sh', 'utf-8');

async function k(path='') {
  const {stdout} = await execa('eval', [kcommand + 'k ' + path], {shell: '/bin/zsh'})
  return stdout.split('\n');
}

k.stripColors = async function (path) {
  const lines = await k(path);
  return lines.map(line => stripAnsi(line));
}

test('First proof of concept test', async t => {
  const lines = await k.stripColors();
  t.is(lines[0], 'total 8');
});
