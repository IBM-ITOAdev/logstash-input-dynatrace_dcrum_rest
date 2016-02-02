# logstash-input-dynatrace_dcrum_rest

Logstash plugin for Dynatrace DC RUM REST API.
## Prerequisites
This plugin is developed and tested on Logstash 1.4.2 on Redhat linux server. It uses the [*curl*](https://en.wikipedia.org/wiki/CURL) command to do the HTTP requests.
## The API
Please check out [The official DCRUM REST API](https://community.dynatrace.com/community/display/DCRUM123/Using+REST-based+Web+Services) documentation for more details.
This plugin calls the [*getDMIData3*](https://community.dynatrace.com/community/display/DCRUM123/Example+REST+getDMIData%2C+getDMIData2%2C+getDMIData3) function to get the metrics.
## How it works
The plugin will call the API through curl command at the interval defined in the parameter. The resolution of metrics on DCRUM can be found out via the [*getResolutions*](https://community.dynatrace.com/community/display/DCRUM123/Example+REST+getResolutions) function. (*IBM Predictive Insights* prefers finer resolutions such as one minute or five minutes so the interval of the polling should also be defined accordingly.)  The query input is defined in the json file as defined in the *input_file* parameter (see below).
## Parameters
### hostname
Type: string

The host that services the API.
### port
Type: number

The port number of the API.  If it's not present then 80 is the default.
### username
Type: string

The username to access the API.
### password
Type: string

The password of the username.
### interval
Type: number

The API will be called by this interval.  If it's not present then 60 seconds is the default.
### input_file
Type: string

The json file as the input of the HTTP POST request.  For the definition of the parameters in this file please refer to https://community.dynatrace.com/community/display/DCRUM123/getDMIData3

Here is a sample input file:
```
{
  "appId": "CVENT",
  "viewId": "ClientView",
  "dataSourceId": "ALL_AGGR",
  "dimensionIds": [
    "pUrl",
    "begT"
  ],
  "metricIds": ["cRtt"],
  "dimFilters": [
  ],
  "metricFilters": [],
  "sort": [],
  "top": 0,
  "resolution": "r",
  "timePeriod": "p",
  "numberOfPeriods": 1
}
```
This input file quries the API for the metrics in the last one "period".  If the period is 300 seconds then the "interval" should also be defined as 300 seconds.

## To call this input plugin

Here is a sample of the logstash .conf file:

```
input {
  dcrum_rest {
    hostname => 'a.b.c.d'
    port => 81
    username => 'xxx'
    password => 'yyy'
    interval => 60
    input_file => '/export/home/scadmin/dev/input.json'
    tags => 'dcrum_rest'
  }
}
filter {
}
output {
  stdout {
    codec => rubydebug
  }
  scacsv {
    fields => [
       "Operation",
       "Time",
       "Client RTT"
    ]
    path => '/export/home/scadmin/dcrum/scacsv/dcrum_rest.csv'
    group => 'dcrum_rest'
    time_field => "Time"
    time_field_format => 'MM/dd/yyyy HH:mm'
    timestamp_output_format => 'YYMMddHHmmZ'
  }
}

```
## Sample scacsv output
File name: *dcrum_rest__1601130816+1100__1601131551+1100.csv*
```
Operation,Time,Client RTT
All other operations,01/13/2016 08:16,7.400000095367432
http://a.b.c.d/sap(zt1vreu0tvrjmlgxowzymtlmtvrvne1qttnwbmdma2cyeldgtghbqufbq3zdtvfnpt0=)/bc/bsp/sap/crm_ui_frame/blank.htm,01/13/2016 08:16,7.199999809265137
http://a.b.c.d/sap(zt1vreu0tvrjmlgxowzymtlmtvrvne1qttnwbmdma2cyeldgtghbqufbq3zdtvfnpt0=)/bc/bsp/sap/crm_ui_frame/main.htm,01/13/2016 08:16,7.400000095367432
http://a.b.c.d/sap/crm_logon,01/13/2016 08:16,7.5
All other operations,01/13/2016 08:17,7.599999904632568
http://a.b.c.d/sap(zt1vreu0tvrjmlgxowzymtlmtvrvne1qttnwbmdma2cyeldgtghbqufbq3zdtvfnpt0=)/bc/bsp/sap/crm_ui_frame/bspwdapplication.do,01/13/2016 08:17,7.5
http://a.b.c.d/sap/bc/bsp/sap/crmcmp_hdr/bspwdapplication.do,01/13/2016 08:17,7.400000095367432
```
This file can then be picked up by the Predictive Insights mediation tool for further processing and ingestion.
