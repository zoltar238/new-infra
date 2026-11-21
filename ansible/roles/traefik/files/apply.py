import argparse
import fcntl
import hashlib
import json
import subprocess
from pathlib import Path


DEPLOYMENT_DIR = Path("/etc/traefik-swarm")
CERTBOT_DIR = DEPLOYMENT_DIR / "certbot"
SERVICE_NAME = "traefik_traefik"
CADDY_SERVICE = "caddy_caddy"
WEB_PORTS = {80, 443}


def ensure_swarm_object(kind, name, content):
    inspected = subprocess.run(
        ["docker", kind, "inspect", name], capture_output=True, check=False
    )
    if inspected.returncode != 0:
        subprocess.run(
            ["docker", kind, "create", name, "-"], input=content, check=True
        )


def issue_certificate(domain, email):
    return subprocess.run(
        [
            "certbot", "certonly", "--non-interactive", "--agree-tos",
            "--keep-until-expiring", "--dns-cloudflare",
            "--dns-cloudflare-credentials", str(DEPLOYMENT_DIR / "cloudflare.ini"),
            "--config-dir", str(CERTBOT_DIR),
            "--work-dir", str(DEPLOYMENT_DIR / "certbot-work"),
            "--logs-dir", "/var/log/traefik-certbot",
            "--cert-name", domain, "--email", email, "-d", domain,
        ],
        check=False,
    ).returncode == 0


def certificate_secrets(domain):
    lineage = CERTBOT_DIR / "live" / domain
    domain_id = hashlib.sha256(domain.encode()).hexdigest()[:16]
    cert_paths = {}
    mounts = []

    for field, filename in (("certFile", "fullchain.pem"), ("keyFile", "privkey.pem")):
        content = (lineage / filename).read_bytes()
        version = hashlib.sha256(content).hexdigest()[:20]
        target = f"traefik-{domain_id}-{filename}"
        name = f"{target}-{version}"
        ensure_swarm_object("secret", name, content)
        cert_paths[field] = f"/run/secrets/{target}"
        mounts.append({"source": name, "target": target, "mode": 0o400})

    return cert_paths, mounts


def service_spec(name):
    result = subprocess.run(
        ["docker", "service", "inspect", "--format", "{{json .Spec}}", name],
        capture_output=True, text=True, check=False,
    )
    if result.returncode == 0:
        return json.loads(result.stdout)
    if f"no such service: {name}" in result.stderr:
        return {}
    raise RuntimeError(result.stderr.strip())


def web_publications(spec):
    ports = spec.get("EndpointSpec", {}).get("Ports") or []
    return [port for port in ports if port["PublishedPort"] in WEB_PORTS]


def update_publications(name, operation, ports):
    if not ports:
        return
    command = ["docker", "service", "update", "--detach=false"]
    for port in ports:
        protocol = port.get("Protocol", "tcp")
        mode = port.get("PublishMode", "ingress")
        command.extend([
            f"--publish-{operation}",
            f"published={port['PublishedPort']},target={port['TargetPort']},"
            f"protocol={protocol},mode={mode}",
        ])
    subprocess.run([*command, name], check=True, timeout=120)


def deploy_stack(overrides, publish=True, timeout=None):
    overrides["services"]["traefik"]["ports"] = [
        f"{port}:{port}" for port in sorted(WEB_PORTS)
    ] if publish else []
    subprocess.run(
        [
            "docker", "stack", "deploy", "--resolve-image", "changed", "--detach=false",
            "--compose-file", str(DEPLOYMENT_DIR / "compose.yaml"),
            "--compose-file", "-", "traefik",
        ],
        input=json.dumps(overrides), text=True, check=True, timeout=timeout,
    )


def migrate_from_caddy(overrides, caddy_ports):
    # Start Traefik and wait for its health check before opening the public ports.
    deploy_stack(overrides, publish=False, timeout=180)
    print("Moving HTTP and HTTPS ports from Caddy to Traefik", flush=True)
    try:
        update_publications(CADDY_SERVICE, "rm", caddy_ports)
        deploy_stack(overrides, timeout=180)
        traefik_ports = web_publications(service_spec(SERVICE_NAME))
        if {port["PublishedPort"] for port in traefik_ports} != WEB_PORTS:
            raise RuntimeError("Traefik did not retain its HTTP and HTTPS ports")
    except (RuntimeError, subprocess.SubprocessError, KeyboardInterrupt):
        update_publications(SERVICE_NAME, "rm", web_publications(service_spec(SERVICE_NAME)))
        update_publications(CADDY_SERVICE, "add", caddy_ports)
        print("Restored Caddy's HTTP and HTTPS ports", flush=True)
        raise


def apply(migrate_caddy=False):
    settings = json.loads((DEPLOYMENT_DIR / "acme.json").read_text())
    certificates = []
    mounts = []
    failures = []

    for domain in settings["domains"]:
        if not issue_certificate(domain, settings["email"]):
            failures.append(domain)
        try:
            cert_paths, domain_mounts = certificate_secrets(domain)
        except FileNotFoundError:
            if domain not in failures:
                raise
            continue
        certificates.append(cert_paths)
        mounts.extend(domain_mounts)

    # JSON is also valid YAML for the Traefik file provider.
    tls_config = json.dumps({"tls": {"certificates": certificates}}).encode()
    config_name = f"traefik-tls-{hashlib.sha256(tls_config).hexdigest()[:20]}"
    ensure_swarm_object("config", config_name, tls_config)
    overrides = {
        "version": "3.8",
        "services": {
            "traefik": {
                "configs": [{"source": config_name, "target": "/etc/traefik/tls.yaml"}],
                "secrets": mounts,
            },
        },
        "configs": {config_name: {"external": True}},
        "secrets": {mount["source"]: {"external": True} for mount in mounts},
    }
    previous_spec = service_spec(SERVICE_NAME)
    caddy_ports = []
    if migrate_caddy:
        caddy_spec = service_spec(CADDY_SERVICE)
        if caddy_spec.get("Labels", {}).get("com.docker.stack.namespace") == "caddy":
            caddy_ports = web_publications(caddy_spec)

    if caddy_ports:
        if failures:
            raise SystemExit(f"Resolve DNS-01 failures before switching from Caddy: {', '.join(failures)}")
        migrate_from_caddy(overrides, caddy_ports)
    else:
        deploy_stack(overrides)

    if service_spec(SERVICE_NAME) != previous_spec:
        print("Traefik service updated")
    if failures:
        raise SystemExit(f"DNS-01 issuance or renewal failed for: {', '.join(failures)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deploy Traefik and synchronize its certificates")
    parser.add_argument("--migrate-caddy", action="store_true")
    options = parser.parse_args()
    with (DEPLOYMENT_DIR / "apply.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        apply(migrate_caddy=options.migrate_caddy)
