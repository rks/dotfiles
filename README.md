# dotfiles

Files that (mostly) start with a dot and do configurish things.

## Setup (not yet scripted)

### Turn off visible scrollbar for macOS Terminal

```shell
defaults write com.apple.Terminal AppleShowScrollBars -string WhenScrolling
```

### Enable 1Password SSH agent, including for Docker Desktop

1. Enable the [1Password SSH agent](https://developer.1password.com/docs/ssh/agent).
2. Create an easier-to-remember symlink for the agent:
    ```sh
    mkdir -p $HOME/.1password; \
    ln -s $HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock $HOME/.1password/agent.sock
    ```
3. Create a LaunchAgent (`$HOME/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist`) that replaces the default macOS agent socket with the 1Password agent socket:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.1password.SSH_AUTH_SOCK</string>
        <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>-c</string>
            <string>/bin/ln -sf $HOME/.1password/agent.sock \$SSH_AUTH_SOCK</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
    ```
4. Configure SSH (`$HOME/.ssh/config`) to use the 1Password agent:
    ```
    Host *
        IdentityAgent "$HOME/.1password/agent.sock"
    ```
5. Configure Git (`$HOME/.gitconfig`) to sign commits with the 1Password agent:
    ```
    [commit]
        gpgsign = true
    [gpg]
        format = ssh
    [gpg "ssh"]
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    ```

#### For Docker Desktop

1. Mount `/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock`
2. Set the SSH_AUTH_SOCK environment variable to `/run/host-services/ssh-auth.sock`
3. Add required hosts to the container user's `$HOME/.ssh/known_hosts`.
