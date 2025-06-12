CREATE PROGRAM bed_get_dgb_event_sets_by_name:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 code_value = f8
    1 display = vc
    1 description = vc
    1 name = vc
    1 codes[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   v500_event_code vec
  PLAN (vesc
   WHERE (vesc.event_set_name=request->search_string))
   JOIN (cv
   WHERE vesc.event_set_cd=cv.code_value
    AND cv.code_set=93
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd
    AND vese.event_set_level=0)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd
    AND cnvtupper(vec.event_cd_disp)=cnvtupper(vesc.event_set_cd_disp))
  ORDER BY cv.code_value, vec.event_cd
  HEAD cv.code_value
   reply->code_value = cv.code_value, reply->display = cv.display, reply->description = cv
   .description,
   reply->name = vesc.event_set_name, code_cnt = 0, code_tot_cnt = 0,
   stat = alterlist(reply->codes,10)
  HEAD vec.event_cd
   code_cnt = (code_cnt+ 1), code_tot_cnt = (code_tot_cnt+ 1)
   IF (code_cnt > 10)
    stat = alterlist(reply->codes,(code_tot_cnt+ 10)), code_cnt = 1
   ENDIF
   reply->codes[code_tot_cnt].code_value = vec.event_cd, reply->codes[code_tot_cnt].display = vec
   .event_cd_disp, reply->codes[code_tot_cnt].description = vec.event_cd_descr
  FOOT  cv.code_value
   stat = alterlist(reply->codes,code_tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
