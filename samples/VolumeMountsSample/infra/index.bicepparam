using './index.bicep'

// Location to create the resources in.
param location = 'eastus'

// Change this param to deploy a new set of resources.
param dep_name = 'fnacavol'

// Change this param to use NFS mount instead of SMB.
param use_nfs_mount = false

// Use this to provide a sub-path in a fileshare for the volume mount.
param sub_path = ''

// Use this to mount the volume as read-only.
param use_read_only = false
