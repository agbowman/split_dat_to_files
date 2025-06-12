CREATE PROGRAM ce_esh_get_event_set_canon:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 qual = i4
    1 error_code = f8
    1 error_msg = vc
    1 reply_list[*]
      2 canon_list[*]
        3 parent_event_set_cd = f8
        3 collating_seq = i4
        3 event_set_cd = f8
        3 event_set_name = vc
        3 event_set_name_key = vc
        3 event_set_cd_disp = vc
        3 event_set_cd_descr = vc
        3 event_set_icon_name = vc
        3 category_flag = i2
        3 accumulation_ind = i2
        3 display_association_ind = i2
        3 show_if_no_data_ind = i2
        3 grouping_rule_flag = i2
        3 concept_cki = vc
        3 updt_dt_tm = dq8
  )
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE outerlistcnt = i4 WITH noconstant(0)
 DECLARE totalcnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT DISTINCT INTO "nl:"
  FROM v500_event_set_canon c,
   v500_event_set_code esc,
   code_value cv
  PLAN (esc)
   JOIN (c
   WHERE c.event_set_cd=esc.event_set_cd)
   JOIN (cv
   WHERE cv.code_value=esc.event_set_cd)
  ORDER BY c.parent_event_set_cd, c.event_set_collating_seq
  HEAD REPORT
   outerlistcnt += 1, stat = alterlist(reply->reply_list,outerlistcnt)
  DETAIL
   cnt += 1, totalcnt += 1
   IF (cnt > 60000)
    stat = alterlist(reply->reply_list[outerlistcnt].canon_list,(cnt - 1)), cnt = 1, outerlistcnt +=
    1,
    stat = alterlist(reply->reply_list,outerlistcnt)
   ENDIF
   IF (mod(cnt,100)=1)
    stat = alterlist(reply->reply_list[outerlistcnt].canon_list,(cnt+ 99))
   ENDIF
   reply->reply_list[outerlistcnt].canon_list[cnt].parent_event_set_cd = c.parent_event_set_cd, reply
   ->reply_list[outerlistcnt].canon_list[cnt].collating_seq = c.event_set_collating_seq, reply->
   reply_list[outerlistcnt].canon_list[cnt].event_set_cd = esc.event_set_cd,
   reply->reply_list[outerlistcnt].canon_list[cnt].event_set_name = trim(esc.event_set_name), reply->
   reply_list[outerlistcnt].canon_list[cnt].event_set_name_key = trim(esc.event_set_name_key), reply
   ->reply_list[outerlistcnt].canon_list[cnt].event_set_cd_disp = trim(esc.event_set_cd_disp),
   reply->reply_list[outerlistcnt].canon_list[cnt].event_set_cd_descr = trim(esc.event_set_cd_descr),
   reply->reply_list[outerlistcnt].canon_list[cnt].event_set_icon_name = trim(esc.event_set_icon_name
    ), reply->reply_list[outerlistcnt].canon_list[cnt].category_flag = esc.category_flag,
   reply->reply_list[outerlistcnt].canon_list[cnt].accumulation_ind = esc.accumulation_ind, reply->
   reply_list[outerlistcnt].canon_list[cnt].display_association_ind = esc.display_association_ind,
   reply->reply_list[outerlistcnt].canon_list[cnt].show_if_no_data_ind = esc.show_if_no_data_ind,
   reply->reply_list[outerlistcnt].canon_list[cnt].grouping_rule_flag = esc.grouping_rule_flag, reply
   ->reply_list[outerlistcnt].canon_list[cnt].concept_cki = trim(cv.concept_cki), reply->reply_list[
   outerlistcnt].canon_list[cnt].updt_dt_tm = esc.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->reply_list[outerlistcnt].canon_list,cnt)
  WITH nocounter
 ;end select
 SET reply->qual = totalcnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
