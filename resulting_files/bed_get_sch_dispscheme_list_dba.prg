CREATE PROGRAM bed_get_sch_dispscheme_list:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 disp_scheme_id = f8
     2 mnemonic = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SELECT INTO "nl:"
  FROM sch_disp_scheme sds
  PLAN (sds
   WHERE (sds.scheme_type_flag=request->scheme_type_flag))
  ORDER BY sds.mnemonic
  HEAD REPORT
   scnt = 0
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->slist,scnt), reply->slist[scnt].disp_scheme_id = sds
   .disp_scheme_id,
   reply->slist[scnt].mnemonic = sds.mnemonic
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
