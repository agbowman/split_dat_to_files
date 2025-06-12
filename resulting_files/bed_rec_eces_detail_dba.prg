CREATE PROGRAM bed_rec_eces_detail:dba
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
     2 prim_event_set_name = vc
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
 SET col_cnt = 7
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Primitive Event Set"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Event Set Code Value"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Event Set Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Recommended Setting"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Resolution"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET active_cd = get_code_value(48,"ACTIVE")
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
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
   temp->pelist[tcnt].event_set_name = vesc.event_set_name, temp->pelist[tcnt].event_set_cd = vesc
   .event_set_cd, temp->pelist[tcnt].display_association_ind = vesc.display_association_ind,
   temp->pelist[tcnt].more_than_one_ind = 0, temp->pelist[tcnt].not_exist_ind = 0, temp->pelist[tcnt]
   .prim_event_set_name = wvi.primitive_event_set_name
  WITH nocounter
 ;end select
 CALL echo(build("TCNT:",tcnt))
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET plsize = 0
 SET plsize = size(request->paramlist,5)
 SET match_ind = 0
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning IN ("IVIEWPRIMSETDTA", "IVIEWCODEWDTA")))
    SET match_ind = 1
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
        temp->pelist[d.seq].more_than_one_ind = 1
       ENDIF
      ELSE
       temp->pelist[d.seq].event_cd = vec.event_cd
      ENDIF
     WITH nocounter
    ;end select
    IF ((request->paramlist[x].meaning="IVIEWPRIMSETDTA"))
     SET short_desc = ""
     SET resolution_txt = ""
     SELECT INTO "nl:"
      FROM br_rec b,
       br_long_text bl2
      PLAN (b
       WHERE b.rec_mean="IVIEWPRIMSETDTA")
       JOIN (bl2
       WHERE bl2.long_text_id=b.resolution_txt_id)
      DETAIL
       short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      sname = cnvtupper(temp->pelist[d.seq].section_name), pename = cnvtupper(temp->pelist[d.seq].
       event_set_name)
      FROM (dummyt d  WITH seq = tcnt)
      PLAN (d
       WHERE (temp->pelist[d.seq].more_than_one_ind=1))
      ORDER BY sname, pename
      HEAD d.seq
       stat = add_rep(short_desc,temp->pelist[d.seq].section_name,temp->pelist[d.seq].
        prim_event_set_name,temp->pelist[d.seq].event_set_cd,temp->pelist[d.seq].event_set_name,
        "One active event code associated with the primitive event set",resolution_txt)
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->paramlist[x].meaning="IVIEWCODEWDTA"))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = tcnt),
       code_value_event_r cver
      PLAN (d
       WHERE (temp->pelist[d.seq].event_cd > 0))
       JOIN (cver
       WHERE (cver.event_cd=temp->pelist[d.seq].event_cd))
      ORDER BY d.seq
      HEAD d.seq
       dta_cnt = 0
      DETAIL
       dta_cnt = (dta_cnt+ 1)
      FOOT  d.seq
       IF (dta_cnt > 1)
        temp->pelist[d.seq].more_than_one_dta_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = tcnt),
       discrete_task_assay dta
      PLAN (d
       WHERE (temp->pelist[d.seq].event_cd > 0)
        AND (temp->pelist[d.seq].more_than_one_dta_ind=0))
       JOIN (dta
       WHERE (dta.event_cd=temp->pelist[d.seq].event_cd))
      ORDER BY d.seq
      HEAD d.seq
       dta_cnt = 0
      DETAIL
       dta_cnt = (dta_cnt+ 1)
      FOOT  d.seq
       IF (dta_cnt > 1)
        temp->pelist[d.seq].more_than_one_dta_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     SET short_desc = ""
     SET resolution_txt = ""
     SELECT INTO "nl:"
      FROM br_rec b,
       br_long_text bl2
      PLAN (b
       WHERE b.rec_mean="IVIEWCODEWDTA")
       JOIN (bl2
       WHERE bl2.long_text_id=b.resolution_txt_id)
      DETAIL
       short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      sname = cnvtupper(temp->pelist[d.seq].section_name), pename = cnvtupper(temp->pelist[d.seq].
       event_set_name)
      FROM (dummyt d  WITH seq = tcnt)
      PLAN (d
       WHERE (temp->pelist[d.seq].more_than_one_dta_ind=1))
      ORDER BY sname, pename
      HEAD d.seq
       stat = add_rep(short_desc,temp->pelist[d.seq].section_name,temp->pelist[d.seq].
        prim_event_set_name,temp->pelist[d.seq].event_set_cd,temp->pelist[d.seq].event_set_name,
        "One assay per event code",resolution_txt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IVIEWALLRESULTS"))
    SET allresult_cd = 0.0
    SELECT INTO "nl:"
     FROM v500_event_set_code vesc
     PLAN (vesc
      WHERE vesc.event_set_name_key="ALLRESULTSECTIONS")
     DETAIL
      allresult_cd = vesc.event_set_cd
     WITH nocounter
    ;end select
    SET match_ind = 1
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
     FOOT  d.seq
      IF (found="N")
       temp->pelist[d.seq].not_exist_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="ALLRESULTSECTIONS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     sname = cnvtupper(temp->pelist[d.seq].section_name), pename = cnvtupper(temp->pelist[d.seq].
      event_set_name)
     FROM (dummyt d  WITH seq = tcnt)
     PLAN (d
      WHERE (temp->pelist[d.seq].not_exist_ind=1))
     ORDER BY sname, pename
     HEAD d.seq
      stat = add_rep(short_desc,temp->pelist[d.seq].section_name,temp->pelist[d.seq].
       prim_event_set_name,temp->pelist[d.seq].event_set_cd,temp->pelist[d.seq].event_set_name,
       "Primitive event set included once in All Results",resolution_txt)
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[x].meaning="CLINREPMRPDUP"))
    FREE SET temp
    RECORD temp(
      1 qual[*]
        2 es_code = f8
        2 level = i4
    )
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CLINREPMRPDUP")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SET level = 0
    SET stat = alterlist(temp->qual,1)
    SELECT INTO "nl:"
     FROM v500_event_set_code s
     PLAN (s
      WHERE s.event_set_name_key="MRPDOCUMENTS"
       AND s.event_set_name="MRP Documents")
     DETAIL
      temp->qual[1].es_code = s.event_set_cd
     WITH nocounter
    ;end select
    IF ((temp->qual[1].es_code > 0))
     SET found = 1
     SET tcnt = 1
     WHILE (found=1)
      SET found = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(tcnt)),
        v500_event_set_canon v
       PLAN (d
        WHERE (temp->qual[d.seq].level=level))
        JOIN (v
        WHERE (v.parent_event_set_cd=temp->qual[d.seq].es_code))
       ORDER BY v.event_set_cd
       HEAD REPORT
        level = (level+ 1), cnt = 0, ttcnt = tcnt,
        stat = alterlist(temp->qual,(ttcnt+ 100))
       HEAD v.event_set_cd
        cnt = (cnt+ 1), ttcnt = (ttcnt+ 1)
        IF (cnt > 100)
         stat = alterlist(temp->qual,(ttcnt+ 100)), cnt = 1
        ENDIF
        temp->qual[ttcnt].es_code = v.event_set_cd, temp->qual[ttcnt].level = level, found = 1
       FOOT REPORT
        stat = alterlist(temp->qual,ttcnt), tcnt = ttcnt
       WITH nocounter
      ;end select
     ENDWHILE
     IF (tcnt > 1)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(tcnt)),
        v500_event_set_code v
       PLAN (d)
        JOIN (v
        WHERE (v.event_set_cd=temp->qual[d.seq].es_code))
       ORDER BY v.event_set_name
       HEAD v.event_set_cd
        set_cnt = 0
       DETAIL
        set_cnt = (set_cnt+ 1)
       FOOT  v.event_set_cd
        IF (set_cnt > 1)
         stat = add_rep(short_desc,"","",v.event_set_cd,v.event_set_name,
          "No dupliacte event sets in MRP Documents grouper",resolution_txt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].double_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
END GO
