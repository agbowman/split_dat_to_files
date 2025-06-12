CREATE PROGRAM bed_aud_inet_ce_eval:dba
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
 RECORD temp(
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
  SET stat = alterlist(reply->collist,1)
  SET reply->collist[1].header_text = "Unable to Continue Reason"
  SET reply->collist[1].data_type = 1
  SET stat = alterlist(reply->rowlist,1)
  SET stat = alterlist(reply->rowlist[1].celllist,1)
  SET reply->rowlist[1].celllist[1].string_value = concat(
   "Event Set Hierarchy is incorrect. The Working View Sections ",
   "specialty event set must be directly below the ","All Specialty Sections event set.")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Section Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primitive Event Set"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "More Than One Active Event Code"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "More Than One Assay per Event Code"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Inactive Event Code"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Missing Event Code"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Not in All Results Event Set"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
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
 CALL echo(build("TCNT:",tcnt))
 IF ((request->skip_volume_check_ind=0))
  IF (tcnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (tcnt > 2500)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   v500_event_set_canon vs,
   v500_event_set_code vesc
  PLAN (d
   WHERE (temp->pelist[d.seq].display_association_ind=1))
   JOIN (vs
   WHERE (vs.parent_event_set_cd=temp->pelist[d.seq].event_set_cd))
   JOIN (vesc
   WHERE vesc.event_set_cd=vs.event_set_cd)
  ORDER BY d.seq, vesc.event_set_cd
  HEAD vesc.event_set_cd
   tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = temp->
   pelist[d.seq].section_name,
   temp->pelist[tcnt].event_set_name = vesc.event_set_name, temp->pelist[tcnt].event_set_cd = vesc
   .event_set_cd, temp->pelist[tcnt].display_association_ind = vesc.display_association_ind,
   temp->pelist[tcnt].more_than_one_ind = 0, temp->pelist[tcnt].inactive_ind = 0, temp->pelist[tcnt].
   missing_ind = 1,
   temp->pelist[tcnt].not_exist_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   v500_event_set_explode vese,
   v500_event_code vec,
   code_value cv
  PLAN (d
   WHERE (temp->pelist[d.seq].event_set_cd > 0)
    AND (temp->pelist[d.seq].display_association_ind=0))
   JOIN (vese
   WHERE (vese.event_set_cd=temp->pelist[d.seq].event_set_cd))
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
   JOIN (cv
   WHERE cv.code_value=vec.event_cd)
  HEAD d.seq
   active_cnt = 0
  DETAIL
   temp->pelist[d.seq].missing_ind = 0
   IF (vec.code_status_cd=active_cd
    AND cv.active_ind=1)
    active_cnt = (active_cnt+ 1)
   ELSE
    temp->pelist[d.seq].inactive_ind = 1
   ENDIF
  FOOT  d.seq
   IF (active_cnt > 1)
    IF ((temp->pelist[d.seq].display_association_ind != 1))
     temp->pelist[d.seq].more_than_one_ind = 1
    ENDIF
   ELSE
    temp->pelist[d.seq].event_cd = vec.event_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   discrete_task_assay dta
  PLAN (d
   WHERE (temp->pelist[d.seq].event_cd > 0))
   JOIN (dta
   WHERE (dta.event_cd=temp->pelist[d.seq].event_cd))
  HEAD d.seq
   dta_cnt = 0
  DETAIL
   dta_cnt = (dta_cnt+ 1),
   CALL echo(build(dta_cnt))
  FOOT  d.seq
   IF (dta_cnt > 1)
    temp->pelist[d.seq].more_than_one_dta_ind = 1,
    CALL echo(build(temp->pelist[d.seq].event_cd))
   ENDIF
  WITH nocounter
 ;end select
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
   WHERE (temp->pelist[d.seq].event_set_cd > 0)
    AND (temp->pelist[d.seq].display_association_ind=0))
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
   IF (((vesc19.parent_event_set_cd=allresult_cd) OR (((vesc18.parent_event_set_cd=allresult_cd) OR (
   ((vesc17.parent_event_set_cd=allresult_cd) OR (((vesc16.parent_event_set_cd=allresult_cd) OR (((
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
    temp->pelist[d.seq].not_exist_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET rcnt = 0
 SET sect_too_many_cnt = 0
 SET sect_too_many_dta_cnt = 0
 SET sect_inactive_cnt = 0
 SET sect_missing_cnt = 0
 SET sect_not_exist_cnt = 0
 SELECT INTO "nl:"
  sname = cnvtupper(temp->pelist[d.seq].section_name), pename = cnvtupper(temp->pelist[d.seq].
   event_set_name)
  FROM (dummyt d  WITH seq = tcnt)
  PLAN (d
   WHERE (temp->pelist[d.seq].display_association_ind=0))
  ORDER BY sname, pename
  HEAD sname
   sect_too_many_ind = 0, sect_too_many_dta_ind = 0, sect_inactive_ind = 0,
   sect_missing_ind = 0, sect_not_exist_ind = 0
  DETAIL
   IF ((((temp->pelist[d.seq].more_than_one_ind=1)) OR ((((temp->pelist[d.seq].more_than_one_dta_ind=
   1)) OR ((((temp->pelist[d.seq].missing_ind=1)) OR ((((temp->pelist[d.seq].inactive_ind=1)) OR ((
   temp->pelist[d.seq].not_exist_ind=1))) )) )) )) )
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,7),
    reply->rowlist[rcnt].celllist[1].string_value = temp->pelist[d.seq].section_name, reply->rowlist[
    rcnt].celllist[2].string_value = temp->pelist[d.seq].event_set_name
    IF ((temp->pelist[d.seq].more_than_one_ind=1))
     sect_too_many_ind = 1, reply->rowlist[rcnt].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[3].string_value = " "
    ENDIF
    IF ((temp->pelist[d.seq].more_than_one_dta_ind=1))
     sect_too_many_dta_ind = 1, reply->rowlist[rcnt].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[4].string_value = " "
    ENDIF
    IF ((temp->pelist[d.seq].inactive_ind=1))
     sect_inactive_ind = 1, reply->rowlist[rcnt].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[5].string_value = " "
    ENDIF
    IF ((temp->pelist[d.seq].missing_ind=1))
     sect_missing_ind = 1, reply->rowlist[rcnt].celllist[6].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[6].string_value = " "
    ENDIF
    IF ((temp->pelist[d.seq].not_exist_ind=1))
     sect_not_exist_ind = 1, reply->rowlist[rcnt].celllist[7].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[7].string_value = " "
    ENDIF
   ENDIF
  FOOT  sname
   IF (sect_too_many_ind=1)
    sect_too_many_cnt = (sect_too_many_cnt+ 1)
   ENDIF
   IF (sect_too_many_dta_ind=1)
    sect_too_many_dta_cnt = (sect_too_many_dta_cnt+ 1)
   ENDIF
   IF (sect_inactive_ind=1)
    sect_inactive_cnt = (sect_inactive_cnt+ 1)
   ENDIF
   IF (sect_missing_ind=1)
    sect_missing_cnt = (sect_missing_cnt+ 1)
   ENDIF
   IF (sect_not_exist_ind=1)
    sect_not_exist_cnt = (sect_not_exist_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,5)
 SET reply->statlist[1].statistic_meaning = "INETCEMORETHANONE"
 SET reply->statlist[1].total_items = sectioncnt
 SET reply->statlist[1].qualifying_items = sect_too_many_cnt
 IF (sect_too_many_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "INETCEMORETHANONEDTA"
 SET reply->statlist[2].total_items = sectioncnt
 SET reply->statlist[2].qualifying_items = sect_too_many_dta_cnt
 IF (sect_too_many_dta_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "INETCEINACTIVE"
 SET reply->statlist[3].total_items = sectioncnt
 SET reply->statlist[3].qualifying_items = sect_inactive_cnt
 IF (sect_inactive_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].statistic_meaning = "INETCEMISSING"
 SET reply->statlist[4].total_items = sectioncnt
 SET reply->statlist[4].qualifying_items = sect_missing_cnt
 IF (sect_missing_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
 SET reply->statlist[5].statistic_meaning = "INETCENOTEXIST"
 SET reply->statlist[5].total_items = sectioncnt
 SET reply->statlist[5].qualifying_items = sect_not_exist_cnt
 IF (sect_not_exist_cnt > 0)
  SET reply->statlist[5].status_flag = 3
 ELSE
  SET reply->statlist[5].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("inet_ce_eval_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
