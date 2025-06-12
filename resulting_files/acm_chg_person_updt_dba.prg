CREATE PROGRAM acm_chg_person_updt:dba
 SET reply->status_data.status = "S"
 GO TO bypass_status
#bypass_status
END GO
