# Dockerfiles

Widely applicable docker base images for reuse across multiple projects.

Currently there is only one Dockerfile. It is a general purpose image for building and testing solana programs and clients. It includes rust, cargo, solana, anchor, nodejs, npm, yarn, and cargo-llvm-cov.

## Tags
Each image gets a unique tag that is explicit about component versions. Explicitly versioned tags need to be frozen in time and always point to the same image. Never tag a new image with an explicitly versioned tag that was used for a prior image.

### pattern
```
jetprotocol/builder:rust-<version>-node-<version>-solana-<version>-anchor-<version>-<image-version>
```
`<image-version>`: Increment when uploading another image with the same components as a previous image. 

### Reusable tags
These tags may be reassigned to new images as they are published:
- `latest`: points to the latest image that was built with the default arguments.
