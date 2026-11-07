import base64

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import x25519


def wg_public_key(private_key_b64: str) -> str:
    if not private_key_b64:
        return ""
    try:
        priv_bytes = base64.b64decode(private_key_b64.strip())
        priv_key = x25519.X25519PrivateKey.from_private_bytes(priv_bytes)
        pub_bytes = priv_key.public_key().public_bytes(
            encoding=serialization.Encoding.Raw, format=serialization.PublicFormat.Raw
        )
        return base64.b64encode(pub_bytes).decode("ascii")
    except Exception:
        return ""


class FilterModule(object):
    def filters(self):
        return {"wg_public_key": wg_public_key}
