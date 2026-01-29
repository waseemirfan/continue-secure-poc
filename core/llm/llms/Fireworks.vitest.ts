import Fireworks from "./Fireworks.js";
import { createOpenAISubclassTests } from "./test-utils/openai-test-utils.js";

createOpenAISubclassTests(Fireworks, {
  providerName: "fireworks",
  defaultApiBase: "http://127.0.0.1/",
  modelConversions: {
    "starcoder-7b": "accounts/fireworks/models/starcoder-7b",
  },
  modelConversionContent:
    "<|im_start|>user\nhello<|im_end|>\n<|im_start|>assistant\n",
});
