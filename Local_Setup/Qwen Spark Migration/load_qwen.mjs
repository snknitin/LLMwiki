#!/usr/bin/env node
// LM Studio alternative: run ON FirstSpark, after the exact GGUF and memory budget are qualified.
// Requires a separately installed, pinned @lmstudio/sdk@2.0.0 beside this script.
// This file does not download/install anything or alter boot/services/Hermes/vLLM.
// Usage: node load_qwen.mjs --model '<exact lms ls model key>' [--mtp off|2|3]
//        node load_qwen.mjs --model '<key>' --print-config
//        node load_qwen.mjs --model '<key>' --check
// --replace reloads ONLY the existing qwen38-27b-spark alias, never another model.
// Run the workload qualification separately; a successful load is not a performance test.

import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';

const identifier = 'qwen38-27b-spark';
const args = process.argv.slice(2);
const options = { model: process.env.QWEN_MODEL_KEY || '', mtp: '3' };
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--model' || arg === '--mtp') {
    if (!args[i + 1] || args[i + 1].startsWith('--')) throw new Error(`Missing value for ${arg}`);
    options[arg.slice(2)] = args[++i];
  } else if (['--print-config', '--check', '--replace'].includes(arg)) {
    options[arg.slice(2)] = true;
  } else {
    throw new Error(`Unknown argument: ${arg}`);
  }
}
if (!options.model || !['off', '2', '3'].includes(options.mtp)) {
  throw new Error('Supply --model with the exact downloaded model key and --mtp off, 2 or 3.');
}
if (options.check && options.replace) throw new Error('--check cannot be combined with --replace.');

const config = {
  gpu: { ratio: 'max' },
  contextLength: 262144,
  maxParallelPredictions: 2,
  // Essential: LM Studio multiplies the underlying ctx-size by parallel when false.
  // Expected backend: --ctx-size 524288 --parallel 2 --no-kv-unified.
  useUnifiedKvCache: false,
  flashAttention: true,
  offloadKVCacheToGpu: true,
  llamaKCacheQuantizationType: 'q8_0',
  llamaVCacheQuantizationType: 'q8_0',
  evalBatchSize: 2048,
  physicalBatchSize: 512,
  // Bound recurrent-state checkpoint memory while retaining multi-turn reuse.
  contextCheckpoints: 16,
  speculativeDraftMtp: options.mtp !== 'off',
  speculativeDraftSimple: false,
  speculativeDraftModel: '',
  speculativeDraftMaxTokens: options.mtp === 'off' ? 3 : Number(options.mtp),
  speculativeDraftMinTokens: 0,
  speculativeDraftMinContinueProbability: 0.75,
  keepModelInMemory: true,
};

if (options['print-config']) {
  console.log(JSON.stringify({ identifier, model: options.model, config, ttl: 'omitted: manually resident' }, null, 2));
  process.exit(0);
}
if (process.platform !== 'linux' || process.arch !== 'arm64') {
  throw new Error('Run this loader on FirstSpark Linux ARM64. It intentionally refuses Windows/local desktop loads.');
}

// Require the exact inspected SDK release, rather than an older SDK silently dropping settings.
const require = createRequire(import.meta.url);
let sdkDirectory = dirname(require.resolve('@lmstudio/sdk'));
let sdkVersion;
for (let i = 0; i < 6; i++) {
  try {
    const manifest = JSON.parse(readFileSync(join(sdkDirectory, 'package.json'), 'utf8'));
    if (manifest.name === '@lmstudio/sdk') { sdkVersion = manifest.version; break; }
  } catch { /* Continue toward the resolved package root. */ }
  sdkDirectory = dirname(sdkDirectory);
}
if (sdkVersion !== '2.0.0') throw new Error('Requires the inspected @lmstudio/sdk version 2.0.0. No automatic install performed.');
const { LMStudioClient } = await import('@lmstudio/sdk');
const client = new LMStudioClient({
  baseUrl: 'ws://127.0.0.1:1234',
  ...(process.env.LM_API_TOKEN ? { apiToken: process.env.LM_API_TOKEN } : {}),
  verboseErrorMessages: false,
});

function differences(actual) {
  const mismatches = [];
  for (const [key, expected] of Object.entries(config)) {
    // Full layer offload must additionally be confirmed in sanitized backend args/logs.
    if (key === 'gpu') continue;
    if (actual[key] !== expected) mismatches.push({ field: key, expected, actual: actual[key] ?? null });
  }
  return mismatches;
}

try {
  let model = (await client.llm.listLoaded()).find(item => item.identifier === identifier);
  if (model) {
    if (model.modelKey !== options.model && model.path !== options.model) {
      throw new Error('The existing target alias points to a different model key. Inspect it; this script will not unload it.');
    }
    const mismatch = differences(await model.getLoadConfig());
    if (mismatch.length && !options.replace) {
      console.error(JSON.stringify({ status: 'configuration_mismatch', identifier, mismatch }, null, 2));
      throw new Error('Existing alias does not have the requested configuration. Explicit --replace is required after draining clients.');
    }
    if (mismatch.length) {
      await client.llm.unload(identifier);
      model = undefined;
    }
  }
  if (!model) {
    if (options.check) throw new Error('The target model is not loaded; --check performs no load.');
    // No TTL: retain a manually loaded serving instance. Never unload other models here.
    model = await client.llm.load(options.model, { identifier, config, verbose: false });
  }
  const actual = await model.getLoadConfig();
  const mismatch = differences(actual);
  if (mismatch.length) {
    console.error(JSON.stringify({ status: 'configuration_mismatch', identifier, mismatch }, null, 2));
    throw new Error('Loaded configuration did not match. Stop qualification and inspect the runtime; no fallback was attempted.');
  }
  console.log(JSON.stringify({
    status: 'configured_not_workload_qualified',
    identifier, modelKey: model.modelKey, sdkVersion,
    contextPerRequest: actual.contextLength,
    simultaneousRequests: actual.maxParallelPredictions,
    expectedUnderlyingContextPool: 524288,
    config: Object.fromEntries(Object.keys(config).map(key => [key, actual[key]])),
    nextGate: 'Verify sanitized backend args, two near-capacity prompts including output reserve, tool calls, speed and host memory.',
  }, null, 2));
} finally {
  if (typeof client[Symbol.asyncDispose] === 'function') await client[Symbol.asyncDispose]();
}
