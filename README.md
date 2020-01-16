# **Google Analytics Reporting in R**

These are examples of how to use the [googleAnalyticsR](https://code.markedmondson.me/googleAnalyticsR/) package by Mark Edmondson. 

The package offers support to download data from Google Analytics via the Google Analytics Reporting API. 

This is valuable when you have a large dataset, f.ex more than ten pages with 5,000 rows in each, and when you want to attempt to download data without sampling.

In my case I found it useful when the dataset contains a few hundred thousand rows. If you have a lot of traffic and custom dimensions containing unique IDs such as timestamp, client ID and session ID this is likely to occur. Doing this manually takes a lot of time.

Rather than downloading these datasets from the user interface of Google Analytics, this package handles downloading the entire dataset for you, freeing up your time to plan your analysis and reporting instead. :)

This has helped me run AB tests, spend less time gathering data and focus more time on interpreting the information to draw conclusions.

**Use cases**
* Creating reports with large datasets
* Performing AB-tests and other statistical tests
* ETL jobs for a database
* Data mining

**Contents**
* [Authentication](https://github.com/tobmcv/gar-reporting#authentication)
* [Creating Reports](https://github.com/tobmcv/gar-reporting#creating-reports)
* [Reports with filters](https://github.com/tobmcv/gar-reporting#example-query-for-reporting-with-filters)
* [Reports with segments](https://github.com/tobmcv/gar-reporting#example-query-for-reporting-with-segments)
* [Fields in reporting queries](https://github.com/tobmcv/gar-reporting#fields-in-example-requests)

## **Authentication**

I recommend reading [Mark Edmondson's guide for setting up a project in Google Cloud](http://code.markedmondson.me/googleAnalyticsR/articles/setup.html#your-own-google-project)

I use the googleAuthR package for authentication but there are other options.
```r 
googleAuthR::gar_set_client
```

I create 2 JSON-files to store credentials and account-specific information. These are exempted in `.gitinore`. 

The first contains project credentials from Google Cloud, and the second contains the unique table IDs for querying different properties in Google Analytics.

## **Creating reports**
I recommend you choose starting with reports that have filters OR reports with segments. 

Creating reports is simple with googleAnalyticsR. I recommend the following syntax to benefit from Analytics Reporting API version 4.

Use the [Metrics and Dimension explorer](https://ga-dev-tools.appspot.com/dimensions-metrics-explorer/) for the API name of your metrics and dimensions.

Use the [Google Analytics Account Explorer](https://ga-dev-tools.appspot.com/account-explorer/) to look up the View IDs for your account properties.


### **Example Query for reporting with filters**

Here is an example query to create a report with a flat table
```r
mypage_usage <- google_analytics(ga_tableid,
                                 date_range = c("2019-09-02", "2019-09-08"),
                                 metrics = c("uniquePageviews", "uniqueEvents"),
                                 dimensions = c("pagePath"),
                                 dim_filters = dim_filter_pagepath,
                                 anti_sample = TRUE)

```

This lets us download a table consisting of 2 metrics: Unique Pageviews and Unique Events, and the dimension Page Path. We also use a filter to hone in a specific webpage. Finally we add the anti_sample argument to ensure googleAnalyticsR tries to retrieve a complete dataset before downloading it to R.

**Making filters**

I highly recommend using filters in your report to speed up the download of your dataset and to reduce the risk of sampling. Google Analytics will often let you get more data without sampling if you just filter the dataset thoroughly in advance. If you use filters in segments this is less likely to work.

Simply assign a variable and use it in your query object. In this example we look at page path, which requires the URI only, without the hostname and protocol.
```r
dim_filter_pagepath <- filter_clause_ga4(list(dim_filter(dimension = "pagePath", operator = "REGEXP", expressions = "^\\/(foldername)\\/(pagename)\\/$")))
```

I prefer to use Regular Expressions since it lets you choose between a group of multiple values, f.ex URLs, or a specific page URL. You can also use other filter criteria, such as exact match and containing like so

```r
dim_filter_pagepath <- filter_clause_ga4(list(dim_filter(dimension = "pagePath", operator = "EXACT", expressions = "/foldername/pagename")))
```

### **Example Query for reporting with segments**
To run a query for a report based on **segments** you can try this approach

**If you already have a segment** in Google Analytics you can retrieve the data that matches the segment by using the `segment_ga4` argument.

To see the list of segments and IDs you can run store this as a table since it's easier to read, f.ex `ga_segments <- ga_segment_list()`. Your custom segments will appear with the prefix `gaid::`.

For example, retrieving 2 segments for an AB split test:
```r
ab_controlgroup <- segment_ga4("control", segment_id = "gaid::xxxxxxxxxxxxxx")
ab_variantgroup <- segment_ga4("variant", segment_id = "gaid::yyyyyyyyyyyyyy")
```
Find your segment ID and then use it to store your segments with an easily recognisable variable name

Then compose a query containing the segment, for example like this
```r
ab_mypage_controlgroup <- google_analytics(ga_tableid,
                                                  date_range = c("2019-10-21","2019-10-23"),
                                                  metrics = c("users","uniqueEvents"),
                                                  dimensions = c("dimension14", "eventCategory", "eventAction", "eventLabel"),
                                                  segments = ab_controlgroup,
                                                  anti_sample = TRUE)
```

This retrieves a table with the metrics Users and Unique Events, and combines both standard and custom dimensions, containing our 14th Custom Dimension, Event Category, Event Action and Event Label. We add a segment to retrieve only data for our control group in an AB split test, and add anti_sample just to be sure we can get unsampled data. The custom dimension contains a session specific ID so we can compare our segments by a unique ID for each visit.

If you want to **create a segment on the fly** here is an example
```r
se <- segment_element("eventAction",
                      operator = "REGEXP",
                      type = "DIMENSION",
                      expressions = "optimize.*",
                      scope = "HIT")
```

### **Fields in example requests**
These are the fields used in the example queries

| Object | Argument | Explanation | Example Values |
| :--------- | --------: | :----------- | :--------------|
| `google_analytics` | `viewId` | unique ID for the View in Google Analytics| a variable `ga_tableid` or string `1234567` |
| `google_analytics` | `date_range` | date range to query | `c("2019-09-02", "2019-09-08")` |
| `google_analytics` | `metrics` | list of GA metrics | `c("uniquePageviews", "uniqueEvents")` |
| `google_analytics` | `dimensions` | list of GA dimensions | `c("pagePath")` |
| `google_analytics` | `dim_filters` | list of GA filters | a variable `dim_filter_pagepath` or a filter clause |
| `google_analytics` | `segments` | list of GA segments | a variable containing a segment ID or a string |
| `google_analytics` | `anti_sample` | Try to download the data without sampling | `TRUE` or `FALSE` |


## **To Do**
Example code for running AB tests


## SessionInfo

```
> sessionInfo()
R version 3.6.1 (2019-07-05)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS Catalina 10.15.2

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/3.6/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] googleAnalyticsR_0.6.0 jsonlite_1.6          

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.2        pillar_1.4.2      compiler_3.6.1    googleAuthR_1.0.0
 [5] remotes_2.1.0     prettyunits_1.0.2 tools_3.6.1       testthat_2.2.1   
 [9] pkgload_1.0.2     zeallot_0.1.0     digest_0.6.20     pkgbuild_1.0.5   
[13] memoise_1.1.0     gargle_0.3.1      tibble_2.1.3      lifecycle_0.1.0  
[17] pkgconfig_2.0.2   rlang_0.4.2       cli_1.1.0         rstudioapi_0.10  
[21] curl_4.0          withr_2.1.2       dplyr_0.8.3       httr_1.4.1       
[25] askpass_1.1       desc_1.2.0        fs_1.3.1          vctrs_0.2.1      
[29] htmlwidgets_1.3   devtools_2.2.0    rprojroot_1.3-2   DT_0.8           
[33] tidyselect_0.2.5  glue_1.3.1        R6_2.4.0          processx_3.4.1   
[37] sessioninfo_1.1.1 tidyr_1.0.0       purrr_0.3.3       callr_3.3.1      
[41] magrittr_1.5      usethis_1.5.1     backports_1.1.4   ps_1.3.0         
[45] htmltools_0.3.6   ellipsis_0.2.0.1  assertthat_0.2.1  openssl_1.4.1    
[49] crayon_1.3.4  
```