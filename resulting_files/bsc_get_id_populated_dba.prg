CREATE PROGRAM bsc_get_id_populated:dba
 SET stat = alterlist(reply->datacoll,1)
 SET reply->datacoll[1].currcv = "0.00"
 SET reply->datacoll[1].description = "Not Set"
 SET reply->status_data.status = "S"
END GO
