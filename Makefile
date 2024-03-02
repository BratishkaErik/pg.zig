F=

.PHONY: t
t:
	TEST_FILTER="${F}" zig build test --summary all -freference-trace

.PHONY: .d
d:
	# docker build tests/ -f tests/Dockerfile -t "pgzig:pg"
	docker run -p 5432:5432 -it --rm \
		-v $(shell pwd)/tests/pg_hba.conf:/etc/postgresql/pg_hba.conf \
		-v $(shell pwd)/tests/server.key:/etc/postgresql/server.key \
		-v $(shell pwd)/tests/server.crt:/etc/postgresql/server.crt \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=root_pw \
		pgzig:pg \
		postgres \
			-c 'hba_file=/etc/postgresql/pg_hba.conf' \
			-c 'ssl_key_file=/etc/postgresql/server.key' \
			-c 'ssl_cert_file=/etc/postgresql/server.crt' \
			-c 'ssl=on'

.PHONY: .certs
certs:
	bash -c "openssl req -x509 -out tests/server.crt -keyout tests/server.key \
		-newkey rsa:2048 -nodes -sha256 \
		-subj '/CN=localhost' -extensions EXT -config <(printf \"[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth\")"
