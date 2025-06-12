CREATE PROGRAM bsc_get_omf_source_app_value:dba
 SET stat = alterlist(reply->datacoll,6)
 SET reply->datacoll[1].currcv = "0"
 SET reply->datacoll[1].description = "Unknown Application"
 SET reply->datacoll[2].currcv = "1"
 SET reply->datacoll[2].description = "CareMobile"
 SET reply->datacoll[3].currcv = "2"
 SET reply->datacoll[3].description = "CareAdmin"
 SET reply->datacoll[4].currcv = "3"
 SET reply->datacoll[4].description = "PowerChart"
 SET reply->datacoll[5].currcv = "4"
 SET reply->datacoll[5].description = "OpsJob"
 SET reply->datacoll[6].currcv = "5"
 SET reply->datacoll[6].description = "Connect Nursing"
 SET reply->status_data.status = "S"
END GO
