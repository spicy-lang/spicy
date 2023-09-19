import { toList } from './gleam.mjs';

export function getArgs() {
  return toList(Deno.args);
}