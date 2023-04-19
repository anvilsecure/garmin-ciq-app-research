import os
import sys
import struct
import argparse

# python3 -m pip install cryptography
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import load_der_private_key
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding

from ciq import Ciq


def pack_section(section: Ciq.Section, fake_size: int = None) -> bytes:
    """Pack a PRG sectoin back to bytes. Possible to specify a fake size for fuzzing."""
    data = b""
    data += struct.pack(">I", section.section_type)
    if fake_size:
        data += struct.pack(">I", fake_size)
    else:
        data += struct.pack(">I", section.length)
    if section.length:
        data += section._raw_data
    print(f"Packing section 0x{section.section_type:08x}; total of {len(data)} bytes")
    return data


def verify_prg(prg_data: bytes, signature: bytes, key: rsa.RSAPrivateKey) -> None:
    """Verify the signature of a PRG file."""
    print("Verifying signature")
    pub_key = key.public_key()
    pub_key.verify(signature, prg_data, padding.PKCS1v15(), hashes.SHA1())
    print("Signature is valid")


def sign_prg(prg_data: bytes, key: rsa.RSAPrivateKey) -> bytes:
    """Sign data with the specified keys."""
    print(f"Signing {len(prg_data)} bytes")
    sig = key.sign(prg_data, padding.PKCS1v15(), hashes.SHA1())
    return sig


def generate_section_signature(signature: bytes, sig_section: Ciq.Section) -> bytes:
    """Generate the section of the developer signature of a PRG file."""
    data = b""
    data += signature
    data += sig_section.data.modulus
    data += struct.pack(">I", sig_section.data.exponent)

    header = b""
    header += struct.pack(">I", Ciq.Section.SectionMagic.section_magic_developer_signature_block.value)
    header += struct.pack(">I", len(data))
    return header + data


def generate_section_end() -> bytes:
    """Generate the section end of a PRG file."""
    header = b""
    header += struct.pack(">I", Ciq.Section.SectionMagic.section_magic_end.value)
    header += struct.pack(">I", 0)
    return header


def patch_prg(prg: Ciq, key: rsa.RSAPrivateKey) -> bytes:
    """Process a PRG file, perform modifications, and regenerate a valid signature."""
    # checking that last section is the expected end of section.
    if not prg.sections[-1].section_type == Ciq.Section.SectionMagic.section_magic_end.value:
        print(f"Expected last section to be end of section; got {prg.sections[-1].section_type}")
        return

    # checking second to last section is signature.
    if not prg.sections[-2].section_type == Ciq.Section.SectionMagic.section_magic_developer_signature_block.value:
        print(f"Expected second to last section to be signature section; got {prg.sections[-2].section_type}")
        return

    # original signature section before doing any change.
    sig_section = prg.sections[-2]

    new_prg = b""
    for section in prg.sections[:-2]:
        if section.section_type == Ciq.Section.SectionMagic.section_magic_entry_points.value:
            # TODO: Do something about the entry points section.
            pass
        elif section.section_type == Ciq.Section.SectionMagic.section_magic_data.value:
            # TODO: Do something else about the data section.
            pass
        new_prg += pack_section(section)

    print("Fixing signature")
    sig = sign_prg(new_prg, key)
    new_sig_section = generate_section_signature(sig, sig_section)
    new_prg += new_sig_section

    new_prg += generate_section_end()

    return new_prg


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--developer_key", required=True)
    parser.add_argument("-f", "--prg_file", required=True)
    parser.add_argument("-o", "--out_file")
    args = parser.parse_args()

    with open(args.developer_key, "rb") as dev_key:
        developer_key = dev_key.read()
        key = load_der_private_key(developer_key, password=None)
        if not isinstance(key, rsa.RSAPrivateKey):
            print(f"Expected RSA private key; got {type(key)}")
            sys.exit(-1)

    prg = Ciq.from_file(args.prg_file)
    print(f"PRG has {len(prg.sections)} sections")

    patched_prg = patch_prg(prg, key)

    if args.out_file:
        new_filename = args.out_file
    else:
        new_filename = os.path.basename(args.prg_file).rsplit(".", maxsplit=1)[0] + "_patched.prg"

    print(f"Saving patched prg file as {new_filename}")
    with open(new_filename, "wb") as f:
        f.write(patched_prg)
