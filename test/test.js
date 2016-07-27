import test from 'ava';
import k from './helpers/run-k-in-javascript';

test('First proof of concept test', async t => {
  const lines = await k.stripColors();
  t.is(lines[0], 'total 8');
});
