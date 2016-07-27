import test from 'ava';
import {default as k, split} from './helpers/run-k-in-javascript';

test('First proof of concept test', async t => {
  const lines = await k.stripColors('fixtures/one').then(split);
  t.is(lines[0], 'total 16');
});
