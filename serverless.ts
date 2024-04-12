import serverless from "serverless-http";
import NextServer from "next/dist/server/next-server";
// @ts-ignore
import { config } from "./.next/required-server-files.json";
import type {
  Options,
} from "serverless-http";
import type {
  NextConfig,
} from "next";

const server = new NextServer({
  hostname: "localhost",
  dir: __dirname,
  dev: false,
  conf: {
    ...(config as NextConfig),
  },
});
const serverlessOption: Options = {
  binary: ["*/*"],
};

export const handler = serverless(server.getRequestHandler(), serverlessOption);
