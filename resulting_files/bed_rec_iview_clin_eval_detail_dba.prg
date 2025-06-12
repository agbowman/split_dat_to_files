CREATE PROGRAM bed_rec_iview_clin_eval_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 RECORD temp(
   1 pelist[*]
     2 section_name = vc
     2 event_set_name = vc
     2 event_set_cd = f8
     2 event_cd = f8
     2 more_than_one_ind = i2
     2 more_than_one_dta_ind = i2
     2 inactive_ind = i2
     2 missing_ind = i2
     2 not_exist_ind = i2
 )
 RECORD temp2(
   1 pelist[*]
     2 section_name = vc
     2 event_set_name = vc
     2 event_set_cd = f8
     2 event_cd = f8
     2 more_than_one_ind = i2
     2 more_than_one_dta_ind = i2
     2 inactive_ind = i2
     2 missing_ind = i2
     2 not_exist_ind = i2
 )
 SET active_cd = get_code_value(48,"ACTIVE")
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
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET check_more_act_ind = 0
 SET check_more_dta_ind = 0
 SET check_inact_ind = 0
 SET check_missing_ind = 0
 SET check_all_res_ind = 0
 SET more_act_col_nbr = 0
 SET more_dta_col_nbr = 0
 SET inact_col_nbr = 0
 SET missing_col_nbr = 0
 SET all_res_col_nbr = 0
 SET allresult_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc
  PLAN (vesc
   WHERE vesc.event_set_name_key IN ("ALLSPECIALTYSECTIONS", "WORKINGVIEWSECTIONS",
   "ALLRESULTSECTIONS"))
  DETAIL
   IF (vesc.event_set_name_key="ALLRESULTSECTIONS")
    allresult_cd = vesc.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 SET col_cnt = (2+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Section Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primitive Event Set"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET tcnt = 0
 SET sectioncnt = 0
 SET next_col = 2
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="MORETHN1ACTIVEEVNTCD"))
    SET check_more_act_ind = 1
    SET next_col = (next_col+ 1)
    SET more_act_col_nbr = next_col
    SET reply->collist[next_col].header_text = "More Than One Active Event Code"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code vesc,
      v500_event_set_explode vese,
      v500_event_code vec,
      code_value cv
     PLAN (wvs
      WHERE wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
      JOIN (vesc
      WHERE vesc.event_set_name=wvi.primitive_event_set_name
       AND vesc.display_association_ind=0)
      JOIN (vese
      WHERE vese.event_set_cd=vesc.event_set_cd
       AND vese.event_set_level=0)
      JOIN (vec
      WHERE vec.event_cd=vese.event_cd)
      JOIN (cv
      WHERE cv.code_value=vec.event_cd)
     ORDER BY wvs.display_name, wvi.primitive_event_set_name
     HEAD wvs.display_name
      sectioncnt = (sectioncnt+ 1)
     HEAD wvi.primitive_event_set_name
      tcnt = (tcnt+ 1), active_cnt = 0, stat = alterlist(temp->pelist,tcnt),
      temp->pelist[tcnt].section_name = wvs.display_name, temp->pelist[tcnt].event_set_name = wvi
      .primitive_event_set_name, temp->pelist[tcnt].event_set_cd = vesc.event_set_cd
     HEAD vec.event_cd
      IF (vec.code_status_cd=active_cd
       AND cv.active_ind=1)
       active_cnt = (active_cnt+ 1)
      ENDIF
     FOOT  wvi.primitive_event_set_name
      IF (active_cnt > 1)
       temp->pelist[tcnt].more_than_one_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MORETHN1ASSAYPEREVNTCD"))
    SET check_more_dta_ind = 1
    SET next_col = (next_col+ 1)
    SET more_dta_col_nbr = next_col
    SET reply->collist[next_col].header_text = "More Than One Assay per Event Code"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code vesc,
      v500_event_set_explode vese,
      v500_event_code vec,
      code_value cv,
      discrete_task_assay dta
     PLAN (wvs
      WHERE wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
      JOIN (vesc
      WHERE vesc.event_set_name=wvi.primitive_event_set_name
       AND vesc.display_association_ind=0)
      JOIN (vese
      WHERE vese.event_set_cd=vesc.event_set_cd
       AND vese.event_set_level=0)
      JOIN (vec
      WHERE vec.event_cd=vese.event_cd)
      JOIN (cv
      WHERE cv.code_value=vec.event_cd)
      JOIN (dta
      WHERE dta.event_cd=vec.event_cd)
     ORDER BY wvs.display_name, wvi.primitive_event_set_name
     HEAD wvs.display_name
      sectioncnt = (sectioncnt+ 1)
     HEAD wvi.primitive_event_set_name
      tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = wvs
      .display_name,
      temp->pelist[tcnt].event_set_name = wvi.primitive_event_set_name, temp->pelist[tcnt].
      event_set_cd = vesc.event_set_cd
     HEAD vec.event_cd
      dta_cnt = 0
     HEAD dta.task_assay_cd
      dta_cnt = (dta_cnt+ 1)
     FOOT  vec.event_cd
      IF (dta_cnt > 1)
       temp->pelist[tcnt].more_than_one_dta_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="INACTIVEEVNTCD"))
    SET check_inact_ind = 1
    SET next_col = (next_col+ 1)
    SET inact_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Inactive Event Code"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code vesc,
      v500_event_set_explode vese,
      v500_event_code vec,
      code_value cv
     PLAN (wvs
      WHERE wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
      JOIN (vesc
      WHERE vesc.event_set_name=wvi.primitive_event_set_name
       AND vesc.display_association_ind=0)
      JOIN (vese
      WHERE vese.event_set_cd=vesc.event_set_cd
       AND vese.event_set_level=0)
      JOIN (vec
      WHERE vec.event_cd=vese.event_cd)
      JOIN (cv
      WHERE cv.code_value=vec.event_cd)
     ORDER BY wvs.display_name, wvi.primitive_event_set_name
     HEAD wvs.display_name
      sectioncnt = (sectioncnt+ 1)
     HEAD wvi.primitive_event_set_name
      tcnt = (tcnt+ 1), active_cnt = 0, stat = alterlist(temp->pelist,tcnt),
      temp->pelist[tcnt].section_name = wvs.display_name, temp->pelist[tcnt].event_set_name = wvi
      .primitive_event_set_name, temp->pelist[tcnt].event_set_cd = vesc.event_set_cd
     HEAD vec.event_cd
      IF (vec.code_status_cd=active_cd
       AND cv.active_ind=1)
       active_cnt = (active_cnt+ 1)
      ELSE
       temp->pelist[tcnt].inactive_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MISSINGEVNTCD"))
    SET check_missing_ind = 1
    SET next_col = (next_col+ 1)
    SET missing_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Missing Event Code"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code vesc,
      v500_event_set_explode vese,
      v500_event_code vec,
      code_value cv
     PLAN (wvs
      WHERE wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
      JOIN (vesc
      WHERE vesc.event_set_name=wvi.primitive_event_set_name
       AND vesc.display_association_ind=0
       AND  NOT ( EXISTS (
      (SELECT
       parent_event_set_cd
       FROM v500_event_set_canon
       WHERE parent_event_set_cd=vesc.event_set_cd))))
      JOIN (vese
      WHERE vese.event_set_cd=outerjoin(vesc.event_set_cd)
       AND vese.event_set_level=outerjoin(0))
      JOIN (vec
      WHERE vec.event_cd=outerjoin(vese.event_cd))
      JOIN (cv
      WHERE cv.code_value=outerjoin(vec.event_cd))
     ORDER BY wvs.display_name, wvi.primitive_event_set_name
     HEAD wvs.display_name
      sectioncnt = (sectioncnt+ 1)
     HEAD wvi.primitive_event_set_name
      IF (vese.event_set_cd=0)
       tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = wvs
       .display_name,
       temp->pelist[tcnt].event_set_name = wvi.primitive_event_set_name, temp->pelist[tcnt].
       event_set_cd = vesc.event_set_cd, temp->pelist[tcnt].missing_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="NOTINALLRESULTEVNTSET"))
    SET check_all_res_ind = 1
    SET next_col = (next_col+ 1)
    SET all_res_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Not in All Results Event Set"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM working_view_section wvs,
      working_view_item wvi,
      v500_event_set_code vesc,
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
     PLAN (wvs
      WHERE wvs.display_name > " ")
      JOIN (wvi
      WHERE wvi.working_view_section_id=wvs.working_view_section_id)
      JOIN (vesc
      WHERE vesc.event_set_name=wvi.primitive_event_set_name
       AND vesc.display_association_ind=0)
      JOIN (vesc1
      WHERE vesc1.event_set_cd=vesc.event_set_cd
       AND  NOT ( EXISTS (
      (SELECT
       parent_event_set_cd
       FROM v500_event_set_canon
       WHERE parent_event_set_cd=vesc1.event_set_cd))))
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
     ORDER BY wvs.display_name, wvi.primitive_event_set_name
     HEAD REPORT
      found = "N"
     HEAD wvs.display_name
      sectioncnt = (sectioncnt+ 1)
     HEAD wvi.primitive_event_set_name
      tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = wvs
      .display_name,
      temp->pelist[tcnt].event_set_name = wvi.primitive_event_set_name, temp->pelist[tcnt].
      event_set_cd = vesc.event_set_cd
     HEAD vesc1.event_set_cd
      found = "N"
     DETAIL
      IF (((vesc19.parent_event_set_cd=allresult_cd) OR (((vesc18.parent_event_set_cd=allresult_cd)
       OR (((vesc17.parent_event_set_cd=allresult_cd) OR (((vesc16.parent_event_set_cd=allresult_cd)
       OR (((vesc15.parent_event_set_cd=allresult_cd) OR (((vesc14.parent_event_set_cd=allresult_cd)
       OR (((vesc13.parent_event_set_cd=allresult_cd) OR (((vesc12.parent_event_set_cd=allresult_cd)
       OR (((vesc11.parent_event_set_cd=allresult_cd) OR (((vesc10.parent_event_set_cd=allresult_cd)
       OR (((vesc9.parent_event_set_cd=allresult_cd) OR (((vesc8.parent_event_set_cd=allresult_cd)
       OR (((vesc7.parent_event_set_cd=allresult_cd) OR (((vesc6.parent_event_set_cd=allresult_cd)
       OR (((vesc5.parent_event_set_cd=allresult_cd) OR (((vesc4.parent_event_set_cd=allresult_cd)
       OR (((vesc3.parent_event_set_cd=allresult_cd) OR (((vesc2.parent_event_set_cd=allresult_cd)
       OR (vesc1.parent_event_set_cd=allresult_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
      )) )
       found = "Y"
      ENDIF
     FOOT  vesc1.event_set_cd
      IF (found="N")
       temp->pelist[tcnt].not_exist_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET phx = 0
 IF (tcnt > 0)
  SET stat = alterlist(temp2->pelist,tcnt)
  SELECT INTO "nl:"
   sname = cnvtupper(temp->pelist[d.seq].section_name), pename = cnvtupper(temp->pelist[d.seq].
    event_set_name)
   FROM (dummyt d  WITH seq = tcnt)
   PLAN (d)
   ORDER BY sname, pename
   DETAIL
    IF ((((temp->pelist[d.seq].more_than_one_ind=1)) OR ((((temp->pelist[d.seq].more_than_one_dta_ind
    =1)) OR ((((temp->pelist[d.seq].missing_ind=1)) OR ((((temp->pelist[d.seq].inactive_ind=1)) OR ((
    temp->pelist[d.seq].not_exist_ind=1))) )) )) )) )
     phx = (phx+ 1), temp2->pelist[phx].event_set_cd = temp->pelist[d.seq].event_set_cd, temp2->
     pelist[phx].section_name = temp->pelist[d.seq].section_name,
     temp2->pelist[phx].event_set_name = temp->pelist[d.seq].event_set_name, temp2->pelist[phx].
     more_than_one_ind = temp->pelist[d.seq].more_than_one_ind, temp2->pelist[phx].
     more_than_one_dta_ind = temp->pelist[d.seq].more_than_one_dta_ind,
     temp2->pelist[phx].inactive_ind = temp->pelist[d.seq].inactive_ind, temp2->pelist[phx].
     missing_ind = temp->pelist[d.seq].missing_ind, temp2->pelist[phx].not_exist_ind = temp->pelist[d
     .seq].not_exist_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (phx > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   sname = cnvtupper(temp2->pelist[d.seq].section_name), pename = cnvtupper(temp2->pelist[d.seq].
    event_set_name)
   FROM (dummyt d  WITH seq = phx)
   PLAN (d)
   ORDER BY sname, pename
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp2->pelist[d.seq].section_name, reply->
    rowlist[rcnt].celllist[2].string_value = temp2->pelist[d.seq].event_set_name
    IF (check_more_act_ind=1
     AND (temp2->pelist[d.seq].more_than_one_ind=1))
     reply->rowlist[rcnt].celllist[more_act_col_nbr].string_value = "X"
    ENDIF
    IF (check_more_dta_ind=1
     AND (temp2->pelist[d.seq].more_than_one_dta_ind=1))
     reply->rowlist[rcnt].celllist[more_dta_col_nbr].string_value = "X"
    ENDIF
    IF (check_inact_ind=1
     AND (temp2->pelist[d.seq].inactive_ind=1))
     reply->rowlist[rcnt].celllist[inact_col_nbr].string_value = "X"
    ENDIF
    IF (check_missing_ind=1
     AND (temp2->pelist[d.seq].missing_ind=1))
     reply->rowlist[rcnt].celllist[missing_col_nbr].string_value = "X"
    ENDIF
    IF (check_all_res_ind=1
     AND (temp2->pelist[d.seq].not_exist_ind=1))
     reply->rowlist[rcnt].celllist[all_res_col_nbr].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO
