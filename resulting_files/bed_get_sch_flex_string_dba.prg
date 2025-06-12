CREATE PROGRAM bed_get_sch_flex_string:dba
 FREE SET reply
 RECORD reply(
   1 flist[*]
     2 sch_flex_id = f8
     2 mnemonic = c40
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET active_cd = get_code_value(48,"ACTIVE")
 SET slot_type_cd = get_code_value(16162,"SLOTTYPE")
 SET fcount = 0
 SELECT INTO "NL:"
  FROM sch_flex_string sfs
  WHERE sfs.flex_type_cd=slot_type_cd
   AND sfs.active_ind=1
  ORDER BY sfs.mnemonic
  HEAD REPORT
   fcount = 0
  DETAIL
   fcount = (fcount+ 1), stat = alterlist(reply->flist,fcount), reply->flist[fcount].sch_flex_id =
   sfs.sch_flex_id,
   reply->flist[fcount].mnemonic = sfs.mnemonic
  WITH nocounter
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
