CREATE PROGRAM cv_omf_view_indicator_name:dba
 SET icodeset = 24549
 RECORD request(
   1 codeset = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->codeset = icodeset
 EXECUTE omf_ins_upd_view_indicator
 SET reqinfo->commit_ind = 1
 SET reply->status = "S"
END GO
