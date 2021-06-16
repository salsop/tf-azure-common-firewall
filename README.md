# VM-Series Common Firewall Deployment

## Setting Terraform Variables

View which versions are available by running the Azure CLI:
```
$ az vm image list --all --publisher PaloAltoNetworks --offer vmseries-flex -o table                                                               ─╯
```

Example output from the command:
```
$ az vm image list --all --publisher PaloAltoNetworks --offer vmseries-flex -o table                                                               ─╯

Offer          Publisher         Sku      Urn                                            Version
-------------  ----------------  -------  ---------------------------------------------  ---------
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:10.0.0  10.0.0
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:10.0.1  10.0.1
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:10.0.2  10.0.2
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:10.0.3  10.0.3
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:9.1.2   9.1.2
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:9.1.3   9.1.3
vmseries-flex  paloaltonetworks  bundle1  paloaltonetworks:vmseries-flex:bundle1:9.1.6   9.1.6
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:10.0.0  10.0.0
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:10.0.1  10.0.1
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:10.0.2  10.0.2
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:10.0.3  10.0.3
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:9.1.2   9.1.2
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:9.1.3   9.1.3
vmseries-flex  paloaltonetworks  bundle2  paloaltonetworks:vmseries-flex:bundle2:9.1.6   9.1.6
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:10.0.0     10.0.0
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:10.0.1     10.0.1
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:10.0.2     10.0.2
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:10.0.3     10.0.3
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:9.1.2      9.1.2
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:9.1.3      9.1.3
vmseries-flex  paloaltonetworks  byol     paloaltonetworks:vmseries-flex:byol:9.1.6      9.1.6
```


## Module Use:
You can also use this Repo as a basic module for deployment:

```terraform
module "panos-hub" {
  source = "github.com/salsop/tf-azure-common-firewall"

//  Azure Configuration
  resource_group_name = "panos-hub"
  resource_location   = "westeurope"
    
  virtual_network_name = "vnet"
  virtual_network_cidr = "10.1.0.0/16"

//  Panorama Configuration
  panorama = {
    primary     = "panorama.paloaltonetworks.com"
    secondary   = ""
    vm_auth_key = "44******25"
    apikey      = "LU***=="
  }

//  VM-Series
  vmseries = {
    no_of_instances = 2
    version         = "10.0.4"
    license         = "bundle2"
    offer           = "vmseries-flex"
    instance_size   = "Standard_DS3_v2"
    authcodes       = ""

    admin_username = "pandemo"
    admin_password = "Pal0Alto!"

    public_management = true
  }

  // CSP Self Registration
  csp_pin_id    = ""
  csp_pin_value = ""
}
```
