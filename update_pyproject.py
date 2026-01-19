# Add torch version in pyproject.toml
# and set CUDA version in simpleindex.toml
# according to the environment variables

import os

with open("./pyproject.toml", "r") as f:
    text = f.read()

# If TORCH_VERSION is provided (e.g. 2.7.0), use it to determine bounds
if os.getenv("TORCH_VERSION"):
    torch_ver = os.getenv("TORCH_VERSION")
    # Assuming semantic versioning: 2.7.0 -> >=2.7.0, <2.8.0
    parts = torch_ver.split('.')
    if len(parts) >= 2:
        major, minor = parts[0], parts[1]
        next_minor = int(minor) + 1
        text = text.replace('"torch"', f'"torch>={major}.{minor}.0,<{major}.{next_minor}.0"')
    else:
        # Fallback if version format is unexpected
        text = text.replace('"torch"', f'"torch=={torch_ver}"')
else:
    # Legacy logic fallback
    TORCH_MINOR_VERSION = os.getenv("TORCH_MINOR_VERSION", "6")
    TORCH_PATCH_VERSION = os.getenv("TORCH_PATCH_VERSION", "0")
    TORCH_PATCH_VERSION_NEXT = str(int(TORCH_PATCH_VERSION) + 1)
    TORCH_VERSION = f"2.{TORCH_MINOR_VERSION}.{TORCH_PATCH_VERSION}.dev0"
    TORCH_VERSION_NEXT = f"2.{TORCH_MINOR_VERSION}.{TORCH_PATCH_VERSION_NEXT}"
    text = text.replace('"torch"', f'"torch>={TORCH_VERSION},<{TORCH_VERSION_NEXT}"')

with open("./pyproject.toml", "w") as f:
    f.write(text)


with open("./simpleindex.toml", "r") as f:
    text = f.read()

CUDA_MAJOR_VERSION = os.getenv("CUDA_MAJOR_VERSION", "12")
CUDA_MINOR_VERSION = os.getenv("CUDA_MINOR_VERSION", "6")
if os.getenv("TORCH_IS_NIGHTLY") in ["1", "nightly"]:
    text = text.replace("/cu126/", f"/nightly/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")
elif os.getenv("TORCH_IS_NIGHTLY") == "test":
    text = text.replace("/cu126/", f"/test/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")
else:
    text = text.replace("/cu126/", f"/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")

with open("./simpleindex.toml", "w") as f:
    f.write(text)
