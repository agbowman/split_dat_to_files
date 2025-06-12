CREATE PROGRAM bb_ref_get_std_abrh1:dba
 RECORD reply(
   1 code_ext[*]
     2 codevalue_cd = f8
     2 code_disp = vc
     2 code_desp = vc
     2 abo_cd = vc
     2 rh_cd = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET error_check = error(serrormsg,1)
 SELECT INTO "nl:"
  *
  FROM code_value ce,
   code_value_extension cve,
   code_value_extension cve2
  PLAN (ce
   WHERE (ce.active_ind=request->active_flag))
   JOIN (cve
   WHERE cve.code_value=ce.code_value
    AND cve.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_value=ce.code_value
    AND cve2.field_name="RhOnly_cd")
  DETAIL
   ncnt = (ncnt+ 1), stat = alterlist(reply->code_ext,ncnt), reply->code_ext[ncnt].codevalue_cd = cve
   .code_value,
   reply->code_ext[ncnt].abo_cd = cnvtdbl(cve.field_value), reply->code_ext[ncnt].rh_cd = cnvtdbl(
    cve2.field_value),
   CALL echo(build("reply->code_ext[nCnt].codevalue_cd==>",reply->code_ext[ncnt].codevalue_cd)),
   CALL echo(build("reply->code_ext[nCnt].abo_cd===>",reply->code_ext[ncnt].abo_cd)),
   CALL echo(build("reply->code_ext[nCnt].rh_cd===>",reply->code_ext[ncnt].rh_cd))
  WITH nocounter
 ;end select
 SET error_check = error(serrormsg,0)
 IF (error_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
