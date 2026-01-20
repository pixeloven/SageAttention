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
    raise RuntimeError("TORCH_VERSION environment variable is required.")

with open("./pyproject.toml", "w") as f:
    f.write(text)


with open("./simpleindex.toml", "r") as f:
    text = f.read()

if os.getenv("CUDA_VERSION"):
    cuda_ver = os.getenv("CUDA_VERSION")
    parts = cuda_ver.split('.')
    if len(parts) >= 2:
        CUDA_MAJOR_VERSION = parts[0]
        CUDA_MINOR_VERSION = parts[1]
    else:
        # Fallback if parsing fails but env var exists (unlikely but safe)
        CUDA_MAJOR_VERSION = "12"
        CUDA_MINOR_VERSION = "8"
else:
    # Default to 12.8
    CUDA_MAJOR_VERSION = "12"
    CUDA_MINOR_VERSION = "8"
if os.getenv("TORCH_IS_NIGHTLY") in ["1", "nightly"]:
    text = text.replace("/cu128/", f"/nightly/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")
elif os.getenv("TORCH_IS_NIGHTLY") == "test":
    text = text.replace("/cu128/", f"/test/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")
else:
    text = text.replace("/cu128/", f"/cu{CUDA_MAJOR_VERSION}{CUDA_MINOR_VERSION}/")

with open("./simpleindex.toml", "w") as f:
    f.write(text)
