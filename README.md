# CZERTAINLY-Docker-Develop-Environment

This repository contains Docker Compose files and scripts that can be used to streamline development of the CZERTAINLY platform.
There are couple of microservices that need to be running for the development. Depending on the service that is going to be developed, the compose will run the services.

## Setup the environment variables

Create a `.env` file in the root of the repository and update values. The `.env.example` file can be used as a template with the following values:

| Variable                    | Description                                                                                             |
|-----------------------------|---------------------------------------------------------------------------------------------------------|
| CZERTAINLY_SOURCES_BASE_DIR | Path to the directory where the CZERTAINLY sources are located for building the images.                 |
| DB_HOST                     | Hostname of the PostgreSQL database. Keep the default value if you are using the PostgreSQL in Docker.  |
| DB_PORT                     | Port of the PostgreSQL database. Keep the default value if you are using the PostgreSQL in Docker.      |
| DB_USERNAME                 | Username for the PostgreSQL database. Keep the default value if you are using the PostgreSQL in Docker. |
| DB_PASSWORD                 | Password for the PostgreSQL database. Keep the default value if you are using the PostgreSQL in Docker. |
| DB_NAME                     | Name of the PostgreSQL database. Keep the default value if you are using the PostgreSQL in Docker.      |
| SMTP_HOST                   | Hostname of the SMTP server. Used with the `email-notification-provider` service.                       |
| SMTP_USERNAME               | Username for the SMTP server. Used with the `email-notification-provider` service.                      |
| SMTP_PASSWORD               | Password for the SMTP server. Used with the `email-notification-provider` service.                      |
| GITHUB_USERNAME             | Username for the GitHub account to get the packages, if necessary.                                      |
| GITHUB_PASSWORD             | Password for the GitHub account to get the packages, if necessary.                                      |

### Trusted CA certificates

If you are using the self-signed or not publicly trusted certificates, you should add the CA certificate to the trusted certificates in the Docker. You can add the CA certificate to the `./secrtes/trusted_certificates.pem` file and it will be automatically mounted to the Docker containers.

The file contains the CA certificate in the PEM format. You can add multiple certificates to the file.

## Quick start

Copy the `.env.example` file to `.env` and update the `CZERTAINLY_SOURCES_BASE_DIR` with the path to the CZERTAINLY sources on your local.
For a quick start, you can use the following command to start the environment for the core services using the PostgreSQL database in docker:

```bash
docker-compose -f czertainly-compose.yml -f postgres-compose.yml --profile database --profile core up
```

This should merge both `czertainly-compose.yml` and `postgres-compose.yml` compose file and start the PostgreSQL database and the core services according to the profiles `database` and `core`.

To stop the services, you can use the following command:

```bash
docker-compose -f czertainly-compose.yml -f postgres-compose.yml --profile database --profile core down
```

## Database

