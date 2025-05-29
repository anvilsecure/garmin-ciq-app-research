import sys
import re

def normalize_symbol_name(name):
    """
    Normalizes the symbol name to comply with /^[a-z][a-z0-9_]*$/
    """
    # Replace invalid characters with underscores and lowercase the name
    name = re.sub(r"[^a-zA-Z0-9_]", "_", name).lower()
    # Ensure it starts with a lowercase letter, prepend "s_" if necessary
    if not re.match(r"^[a-z]", name):
        name = f"s_{name}"
    return name

def parse_api_symbol_file(file_path):
    """
    Parses the API symbol file and generates a Kaitai enum.
    """
    with open(file_path, "r") as f:
        lines = f.readlines()

    # Extract the API version from the first line
    api_version = lines[0].strip()

    # Parse the symbols and their values
    symbols = []
    for line in lines[1:]:
        line = line.strip()
        # Match formats with <> brackets
        match = re.match(r"^<([^>]+)>[\s>]*([\d]+)$", line)
        if not match:
            # Match formats without brackets
            match = re.match(r"^([^\s]+)\s+([\d]+)$", line)
        if match:
            symbol_name = normalize_symbol_name(match.group(1))
            symbol_value = int(match.group(2))
            symbols.append((symbol_name, symbol_value))
        else:
            print(f"Skipping malformed line: {line}")

    # Generate Kaitai enum
    kaitai_enum = f"""meta:
  id: ciq_sdk
  title: Symbols for CiQ SDK {api_version}

enums:
  symbols:
"""
    symbol_name_set = set()
    for symbol_name, symbol_value in symbols:
        if symbol_name in symbol_name_set:  # avoid duplicate symbol definitions
            symbol_name += '_'
        kaitai_enum += f"    {symbol_value}: {symbol_name}\n"
        symbol_name_set.add(symbol_name)

    return kaitai_enum

# Write the generated Kaitai enum to a file
def write_kaitai_enum(output_path, kaitai_enum):
    with open(output_path, "w") as f:
        f.write(kaitai_enum)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path/to/ciq/sdk/api.db>")
        sys.exit(1)
    # Example usage
    input_file = sys.argv[1]  # Path to the API symbol file

    kaitai_enum = parse_api_symbol_file(input_file)
    output_file = "ciq_sdk.ksy"  # Output Kaitai file
    write_kaitai_enum(output_file, kaitai_enum)

    print(f"Kaitai enum successfully generated! Stored in {output_file}")

