CREATE PROGRAM bed_get_dgb_event_sets:dba
 FREE SET reply
 RECORD reply(
   1 starts_with[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 name = vc
     2 codes[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 contains[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 name = vc
     2 codes[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->search_string = cnvtalphanum(cnvtupper(request->search_string))
 SET startstr = concat("cv.display_key = patstring('",request->search_string,"*')")
 SET containstr = concat("cv.display_key = patstring('*",request->search_string,
  "*') and cv.display_key != patstring('",request->search_string,"*')")
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   v500_event_code vec
  PLAN (cv
   WHERE parser(startstr)
    AND cv.code_set=93
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (vesc
   WHERE vesc.event_set_cd=cv.code_value)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd
    AND vese.event_set_level=0)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd
    AND ((cnvtupper(vec.event_cd_disp)=cnvtupper(vesc.event_set_cd_disp)) OR ((request->
   display_match_ind=0))) )
  ORDER BY cv.code_value, vec.event_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->starts_with,10)
  HEAD cv.code_value
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->starts_with,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->starts_with[tot_cnt].code_value = cv.code_value, reply->starts_with[tot_cnt].display = cv
   .display, reply->starts_with[tot_cnt].description = cv.description,
   reply->starts_with[tot_cnt].name = vesc.event_set_name, code_cnt = 0, code_tot_cnt = 0,
   stat = alterlist(reply->starts_with[tot_cnt].codes,10)
  HEAD vec.event_cd
   code_cnt = (code_cnt+ 1), code_tot_cnt = (code_tot_cnt+ 1)
   IF (code_cnt > 10)
    stat = alterlist(reply->starts_with[tot_cnt].codes,(code_tot_cnt+ 10)), code_cnt = 1
   ENDIF
   reply->starts_with[tot_cnt].codes[code_tot_cnt].code_value = vec.event_cd, reply->starts_with[
   tot_cnt].codes[code_tot_cnt].display = vec.event_cd_disp, reply->starts_with[tot_cnt].codes[
   code_tot_cnt].description = vec.event_cd_descr
  FOOT  cv.code_value
   stat = alterlist(reply->starts_with[tot_cnt].codes,code_tot_cnt)
  FOOT REPORT
   stat = alterlist(reply->starts_with,tot_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   v500_event_code vec
  PLAN (cv
   WHERE parser(containstr)
    AND cv.code_set=93
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (vesc
   WHERE vesc.event_set_cd=cv.code_value)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd
    AND vese.event_set_level=0)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd
    AND ((cnvtupper(vec.event_cd_disp)=cnvtupper(vesc.event_set_cd_disp)) OR ((request->
   display_match_ind=0))) )
  ORDER BY cv.code_value, vec.event_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->contains,10)
  HEAD cv.code_value
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->contains,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->contains[tot_cnt].code_value = cv.code_value, reply->contains[tot_cnt].display = cv.display,
   reply->contains[tot_cnt].description = cv.description,
   reply->contains[tot_cnt].name = vesc.event_set_name, code_cnt = 0, code_tot_cnt = 0,
   stat = alterlist(reply->contains[tot_cnt].codes,10)
  HEAD vec.event_cd
   code_cnt = (code_cnt+ 1), code_tot_cnt = (code_tot_cnt+ 1)
   IF (code_tot_cnt > 10)
    stat = alterlist(reply->contains[tot_cnt].codes,(code_tot_cnt+ 10)), code_cnt = 1
   ENDIF
   reply->contains[tot_cnt].codes[code_tot_cnt].code_value = vec.event_cd, reply->contains[tot_cnt].
   codes[code_tot_cnt].display = vec.event_cd_disp, reply->contains[tot_cnt].codes[code_tot_cnt].
   description = vec.event_cd_descr
  FOOT  cv.code_value
   stat = alterlist(reply->contains[tot_cnt].codes,code_tot_cnt)
  FOOT REPORT
   stat = alterlist(reply->contains,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
