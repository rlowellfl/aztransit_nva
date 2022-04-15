# Environmental variables
environment = "prod"
location    = "eastus2"

# Hub VNet variables
hubvnetspace       = ["10.0.1.0/24"]
hubdnsservers      = ["8.8.8.8", "8.8.4.4"]
hubmgmtsubrange    = ["10.0.1.0/27"]
hubuntrustsubrange = ["10.0.1.32/27"]
hubtrustsubrange   = ["10.0.1.64/27"]
hubgatewayrange    = ["10.0.1.96/27"]
routeserverrange   = ["10.0.1.128/27"]
allowedips         = ["<your static ip here>"]

# Palo NVA variables
bootdiagsname   = "<storage account name>"
palodeploycount = "2"
palovmsize      = "Standard_DS2v4"
palooffer       = "vmseries-flex"
palosku         = "bundle2"
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