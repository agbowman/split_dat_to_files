CREATE PROGRAM ce_get_aotf_event_sets:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 rows_qualified = i4
    1 error_code = f8
    1 error_msg = vc
    1 event_set_list[*]
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
  )
 ENDIF
 DECLARE totalcount = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc,
   v500_event_set_canon canon,
   code_value cv
  PLAN (vesc
   WHERE (vesc.event_set_cd > request->starting_event_set_cd))
   JOIN (canon
   WHERE (canon.event_set_cd= Outerjoin(vesc.event_set_cd))
    AND nullind(canon.event_set_cd)=1)
   JOIN (cv
   WHERE cv.code_value=vesc.event_set_cd
    AND cv.code_set=93)
  ORDER BY vesc.event_set_cd
  HEAD REPORT
   status = alterlist(reply->event_set_list,20000), totalcount = 0
  DETAIL
   totalcount += 1, reply->event_set_list[totalcount].event_set_cd = vesc.event_set_cd, reply->
   event_set_list[totalcount].event_set_name = trim(vesc.event_set_name),
   reply->event_set_list[totalcount].event_set_name_key = trim(vesc.event_set_name_key), reply->
   event_set_list[totalcount].event_set_cd_disp = trim(vesc.event_set_cd_disp), reply->
   event_set_list[totalcount].event_set_cd_descr = trim(vesc.event_set_cd_descr),
   reply->event_set_list[totalcount].event_set_icon_name = trim(vesc.event_set_icon_name), reply->
   event_set_list[totalcount].category_flag = vesc.category_flag, reply->event_set_list[totalcount].
   accumulation_ind = vesc.accumulation_ind,
   reply->event_set_list[totalcount].display_association_ind = vesc.display_association_ind, reply->
   event_set_list[totalcount].show_if_no_data_ind = vesc.show_if_no_data_ind, reply->event_set_list[
   totalcount].grouping_rule_flag = vesc.grouping_rule_flag,
   reply->event_set_list[totalcount].concept_cki = trim(cv.concept_cki)
  FOOT REPORT
   stat = alterlist(reply->event_set_list,totalcount)
  WITH nocounter, maxrec = 20000, orahintcbo(
    "USE_NL(vesc cv canon) LEADING(vesc) INDEX(vesc XPKV500_EVENT_SET_CODE)")
 ;end select
 SET reply->rows_qualified = totalcount
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
