CREATE PROGRAM ce_get_event_code:dba
 IF (validate(reply,"-999")="-999")
  RECORD reply(
    1 qual = i4
    1 error_code = f8
    1 error_msg = vc
    1 reply_list[*]
      2 code_list[*]
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
        3 collating_seq = i4
        3 concept_cki = vc
  )
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE outerlistcnt = i4 WITH noconstant(0)
 DECLARE totalcnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM v500_event_code c
  HEAD REPORT
   outerlistcnt += 1, stat = alterlist(reply->reply_list,outerlistcnt)
  DETAIL
   cnt += 1, totalcnt += 1
   IF (cnt > 60000)
    stat = alterlist(reply->reply_list[outerlistcnt].code_list,(cnt - 1)), cnt = 1, outerlistcnt += 1,
    stat = alterlist(reply->reply_list,outerlistcnt)
   ENDIF
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list[outerlistcnt].code_list,(cnt+ 9))
   ENDIF
   reply->reply_list[outerlistcnt].code_list[cnt].collating_seq = c.collating_seq, reply->reply_list[
   outerlistcnt].code_list[cnt].event_set_cd = c.event_cd, reply->reply_list[outerlistcnt].code_list[
   cnt].event_set_name = trim(c.event_set_name),
   reply->reply_list[outerlistcnt].code_list[cnt].event_set_cd_disp = trim(c.event_cd_disp), reply->
   reply_list[outerlistcnt].code_list[cnt].event_set_cd_descr = trim(c.event_cd_descr)
  FOOT REPORT
   stat = alterlist(reply->reply_list[outerlistcnt].code_list,cnt), stat = alterlist(reply->
    reply_list,outerlistcnt)
  WITH nocounter
 ;end select
 SET reply->qual = totalcnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
