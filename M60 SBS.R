library(RCurl)
library(RJSONIO)

key <- '3a0e06e0-ff3f-4e7e-95ea-b8f4c989bb13'
url <- 'https://bustime.mta.info/api/siri/vehicle-monitoring.json?'
url2 <- 'https://bustime.mta.info/api/siri/stop-monitoring.json?'
OperatorRef <- 'MTA'
LineRef <- 'MTA%20NYCT_M60%2B'
Origin <- 403122
Destin <- 904199

#vehicle monitoring (This is to get the total number of buses on the route at any given time)
busrouteurl <- paste0(url,'key=',key,'&LineRef=',LineRef)
busrouteinfo <- getURL(busrouteurl)
raw <-fromJSON(busrouteinfo)
raw$Siri$ServiceDelivery$VehicleMonitoringDelivery[[1]]$VehicleActivity[[1]]
length(raw$Siri$ServiceDelivery$VehicleMonitoringDelivery[[1]]$VehicleActivity)

#key - your MTA Bus Time developer API key (required).  Go here to get one.
#OperatorRef - the GTFS agency ID to be monitored (optional).  Currently MTA.
#VehicleRef - the ID of the vehicle to be monitored (optional).  This is the 4-digit number painted on the side of the bus, for example 7560. Response will include all buses if not included. 
#LineRef - a filter by 'fully qualified' route name, GTFS agency ID + route ID (optional).
#DirectionRef - a filter by GTFS direction ID (optional).  Either 0 or 1.
#VehicleMonitoringDetailLevel - Determines whether or not the response will include the stops ("calls" in SIRI-speak) each vehicle is going to make (optional).  To get calls data, use value calls, otherwise use value normal (default is normal).
#MaximumNumberOfCallsOnwards Limit on the number of OnwardCall elements for each vehicle when VehicleMonitoringDetailLevel=calls
#MaximumStopVisits - an upper bound on the number of buses to return in the results.
#MinimumStopVisitsPerLine - a lower bound on the number of buses to return in the results per line/route (assuming that many are available)

#stop monitoring (This is to determine if a bus)
busoriginurl <- paste0(url2,'key=',key,'&OperatorRef=',OperatorRef,'&LineRef=',LineRef,'&MonitoringRef=',Origin,'&MaximumStopVisits=3')
busorigininfo <- getURL(busoriginurl)
raw <-fromJSON(busorigininfo)
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[1]]$MonitoredVehicleJourney$VehicleRef
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[2]]$MonitoredVehicleJourney$VehicleRef
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[3]]$MonitoredVehicleJourney$VehicleRef

busdestinurl <- paste0(url2,'key=',key,'&OperatorRef=',OperatorRef,'&LineRef=',LineRef,'&MonitoringRef=',Destin,'&MaximumStopVisits=3')
busdestininfo <- getURL(busdestinurl)
raw <-fromJSON(busdestininfo)
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[1]]$MonitoredVehicleJourney$VehicleRef
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[2]]$MonitoredVehicleJourney$VehicleRef
raw$Siri$ServiceDelivery$StopMonitoringDelivery[[1]]$MonitoredStopVisit[[3]]$MonitoredVehicleJourney$VehicleRef

#key - your MTA Bus Time developer API key (required).  Go here to get one.
#OperatorRef - the GTFS agency ID to be monitored (optional).  Currently, all stops have operator/agency ID of MTA. If left out, the system will make a best guess. Usage of the OperatorRef is suggested, as calls will return faster when populated.
#MonitoringRef - the GTFS stop ID of the stop to be monitored (required).  For example, 308214 for the stop at 5th Avenue and Union St towards Bay Ridge.
#LineRef - a filter by 'fully qualified' route name, GTFS agency ID + route ID (e.g. MTA NYCT_B63).
#DirectionRef - a filter by GTFS direction ID (optional).  Either 0 or 1.
#StopMonitoringDetailLevel - Determines whether or not the response will include the stops ("calls" in SIRI-speak) each vehicle is going to make after it serves the selected stop (optional).  To get calls data, use value calls, otherwise use value normal (default is normal).
#MaximumNumberOfCallsOnwards - Limits the number of OnwardCall elements returned in the query.
#MaximumStopVisits - an upper bound on the number of buses to return in the results.
#MinimumStopVisitsPerLine - a lower bound on the number of buses to return in the results per line/route (assuming that many are available)

#M60 Bus Status
library(XML)
MTAServiceStatus <- xmlTreeParse(getURL('http://web.mta.info/status/serviceStatus.txt'))
xmltop <- xmlRoot(MTAServiceStatus)
grep('M60',xmlValue(xmltop[[4]][[6]])) #This checks the MTA Service Status for any known delays for the M60 SBS Route.

#RFK Bridge Status
xmlValue(xmltop[[5]][[7]])

#LGA Delay Status

AirportStatus <- xmlTreeParse(getURL('http://www.fly.faa.gov/flyfaa/xmlAirportStatus.jsp'))
xmltop <- xmlRoot(AirportStatus)
grep('LGA',xmlValue(xmltop))
xmlValue(xmltop[[4]][[2]][[3]][[3]]) #average delay, will add in v2


#Weather
mykey <- '9f5fb48aa30f3a4f'
wundergroundurl <- paste0('http://api.wunderground.com/api/', mykey,'/conditions/forecast/q/NY/New_York.json')

fromurl<- function(someurl) {
# download webpage and parse JSON object
web <- getURL(someurl)
raw <-fromJSON(web)
currenttemp <- raw$current_observation$temp_f
currentweather <- raw$current_observation$weather
city <- as.character(raw$current_observation$display_location['full'])
result <-list(city=city,current=paste(currenttemp,'°F ',currentweather,sep=''))
names(result) <-c('city','current')
return(result)
}
fromurl(wundergroundurl)

id1 <- 36507
id2 <- 36514
id3 <- 36515
id4 <- 36516
id5 <- 36517
id6 <- 36526
token <- '07a45bd2c585dbd7bc94472d323e1ecd'

logs1url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id1)
logs1 <- getURL(logs1url)
setwd("/Users/harrisonadler/Desktop/R004/M60/Destin")
fileConn<-file("T0800-1200.txt")
writeLines(logs1, fileConn)
close(fileConn)

logs2url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id2)
logs2 <- getURL(logs2url)
setwd("/Users/harrisonadler/Desktop/R004/M60/Origin")
fileConn<-file("T0800-1200.txt")
writeLines(logs2, fileConn)
close(fileConn)

logs3url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id3)
logs3 <- getURL(logs3url)
setwd("/Users/harrisonadler/Desktop/R004/M60/ManBus")
fileConn<-file("T0800-1200.txt")
writeLines(logs3, fileConn)
close(fileConn)

logs4url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id4)
logs4 <- getURL(logs4url)
setwd("/Users/harrisonadler/Desktop/R004/M60/FAA")
fileConn<-file("T0800-1200.txt")
writeLines(logs4, fileConn)
close(fileConn)

logs5url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id5)
logs5 <- getURL(logs5url)
setwd("/Users/harrisonadler/Desktop/R004/M60/WUnderground")
fileConn<-file("T0800-1200.txt")
writeLines(logs5, fileConn)
close(fileConn)

logs6url <- paste0('https://www.easycron.com/rest/logs?token=',token,'&id=',id6)
logs6 <- getURL(logs6url)
setwd("/Users/harrisonadler/Desktop/R004/M60/BTStatus")
fileConn<-file("T0800-1200.txt")
writeLines(logs6, fileConn)
close(fileConn)


