CREATE PROGRAM bbt_get_result_abo_and_rh:dba
 RECORD reply(
   1 qual[*]
     2 result_aborh_cd = f8
     2 result_aborh_disp = c40
     2 result_aborh_mean = c12
     2 stand_aborh_cd = f8
     2 stand_aborh_disp = c40
     2 stand_aborh_mean = c12
     2 abo_cd = f8
     2 abo_disp = c40
     2 abo_mean = c12
     2 rh_cd = f8
     2 rh_disp = c40
     2 rh_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET qual_cnt = 0
 SET select_ok_ind = 0
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  cve1643.code_value, cve1643.field_name, cve1643.field_value,
  cve1640.field_name, cve1640.field_value
  FROM code_value_extension cve1643,
   code_value_extension cve1640
  PLAN (cve1643
   WHERE cve1643.code_set=1643
    AND cve1643.field_name="ABORH_cd"
    AND cnvtreal(cve1643.field_value) > 0.0)
   JOIN (cve1640
   WHERE cve1640.code_value=cnvtreal(cve1643.field_value)
    AND cnvtreal(cve1640.field_value) > 0.0
    AND ((cve1640.field_name="ABOOnly_cd") OR (cve1640.field_name="RhOnly_cd")) )
  ORDER BY cve1643.code_value, cve1640.field_name
  HEAD REPORT
   select_ok_ind = 0, stat = alterlist(reply->qual,10)
  HEAD cve1643.code_value
   qual_cnt += 1
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].result_aborh_cd = cve1643.code_value, reply->qual[qual_cnt].stand_aborh_cd
    = cnvtreal(cve1643.field_value)
  DETAIL
   IF (cve1640.field_name="ABOOnly_cd")
    reply->qual[qual_cnt].abo_cd = cnvtreal(cve1640.field_value)
   ELSE
    reply->qual[qual_cnt].rh_cd = cnvtreal(cve1640.field_value)
   ENDIF
  FOOT REPORT
   select_ok_ind = 1, stat = alterlist(reply->qual,qual_cnt)
  WITH nocounter, nullreport
 ;end select
 IF (select_ok_ind != 1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "select"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_result_abo_and_rh"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "select for code_value_extensions failed"
 ENDIF
 IF ((request->debug_ind=1))
  SET item_cnt = size(reply->qual,5)
  FOR (item = 1 TO item_cnt)
    CALL echo(build(item,".",reply->qual[item].result_aborh_cd,"/",reply->qual[item].stand_aborh_cd,
      "/",reply->qual[item].abo_cd,"/",reply->qual[item].rh_cd," "))
  ENDFOR
 ENDIF
END GO
