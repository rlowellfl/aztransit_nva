# Environmental variables
environment = "prod"
location    = "azureregion"

# Tag names and values
required_tags = {
}

# Hub VNet variables
hubvnet = {
  addrspace        = ["10.0.0.0/23"]
  dnsservers       = ["8.8.8.8", "8.8.4.4"]
  mgmtsubrange     = ["10.0.0.0/27"]
  untrustsubrange  = ["10.0.0.32/27"]
  trustsubrange    = ["10.0.0.64/27"]
  gatewayrange     = ["10.0.0.96/27"]
  routeserverrange = ["10.0.0.128/27"]
  AppGwsubrange    = ["10.0.0.160/27"]
  bastionrange     = ["10.0.1.0/26"]
  allowedips       = ["11.22.33.44"]
}

# NVA variables
bootdiagsname = "examplepalobootdiag"
nvavalues = {
  deploycount    = "2"
  vmsize         = "Standard_DS3_v2"
  publisher      = "paloaltonetworks"
  offer          = "vmseries-flex"
  sku            = "byol"
  version        = "10.2.2"
  nvauser        = "nvausername"
  nvapass        = "yoursupersecurepasswordhere"
  bootstrapacct  = ""
  bootstrapshare = ""
}
