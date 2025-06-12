CREATE PROGRAM dts_omf_ins_upd_filter_meaning:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE omf_ins_upd_filter_meaning
 SET reqinfo->commit_ind = 1
 SET reply->status = "S"
END GO
