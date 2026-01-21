import os
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(description="Update pyproject.toml with specific torch dependencies.")
    parser.add_argument("target", nargs="?", default="./pyproject.toml", help="Path to pyproject.toml file")
    args = parser.parse_args()

    target_file = args.target
    if not os.path.exists(target_file):
        print(f"Error: Target file '{target_file}' does not exist.")
        sys.exit(1)

    print(f"Updating {target_file}...")

    with open(target_file, "r") as f:
        text = f.read()

    # If TORCH_VERSION is provided (e.g. 2.7.0), use it to determine bounds
    if os.getenv("TORCH_VERSION"):
        torch_ver = os.getenv("TORCH_VERSION")
        # Assuming semantic versioning: 2.7.0 -> >=2.7.0, <2.8.0
        parts = torch_ver.split('.')
        if len(parts) >= 2:
            major, minor = parts[0], parts[1]
            next_minor = int(minor) + 1
            new_spec = f'"torch>={major}.{minor}.0,<{major}.{next_minor}.0"'
            print(f"  Replacing '\"torch\"' with {new_spec}")
            text = text.replace('"torch"', new_spec)
        else:
            raise RuntimeError(f"Invalid TORCH_VERSION format: {torch_ver}. Expected semantic versioning (e.g., 2.7.0).")
    else:
        raise RuntimeError("TORCH_VERSION environment variable is required.")

    with open(target_file, "w") as f:
        f.write(text)
    
    print("Done.")

if __name__ == "__main__":
    main()