CZERTAINLY requires a PostgreSQL database to store the data. The database can be started in Docker using the `postgres-compose.yml` file or you can use your own database.
The database access is configured using [environment variables](#setup-the-environment-variables) in the `.env` file.

### Using the PostgreSQL in Docker

The `postgres-compose.yml` file contains the PostgreSQL database service. The database is used by the core services and the services that require the database.
By default the database will mount the `./data` directory to store the data. The data will be persisted even if the database is stopped. If the `./data` folder does not exists, it will be created.

To start the PostgreSQL database in Docker, you can use the following command:

```bash
docker-compose -f postgres-compose.yml --profile database up
```

To stop the PostgreSQL database, you can use the following command:

```bash
docker-compose -f postgres-compose.yml --profile database down
```

To remove the data and start the database from scratch, you should remove the `./data` directory.

> [!IMPORTANT]  
> The `./data` directory contains the data of the PostgreSQL database. Removing the directory will remove all data stored in the database. Make sure to back up the data before removing the directory, if necessary.

## Profiles

The `czertainly-compose.yml` file contains profiles that can be used to start the required services based on what you are going to work on. The profiles are:

| Profile    | Services                                                                                                                                                                                                                                                                                                  | Description                                                              |
|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `core`     | `opa` `rabbitmq` `auth` `opa-bundle-server` `scheduler` `core`                                                                                                                                                                                                                                            | Starts the core services of the CZERTAINLY platform.                     |
| `database` | `postgres`                                                                                                                                                                                                                                                                                                | Starts the PostgreSQL database.                                          |
| `core-dev` | `opa` `rabbitmq` `auth` `opa-bundle-server` `scheduler`                                                                                                                                                                                                                                                   | Starts services that are needed for the development of the Core service. |
| `all`      | `opa` `rabbitmq` `auth` `opa-bundle-server` `scheduler` `core` `postgres` `common-credential-provider` `ejbca-ng-connector` `keystore-entity-provider` `software-cryptography-provider` `ip-discovery-provider` `cryptosense-discovery-provider` `x509-compliance-provider` `email-notification-provider` | Starts all services.                                                     |

Each service can be started separately using the profile with name `[service name]-standalone`.

### Running service for development of the Core service

To start the services that are needed for the development of the Core service, you can use the `core-dev` profile:

```bash
docker-compose -f czertainly-compose.yml --profile core-dev up
```

Once the services are started, you can start the Core service in your favorite IDE and connect to the running services.

## Authentication

CZERTAINLY authenticate the users using the client certificate on the mTLS enabled port. For the development purposes, you can use non-TLS port and simulate the authenticated user, you can send the `X-APP-CERTIFICATE` header with the Base64 encoded certificate.

You can register the certificate for the first administrator using the [`Local API`](https://docs.czertainly.com/api/core-local/#tag/Local-operations/operation/addAdmin). For the development purposes, you can use the [`CZERTAINLY Administrator`](https://github.com/CZERTAINLY/CZERTAINLY-Helm-Charts/blob/main/dummy-certificates/certs/admin.cert.pem) certificate.

To create the administrator, follow [Create Super Administrator](https://docs.czertainly.com/docs/certificate-key/installation-guide/create-super-administrator).

Additional user and roles can be added using the CZERTAINLY API or Administator UI.

## Administrator frontend

To run the Administrator frontend and use the backend services for the development, you can start the development server in [CZERTAINLY-FE-Administrator](https://github.com/3KeyCompany/CZERTAINLY-FE-Administrator) repository.

Create a `./src/setupProxy.cjs` file in the root of the repository with the following content:

```javascript
const proxyConfig = {
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:8280',
                changeOrigin: true,
                secure: false,
                headers: {
                    // Base64Url encoded certificate of the CZERTAINLY Administrator
                    'ssl-client-cert': 'MIIDPTCCAiUCFBd%2BdfQuley5j4MetX3iewvIxHZDMA0GCSqGSIb3DQEBCwUAMF0xCzAJBgNVBAYTAkNaMRAwDgYDVQQIDAdDemVjaGlhMQswCQYDVQQHDAJDQjENMAsGA1UECgwEM0tFWTEMMAoGA1UECwwDREVWMRIwEAYDVQQDDAlsb2NhbGhvc3QwHhcNMjAwOTI1MTE1NDU3WhcNMzAwODA0MTE1NDU3WjBZMQswCQYDVQQGEwJDWjEQMA4GA1UECAwHQ3plY2hpYTELMAkGA1UEBwwCQ0IxCzAJBgNVBAoMAkNGMQwwCgYDVQQLDANERVYxEDAOBgNVBAMMB0NMSUVOVDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC%2FSsO%2B9IzQ85xxyiT%2Bou8RDNxZMP0Ja8YKrdu19BTFjyLtVLpb%2BI1XqzlXFdJcObYZ5ZboyALB00i5Ds0TTs8ydgEeaw0K2O96DnGh4z5r4qLuF%2BfpVR%2B3A8kKRSrqJN1JNPFeb%2BNKsilUNvx5plZBm5%2BVTd64Sop6r1DALEDBS8AxRJSgp4x%2FoCq%2BT4zLh9XDyVUQ68axLgF86sS4YcBYKQVTH7KwRx%2BFGPFnBqt2ll2IherJ1N1dheXdLqzPYY%2BuIhs55wUPRhQibjiJhM9NgMYsmOPZRzsPIr6%2BgUil82rmSfyMg%2FA0wT4dsm6MT7ly6PPRyxoRvhNvfn96FsCRAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAI%2BYNR82n23p9014wa%2B99aEWJfujlirY07jhAQmsGTkkFM5QTNJzwi6VYnUwjlJMOXw8fEiBVRHUiyLV5RWZGiGZuLdCZgYCjtzCtWuOPidShAK5GpLDipG9upZ%2BRCNpBXVbb6J5tEI0esTSxZ%2Fjwj2JqZZayhRmRXL%2Fj8vGRn74atTILeFwUIYsSreoMI8wG1Rk0que09LgP1RmCiSl1GUSTL%2FlrK%2FdYaw0orZwUxzKg%2FKNnTYprYiAIVRsHUz8bkd6mGEBCfDdpEp0l7laBej2R8RhGDwuxjma1ZrwlCsKLlpdn2lwzqIEc%2BZl7dxiLTb1NLMH80f4LCuF1iFCD6E%3D',
                },
            },
        },
    },
};

module.exports = proxyConfig;
```

This will proxy the requests from the frontend to the backend services authenticated and authorized with the certificate in the `X-APP-CERTIFICATE` header.

> [!IMPORTANT]  
> Change the values in the middleware according to your setup and desired configuration.

## Connectors and technologies

To have a complete setup, you will need to have a technology available for the connectors. For example, if you would like to work with the Authority Provider functions, you should have appropriate connector running that is able to communicate with the target technology.
