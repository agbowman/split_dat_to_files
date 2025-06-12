CREATE PROGRAM bed_aud_iview_bld_rec:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
   1 pelist[*]
     2 section_name = vc
     2 event_set_name = vc
     2 event_set_cd = f8
     2 event_cd = f8
     2 display_association_ind = i2
     2 more_than_one_ind = i2
     2 more_than_one_dta_ind = i2
     2 inactive_ind = i2
     2 missing_ind = i2
     2 not_exist_ind = i2
 )
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 EXECUTE prefrtl
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Recommendation"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Grade"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET active_cd = get_code_value(48,"ACTIVE")
 SET tcnt = 0
 SET sectioncnt = 0
 SELECT INTO "nl:"
  FROM working_view_section wvs,
   working_view_item wvi,
   v500_event_set_code vesc
  PLAN (wvs
   WHERE wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vesc
   WHERE vesc.event_set_name=wvi.primitive_event_set_name)
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD wvs.display_name
   sectioncnt = (sectioncnt+ 1)
  HEAD wvi.primitive_event_set_name
   tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = wvs
   .display_name,
   temp->pelist[tcnt].event_set_name = wvi.primitive_event_set_name, temp->pelist[tcnt].event_set_cd
    = vesc.event_set_cd, temp->pelist[tcnt].display_association_ind = vesc.display_association_ind,
   temp->pelist[tcnt].more_than_one_ind = 0, temp->pelist[tcnt].inactive_ind = 0, temp->pelist[tcnt].
   missing_ind = 1,
   temp->pelist[tcnt].not_exist_ind = 0
  WITH nocounter
 ;end select
 SET rcnt = 15
 SET stat = alterlist(reply->statlist,15)
 SET stat = alterlist(reply->rowlist,rcnt)
 FOR (rcnt = 1 TO 15)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,2)
 ENDFOR
 SET reply->run_status_flag = 1
 SET reply->rowlist[1].celllist[1].string_value = concat(
  "All primitive event sets used in IView sections are associated"," to only one active event code.")
 SET reply->rowlist[1].celllist[2].string_value = "Pass"
 SET reply->statlist[1].statistic_meaning = "IVIEWBRPESONEEC"
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = 0
 SET reply->statlist[1].status_flag = 1
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    v500_event_set_explode vese,
    v500_event_code vec
   PLAN (d
    WHERE (temp->pelist[d.seq].event_set_cd > 0))
    JOIN (vese
    WHERE (vese.event_set_cd=temp->pelist[d.seq].event_set_cd))
    JOIN (vec
    WHERE vec.event_cd=vese.event_cd)
   HEAD d.seq
    active_cnt = 0
   DETAIL
    temp->pelist[d.seq].missing_ind = 0
    IF (vec.code_status_cd=active_cd)
     active_cnt = (active_cnt+ 1)
    ELSE
     temp->pelist[d.seq].inactive_ind = 1
    ENDIF
   FOOT  d.seq
    IF (active_cnt > 1)
     IF ((temp->pelist[d.seq].display_association_ind != 1))
      reply->rowlist[1].celllist[2].string_value = "Fail", reply->statlist[1].status_flag = 3, reply
      ->run_status_flag = 3
     ENDIF
    ELSE
     temp->pelist[d.seq].event_cd = vec.event_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->rowlist[2].celllist[1].string_value = concat(
  "All event codes used in IView sections are associated"," to only one active DTA.")
 SET reply->rowlist[2].celllist[2].string_value = "Pass"
 SET reply->statlist[2].statistic_meaning = "IVIEWBRECONEDTA"
 SET reply->statlist[2].total_items = 0
 SET reply->statlist[2].qualifying_items = 0
 SET reply->statlist[2].status_flag = 1
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    code_value_event_r cver
   PLAN (d
    WHERE (temp->pelist[d.seq].event_cd > 0))
    JOIN (cver
    WHERE (cver.event_cd=temp->pelist[d.seq].event_cd))
   HEAD d.seq
    dta_cnt = 0
   DETAIL
    dta_cnt = (dta_cnt+ 1)
   FOOT  d.seq
    IF (dta_cnt > 1)
     reply->rowlist[2].celllist[2].string_value = "Fail", reply->statlist[2].status_flag = 3, reply->
     run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->rowlist[3].celllist[1].string_value = concat(
  "The Working View Section specialty event set is on the level",
  " directly below All Specialty Sections in the event set hierarchy.")
 SET reply->rowlist[3].celllist[2].string_value = "Pass"
 SET reply->statlist[3].statistic_meaning = "IVIEWBRWVSCORRECT"
 SET reply->statlist[3].total_items = 0
 SET reply->statlist[3].qualifying_items = 0
 SET reply->statlist[3].status_flag = 1
 SET all_okay_ind = 0
 SET allresult_cd = 0.0
 SET allspec_cd = 0.0
 SET workview_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc
  PLAN (vesc
   WHERE vesc.event_set_name_key IN ("ALLSPECIALTYSECTIONS", "WORKINGVIEWSECTIONS",
   "ALLRESULTSECTIONS"))
  DETAIL
   IF (vesc.event_set_name_key="ALLSPECIALTYSECTIONS")
    allspec_cd = vesc.event_set_cd
   ELSEIF (vesc.event_set_name_key="ALLRESULTSECTIONS")
    allresult_cd = vesc.event_set_cd
   ELSE
    workview_cd = vesc.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (allspec_cd > 0
  AND workview_cd > 0)
  SELECT INTO "nl:"
   FROM v500_event_set_canon vesc
   PLAN (vesc
    WHERE vesc.parent_event_set_cd=allspec_cd
     AND vesc.event_set_cd=workview_cd)
   DETAIL
    all_okay_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (all_okay_ind=0)
  SET reply->rowlist[3].celllist[2].string_value = "Fail"
  SET reply->statlist[3].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[4].celllist[1].string_value = concat(
  "All primitive event sets used in IView sections are included",
  " once in the All Results side of the event set hierarchy.")
 SET reply->rowlist[4].celllist[2].string_value = "Pass"
 SET reply->statlist[4].statistic_meaning = "IVIEWBRPESINHIER"
 SET reply->statlist[4].total_items = 0
 SET reply->statlist[4].qualifying_items = 0
 SET reply->statlist[4].status_flag = 1
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    v500_event_set_canon vesc1,
    v500_event_set_canon vesc2,
    v500_event_set_canon vesc3,
    v500_event_set_canon vesc4,
    v500_event_set_canon vesc5,
    v500_event_set_canon vesc6,
    v500_event_set_canon vesc7,
    v500_event_set_canon vesc8,
    v500_event_set_canon vesc9,
    v500_event_set_canon vesc10,
    v500_event_set_canon vesc11,
    v500_event_set_canon vesc12,
    v500_event_set_canon vesc13,
    v500_event_set_canon vesc14,
    v500_event_set_canon vesc15,
    v500_event_set_canon vesc16,
    v500_event_set_canon vesc17,
    v500_event_set_canon vesc18,
    v500_event_set_canon vesc19
   PLAN (d
    WHERE (temp->pelist[d.seq].event_set_cd > 0))
    JOIN (vesc1
    WHERE (vesc1.event_set_cd=temp->pelist[d.seq].event_set_cd))
    JOIN (vesc2
    WHERE vesc2.event_set_cd=outerjoin(vesc1.parent_event_set_cd))
    JOIN (vesc3
    WHERE vesc3.event_set_cd=outerjoin(vesc2.parent_event_set_cd))
    JOIN (vesc4
    WHERE vesc4.event_set_cd=outerjoin(vesc3.parent_event_set_cd))
    JOIN (vesc5
    WHERE vesc5.event_set_cd=outerjoin(vesc4.parent_event_set_cd))
    JOIN (vesc6
    WHERE vesc6.event_set_cd=outerjoin(vesc5.parent_event_set_cd))
    JOIN (vesc7
    WHERE vesc7.event_set_cd=outerjoin(vesc6.parent_event_set_cd))
    JOIN (vesc8
    WHERE vesc8.event_set_cd=outerjoin(vesc7.parent_event_set_cd))
    JOIN (vesc9
    WHERE vesc9.event_set_cd=outerjoin(vesc8.parent_event_set_cd))
    JOIN (vesc10
    WHERE vesc10.event_set_cd=outerjoin(vesc9.parent_event_set_cd))
    JOIN (vesc11
    WHERE vesc11.event_set_cd=outerjoin(vesc10.parent_event_set_cd))
    JOIN (vesc12
    WHERE vesc12.event_set_cd=outerjoin(vesc11.parent_event_set_cd))
    JOIN (vesc13
    WHERE vesc13.event_set_cd=outerjoin(vesc12.parent_event_set_cd))
    JOIN (vesc14
    WHERE vesc14.event_set_cd=outerjoin(vesc13.parent_event_set_cd))
    JOIN (vesc15
    WHERE vesc15.event_set_cd=outerjoin(vesc14.parent_event_set_cd))
    JOIN (vesc16
    WHERE vesc16.event_set_cd=outerjoin(vesc15.parent_event_set_cd))
    JOIN (vesc17
    WHERE vesc17.event_set_cd=outerjoin(vesc16.parent_event_set_cd))
    JOIN (vesc18
    WHERE vesc18.event_set_cd=outerjoin(vesc17.parent_event_set_cd))
    JOIN (vesc19
    WHERE vesc19.event_set_cd=outerjoin(vesc18.parent_event_set_cd))
   HEAD REPORT
    found = "N"
   HEAD d.seq
    found = "N"
   DETAIL
    IF (((vesc19.parent_event_set_cd=allresult_cd) OR (((vesc18.parent_event_set_cd=allresult_cd) OR
    (((vesc17.parent_event_set_cd=allresult_cd) OR (((vesc16.parent_event_set_cd=allresult_cd) OR (((
    vesc15.parent_event_set_cd=allresult_cd) OR (((vesc14.parent_event_set_cd=allresult_cd) OR (((
    vesc13.parent_event_set_cd=allresult_cd) OR (((vesc12.parent_event_set_cd=allresult_cd) OR (((
    vesc11.parent_event_set_cd=allresult_cd) OR (((vesc10.parent_event_set_cd=allresult_cd) OR (((
    vesc9.parent_event_set_cd=allresult_cd) OR (((vesc8.parent_event_set_cd=allresult_cd) OR (((vesc7
    .parent_event_set_cd=allresult_cd) OR (((vesc6.parent_event_set_cd=allresult_cd) OR (((vesc5
    .parent_event_set_cd=allresult_cd) OR (((vesc4.parent_event_set_cd=allresult_cd) OR (((vesc3
    .parent_event_set_cd=allresult_cd) OR (((vesc2.parent_event_set_cd=allresult_cd) OR (vesc1
    .parent_event_set_cd=allresult_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
     found = "Y"
    ENDIF
   FOOT  d.seq
    IF (found="N")
     reply->rowlist[4].celllist[2].string_value = "Fail", reply->statlist[4].status_flag = 3, reply->
     run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->rowlist[5].celllist[1].string_value = concat(
  "The 'falloff time' for results should not be"," set.")
 SET reply->rowlist[5].celllist[2].string_value = "Pass"
 SET reply->statlist[5].statistic_meaning = "IVIEWBRNOFALLOFF"
 SET reply->statlist[5].total_items = 0
 SET reply->statlist[5].qualifying_items = 0
 SET reply->statlist[5].status_flag = 1
 SELECT INTO "nl:"
  FROM working_view_item wvi
  PLAN (wvi
   WHERE wvi.falloff_view_minutes > 0)
  DETAIL
   reply->rowlist[5].celllist[2].string_value = "Fail", reply->statlist[5].status_flag = 3, reply->
   run_status_flag = 3
  WITH nocounter
 ;end select
 SET reply->rowlist[6].celllist[1].string_value = concat(
  "All Iviews should contain < 400 total DTAs for the entire"," view.")
 SET reply->rowlist[6].celllist[2].string_value = "Pass"
 SET reply->statlist[6].statistic_meaning = "IVIEWBRDTAPERVIEW"
 SET reply->statlist[6].total_items = 0
 SET reply->statlist[6].qualifying_items = 0
 SET reply->statlist[6].status_flag = 1
 SELECT INTO "nl:"
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id
    AND wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
  ORDER BY wv.working_view_id
  HEAD REPORT
   tcnt = 0
  HEAD wv.working_view_id
   pecnt = 0
  DETAIL
   pecnt = (pecnt+ 1)
  FOOT  wv.working_view_id
   IF (pecnt > 400)
    reply->rowlist[6].celllist[2].string_value = "Fail", reply->statlist[6].status_flag = 3, reply->
    run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SET reply->rowlist[7].celllist[1].string_value = concat(
  "All Iviews should have ten or less sections defaulted"," open.")
 SET reply->rowlist[7].celllist[2].string_value = "Pass"
 SET reply->statlist[7].statistic_meaning = "IVIEWBRDEFAULTOPEN"
 SET reply->statlist[7].total_items = 0
 SET reply->statlist[7].qualifying_items = 0
 SET reply->statlist[7].status_flag = 1
 SET default_sections_ok = "Y"
 SET sect_cnt = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=default_open")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      IF (valcnt > 10)
       SET default_sections_ok = "N"
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (default_sections_ok="N")
  SET reply->rowlist[7].celllist[2].string_value = "Fail"
  SET reply->statlist[7].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[8].celllist[1].string_value = concat(
  "The 'seeker' preference is turned off at the global"," level.")
 SET reply->rowlist[8].celllist[2].string_value = "Pass"
 SET reply->statlist[8].statistic_meaning = "IVIEWBRNOSEEKER"
 SET reply->statlist[8].total_items = 0
 SET reply->statlist[8].qualifying_items = 0
 SET reply->statlist[8].status_flag = 1
 SET system_seeker_off = "N"
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=seeker")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       IF (xvalue="0")
        SET system_seeker_off = "Y"
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (system_seeker_off="N")
  SET reply->rowlist[8].celllist[2].string_value = "Fail"
  SET reply->statlist[8].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[9].celllist[1].string_value = concat(
  "The 'orders integration' preference is turned off at"," the global level.")
 SET reply->rowlist[9].celllist[2].string_value = "Pass"
 SET reply->statlist[9].statistic_meaning = "IVIEWBRNOORDINT"
 SET reply->statlist[9].total_items = 0
 SET reply->statlist[9].qualifying_items = 0
 SET reply->statlist[9].status_flag = 1
 SET system_ordinteg_off = "N"
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=order_integration")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       IF (xvalue="0")
        SET system_ordinteg_off = "Y"
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (system_ordinteg_off="N")
  SET reply->rowlist[9].celllist[2].string_value = "Fail"
  SET reply->statlist[9].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[10].celllist[1].string_value = concat(
  "The result cap preference is set with a value between"," 1 and 2,500.")
 SET reply->rowlist[10].celllist[2].string_value = "Pass"
 SET reply->statlist[10].statistic_meaning = "IVIEWBRRSLTCAP"
 SET reply->statlist[10].total_items = 0
 SET reply->statlist[10].qualifying_items = 0
 SET reply->statlist[10].status_flag = 1
 SET result_cap_ok = "Y"
 SET cap_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=result_cap")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET cap_value = cnvtint(trim(xvalue))
        IF (((cap_value < 1) OR (cap_value > 2500)) )
         SET result_cap_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (result_cap_ok="N")
  SET reply->rowlist[10].celllist[2].string_value = "Fail"
  SET reply->statlist[10].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[11].celllist[1].string_value = concat(
  "All 'retrieve by timeframe' values are set with"," values <= 24 hours.")
 SET reply->rowlist[11].celllist[2].string_value = "Pass"
 SET reply->statlist[11].statistic_meaning = "IVIEWBRRETRIEVETIMEFRAME"
 SET reply->statlist[11].total_items = 0
 SET reply->statlist[11].qualifying_items = 0
 SET reply->statlist[11].status_flag = 1
 SET last_x_hours_ok = "Y"
 SET lxh_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=last_x_hours")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET lxh_value = cnvtint(trim(xvalue))
        IF (lxh_value > 24)
         SET last_x_hours_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (last_x_hours_ok="N")
  SET reply->rowlist[11].celllist[2].string_value = "Fail"
  SET reply->statlist[11].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[12].celllist[1].string_value = concat("The default retrieve type is not set as",
  " 'admission to current'.")
 SET reply->rowlist[12].celllist[2].string_value = "Pass"
 SET reply->statlist[12].statistic_meaning = "IVIEWBRDFLTRETRIEVETYPE"
 SET reply->statlist[12].total_items = 0
 SET reply->statlist[12].qualifying_items = 0
 SET reply->statlist[12].status_flag = 1
 SET retrieve_type_ok = "Y"
 DECLARE rt_value = vc
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=retrieve_type")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET rt_value = trim(xvalue)
        IF (rt_value="Adm to current")
         SET retrieve_type_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (retrieve_type_ok="N")
  SET reply->rowlist[12].celllist[2].string_value = "Fail"
  SET reply->statlist[12].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[13].celllist[1].string_value = concat(
  "The 'enhanced performance' preference is turned"," on (releases 2007 and greater).")
 SET reply->rowlist[13].celllist[2].string_value = "Pass"
 SET reply->statlist[13].statistic_meaning = "IVIEWBRENHPERF"
 SET reply->statlist[13].total_items = 0
 SET reply->statlist[13].qualifying_items = 0
 SET reply->statlist[13].status_flag = 1
 SET ep_ok = " "
 SET cap_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=enhanced_performance")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET cap_value = cnvtint(trim(xvalue))
        IF (cap_value=1
         AND ep_ok=" ")
         SET ep_ok = "Y"
        ELSE
         SET ep_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (ep_ok IN (" ", "N"))
  SET reply->rowlist[13].celllist[2].string_value = "Fail"
  SET reply->statlist[13].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[14].celllist[1].string_value = concat(
  "The 'BMDI look back min' preference is set for"," 15-60 minutes.")
 SET reply->rowlist[14].celllist[2].string_value = "Pass"
 SET reply->statlist[14].statistic_meaning = "IVIEWBRLOOKBACKMIN"
 SET reply->statlist[14].total_items = 0
 SET reply->statlist[14].qualifying_items = 0
 SET reply->statlist[14].status_flag = 1
 SET bmdi_lookback_ok = "Y"
 SET lb_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_back_min")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET lb_value = cnvtint(trim(xvalue))
        IF (((lb_value < 15) OR (lb_value > 60)) )
         SET bmdi_lookback_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (bmdi_lookback_ok="N")
  SET reply->rowlist[14].celllist[2].string_value = "Fail"
  SET reply->statlist[14].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->rowlist[15].celllist[1].string_value = concat(
  "The 'BMDI look forward min' preference is set for"," 5 minutes.")
 SET reply->rowlist[15].celllist[2].string_value = "Pass"
 SET reply->statlist[15].statistic_meaning = "IVIEWBRLOOKFWDMIN"
 SET reply->statlist[15].total_items = 0
 SET reply->statlist[15].qualifying_items = 0
 SET reply->statlist[15].status_flag = 1
 SET bmdi_lookforward_ok = "Y"
 SET lf_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_forward_min")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET lf_value = cnvtint(trim(xvalue))
        IF (lf_value != 5)
         SET bmdi_lookforward_ok = "N"
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (bmdi_lookforward_ok="N")
  SET reply->rowlist[15].celllist[2].string_value = "Fail"
  SET reply->statlist[15].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_build_rec_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
