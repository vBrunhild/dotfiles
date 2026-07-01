{
  programs.ssh = {
    startAgent = true;
    extraConfig =
      # ssh_config
      ''
        Host *
          SetEnv TERM=xterm-256color

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

        Host ped-stag
          User bruno.moretti
          HostName ped-stag.agencehost.com.br

        Host ped-prod
          User bruno.moretti
          HostName ped-prod.agencehost.com.br
          IdentityFile ~/.ssh/ped-prod.pem

        Host musk
          User bruno.moretti
          HostName musk.agencehost.com.br
          IdentityFile ~/.ssh/musk.pem
      '';
  };
}
