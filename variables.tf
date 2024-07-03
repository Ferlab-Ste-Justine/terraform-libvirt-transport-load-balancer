variable "name" {
  description = "Name to give to the vm."
  type        = string
}

variable "vcpus" {
  description = "Number of vcpus to assign to the vm"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory in MiB"
  type        = number
  default     = 8192
}

variable "volume_id" {
  description = "Id of the disk volume to attach to the vm"
  type        = string
}

variable "libvirt_networks" {
  description = "Parameters of libvirt network connections if a libvirt networks are used."
  type = list(object({
    network_name = string
    network_id = string
    prefix_length = string
    ip = string
    mac = string
    gateway = string
    dns_servers = list(string)
  }))
  default = []
}

variable "macvtap_interfaces" {
  description = "List of macvtap interfaces."
  type        = list(object({
    interface     = string
    prefix_length = string
    ip            = string
    mac           = string
    gateway       = string
    dns_servers   = list(string)
  }))
  default = []
}

variable "cloud_init_volume_pool" {
  description = "Name of the volume pool that will contain the cloud init volume"
  type        = string
}

variable "cloud_init_volume_name" {
  description = "Name of the cloud init volume"
  type        = string
  default = ""
}

variable "ssh_admin_user" { 
  description = "Pre-existing ssh admin user of the image"
  type        = string
  default     = "ubuntu"
}

variable "admin_user_password" { 
  description = "Optional password for admin user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_admin_public_key" {
  description = "Public ssh part of the ssh key the admin will be able to login as"
  type        = string
}

variable "ssh_host_key_rsa" {
  description = "Predefined rsa ssh host key"
  type        = object({
    public  = string
    private = string
  })
  default     = {
    public  = ""
    private = ""
  }
}

variable "ssh_host_key_ecdsa" {
  description = "Predefined ecdsa ssh host key"
  type        = object({
    public  = string
    private = string
  })
  default     = {
    public  = ""
    private = ""
  }
}

variable "load_balancer" {
  description = "Properties of the load balancer"
  type = object({
    cluster = string
    node_id = string
  })
  default     = {
    cluster = ""
    node_id = ""
  }
}

variable "control_plane" {
  description = "Properties of the control plane"
  type = object({
    log_level        = string
    version_fallback = string
    server           = object({
      port                = number
      max_connections     = number
      keep_alive_time     = string
      keep_alive_timeout  = string
      keep_alive_min_time = string
    })
    etcd        = object({
      key_prefix         = string
      endpoints          = list(string)
      connection_timeout = string
      request_timeout    = string
      retries            = number
      ca_certificate     = string
      client             = object({
        certificate = string
        key         = string
        username    = string
        password    = string
      })
    })
  })
}

variable "ssh_tunnel" {
  description = "Setting for restricting the bastion access via an ssh tunnel only"
  type        = object({
    enabled = bool
    ssh     = object({
      user           = string
      authorized_key = string
    })
  })
  default     = {
    enabled = false
    ssh     = {
      user           = ""
      authorized_key = ""
    }
  }
}

variable "fluentbit" {
  description = "Fluent-bit configuration"
  type = object({
    enabled = bool
    load_balancer_tag = string
    control_plane_tag = string
    node_exporter_tag = string
    metrics = object({
      enabled = bool
      port    = number
    })
    forward = object({
      domain = string
      port = number
      hostname = string
      shared_key = string
      ca_cert = string
    })
  })
  default = {
    enabled = false
    load_balancer_tag = ""
    control_plane_tag = ""
    node_exporter_tag = ""
    metrics = {
      enabled = false
      port = 0
    }
    forward = {
      domain = ""
      port = 0
      hostname = ""
      shared_key = ""
      ca_cert = ""
    }
  }
}

variable "fluentbit_dynamic_config" {
  description = "Parameters for fluent-bit dynamic config if it is enabled"
  type = object({
    enabled = bool
    source  = string
    etcd    = object({
      key_prefix     = string
      endpoints      = list(string)
      ca_certificate = string
      client         = object({
        certificate = string
        key         = string
        username    = string
        password    = string
      })
    })
    git     = object({
      repo             = string
      ref              = string
      path             = string
      trusted_gpg_keys = list(string)
      auth             = object({
        client_ssh_key         = string
        server_ssh_fingerprint = string
      })
    })
  })
  default = {
    enabled = false
    source = "etcd"
    etcd = {
      key_prefix     = ""
      endpoints      = []
      ca_certificate = ""
      client         = {
        certificate = ""
        key         = ""
        username    = ""
        password    = ""
      }
    }
    git  = {
      repo             = ""
      ref              = ""
      path             = ""
      trusted_gpg_keys = []
      auth             = {
        client_ssh_key         = ""
        server_ssh_fingerprint = ""
      }
    }
  }

  validation {
    condition     = contains(["etcd", "git"], var.fluentbit_dynamic_config.source)
    error_message = "fluentbit_dynamic_config.source must be 'etcd' or 'git'."
  }
}

variable "chrony" {
  description = "Chrony configuration for ntp. If enabled, chrony is installed and configured, else the default image ntp settings are kept"
  type        = object({
    enabled  = bool,
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#server
    servers  = list(object({
      url     = string,
      options = list(string)
    })),
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#pool
    pools    = list(object({
      url     = string,
      options = list(string)
    })),
    //https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#makestep
    makestep = object({
      threshold = number,
      limit     = number
    })
  })
  default     = {
    enabled  = false
    servers  = []
    pools    = []
    makestep = {
      threshold = 0,
      limit     = 0
    }
  }
}

variable "custom_certificates" {
  description = "A set of custom certificate-key pairs that can be added to the vm and configured in envoy to perform tls termination"
  type        = list(object({
    certificate = object({
      path  = string
      content = string
    })
    key = object({
      path  = string
      content = string
    })
  }))
  default     = []
}


variable "install_dependencies" {
  description = "Whether to install all dependencies in cloud-init"
  type        = bool
  default     = true
}