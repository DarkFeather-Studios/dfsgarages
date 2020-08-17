Config = {
    
    RecoveryLocation = vector3(1955.23, 3766.45, 32.2),
    RecoveryLocationBlip = nil,

    ImpoundLocations = {
        {Loc=vector3(-447.18, 6001.52, 31.69), BlipObject=nil, Type="car", Name="Paleto Bay Sheriff's Station Impound Lot"},
        {Loc=vector3(-1071.15, -853.35, 4.87), BlipObject=nil, Type="car", Name="Vespucci PD Impound Lot"},
        {Loc=vector3(-1146.26, -2864.42, 13.95), BlipObject=nil, Type="heli", Name="FAA Helicopter Impound Hangar"},
        {Loc=vector3(-1273.88, -3384.75, 13.22), BlipObject=nil, Type="plane", Name="FAA Plane Impound Hangar"},
        {Loc=vector3(-798.76, -1522.2, 1.0), BlipObject=nil, Type="boat", Name="Higgins Boat Impound Bay"},
    },

    GarageLocations = {
        {Store=vector3(294.35  , -330.65 , 44.92), Pull=vector3(270.96  , -341.1  , 44.92), Type="car"  , Name="North Elgin Garage"                     , BlipObject=nil},
        {Store=vector3(-34.41  , -1079.35, 26.69), Pull=vector3(-26.73  , -1082.17, 26.24), Type="car"  , Name="PDM Garage"                             , BlipObject=nil , JobRequired={"cardealer", "consultant"}},
        {Store=vector3(-36.88  , -1099.26, 35.96), Pull=vector3(-36.88  , -1099.26, 35.96), Type="heli" , Name="PDM Heli Hangar"                        , BlipObject=nil , JobRequired={"cardealer", "consultant"}},
        {Store=vector3(-938.05 , -3178.60, 13.23), Pull=vector3(-1044.44, -2952.16, 13.96), Type="plane", Name="LSIA Plane Hangar"                      , BlipObject=nil},
        {Store=vector3(-798.71 , -1487.51, 1.0)  , Pull=vector3(-797.60 , -1502.67, 1.0)  , Type="boat" , Name="Higgins Boat Yard"                      , BlipObject=nil},
        {Store=vector3(-334.14 , 300.11  , 85.36), Pull=vector3(-345.09 , 298.98  , 84.71), Type="car"  , Name="Big Red Caboose Garage"                 , BlipObject=nil},
        {Store=vector3(456.31  , -1023.77, 28.44), Pull=vector3(456.31  , -1023.77, 28.44), Type="car"  , Name="LSPD Garage"                            , BlipObject=nil , JobRequired={"offpolice", "police", "consultant"}},
        {Store=vector3(132.62  , 6617.39 ,31.81) , Pull=vector3(128.05  , 6605.29 ,31.86) , Type="car"  , Name="Paleto Truck Stop Parking"              , BlipObject=nil},
        {Store=vector3(1870.39 , 3693.37 , 33.6) , Pull=vector3(1861.93 , 3706.77 , 33.35), Type="car"  , Name="BCSO Garage"                            , BlipObject=nil , JobRequired={"offsheriff", "sheriff", "consultant"}},
        {Store=vector3(    0.0 ,  0.0    , -2000), Pull=vector3(1848.36 , 3670.0  , 33.7) , Type="car"  , Name="BCSO Vehicle Recovery Garage"           , BlipObject=nil},
        {Store=vector3(1041.62 , -781.83 ,58.01) , Pull=vector3(1022.03 , -764.7  , 57.95), Type="car"  , Name="Mirror Park Public Parking"             , BlipObject=nil},
        {Store=vector3(-358.79 , -115.28 ,38.70) , Pull=vector3(-358.79 , -115.28 ,38.70) , Type="car"  , Name="Central LS Mechanic's Garage"           , BlipObject=nil, JobRequired={"mechanic"}},
        {Store=vector3(1700.77 , 3597.12 ,35.47) , Pull=vector3(1714.47 , 3596.95 ,35.32) , Type="car"  , Name="Sandy Shores Fire Department Parking"   , BlipObject=nil, JobRequired={"firedept"}},
        {Store=vector3(-3.86, -1519.37, 29.21  ) , Pull=vector3(1.71, -1510.69, 29.42   ) , Type="car"  , Name="Strawberry Church Garage"               , BlipObject=nil, JobRequired={"ballas", "losvatos", "vagos", "grovestreetfamily"}},
        {Store=vector3(-43.88, -1681.93, 29.43)  , Pull=vector3(-43.88, -1681.93, 29.43 ) , Type="car"  , Name="<MISSING_MOSLEYGARAGE_STRING>"          , BlipObject=nil, JobRequired={"mosley"}},
        {Store=vector3(-2141.28, 3251.23, 32.81) , Pull=vector3(-2141.28, 3251.23, 32.81) , Type="car"  , Name="Fort Zancudo JOT Car Lot"               , BlipObject=nil, JobRequired={"consultant", "offpolice", "police", "offsheriff", "sheriff", "offranger", "ranger", "offstatepatrl", "statepatrol"}},
        {Store=vector3( -1926.03, 3023.75, 32.81), Pull=vector3( -1926.03, 3023.75, 32.81), Type="heli" , Name="Fort Zancudo JOT Heli Lot"              , BlipObject=nil, JobRequired={"consultant", "offpolice", "police", "offsheriff", "sheriff", "offranger", "ranger", "offstatepatrl", "statepatrol"}},
        {Store=vector3(-2070.12, 2894.09, 32.81) , Pull=vector3(-2070.12, 2894.09, 32.81) , Type="plane", Name="Fort Zancudo JOT Plane Lot"             , BlipObject=nil, JobRequired={"consultant", "offpolice", "police", "offsheriff", "sheriff", "offranger", "ranger", "offstatepatrl", "statepatrol"}},
        {Store=vector3(1689.32, 3246.55, 40.86)  , Pull=vector3(1689.32, 3246.55, 40.86)  , Type="plane", Name="Sandy Airfield Plane Lot"               , BlipObject=nil},
        {Store=vector3(2040.66, 4792.87, 43.50), Pull=vector3(2069.62, 4808.34, 43.45)    , Type="heli" , Name="GrapeseedAIR Heli Lot"                  , BlipObject=nil},
        {Store=vector3(2103.78, 4796.20, 41.06), Pull=vector3(2103.78, 4796.20, 41.06)    , Type="plane", Name="GrapeseedAIR Plane Lot"                 , BlipObject=nil},
        {Store=vector3(2103.01, 4765.08, 41.15), Pull=vector3(2103.01, 4765.08, 41.15)    , Type="car"  , Name="GrapeseedAIR Employee Car Lot"          , BlipObject=nil, JobRequired={"grapemech"}},
        {Store=vector3(317.28, -547.73, 28.74), Pull=vector3(326.14, -541.4, 28.74)       , Type="car"  , Name="EMS Car Park"                            , BlipObject=nil, JobRequired={"ems", "offems"}}
        
    },
}

