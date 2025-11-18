# Release Management

This sample uses GitHub Releases to host `workflows.zip` for 1-click deployment.

## Release Process

1. **Make local changes and bundle**
   - Make changes to workflow files in `LogicApps/` directory
   - Run `1ClickDeploy/BundleAssets.ps1` to regenerate `workflows.zip` and `sample-arm.json`
   - Commit and push all changes

2. **Publish release**
   - Go to https://github.com/modularity/logicapps-labs/releases
   - Click "Draft a new release"
   - Create version tag (e.g., `v1.0.2`)
   - Add release title and notes documenting changes
   - **Check "Set as the latest release"** (required - Bicep points to `/releases/latest/`)
   - Attach `1ClickDeploy/workflows.zip` to the release
   - Click "Publish release"

**Note:** `main.bicep` uses `/releases/latest/download/workflows.zip`, so you don't need to update version numbers in the Bicep file. Just ensure your new release is marked as "latest".

## Why Attach workflows.zip to Releases?

`workflows.zip` is tracked in Git LFS. While GitHub's web UI automatically resolves LFS files for browser downloads, raw URLs (`raw.githubusercontent.com`) and programmatic downloads (like Azure deployment scripts) get the 3-line LFS pointer instead of the binary, causing "ajaxExtended call failed" or malformed trigger schema errors.

GitHub Releases provide a `releases/download` URL that serves the actual binary.

