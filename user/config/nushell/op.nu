export def sum [
  --start (-s): any
] {
  if $start == null {
    $in | reduce { |it, acc| $acc + $it }
  } else {
    $in | reduce -f $start { |it, acc| $acc + $it }
  }
}

export def read-env [] {
  let $env_file = if $in == null {
    pwd | path join '.env'
  } else {
    $in
  }

  open $env_file
  | lines
  | where {|line| $line != "" and not ($line | str starts-with "#") }
  | parse '{key}={value}'
  | update value {|row|
    $row.value
    | split row "#"
    | first
    | str trim
    | str trim -c '"'
    | str trim -c "'"
  }
  | transpose -r -d
}

export def with-tunnel [
  ssh_target: string,
  ports: string,
  code: closure,
] {
  let ports = $ports | parse "{local}:{remote}" | first
  let local_port = $ports.local | into int
  let remote_port = $ports.remote | into int

  let job = job spawn {
    ssh -N -L $"($local_port):127.0.0.1:($remote_port)" $ssh_target
  }

  let pid = job list | where id == $job | get pid | first
  print pid;

  try {
    mut attempts = 0;
    loop {
      if $attempts > 50 {
        error make {msg: "SSH tunnel timeout, port never opened"}
      }

      if (ps | where pid == $pid | is-empty) {
        error make {msg: "SSH process died."}
      }

      if (nc -z -w 1 127.0.0.1 $local_port | complete).status == 0 {
        break
      }

      sleep 100ms
      $attempts += 1;
    }

    do $code
  } finally {
    job kill $job
  }
}
