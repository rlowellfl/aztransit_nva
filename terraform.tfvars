# Environmental variables
environment = "prod"
location    = "eastus2"

# Tag names and values
required_tags = {
  WorkloadName = "Transit Hub"
  DataClassification = "Sensitive"
  Criticality = "Business-Critical"
  BusinessUnit = "Information Technology"
  OpsTeam = "Network Team"
  ApplicationName = "Transit Hub"
  Approver = "some@guy.com"
  BudgetAmount = "1234"
  CostCenter = "99999"
  DR = "Mission-Critical"
  Env = "Production"
  EndDate = "2025-12-31"
  Owner = "some@gal.com"
  Requester = "someother@dude.com"
  TicketNumber = "54321"
}

# Hub VNet variables
hubvnetspace       = ["10.0.0.0/23"]
hubdnsservers      = ["8.8.8.8", "8.8.4.4"]
hubmgmtsubrange    = ["10.0.0.0/27"]
hubuntrustsubrange = ["10.0.0.32/27"]
hubtrustsubrange   = ["10.0.0.64/27"]
hubgatewayrange    = ["10.0.0.96/27"]
routeserverrange   = ["10.0.0.128/27"]
bastionrange       = ["10.0.1.0/26"]
allowedips         = ["11.22.33.44"]

# Palo NVA variables
bootdiagsname   = "rlsamplebootdiagsname"
palodeploycount = "2"
palovmsize      = "Standard_DS2v4"
palooffer       = "vmseries-flex"
palosku         = "byol"
paloversion     = "10.1.3"
palonvauser     = "azpalovmseries"
palonvapass     = "<Palo Alto VM Series password>"

# Spoke network variables
spoke_network = {
  sandbox1 = {
    spokeVnetName  = "sandbox1"
    spokeVnetRange = ["10.0.2.0/24"]
    spokeSubName   = "subnet1"
    spokeSubRange  = ["10.0.2.0/24"]
  }

  sandbox2 = {
    spokeVnetName  = "sandbox2"
    spokeVnetRange = ["10.0.3.0/24"]
    spokeSubName   = "subnet1"
    spokeSubRange  = ["10.0.3.0/24"]
  }
}