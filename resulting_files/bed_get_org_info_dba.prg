CREATE PROGRAM bed_get_org_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 organization_info[*]
      2 organization_id = f8
      2 sub_types[*]
        3 code_value = f8
        3 cdf_meaning = vc
        3 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->organization_ids,5)
 SET stat = alterlist(reply->organization_info,req_cnt)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (index_t = 1 TO req_cnt)
   SET reply->organization_info[index_t].organization_id = request->organization_ids[index_t].
   organization_id
 ENDFOR
 SELECT INTO "nl:"
  FROM org_info oi,
   code_value cv,
   (dummyt d  WITH seq = req_cnt)
  PLAN (d)
   JOIN (oi
   WHERE (oi.organization_id=request->organization_ids[d.seq].organization_id)
    AND (oi.info_type_cd=request->info_type_cd)
    AND oi.active_ind=1
    AND oi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND oi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=oi.value_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->organization_info[d.seq].sub_types,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->organization_info[d.seq].sub_types,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->organization_info[d.seq].sub_types[tot_cnt].code_value = cv.code_value, reply->
   organization_info[d.seq].sub_types[tot_cnt].cdf_meaning = cv.cdf_meaning, reply->
   organization_info[d.seq].sub_types[tot_cnt].display = cv.display
  FOOT  d.seq
   stat = alterlist(reply->organization_info[d.seq].sub_types,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
