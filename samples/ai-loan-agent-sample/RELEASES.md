# Release Management

This sample uses GitHub Releases to host `workflows.zip` for 1-click deployment.

## Release Process

1. **Make local changes**
   - Run `Deployment/infrastructure/BundleAssets.ps1` to regenerate `workflows.zip`
   - Update `workflowsZipUrl` in `Deployment/infrastructure/main.bicep` with new version tag:
     ```bicep
     workflowsZipUrl: 'https://github.com/modularity/logicapps-labs/releases/download/v1.1.0/workflows.zip'
     ```

2. **Push changes**
   - Commit and push workflow source files and updated Bicep file to git

3. **Publish release**
   - Go to https://github.com/modularity/logicapps-labs/releases
   - Click "Draft a new release"
   - Create tag matching Bicep URL (e.g., `v1.1.0`)
   - Add release title and notes documenting changes
   - Attach `1ClickDeploy/workflows.zip` to the release
   - Click "Publish release"

## Why Attach workflows.zip to Releases?

`workflows.zip` is tracked in Git LFS. While GitHub's web UI automatically resolves LFS files for browser downloads, raw URLs (`raw.githubusercontent.com`) and programmatic downloads (like Azure deployment scripts) get the 3-line LFS pointer instead of the binary, causing "ajaxExtended call failed" or malformed trigger schema errors.

GitHub Releases provide a `releases/download` URL that serves the actual binary.

