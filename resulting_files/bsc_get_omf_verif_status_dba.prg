CREATE PROGRAM bsc_get_omf_verif_status:dba
 SET stat = alterlist(reply->datacoll,6)
 SET reply->datacoll[1].currcv = "0"
 SET reply->datacoll[1].description = "no verify needed"
 SET reply->datacoll[2].currcv = "1"
 SET reply->datacoll[2].description = "verify needed"
 SET reply->datacoll[3].currcv = "2"
 SET reply->datacoll[3].description = "superceded"
 SET reply->datacoll[4].currcv = "3"
 SET reply->datacoll[4].description = "verified"
 SET reply->datacoll[5].currcv = "4"
 SET reply->datacoll[5].description = "rejected"
 SET reply->datacoll[6].currcv = "5"
 SET reply->datacoll[6].description = "reviewed"
 SET reply->status_data.status = "S"
END GO
