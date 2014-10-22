# Custom Docker Registry with Authentication

A private docker registry that used a NGINX reverse proxy to add basic authentication.

## Requirements

### 1. Amazon S3 Credentials

The run-script of this registry is configured to use Amazon S3 as the storage-backend. So you need the following parameters available before you start your registry:

- S3 Bucket Name
- AWS Key
- AWS Secret

### 2. A SSL certificate

Since this image is using basic authentication via HTTPs to secure your docker registry you should have an SSL certificate and private key that matches the hostname your planning to use for the registry (and that is trusted by your computer).

## Usage

![Screenrecording: How to build and run the private docker-registry with basic authentication](documentation/building-and-running-docker-registry-with-authentication.gif)

### 1. Build the reverse proxy image

Build the reverse-proxy image:

```bash
cd <project-directory>
cd reverse-proxy
sudo docker build -t=andreaskoch/reverse-proxy .
```

### 2. Configure SSL

Place the .key and .cert files of your site in the `sites` folder.
Make sure the certificate matches the hostname you are using and that the certificates CA is trusted by your operating system.

Otherwise you will get errors like these:

> Error: Invalid Registry endpoint: Get https://localhost/v1/_ping: x509: certificate is valid for registry.example.com, not localhost

> Error response from daemon: Invalid Registry endpoint: Get https://localhost/v1/_ping: x509: certificate signed by unknown authority

### 3. Create a basic auth file

Add some users to the `.htpasswd` files (or place your existing password file in the `sites folder):

```bash
cd <project-direcotry>
cd sites
htpasswc -c .htpasswd user1 password1
```

### 4. Start the registry container

Start the registry and reverse-proxy containers:

```bash
cd <project-direcotry>

AWS_BUCKET=<your-docker-registry name>
AWS_KEY=<your-aws-key>
AWS_SECRET=<your-aws-secret>

sudo ./run.sh $AWS_BUCKET $AWS_KEY $AWS_SECRET
```

### 5. Test the connection

You should be able to access the repository under your local ip-address:

```bash
curl --insecure -u user1:password1 https://127.0.0.1
```

The result should look something-like this:

> "docker-registry server (s3) (v0.8.1)"

If that worked you can try to login with docker:

```bash
docker login https://127.0.0.1
```
