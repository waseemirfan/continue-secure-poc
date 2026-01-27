import { describe, expect, it } from "vitest";
import { validateHostOrThrow } from "../networkGate";

describe("networkGate.validateHostOrThrow", () => {
  it("allows localhost", async () => {
    await expect(validateHostOrThrow("127.0.0.1")).resolves.toBeUndefined();
  });

  it("allows private network IP", async () => {
    await expect(validateHostOrThrow("10.0.5.12")).resolves.toBeUndefined();
  });

  it("blocks public IP", async () => {
    await expect(validateHostOrThrow("8.8.8.8")).rejects.toThrow();
  });

  it("blocks public domain", async () => {
    await expect(validateHostOrThrow("google.com")).rejects.toThrow();
  });
});
