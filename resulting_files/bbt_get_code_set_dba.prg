CREATE PROGRAM bbt_get_code_set:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 ext_cnt = i4
     2 ext_list[*]
       3 field_name = c32
       3 field_type = i4
       3 field_value = vc
       3 field_value_cd = f8
       3 field_value_disp = c40
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET failed = "T"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning, cv.display,
  cv.display_key, cv.description, cv.definition,
  cv.collation_seq, cv.active_type_cd, cv.active_ind,
  cv.updt_cnt, cse.field_name, cve.field_type,
  cve.field_value, cve.updt_cnt
  FROM code_value cv,
   (dummyt d_cse  WITH seq = 1),
   code_set_extension cse,
   (dummyt d_cve  WITH seq = 1),
   code_value_extension cve
  PLAN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.code_value != null
    AND cv.code_value > 0
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d_cse
   WHERE d_cse.seq=1)
   JOIN (cse
   WHERE cse.code_set=cv.code_set)
   JOIN (d_cve
   WHERE d_cve.seq=1)
   JOIN (cve
   WHERE cve.code_set=cse.code_set
    AND cve.field_name=cse.field_name
    AND cve.code_value=cv.code_value)
  ORDER BY cv.code_value, cse.field_name
  HEAD REPORT
   cv_cnt = 0, stat = alterlist(reply->qual,10)
  HEAD cv.code_value
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1
    AND cv_cnt != 1)
    stat = alterlist(reply->qual,(cv_cnt+ 9))
   ENDIF
   cve_cnt = 0, stat = alterlist(reply->qual[cv_cnt].ext_list,5), reply->qual[cv_cnt].code_value = cv
   .code_value,
   reply->qual[cv_cnt].cdf_meaning = cv.cdf_meaning, reply->qual[cv_cnt].display = cv.display, reply
   ->qual[cv_cnt].display_key = cv.display_key,
   reply->qual[cv_cnt].description = cv.description, reply->qual[cv_cnt].definition = cv.definition,
   reply->qual[cv_cnt].collation_seq = cv.collation_seq,
   reply->qual[cv_cnt].active_type_cd = cv.active_type_cd, reply->qual[cv_cnt].active_ind = cv
   .active_ind, reply->qual[cv_cnt].updt_cnt = cv.updt_cnt
  DETAIL
   cve_cnt = (cve_cnt+ 1)
   IF (mod(cve_cnt,5)=1
    AND cve_cnt != 1)
    stat = alterlist(reply->qual[cv_cnt].ext_list,(cve_cnt+ 4))
   ENDIF
   reply->qual[cv_cnt].ext_list[cve_cnt].field_name = cve.field_name, reply->qual[cv_cnt].ext_list[
   cve_cnt].field_type = cve.field_type, reply->qual[cv_cnt].ext_list[cve_cnt].field_value = cve
   .field_value
   IF (cve.field_type=1)
    reply->qual[cv_cnt].ext_list[cve_cnt].field_value_cd = cnvtreal(cve.field_value)
   ENDIF
   reply->qual[cv_cnt].ext_list[cve_cnt].updt_cnt = cve.updt_cnt
  FOOT  cv.code_value
   reply->qual[cv_cnt].ext_cnt = cve_cnt, stat = alterlist(reply->qual[cv_cnt].ext_list,cve_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,cv_cnt), failed = "F"
  WITH nocounter, outerjoin(d_cse), outerjoin(d_cve),
   nullreport
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "Get code_value/extensions"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_code_set"
 IF (failed="F")
  IF (size(reply->qual,5) > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ZERO"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Select on code_value/code_value_extension failed"
 ENDIF
END GO
