CREATE PROGRAM dts_omf_pv_view_cv:dba
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
 SET request->codeset = 26513
 EXECUTE omf_ins_cv_view
 SET reqinfo->commit_ind = 1
 SET reply->status = "S"
END GO
