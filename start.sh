#!/bin/sh

RADICALE_CONFIG_PATH='/etc/radicale/config'
RADICALE_RIGHTS_PATH='/etc/radicale/rights'
RADICALE_HTPASSWD_PATH='/etc/radicale/htpasswd'
RADICALE_CERT_PATH='/etc/certs'
RADICALE_DATA_PATH='/data'

if printenv | grep '^RADICALE_CONFIG=' > /dev/null; then
	unset RADICALE_CONFIG
fi


if [ ! -f "$RADICALE_CONFIG_PATH" ]; then
	private_cert_path="${RADICALE_CERT_PATH}/private.key"
	public_cert_path="${RADICALE_CERT_PATH}/public.crt"
	if [ -f "$private_cert_path" ] && [ -f "$public_cert_path" ]; then
		tls_boolean='True'
		tls_comment=''
	else
		tls_boolean='False'
		tls_comment='# '
	fi

	if [ -f "$RADICALE_HTPASSWD_PATH" ]; then
		auth_type='htpasswd'
		auth_comment=''
	else
		auth_type='none'
		auth_comment='# '
	fi

	if [ -f "$RADICALE_RIGHTS_PATH" ]; then
		rights_type='from_file'
		rights_comment=''
	else
		rights_type='owner_only'
		rights_comment='# '
	fi

	if [ -n "$RADICALE_RABBITMQ_ENDPOINT" ] && [ -n "$RADICALE_RABBITMQ_TOPIC" ]; then
		hook_type='rabbitmq'
		rabbitmq_comment=''
		if [ -n "$RADICALE_RABBITMQ_QUEUE_TYPE" ]; then
			RADICALE_RABBITMQ_QUEUE_TYPE='classic'
		fi
	else
		hook_type='none'
		rabbitmq_comment='# '
		RADICALE_RABBITMQ_QUEUE_TYPE='classic'
	fi

	cat > "$RADICALE_CONFIG_PATH" << EOF
[server]
hosts = 0.0.0.0:5232
max_connections = 8
max_content_length = 100000000
timeout = 30
ssl = ${tls_boolean}
${tls_comment}certificate = ${public_cert_path}
${tls_comment}key = ${private_cert_path}
# certificate_authority = 

[encoding]
request = utf-8
stock = utf-8

[auth]
type = ${auth_type}
${auth_comment}htpasswd_filename = ${RADICALE_HTPASSWD_PATH}
${auth_comment}htpasswd_encryption = bcrypt
delay = 1
realm = Radicale - Password Required

[rights]
type = ${rights_type}
${rights_comment}file = ${RADICALE_RIGHTS_PATH}

[storage]
type = multifilesystem
filesystem_folder = ${RADICALE_DATA_PATH}
max_sync_token_age = 2592000
# hook = git add -A && (git diff --cached --quiet || git commit -m "Changes by "%(user)s)

[web]
type = internal

[logging]
level = info
mask_passwords = True

# [headers]
# Access-Control-Allow-Origin = *

[hook]
type=${hook_type}
${rabbitmq_comment}rabbitmq_endpoint=${RADICALE_RABBITMQ_ENDPOINT}
${rabbitmq_comment}rabbitmq_topic=${RADICALE_RABBITMQ_TOPIC}
${rabbitmq_comment}rabbitmq_queue_type=${RADICALE_RABBITMQ_QUEUE_TYPE}

EOF
fi


# if using git versioning and repo not initialised : git init


gitignore_path="${RADICALE_DATA_PATH}/.gitignore"
if [ ! -f "$gitignore_path" ]; then
	cat > "$gitignore_path" << EOF

# Radicale temporary files
.Radicale.cache
.Radicale.lock
.Radicale.tmp-*

EOF
fi


exec radicale

