import { LLMOptions } from "../../index.js";

import OpenAI from "./OpenAI.js";

class Fireworks extends OpenAI {
  static providerName = "fireworks";
  static defaultOptions: Partial<LLMOptions> = {
    apiBase: "http://127.0.0.1/",
  };

  private static modelConversion: { [key: string]: string } = {
    "starcoder-7b": "accounts/fireworks/models/starcoder-7b",
  };
  protected _convertModelName(model: string): string {
    return Fireworks.modelConversion[model] ?? model;
  }
}

export default Fireworks;
