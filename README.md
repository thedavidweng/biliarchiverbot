# biliarchiverbot

Supported production path: **Docker / self-hosted Node** via `@sveltejs/adapter-node`.

## Configuration & Data Storage

> File-based storage needs a persistent filesystem. Admin/blacklist features write JSON under `/app/config` and are intended for Docker or local Node deployments.

The bot stores configuration in the `config` directory:

- `admins.json`: Admin user IDs
- `blacklist.json`: Blocked user IDs

## Using Docker

The published image runs the production Node server (`adapter-node` → `node build`) on port `5173` as UID/GID `10001`.

Prefer a **named volume** for config so ownership stays writable for the container user:

```shell
docker run -d \
  --name biliarchiverbot \
  -p 5173:5173 \
  -v biliarchiverbot-config:/app/config \
  -e BILIARCHIVER_WEBAPP={THE_DEPLOYED_WEBAPP_URL} \
  -e BILIARCHIVER_USERNAME={THE_TELEGRAM_USERNAME_OF_BILIARCHIVER_BOT} \
  -e BILIARCHIVER_API={THE_API_URL_OF_BILIARCHIVER} \
  -e BILIARCHIVER_BOT={YOUR_BOT_TOKEN} \
  --restart always \
  ghcr.io/saveweb/biliarchiverbot:latest
```

Optional environment variables (add only the ones you need):

```shell
  -e BILIARCHIVER_ENABLE_BLACKLIST=true \
  -e BILIARCHIVER_LOG_INTO_CHAT_ID={YOUR_CHAT_ID} \
  -e BILIARCHIVER_LOG_INTO_CHAT_TOPIC={YOUR_CHAT_TOPIC} \
```

If you bind-mount a host directory instead of a named volume, make it writable by UID `10001` first, for example:

```shell
mkdir -p ./config
sudo chown -R 10001:10001 ./config
```

If you have a public IP, set the bot webhook to your IP address:

```shell
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<YOUR_IP_ADDRESS>:5173/bot/webhook
```

If you don't have a public IP, use [ngrok](https://ngrok.com/) or another tunnel (Caddy/Nginx also work):

```shell
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<TUNNELING_URL>/bot/webhook
```

## Local Development

1. Clone this repository
2. Install dependencies:

   ```shell
   pnpm install
   ```

3. Create a `.env` file:

   ```env
   BILIARCHIVER_WEBAPP=<THE_DEPLOYED_WEBAPP_URL>
   BILIARCHIVER_USERNAME=<THE_TELEGRAM_USERNAME_OF_BILIARCHIVER_BOT>
   BILIARCHIVER_API=<THE_API_URL_OF_BILIARCHIVER>
   BILIARCHIVER_BOT=<YOUR_BOT_TOKEN>
   # Optional:
   # BILIARCHIVER_ENABLE_BLACKLIST=true
   # BILIARCHIVER_LOG_INTO_CHAT_ID=<YOUR_CHAT_ID>
   # BILIARCHIVER_LOG_INTO_CHAT_TOPIC=<YOUR_CHAT_TOPIC>
   ```

4. Start the development server:

   ```shell
   pnpm dev
   ```

5. Point the bot webhook at your tunnel or public URL:

   ```shell
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<DEPLOY_URL>/bot/webhook
   ```

## Manage

Please checkout `/admin` command for more information.

### Admin Management

The first user to run `/addadmin` becomes the admin. After that, only admins can add new admins using:

```shell
/addadmin <USER_ID>
```

### User Management

Admins can blacklist users using:

```shell
/blacklist <USER_ID>
```

Blacklisted users will be unable to use the bot and will be directed to contact the first admin.
