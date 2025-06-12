CREATE PROGRAM bed_get_position_list:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->too_many_results_ind = 0
 SET reply->status_data.status = "F"
 SET wcard = "*"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 10000
 ENDIF
 DECLARE position_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_text) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_text)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_text)),wcard)
  ENDIF
  SET position_parse = concat("cnvtupper(c.display) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET position_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 IF ((request->show_inactive_ind=0))
  SET position_parse = concat(trim(position_parse)," and c.active_ind = 1")
 ENDIF
 SET only_active_prsnl_ind = 0
 IF (validate(request->active_prsnl_ind))
  IF ((request->active_prsnl_ind=1))
   SET only_active_prsnl_ind = 1
  ENDIF
 ENDIF
 IF (only_active_prsnl_ind=1)
  SET cnt = 0
  SELECT INTO "nl:"
   FROM code_value c,
    prsnl p
   PLAN (c
    WHERE c.code_set=88
     AND parser(position_parse))
    JOIN (p
    WHERE p.position_cd=c.code_value
     AND p.active_ind=1)
   ORDER BY c.display, c.code_value
   HEAD c.code_value
    cnt = (cnt+ 1), stat = alterlist(reply->positions,cnt), reply->positions[cnt].code_value = c
    .code_value,
    reply->positions[cnt].display = c.display
   WITH nocounter
  ;end select
 ELSE
  SET cnt = 0
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=88
     AND parser(position_parse))
   ORDER BY c.display
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->positions,cnt), reply->positions[cnt].code_value = c
    .code_value,
    reply->positions[cnt].display = c.display
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (cnt > max_cnt)
  SET stat = alterlist(reply->positions,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
