library(googleAnalyticsR) # for working with Google Analytics
library(jsonlite) # for our json files

googleAuthR::gar_set_client("~/projects/gar-reporting/gar-creds.json")

devtools::reload(pkg = devtools::inst("googleAnalyticsR"))

options(googleAuthR.scopes.selected = 
          "https://www.googleapis.com/auth/analytics")

ga_auth() # authenticate
#?googleAuthR # help with auth over Google 

ga_account <- fromJSON("~/projects/gar-reporting/ga-account.json")

ga_tableid <- ga_account$sitename # select the site from our account

# get data only for a specific webpage 
dim_filter_pagepath <- filter_clause_ga4(list(dim_filter(dimension = "pagePath", operator = "REGEXP", expressions = "^\\/(foldername)\\/(pagename)\\/$")))
mypage_usage <- google_analytics(ga_tableid,
                                 date_range = c("2019-09-02", "2019-09-08"),
                                 metrics = c("uniquePageviews", "uniqueEvents"),
                                 dimensions = c("pagePath"),
                                 dim_filters = dim_filter_pagepath,
                                 anti_sample = TRUE)

# store dataset locally for later use
make_csv <- write.csv(mypage_usage,
                      "~/projectname/filename.csv")

# fetch list of segments in GA
ga_segments <- ga_segment_list()

ab_controlgroup <- segment_ga4("control", segment_id = "gaid::xxxxxxxxxxxxxx")
ab_variantgroup <- segment_ga4("variant", segment_id = "gaid::yyyyyyyyyyyyyy")

ab_control <- google_analytics(ga_tableid,
                                                  date_range = c("2019-10-21","2019-10-23"),
                                                  metrics = c("users","uniqueEvents"),
                                                  dimensions = c("dimension14", "eventCategory", "eventAction", "eventLabel"),
                                                  segments = ab_controlgroup,
                                                  anti_sample = TRUE)

make_csv <- write.csv(ab_control,
                      "~/projectname/ab_controlgroup.csv")

ab_variant <- google_analytics(ga_tableid,
                                                 date_range = c("2019-10-21","2019-10-23"),
                                                 metrics = c("users","uniqueEvents"),
                                                 dimensions = c("dimension14", "eventCategory", "eventAction", "eventLabel"),
                                                 segments = ab_variantgroup,
                                                 anti_sample = TRUE)

make_csv <- write.csv(ab_variant,
                      "~/projectname/ab_variantgroup.csv")