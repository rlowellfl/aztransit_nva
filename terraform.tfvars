# Environmental variables
environment = "temporary"
location    = "westus"

# Tag names and values
required_tags = {
  WorkloadName       = "Transit Hub"
  DataClassification = "Sensitive"
  Criticality        = "Business-Critical"
  BusinessUnit       = "Information Technology"
  OpsTeam            = "Network Team"
  ApplicationName    = "Transit Hub"
  Approver           = "some@guy.com"
  BudgetAmount       = "1234"
  CostCenter         = "99999"
  DR                 = "Mission-Critical"
  Env                = "Production"
  EndDate            = "2025-12-31"
  Owner              = "some@gal.com"
  Requester          = "someother@dude.com"
  TicketNumber       = "54321"
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
bootdiagsname = "rlsamplebootdiagsname"
nvavalues = {
  deploycount    = "2"
  vmsize         = "Standard_DS3_v2"
  publisher      = "paloaltonetworks"
  offer          = "vmseries-flex"
  sku            = "byol"
  version        = "10.1.3"
  nvauser        = "nvausername"
  nvapass        = "uT%m04r6uP&z"
  bootstrapacct  = ""
  bootstrapshare = ""
}
