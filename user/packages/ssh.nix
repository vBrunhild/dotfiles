{
  programs.ssh = {
    startAgent = true;
    extraConfig =
      # ssh_config
      ''
        Host *
          # Identity
          IdentityFile ~/.ssh/id_ed25519
          AddKeysToAgent yes

          # Security
          HashKnownHosts yes

          # Connection
          ServerAliveCountMax 5
          ServerAliveInterval 60
          TCPKeepAlive yes

          # Control
          ControlMaster auto
          ControlPath ~/.ssh/master-%r@%h:%p
      '';
  };
}
