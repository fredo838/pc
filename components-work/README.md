# Work Components

Centrica-specific development tools and infrastructure for work projects.

## 📋 Components List

### Version Control & Git
| # | Component | Purpose |
|---|-----------|---------|
| 03 | **gitlab** | GitLab SSH configuration + `glab` CLI (Centrica GitLab) |

### Infrastructure & AWS
| # | Component | Purpose |
|---|-----------|---------|
| 06 | **aws-vpn-client** | AWS VPN client (Centrica work network) |
| 07 | **aws-cli** | AWS CLI v2 (work AWS projects) |

## 🚀 Quick Installation

### Install All Work Components

```bash
cd components-work
bash install-all.sh all
```

### Interactive Selection

```bash
cd components-work
bash install-all.sh
# Follow prompts to select components
```

### Install Individual Component

```bash
cd components-work/03-gitlab
bash install.sh
```

## 📖 Component-Specific Guides

Each component has detailed documentation:

- [03-gitlab/install.sh](03-gitlab/install.sh) - GitLab SSH setup
- [06-aws-vpn-client/install.sh](06-aws-vpn-client/install.sh) - Work VPN
- [07-aws-cli/install.sh](07-aws-cli/install.sh) - AWS CLI

## 📁 Directory Structure

```
components-work/
├── 03-gitlab/
│   └── install.sh
├── 06-aws-vpn-client/
│   └── install.sh
├── 07-aws-cli/
│   └── install.sh
├── install-all.sh          (Master script)
└── README.md               (This file)
```

## 📋 Recommended Installation Order

For Centrica work setup:

1. **03-gitlab** - Set up GitLab SSH keys (do first)
2. **06-aws-vpn-client** - Install work VPN
3. **07-aws-cli** - Install AWS CLI

## ⚙️ Configuration

### GitLab (03-gitlab)

Generates SSH key pair for Centrica GitLab and installs/configures the `glab` CLI. Safe to re-run — it detects existing state and skips steps that are already done (no key regeneration, no reinstall, no re-auth):
- Email: `frederik.bode@centrica.com`
- Key location: `~/.ssh/id_ed25519_centrica`
- Installs `glab` via `apt` if not already present
- Configures `glab` to use the `ssh` git protocol
- Prompts an interactive `glab auth login` if not already authenticated

After running, add the public key to GitLab (if not already added):
1. Go to https://gitlab.com/-/user_settings/ssh_keys
2. Paste contents of `~/.ssh/id_ed25519_centrica.pub`
3. Test: `ssh -T git@gitlab.com`
4. Test glab: `glab auth status`

### AWS VPN Client (06-aws-vpn-client)

Installs AWS VPN Client for Centrica network access:
- Uses GTK GUI
- Connects to Centrica AWS infrastructure
- Required for accessing work resources

### AWS CLI (07-aws-cli)

AWS CLI v2 for command-line AWS operations:
- After installation, configure credentials:
  ```bash
  aws configure
  ```
- Use work AWS account credentials
- Can be used alongside personal AWS setup

## 🔑 SSH Keys

### Generate New Keys

Keys are generated during installation. You need to:

1. Copy the public key from output
2. Add to https://gitlab.com/profile/keys
3. Test connection:
   ```bash
   ssh -T git@gitlab.com
   ```

### View Generated Keys

```bash
# List Centrica GitLab key
ls -la ~/.ssh/id_ed25519_centrica*

# View public key
cat ~/.ssh/id_ed25519_centrica.pub
```

### Add to SSH Agent

Keys are automatically added to SSH agent during installation.

To verify:
```bash
ssh-add -l
```

## 🔄 Integration with Global Components

### Combined Setup

For full work environment, install both:

```bash
# Install global components first
cd components-global
bash install-all.sh all

# Then install work components
cd ../components-work
bash install-all.sh all
```

### VSCode Profiles

With VSCode installed (components-global), work projects automatically use:
```
~/.vscode-work/
```

The `.zshrc` `code` command detects paths under `/Users/fred/centrica/` and uses work profile.

### Git Configuration

Global git config is set up in `components-global/02-github` (personal).

Work-specific config:
```bash
# Set work profile for Centrica repos
cd /path/to/centrica/project
git config user.email frederik.bode@centrica.com
git config user.name "Frederik Bode"
```

Or set globally for work directory:
```bash
# In ~/.gitconfig under [includeIf]
[includeIf "gitdir:/Users/fred/centrica/"]
    path = ~/.gitconfig-work
```

