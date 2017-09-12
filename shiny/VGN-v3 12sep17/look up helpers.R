# this is a file for look up tables and input selection vectors to be used in the shiny app

# setup a set of look up tables (R's equivalent to a Python dictionary) for transforming
#   attribute data to text labels

# choices for subnet input
subnet.choices <- c("Select a subnet",
                    "Information Sharing",
                    "Techncial Assistance",
                    "Program Coordination & Collaboration",
                    "Reporting",
                    "Financial Resource Sharing",
                    "Union: All Subnets")

# choices for policy tool input
pt.choices <- c("Select a policy tool",
                "Community Action",
                "Conservation Easements",
                "Contracting",
                "Cost Sharing",
                "Grants",
                "Litigation",
                "Loans/Guarantees",
                "Permitting",
                "Public Information",
                "Regulation Enforcement",
                "Tax Incentives",
                "Technical Assistance")

# translate policy tool input into the associated indices in the input org data
pt.choice.index <- c("Select a policy tool" = c(),
                     "Community Action" = "23",
                     "Conservation Easements" = "12",
                     "Contracting" = "19",
                     "Cost Sharing" = "17",
                     "Grants" = "16",
                     "Litigation" = "22",
                     "Loans/Guarantees" = "18",
                     "Permitting" = "15",
                     "Public Information" = "14",
                     "Regulation Enforcement" = "13",
                     "Tax Incentives" = "21",
                     "Technical Assistance" = "20")

# choices for action arenas
aa.choices <- c("Select an action arena",
                "Agricultural legislation",
                "Agricultural technical assistance",
                "Lake Champlain Basin Program (LCBP)",
                "Economic development legislation",
                "EPA-led TMDL",
                "Green Infrastructure Roundtable",
                "Municipal stormwater management",
                "Natural resource legislation",
                "Regional Planning Commissions (RPCs)",
                "Transportation legislation",
                "Transportation infrastructure",
                "VT Tactical Basin Planning (TBP)")

# choices for action arenas
aa.choice.index <- c("Select an action arena" = c(),
                     "Lake Champlain Basin Program (LCBP)" = "48",
                     "EPA-led TMDL" = "49",
                     "VT Tactical Basin Planning (TBP)" = "50",
                     "Regional Planning Commissions (RPCs)" = "51",
                     "Municipal stormwater management" = "52",
                     "Agricultural technical assistance" = "53",
                     "Transportation infrastructure" = "54",
                     "Agricultural legislation" = "55",
                     "Natural resource legislation" = "56",
                     "Economic development legislation" = "57",
                     "Transportation legislation" = "58",
                     "Green Infrastructure Roundtable" = "59")

# choices for policy domains
dm.choices <- c("Select a policy domain",
                "Agricultural land management",
                "Development",
                "Forestry",
                "River corridors",
                "Stormwater runoff management",
                "Wastewater management")

dm.choice.index <- c("Select a policy domain" = c(),
                     "Agricultural land management" = "60",
                     "Wastewater management" = "61",
                     "Stormwater runoff management" = "62",
                     "River corridors" = "63",
                     "Forestry" = "64",
                     "Development" = "65")

# translate capacity numeric labels to text labels
capacity.labels <- c("1" = "Very small orgaizations",
                     "2" = "Small organizations",
                     "3" = "Medium organizations",
                     "4" = "Large domestic organizations",
                     "5" = "Large international organizations")

# translate sector numeric labels to text labels
sector.labels <- c("1" = "Federal agencies",
                   "2" = "State/Provincial agencies",
                   "3" = "Regional gov't agencies",
                   "4" = "Local gov't agencies",
                   "5" = "Profit/For-Profit",
                   "6" = "NGO/Non-Profit",
                   "7" = "Individuals",
                   "8" = "Research Inst.",
                   "9" = "Int'l gov't agencies")

# translate jurisdiction numeric labels to text labels
juris.labels <- c("1" = "Vermont",
                  "2" = "New York",
                  "3" = "Quebec",
                  "4" = "United States",
                  "5" = "Canada",
                  "6" = "International")

# translate jurisdictional level numeric labels to text labels
juris.level.labels <- c("1" = "Village/Sub-town",
                        "2" = "Town/Municipality",
                        "3" = "County",
                        "4" = "Sub-state Region",
                        "5" = "Watershed",
                        "6" = "State",
                        "7" = "National",
                        "8" = "International")

