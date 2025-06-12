CREATE PROGRAM da2_group_type_filter:dba
 SET stat = alterlist(reply->datacoll,2)
 SET reply->datacoll[1].currcv = "OWNERGROUP"
 SET reply->datacoll[1].description = "Owner Group"
 SET reply->datacoll[2].currcv = "SECGROUP"
 SET reply->datacoll[2].description = "Security Group"
 SET reply->status_data.status = "S"
END GO