## 🌐 AWS Configuration

### After Installing AWS CLI

1. Configure credentials:
   ```bash
   aws configure
   ```

2. Use work AWS credentials (not personal)

3. Test access:
   ```bash
   aws sts get-caller-identity
   ```

### Docker Credential Helper

For GCR (if used):
```bash
gcloud auth configure-docker europe-west1-docker.pkg.dev
```

### Multiple AWS Profiles

To manage multiple AWS accounts/profiles:

```bash
# Set up profiles
aws configure --profile work
aws configure --profile personal

# Use specific profile
aws s3 ls --profile work
aws s3 ls --profile personal
```

## 🔐 VPN Setup

### AWS VPN Client

After installation:

1. Open AWS VPN Client: Search for "AWS VPN Client"
2. Configure VPN endpoint (provided by Centrica IT)
3. Connect to VPN when accessing work resources

### Network Access

Once VPN is connected, you can access:
- GitLab: https://gitlab.com/centrica
- AWS resources in Centrica account
- Internal services and tools

## 📊 Post-Installation Checklist

After installing all components:

- [ ] GitLab SSH key generated and added to account
- [ ] Test GitLab access: `ssh -T git@gitlab.com`
- [ ] AWS VPN Client installed and configured
- [ ] AWS CLI configured with work credentials
- [ ] Test AWS access: `aws sts get-caller-identity`
- [ ] VSCode opens work projects with work profile
- [ ] Zsh matches between terminal and editor

## 🚨 Important Notes

### Centrica-Specific

These components are specific to Centrica development:
- Email: `frederik.bode@centrica.com`
- GitLab instance: https://gitlab.com
- AWS account: Centrica's AWS organization

### Security

- Keep `~/.ssh/id_ed25519_centrica` secure (private key)
- Don't commit private keys to git
- Use VPN for accessing internal resources
- Rotate credentials periodically

### Credentials

- AWS credentials stored in `~/.aws/credentials` and `~/.aws/config`
- Treat as sensitive - don't commit to git
- Use `.aws/credentials` file or environment variables

## 🔄 Using Both Work and Personal

If you have both Centrica work and personal projects:

1. Install `components-global` first
2. Install `components-work` for work setup
3. Install `components-personal` for personal setup (separate GitHub, Chrome)

VSCode automatically selects profile based on directory:
- `/Users/fred/centrica/*` → work profile
- `/Users/fred/projects/*` → personal profile

## 🆘 Troubleshooting

### GitLab SSH Not Working

```bash
# Test connection
ssh -vvv -T git@gitlab.com

# Verify key is loaded
ssh-add -l | grep centrica

# If not loaded
ssh-add ~/.ssh/id_ed25519_centrica
```

### AWS CLI Not Found

```bash
# Check installation
aws --version

# Add to PATH if needed
export PATH=$HOME/.local/bin:$PATH
```

### VPN Won't Connect

1. Verify VPN endpoint configuration
2. Check internet connection
3. Contact Centrica IT for support
4. Try restarting AWS VPN Client

### AWS Credentials Not Working

```bash
# Verify configuration
cat ~/.aws/config
cat ~/.aws/credentials

# Test access
aws sts get-caller-identity

# If fails, reconfigure
aws configure
```

## 📞 Support

### Centrica-Specific Support

For Centrica-specific issues:
- GitLab: https://gitlab.com/help
- AWS: Contact Centrica IT/Cloud team
- VPN: Contact Centrica IT support

### General Issues

Refer to upstream documentation:
- GitLab: https://docs.gitlab.com/
- AWS CLI: https://docs.aws.amazon.com/cli/
- AWS VPN Client: https://docs.aws.amazon.com/vpn/

## 📝 Notes

- Work components are independent of personal components
- Can be installed alongside personal components without conflicts
- Git configuration should use work email for Centrica repos
- AWS credentials should be work account, not personal

## 🎯 Next Steps

1. Install global components first (if not already done)
2. Run `install-all.sh` with interactive selection
3. Generate GitLab SSH key and add to account
4. Configure AWS credentials
5. Test VPN connection
6. Verify git/AWS access
7. Start working on Centrica projects

## 📚 Related Documentation

- [../README-INSTALL.md](../README-INSTALL.md) - Overall installation guide
- [../components-global/README.md](../components-global/README.md) - Global components
- [../components-personal/README.md](../components-personal/README.md) - Personal components
