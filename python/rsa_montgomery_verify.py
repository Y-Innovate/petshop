"""
RSA signature verification using Montgomery modular exponentiation.

Assumes the standard public exponent e = 65537 (binary: 1 0000 0000 0000 0001,
17 bits) so that s^e mod n = s^(2^16 + 1) mod n, computed as:

    16 repeated squarings, then one final multiplication by the original
    Montgomery form of s.

This uses the classic word-based Montgomery REDC algorithm (64-bit limbs),
so the 64-bit reduction constant n0' is actually used by the arithmetic,
not just printed for reference.

Fill in SIGNATURE_HEX and MESSAGE (or EXPECTED_HASH_HEX) before running.
"""

import hashlib

# ----------------------------------------------------------------------
# Public key
# ----------------------------------------------------------------------
N_HEX = (
    "87e75fb279cc602a4cccb56b147b0a864d0d6eb03ae96d862f0c8351d240afa"
    "2d5cb814fd713a8935985d6515166e927d84124bc13e162b20a37e309ec77b1"
    "f23c424e0de0a701fe5e70a58ceda80282b2f637328968b3dab769b60b23cc1"
    "2b04dccd3c960e6b4afc4e76dbccad2e4979e88a902b8f8cea1b291765ce36a"
    "c7ab1d96e1dac020bf3232325138c3ba32a59b04834eb63b20aa98ad8a74ead"
    "d372facd7942bd04ad9aaedcb9d90192599776d8836ddd578c0053450b2e032"
    "f17421d1e511cdad988a0d15d76b8b0fd7ff01b15f03f743049241de5b77294"
    "ada6bfbb4913aaf9376ca893e04b2a2bd5a3ceea8f0d8f7d2d1bad8f8864b5721ce9401"
)
N = int(N_HEX, 16)
E = 65537  # 0x10001 -> 16 squarings + 1 multiply

# ----------------------------------------------------------------------
# TODO: fill these in
# ----------------------------------------------------------------------
SIGNATURE_HEX = "4A7EE1352A1DFBF2600E32E1407A039000A1B076866C01CDF4FACE76B60B4C42B0496FD656801F66644636AA0A646BA124DCDE2732DD798709CE7E2C41911C534DAAB73E29697DF78F62D805FFC907C15862B389BD10A05F4CDC06DB6533A16F9AD0127E88EB1003FE3611FB4885756ADFF6F34133A8500BB01759EF845D837961F1C66EAF85938918737BAE123CAED518DEA2160880E4B93EDAA9367B0C8470E79B772CFC8B7AFEF86D95597281451765F4AC7E94A0CAAA71A701E323D8577BEF55D98109AC71B5F44BCA7BC4B00DBD0C1A89F073D0DF3E2128912918D881E72F32B5119F7EEC00A9B7F00972999A585C2BDEEC69D8F520C8932199971F02DC"   # the signature to verify, as hex
MESSAGE = b""        # the message that was signed
HASH_ALG = hashlib.sha256                      # hash function used when signing

# ASN.1 DigestInfo prefixes for PKCS#1 v1.5 (add more if you need a different hash)
DIGESTINFO_PREFIX = {
    "sha256": bytes.fromhex("3031300d060960864801650304020105000420"),
    "sha1":   bytes.fromhex("3021300906052b0e03021a05000414"),
    "sha512": bytes.fromhex("3051300d060960864801650304020305000440"),
}

# ----------------------------------------------------------------------
# Montgomery setup
# ----------------------------------------------------------------------
W = 64                      # limb size in bits
WORD_MASK = (1 << W) - 1

s = (N.bit_length() + W - 1) // W   # number of 64-bit limbs needed for n
R = 1 << (W * s)                     # R = 2^(64*s)

R2_mod_n = (R * R) % N
n0 = N & WORD_MASK
n0_prime = (-pow(n0, -1, 1 << W)) % (1 << W)   # -n^-1 mod 2^64


