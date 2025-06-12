CREATE PROGRAM cv_omf_view_options_name:dba
 SET codeset = 24549
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
 SET request->codeset = 24549
 EXECUTE omf_ins_upd_view_options
 SET reqinfo->commit_ind = 1
 SET reply->status = "S"
END GO
