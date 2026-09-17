# Used by docker-compose.yml to deploy the formio application
# (When modified, you must include `--build` )
# -----------------------------------------------------------

# Use Node image, maintained by Docker:
# hub.docker.com/r/_/node/
FROM node:24-alpine

# Copy source dependencies
COPY src/ /app/src/
COPY config/ /app/config
COPY *.js /app/
COPY *.txt /app/
COPY package.json /app/
COPY default-template.json /app/

COPY portal/src /app/portal/src
COPY portal/public /app/portal/public
COPY portal/package.json /app/portal/package.json
COPY portal/tsconfig.json /app/portal/tsconfig.json
COPY portal/webpack.config.mjs /app/portal/webpack.config.mjs

WORKDIR /app

# "bcrypt" requires python/make/g++, all must be installed in alpine
# (note: using pinned versions to ensure immutable build environment)
RUN apk update && \
    apk upgrade && \
    apk add make && \
    apk add python3 && \
    apk add g++ && \
    apk add git

RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"

# install dependencies
RUN npm i
# build the client application
WORKDIR /app/portal
# Standalone Docker builds are outside the Form.io monorepo; map workspace: protocol to published packages.
RUN node -e "const fs=require('fs'); const p=JSON.parse(fs.readFileSync('package.json','utf8')); const map={'@formio/js':'^5.5.2','@formio/react':'^6.2.1','@formio/core':'^2.8.2'}; for (const s of ['dependencies','devDependencies']) { for (const [k,v] of Object.entries(p[s]||{})) { if (String(v).startsWith('workspace:')) { if (!map[k]) throw new Error('No npm mapping for '+k); p[s][k]=map[k]; } } } fs.writeFileSync('package.json', JSON.stringify(p,null,2)+'\n');"
RUN npm i --legacy-peer-deps && npm i --no-save --legacy-peer-deps ajv@8.17.1
RUN npm run build

RUN apk del git

# Set this to inspect more from the application. Examples:
#   DEBUG=formio:db (see index.js for more)
#   DEBUG=formio:*
ENV DEBUG=""

# This will initialize the application based on
# some questions to the user (login email, password, etc.)
ENTRYPOINT [ "node", "--no-node-snapshot", "main" ]
