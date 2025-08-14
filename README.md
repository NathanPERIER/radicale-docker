
# Radicale Docker container

## Build

```bash
docker build . -t radicale
```

## Configuration

The path to the configuration file in the container should be `/etc/radicale/config`. If the configuration file does not exist, the startup script will create it. For this, it will try to find some files in the container and enable or disable features in consequence :

- If both `public.crt` and `private.key` are found in `/etc/certs`, TLS encryption will be enabled (with those keys).
- If the file `/etc/radicale/htpasswd` is found, HTTP authentication will be enabled (see authentication section below).
- If the file `/etc/radicale/rights` is found, it will be used to set the access rights for the various calendars (see [the rights documentation](https://radicale.org/master.html)).
- If the `RADICALE_RABBITMQ_ENDPOINT` and `RADICALE_RABBITMQ_TOPIC` environment variables are set, enables the [RabbitMQ hook](https://radicale.org/v3.html#hook-1).

### Authentication

In order to generate the htpassword file, one can simply use the following command :

```bash
htpasswd -c -B <path> <user>
```

And then enter the password.

Additional users can be added to the created file by omitting the `-c` option.

> [!NOTE]
> The container assumes the passwords are hashed using bcrypt (hence the `-B` in the `htpasswd` command).

## Run the container

Here is a simple `docker-compose` example :

```yaml
version: "3.9"
services:
  radicale:
    image: radicale:latest
    container_name: radicale
    ports:
     - "5232:5232"
    volumes:
      # Configuration (remove read-only for the first run)
      - '/path/to/radicale/conf:/etc/radicale:ro'
      # TLS certificates
      - '/path/to/certs:/etc/certs:ro'
      # Calendar data
      - '/path/to/radicale/data:/data'
    environment:
      # Enables the RabbitMQ hook (optional)
      RADICALE_RABBITMQ_ENDPOINT: 'amqp://user:password@localhost:5672/'
      RADICALE_RABBITMQ_TOPIC: 'topic'
      RADICALE_RABBITMQ_QUEUE_TYPE: 'classic'
    user: "1000:1000"
```

