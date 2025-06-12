CREATE PROGRAM bsc_get_omf_flag_value:dba
 SET stat = alterlist(reply->datacoll,2)
 SET reply->datacoll[1].currcv = "0"
 SET reply->datacoll[1].description = "Not Set"
 SET reply->datacoll[2].currcv = "1"
 SET reply->datacoll[2].description = "Set"
 SET reply->status_data.status = "S"
END GO
