# Nix DevContainer Feature

## Overview

The Nix DevContainer feature provides comprehensive Nix package manager support for any DevContainer environment. This feature enables developers to use Nix packages and devshells seamlessly within containerized development environments.

## Features

### ✅ Multi-Architecture Support
- **x86_64** (Intel/AMD 64-bit)
- **aarch64** (ARM 64-bit, including Apple Silicon)

### ✅ Statically Compiled Nix Binary
- Uses statically linked Nix binaries for maximum compatibility
- No dependency on host system libraries
- Reliable installation across different base images

### ✅ Persistent Storage
- **Nix Store Volume**: `/nix` - Preserves downloaded packages across container rebuilds
- **Configuration Volume**: `/etc/nix` - Maintains Nix configuration and settings
- Significantly reduces build times on subsequent container starts

### ✅ VS Code Integration
- **Nix IDE Extension** (`jnoortheen.nix-ide`): Syntax highlighting, language server support
- **Nix DevContainer Extension** (`AkosPapp.nix-devcontainer`): Automatic devshell integration
- **Nil Language Server**: Advanced Nix language support with diagnostics and formatting
- **Alejandra Formatter**: Consistent code formatting

## How It Works

### 1. Installation Process
- Detects container architecture automatically
- Downloads appropriate statically compiled Nix binary
- Sets up Nix daemon and configuration
- Creates necessary directory structure and permissions

### 2. Persistent Volumes
The feature creates two Docker volumes:
```json
{
  "source": "nix",
  "target": "/nix",
  "type": "volume"
},
{
  "source": "etc-nix", 
  "target": "/etc/nix",
  "type": "volume"
}
```

### 3. Post-Start Command
Executes `/nix-daemon.sh` to:
- Start the Nix daemon
- Initialize the Nix store if needed
- Set up proper permissions

### 4. Automatic Devshell Integration
The included VS Code extension automatically:
- Scans workspace for `flake.nix` files
- Detects available devshells
- Prompts to update DevContainer configuration
- Enables seamless transition into Nix devshells

## Usage Examples

### Basic Usage
Simply add the feature to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/akospapp/nix-devcontainer/nix-devcontainer:0": {}
  }
}
```

### With Existing Flake
If you have a `flake.nix` in your workspace:

1. The VS Code extension will automatically detect it
2. You'll be prompted to update your DevContainer configuration
3. The devshell will be automatically available

### Manual Nix Usage
After the feature is installed, you can use Nix commands directly:

```bash
# Install packages temporarily
nix shell nixpkgs#hello

# Use nix develop with your flake
nix develop

# Install packages permanently
nix profile install nixpkgs#git
```

## Configuration Options

### Nix Language Server Settings
The feature pre-configures the Nil language server with sensible defaults:

```json
{
  "nix.enableLanguageServer": true,
  "nix.serverPath": "nil",
  "nix.serverSettings": {
    "nil": {
      "formatting": {
        "command": ["alejandra"]
      }
    }
  }
}
```

### Optional Diagnostics
You can customize diagnostics by uncommenting and modifying:

```json
{
  "nil": {
    "diagnostics": {
      "ignored": ["unused_binding", "unused_with"]
    }
  }
}
```

## Benefits

### 🚀 Performance
- Persistent Nix store reduces package download times
- Statically compiled binaries start faster
- Cached builds across container sessions

### 🔧 Developer Experience
- Automatic devshell detection and integration
- Rich IDE support with syntax highlighting and language server
- Consistent formatting with Alejandra

### 🌐 Compatibility
- Works with any base DevContainer image
- Multi-architecture support for diverse development environments
- No conflicts with existing package managers

### 📦 Isolation
- Nix packages don't interfere with system packages
- Clean separation between development and runtime dependencies
- Reproducible development environments

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure the post-start command has executed
   - Check that volumes are properly mounted

2. **Nix Command Not Found**
   - Restart the DevContainer to trigger post-start command
   - Verify the feature was properly added to devcontainer.json

3. **Language Server Not Working**
   - Check that the Nix IDE extension is installed
   - Verify nil is available in the container: `which nil`

### Getting Help

- Check the [Nix documentation](https://nixos.org/manual/nix/stable/)
- Visit the [DevContainers documentation](https://containers.dev/)
- Report issues on the project repository

## Contributing

This feature is part of the `nix-devcontainer.vscode` project. Contributions welcome!

- Repository: `AkosPapp/nix-devcontainer.vscode`
- VS Code Extension: `AkosPapp.nix-devcontainer`
