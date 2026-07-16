import type { Config } from "@sveltejs/kit";

// Kept for adapter-auto / Vercel edge deployments.
export const config: Config = {
  runtime: "edge",
};
