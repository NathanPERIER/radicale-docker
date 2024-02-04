
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

### Authentication

In order to generate the htpassword file, one can simply use the following command :

```bash
htpasswd -c -B <path> <user>
```

And then enter the password.

Note that the Docker assumes the passwords are hashed using bcrypt (hence the `-B` in the `htpasswd` command).

