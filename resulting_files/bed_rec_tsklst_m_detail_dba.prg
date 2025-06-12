CREATE PROGRAM bed_rec_tsklst_m_detail:dba
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
 SET col_cnt = 8
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Position"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Task Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Task on PAL"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Task on Task List"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Recommended Setting"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resolution"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET cnt = 0
 SET tcnt = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="PATCAREPALTSKLST"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="PATCAREPALTSKLST")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    FREE SET tpal
    RECORD tpal(
      1 qual[*]
        2 pos_code = f8
        2 pos_disp = vc
        2 type_code = f8
        2 type_disp = vc
        2 loc_code = f8
        2 loc_disp = vc
    )
    FREE SET ttrk
    RECORD ttrk(
      1 qual[*]
        2 pos_code = f8
        2 pos_disp = vc
        2 type_code = f8
        2 type_disp = vc
    )
    FREE SET nomatch
    RECORD nomatch(
      1 qual[*]
        2 pos_disp = vc
        2 type_disp = vc
        2 loc_disp = vc
        2 p_fail = i2
        2 t_fail = i2
    )
    SET ptcnt = 0
    SELECT DISTINCT INTO "nl:"
     p.position_cd, cvg.child_code_value, p.location_cd
     FROM pip p,
      pip_section ps,
      pip_prefs pp,
      code_value_group cvg,
      code_value pos,
      code_value loc,
      code_value c
     PLAN (p
      WHERE p.prsnl_id=0)
      JOIN (ps
      WHERE ps.pip_id=p.pip_id)
      JOIN (pp
      WHERE pp.parent_entity_id=ps.pip_section_id
       AND pp.pref_name="TASK_GROUP")
      JOIN (cvg
      WHERE cvg.parent_code_value=pp.merge_id)
      JOIN (pos
      WHERE pos.code_value=outerjoin(p.position_cd)
       AND pos.active_ind=outerjoin(1))
      JOIN (loc
      WHERE loc.code_value=outerjoin(p.location_cd)
       AND loc.active_ind=outerjoin(1))
      JOIN (c
      WHERE c.code_value=cvg.child_code_value
       AND c.active_ind=1)
     ORDER BY p.position_cd, cvg.child_code_value
     HEAD REPORT
      cnt = 0, ptcnt = 0, stat = alterlist(tpal->qual,100)
     DETAIL
      IF (((((p.position_cd > 0
       AND pos.code_value > 0) OR (p.position_cd=0)) ) OR (((p.location_cd > 0
       AND loc.code_value > 0) OR (p.location_cd=0)) )) )
       cnt = (cnt+ 1), ptcnt = (ptcnt+ 1)
       IF (cnt > 100)
        stat = alterlist(tpal->qual,(ptcnt+ 100)), cnt = 1
       ENDIF
       tpal->qual[ptcnt].pos_code = p.position_cd, tpal->qual[ptcnt].pos_disp = pos.display, tpal->
       qual[ptcnt].type_code = cvg.child_code_value,
       tpal->qual[ptcnt].type_disp = c.display, tpal->qual[ptcnt].loc_code = p.location_cd, tpal->
       qual[ptcnt].loc_disp = loc.display
      ENDIF
     FOOT REPORT
      stat = alterlist(tpal->qual,ptcnt)
     WITH nocounter
    ;end select
    SET ttcnt = 0
    SELECT DISTINCT INTO "nl:"
     tpx.position_cd, tec.task_type_cd
     FROM tl_tab_position_xref tpx,
      tl_eligible_task_code tec,
      tl_tab_content ttc,
      code_value c1,
      code_value c2
     PLAN (tpx)
      JOIN (tec
      WHERE tec.tl_tab_id=tpx.tl_tab_id)
      JOIN (ttc
      WHERE ttc.tl_tab_id=tec.tl_tab_id)
      JOIN (c1
      WHERE c1.code_value=tpx.position_cd
       AND c1.active_ind=1)
      JOIN (c2
      WHERE c2.code_value=tec.task_type_cd
       AND c2.active_ind=1)
     ORDER BY tpx.position_cd, tec.task_type_cd
     HEAD REPORT
      cnt = 0, ttcnt = 0, stat = alterlist(ttrk->qual,100)
     DETAIL
      cnt = (cnt+ 1), ttcnt = (ttcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(ttrk->qual,(ttcnt+ 100)), cnt = 1
      ENDIF
      ttrk->qual[ttcnt].pos_code = tpx.position_cd, ttrk->qual[ttcnt].pos_disp = c1.display, ttrk->
      qual[ttcnt].type_code = tec.task_type_cd,
      ttrk->qual[ttcnt].type_disp = c2.display
     FOOT REPORT
      stat = alterlist(ttrk->qual,ttcnt)
     WITH nocounter
    ;end select
    FOR (x = 1 TO ptcnt)
      IF (ttcnt > 0)
       SET num = 0
       SET tindex = 0
       SET tindex = locatevalsort(num,1,ttcnt,tpal->qual[x].pos_code,ttrk->qual[num].pos_code,
        tpal->qual[x].type_code,ttrk->qual[num].type_code)
       IF (tindex <= 0)
        SET stat = add_row(tpal->qual[x].pos_disp,tpal->qual[x].loc_disp,tpal->qual[x].type_disp,1,0)
       ENDIF
      ELSE
       SET stat = add_row(tpal->qual[x].pos_disp,tpal->qual[x].loc_disp,tpal->qual[x].type_disp,1,0)
      ENDIF
    ENDFOR
    FOR (x = 1 TO ttcnt)
      IF (ptcnt > 0)
       SET num = 0
       SET tindex = 0
       SET tindex = locatevalsort(num,1,ptcnt,ttrk->qual[x].pos_code,tpal->qual[num].pos_code,
        ttrk->qual[x].type_code,tpal->qual[num].type_code)
       IF (tindex <= 0)
        SET stat = add_row(ttrk->qual[x].pos_disp,"",ttrk->qual[x].type_disp,0,1)
       ENDIF
      ELSE
       SET stat = add_row(ttrk->qual[x].pos_disp,"",ttrk->qual[x].type_disp,0,1)
      ENDIF
    ENDFOR
    SET nomatch_cnt = size(nomatch->qual,5)
    IF (nomatch_cnt > 0)
     SELECT INTO "nl:"
      a = nomatch->qual[d.seq].pos_disp, b = nomatch->qual[d.seq].loc_disp, c = nomatch->qual[d.seq].
      type_disp
      FROM (dummyt d  WITH seq = value(nomatch_cnt))
      ORDER BY a, b, c
      DETAIL
       IF ((nomatch->qual[d.seq].t_fail=1))
        stat = add_rep(short_desc,nomatch->qual[d.seq].pos_disp,nomatch->qual[d.seq].loc_disp,nomatch
         ->qual[d.seq].type_disp,"No",
         "Yes","Exist on both",resolution_txt)
       ELSE
        stat = add_rep(short_desc,nomatch->qual[d.seq].pos_disp,nomatch->qual[d.seq].loc_disp,nomatch
         ->qual[d.seq].type_disp,"Yes",
         "No","Exist on both",resolution_txt)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE add_row(pd,ld,td,pf,tf)
   SET fail_cnt = (size(nomatch->qual,5)+ 1)
   SET stat = alterlist(nomatch->qual,fail_cnt)
   SET nomatch->qual[fail_cnt].type_disp = td
   SET nomatch->qual[fail_cnt].loc_disp = ld
   SET nomatch->qual[fail_cnt].pos_disp = pd
   SET nomatch->qual[fail_cnt].t_fail = tf
   SET nomatch->qual[fail_cnt].p_fail = pf
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   RETURN(1)
 END ;Subroutine
 CALL echorecord(ttrk)
 CALL echorecord(tpal)
#exit_script
 SET reply->status_data.status = "S"
END GO
