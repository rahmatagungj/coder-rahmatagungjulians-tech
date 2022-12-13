terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.20.2"
    }
  }
}


# Admin parameters
variable "Architecture" {
  description = "arch: What architecture is your Docker host on?"
  default = "amd64"
  validation {
    condition     = contains(["amd64", "arm64", "armv7"], var.Architecture)
    error_message = "Value must be amd64, arm64, or armv7."
  }
}
variable "OS" {
  description = <<-EOF
  What operating system is your Coder host on?
  EOF
  default="Linux"

  validation {
    condition     = contains(["MacOS", "Windows", "Linux"], var.OS)
    error_message = "Value must be MacOS, Windows, or Linux."
  }
}


provider "docker" {
  host = var.OS == "Windows" ? "npipe:////.//pipe//docker_engine" : "unix:///var/run/docker.sock"
}

provider "coder" {
}

data "coder_workspace" "me" {
}

# Desktop
resource "coder_app" "novnc" {
  agent_id      = coder_agent.dev.id
  slug          = "vnc"
  display_name  = "noVNC Desktop"
  icon          = "https://ppswi.us/noVNC/app/images/icons/novnc-192x192.png"
  url           = "http://localhost:6081?autoconnect=1&resize=scale"
  share         = "owner"
  subdomain    = true
}

# code-server
resource "coder_app" "code-server" {
  agent_id      = coder_agent.dev.id
  slug          = "code"
  display_name  = "Code Editor"
  icon          = "https://cdn.icon-icons.com/icons2/2107/PNG/512/file_type_vscode_icon_130084.png"
  url           = "http://localhost:13337/?folder=/home/coder/projects"
  share         = "owner"
  subdomain     = true
}

# vim
resource "coder_app" "vim" {
  agent_id     = coder_agent.dev.id
  slug         = "vim"
  display_name = "Vim"
  icon         = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Icon-Vim.svg/1200px-Icon-Vim.svg.png"
  command      = "vim"
  share        = "owner"
  subdomain     = false
}

resource "coder_app" "jupyter" {
  agent_id     = coder_agent.dev.id
  slug         = "lab"
  display_name = "Jupyter Lab"
  url          = "http://localhost:8888"
  icon         = "/icon/jupyter.svg"
  share        = "owner"
  subdomain    = true
}

resource "coder_agent" "dev" {
  arch           = var.Architecture
  os             = "linux"
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# start code-server
code-server --auth none --port 13337 &

# start VNC
echo "Creating desktop..."
mkdir -p "$XFCE_DEST_DIR"
cp -rT "$XFCE_BASE_DIR" "$XFCE_DEST_DIR"

# Skip default shell config prompt.
cp /etc/zsh/newuser.zshrc.recommended $HOME/.zshrc

echo "Initializing Supervisor..."
nohup supervisord

# start JupyterLab
$HOME/.local/bin/jupyter lab --ServerApp.token='' --ip='*'
  EOT
}

variable "docker_image" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "desktop-base"

  # List of images available for the user to choose from.
  # Delete this condition to give users free text input.
  validation {
    condition     = contains(["desktop-base"], var.docker_image)
    error_message = "Invalid Docker image!"
  }

  # Prevents admin errors when the image is not found
  validation {
    condition     = fileexists("images/${var.docker_image}.Dockerfile")
    error_message = "Invalid Docker image. The file does not exist in the images directory."
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}-root"
}

resource "docker_image" "coder_image" {
  name = "coder-base-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  build {
    path       = "./images/"
    dockerfile = "${var.docker_image}.Dockerfile"
    tag        = ["coder-${var.docker_image}:v0.3"]
  }

  # Keep alive for other workspaces to use upon deletion
  keep_locally = true
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.coder_image.latest

  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  dns      = ["1.1.1.1"]
  # Use the docker gateway if the access URL is 127.0.0.1 
  command = ["sh", "-c", replace(coder_agent.dev.init_script, "127.0.0.1", "host.docker.internal")]
  env     = ["CODER_AGENT_TOKEN=${coder_agent.dev.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  # users home directory
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
