CREATE PROGRAM bbt_get_code_sets:dba
 RECORD reply(
   1 codesetlist[*]
     2 code_set = i4
     2 qual[*]
       3 code_value = f8
       3 cdf_meaning = c12
       3 display = c40
       3 display_key = c40
       3 description = vc
       3 definition = vc
       3 collation_seq = i4
       3 active_type_cd = f8
       3 active_ind = i2
       3 updt_cnt = i4
       3 ext_cnt = i4
       3 ext_list[*]
         4 field_name = c32
         4 field_type = i4
         4 field_value = vc
         4 field_value_cd = f8
         4 field_value_disp = c40
         4 updt_cnt = i4
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
  cv.code_set, cv.code_value, cv.cdf_meaning,
  cv.display, cv.display_key, cv.description,
  cv.definition, cv.collation_seq, cv.active_type_cd,
  cv.active_ind, cv.updt_cnt, cse.field_name,
  cve.field_type, cve.field_value, cve.updt_cnt
  FROM (dummyt d_cv  WITH seq = value(size(request->codesetlist,5))),
   code_value cv,
   (dummyt d_cse  WITH seq = 1),
   code_set_extension cse,
   (dummyt d_cve  WITH seq = 1),
   code_value_extension cve
  PLAN (d_cv)
   JOIN (cv
   WHERE (cv.code_set=request->codesetlist[d_cv.seq].code_set)
    AND (((request->codesetlist[d_cv.seq].cdf_meaning_ind=0)) OR ((request->codesetlist[d_cv.seq].
   cdf_meaning_ind=1)
    AND (cv.cdf_meaning=request->codesetlist[d_cv.seq].cdf_meaning)))
    AND cv.code_value != null
    AND cv.code_value > 0
    AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
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
  ORDER BY cv.code_set, cv.code_value, cse.field_name
  HEAD REPORT
   cs_cnt = 0, stat = alterlist(reply->codesetlist,5)
  HEAD cv.code_set
   cs_cnt += 1, cv_cnt = 0
   IF (mod(cs_cnt,5)=1
    AND cs_cnt != 1)
    stat = alterlist(reply->codesetlist,(cs_cnt+ 4))
   ENDIF
   reply->codesetlist[cs_cnt].code_set = cv.code_set, stat = alterlist(reply->codesetlist[cs_cnt].
    qual,10)
  HEAD cv.code_value
   cv_cnt += 1
   IF (mod(cv_cnt,10)=1
    AND cv_cnt != 1)
    stat = alterlist(reply->codesetlist[cs_cnt].qual,(cv_cnt+ 9))
   ENDIF
   reply->codesetlist[cs_cnt].qual[cv_cnt].code_value = cv.code_value, reply->codesetlist[cs_cnt].
   qual[cv_cnt].cdf_meaning = cv.cdf_meaning, reply->codesetlist[cs_cnt].qual[cv_cnt].display = cv
   .display,
   reply->codesetlist[cs_cnt].qual[cv_cnt].display_key = cv.display_key, reply->codesetlist[cs_cnt].
   qual[cv_cnt].description = cv.description, reply->codesetlist[cs_cnt].qual[cv_cnt].definition = cv
   .definition,
   reply->codesetlist[cs_cnt].qual[cv_cnt].collation_seq = cv.collation_seq, reply->codesetlist[
   cs_cnt].qual[cv_cnt].active_type_cd = cv.active_type_cd, reply->codesetlist[cs_cnt].qual[cv_cnt].
   active_ind = cv.active_ind,
   reply->codesetlist[cs_cnt].qual[cv_cnt].updt_cnt = cv.updt_cnt, cve_cnt = 0, stat = alterlist(
    reply->codesetlist[cs_cnt].qual[cv_cnt].ext_list,5)
  DETAIL
   cve_cnt += 1
   IF (mod(cve_cnt,5)=1
    AND cve_cnt != 1)
    stat = alterlist(reply->codesetlist[cs_cnt].qual[cv_cnt].ext_list,(cve_cnt+ 4))
   ENDIF
   reply->codesetlist[cs_cnt].qual[cv_cnt].ext_list[cve_cnt].field_name = cve.field_name, reply->
   codesetlist[cs_cnt].qual[cv_cnt].ext_list[cve_cnt].field_type = cve.field_type, reply->
   codesetlist[cs_cnt].qual[cv_cnt].ext_list[cve_cnt].field_value = cve.field_value
   IF (cve.field_type=1)
    reply->codesetlist[cs_cnt].qual[cv_cnt].ext_list[cve_cnt].field_value_cd = cnvtreal(cve
     .field_value)
   ENDIF
   reply->codesetlist[cs_cnt].qual[cv_cnt].ext_list[cve_cnt].updt_cnt = cve.updt_cnt
  FOOT  cv.code_value
   reply->codesetlist[cs_cnt].qual[cv_cnt].ext_cnt = cve_cnt, stat = alterlist(reply->codesetlist[
    cs_cnt].qual[cv_cnt].ext_list,cve_cnt)
  FOOT  cv.code_set
   stat = alterlist(reply->codesetlist[cs_cnt].qual,cv_cnt)
  FOOT REPORT
   stat = alterlist(reply->codesetlist,cs_cnt), failed = "F"
  WITH nocounter, outerjoin(d_cse), outerjoin(d_cve),
   nullreport
 ;end select
 SET count1 += 1
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "Get code_value/extensions"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_code_sets"
 IF (failed="F")
  IF (size(reply->codesetlist,5) > 0)
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
 IF ((request->debug_ind=1))
  CALL echo(build("reply->status_data->status =",reply->status_data.status))
  FOR (cs = 1 TO cnvtint(size(reply->codesetlist,5)))
   CALL echo(build(reply->codesetlist[cs].code_set))
   FOR (cv = 1 TO cnvtint(size(reply->codesetlist[cs].qual,5)))
    CALL echo(build(reply->codesetlist[cs].qual[cv].code_value,"/",reply->codesetlist[cs].qual[cv].
      cdf_meaning,"/",reply->codesetlist[cs].qual[cv].display,
      "/",reply->codesetlist[cs].qual[cv].display_key,"/",reply->codesetlist[cs].qual[cv].description,
      "/",
      reply->codesetlist[cs].qual[cv].definition,"/",reply->codesetlist[cs].qual[cv].collation_seq,
      "/",reply->codesetlist[cs].qual[cv].active_type_cd,
      "/",reply->codesetlist[cs].qual[cv].active_ind,"/",reply->codesetlist[cs].qual[cv].updt_cnt,"/",
      reply->codesetlist[cs].qual[cv].ext_cnt))
    FOR (cve = 1 TO cnvtint(size(reply->codesetlist[cs].qual[cv].ext_list,5)))
      CALL echo(build("-----",reply->codesetlist[cs].qual[cv].ext_list[cve].field_name,"/",reply->
        codesetlist[cs].qual[cv].ext_list[cve].field_type,"/",
        reply->codesetlist[cs].qual[cv].ext_list[cve].field_value,"/",reply->codesetlist[cs].qual[cv]
        .ext_list[cve].updt_cnt))
    ENDFOR
   ENDFOR
  ENDFOR
 ENDIF
END GO
