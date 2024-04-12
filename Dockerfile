FROM public.ecr.aws/lambda/nodejs:20 AS base

FROM base AS deps

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM base AS lambda

WORKDIR /app

COPY --from=builder /app/.next/required-server-files.json ./.next/required-server-files.json
COPY --from=builder /app/package.json /app/serverless.ts  ./
COPY --from=deps /app/node_modules ./node_modules

RUN npm run build:lambda

FROM base AS runner

WORKDIR ${LAMBDA_TASK_ROOT}

ENV NODE_ENV production
ENV HOSTNAME 0.0.0.0

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=lambda /app/index.js ./index.js

CMD ["index.handler"]
