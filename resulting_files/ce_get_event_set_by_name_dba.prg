CREATE PROGRAM ce_get_event_set_by_name:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 qual = i4
    1 error_code = f8
    1 error_msg = vc
    1 reply_list[*]
      2 event_set_cd = f8
      2 event_set_name = vc
      2 event_set_name_key = vc
      2 event_set_cd_disp = vc
      2 event_set_cd_descr = vc
      2 event_set_icon_name = vc
      2 category_flag = i2
      2 accumulation_ind = i2
      2 display_association_ind = i2
      2 show_if_no_data_ind = i2
      2 grouping_rule_flag = i2
      2 concept_cki = vc
      2 updt_cnt = i4
  )
 ENDIF
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = f8 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM v500_event_set_code esc,
   code_value cv
  PLAN (esc
   WHERE esc.event_set_name=trim(request->event_set_name))
   JOIN (cv
   WHERE cv.code_value=esc.event_set_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_set_cd = esc.event_set_cd, reply->reply_list[cnt].event_set_name =
   trim(esc.event_set_name), reply->reply_list[cnt].event_set_name_key = trim(esc.event_set_name_key),
   reply->reply_list[cnt].event_set_cd_disp = trim(esc.event_set_cd_disp), reply->reply_list[cnt].
   event_set_cd_descr = trim(esc.event_set_cd_descr), reply->reply_list[cnt].event_set_icon_name =
   trim(esc.event_set_icon_name),
   reply->reply_list[cnt].category_flag = esc.category_flag, reply->reply_list[cnt].accumulation_ind
    = esc.accumulation_ind, reply->reply_list[cnt].display_association_ind = esc
   .display_association_ind,
   reply->reply_list[cnt].show_if_no_data_ind = esc.show_if_no_data_ind, reply->reply_list[cnt].
   grouping_rule_flag = esc.grouping_rule_flag, reply->reply_list[cnt].concept_cki = trim(cv
    .concept_cki),
   stat = assign(validate(reply->reply_list[cnt].updt_cnt),esc.updt_cnt)
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
