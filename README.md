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