def redc(T):
    """Word-based Montgomery reduction: returns T * R^-1 mod N."""
    print(hex(T))
    for i in range(s):
        u_i = ((T >> (W * i)) & WORD_MASK) * n0_prime & WORD_MASK
        imed = (u_i * N) << (W * i)
        imed = hex(imed)
        T += (u_i * N) << (W * i)
        print(hex(T))
    T >>= (W * s)
    if T >= N:
        T -= N
    return T


def mont_mul(a, b):
    """Montgomery multiplication: returns (a * b * R^-1) mod N."""
    return redc(a * b)


def to_mont(a):
    """Convert an ordinary integer into Montgomery form: a * R mod N."""
    return mont_mul(a, R2_mod_n)


def from_mont(a_mont):
    """Convert out of Montgomery form back to an ordinary integer."""
    return redc(a_mont)


# ----------------------------------------------------------------------
# Main verification flow
# ----------------------------------------------------------------------
def main():
    signature = int(SIGNATURE_HEX, 16)

    print("=== Setup ===")
    print(f"n bit length        : {N.bit_length()}")
    print(f"limbs (64-bit words): {s}")
    print(f"R = 2^{W*s}")
    print(f"R^2 mod n           = {hex(R2_mod_n)}")
    print(f"64-bit n0'          = {hex(n0_prime)}")
    print()

    # Step 1: convert signature into Montgomery form
    sig_mont = to_mont(signature)
    print("=== Montgomery form of signature ===")
    print(f"s * R mod n = {hex(sig_mont)}")
    print()

    # Step 2: 16 successive squarings (since e = 2^16 + 1)
    print("=== Squaring steps (computing s^(2^16) in Montgomery form) ===")
    x = sig_mont
    for i in range(16):
        x = mont_mul(x, x)
        print(f"After squaring {i + 1:2d}: {hex(x)}")
    print()

    # Step 3: final multiply by the original Montgomery form of s
    result_mont = mont_mul(x, sig_mont)
    print("=== Final multiplication (s^(2^16) * s = s^65537, Montgomery form) ===")
    print(f"result (Montgomery form) = {hex(result_mont)}")
    print()

    # Step 4: convert back out of Montgomery form
    result = from_mont(result_mont)
    print("=== Decrypted value (s^e mod n, ordinary form) ===")
    print(f"{hex(result)}")
    print()

    # Cross-check using plain modpow, to make sure the Montgomery result is correct
    expected = pow(signature, E, N)
    print("Sanity check against pow(signature, e, n):", result == expected)
    print()

    # Step 5: strip PKCS#1 v1.5 padding and pull out the embedded hash
    k = (N.bit_length() + 7) // 8
    em = result.to_bytes(k, "big")

    print("=== Recovered EM (padded message) ===")
    print(em.hex())
    print()

    if em[:2] == b"\x00\x01":
        try:
            sep = em.index(b"\x00", 2)
            padding = em[2:sep]
            digest_info = em[sep + 1:]
            if all(b == 0xFF for b in padding) and len(padding) >= 8:
                for name, prefix in DIGESTINFO_PREFIX.items():
                    if digest_info.startswith(prefix):
                        embedded_hash = digest_info[len(prefix):]
                        print(f"Detected hash algorithm: {name}")
                        print(f"Embedded hash   : {embedded_hash.hex()}")
                        computed_hash = HASH_ALG(MESSAGE).hexdigest()
                        print(f"Computed hash   : {computed_hash}")
                        print(f"Signature valid : {embedded_hash.hex() == computed_hash}")
                        return
                print("DigestInfo prefix not recognized:", digest_info.hex())
            else:
                print("PKCS#1 v1.5 padding malformed.")
        except ValueError:
            print("Could not locate 0x00 separator in padding.")
    else:
        print("EM does not start with 0x00 0x01 - not standard PKCS#1 v1.5 padding.")
        print("(Could be raw RSA, PSS padding, or a different scheme.)")


if __name__ == "__main__":
    main()
