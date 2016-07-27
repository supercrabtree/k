import test from 'ava';
import {default as k, split, stripColors} from './helpers/run-k-in-javascript';

test('File and directory types', async t => {
  const lines = await k('fixtures/one').then(stripColors).then(split);
  t.is(lines[0],  'total 16');
  t.is(lines[1],  '-rwxr-sr-x 1 supercrabtree staff  0 10 Feb   20:19 | exe-with-gid');
  t.is(lines[2],  '-rwsr-sr-x 1 supercrabtree staff  0 10 Feb   20:42 | exe-with-gid-and-uid');
  t.is(lines[3],  '-rwsr-xr-x 1 supercrabtree staff  0 10 Feb   20:05 | exe-with-uid');
  t.is(lines[4],  '-rwxr-xr-x 1 supercrabtree staff  0 24 Jan    2016 | executable');
  t.is(lines[5],  'drwxr-xr-x 2 supercrabtree staff 68 24 Jan    2016 | executable-dir');
  t.is(lines[6],  'lrwxr-xr-x 1 supercrabtree staff 10 24 Jan    2016 | link.txt -> string.txt');
  t.is(lines[7],  'drwxr-xr-x 2 supercrabtree staff 68 24 Jan    2016 | nested-dir');
  t.is(lines[8],  '-rw-r--r-- 1 supercrabtree staff 12 24 Jan    2016 | string.txt');
  t.is(lines[9],  'drwxrwxrwt 2 supercrabtree staff 68 10 Feb   20:50 | wto-with-sticky');
  t.is(lines[10], 'drwxrwxrwx 2 supercrabtree staff 68 10 Feb   20:50 | wto-without-sticky');
});
