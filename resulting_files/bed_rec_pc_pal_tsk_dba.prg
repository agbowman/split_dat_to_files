CREATE PROGRAM bed_rec_pc_pal_tsk:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tpal
 RECORD tpal(
   1 qual[*]
     2 pos_code = f8
     2 type_code = f8
 )
 FREE SET ttrk
 RECORD ttrk(
   1 qual[*]
     2 pos_code = f8
     2 type_code = f8
 )
 SET reply->run_status_flag = 3
 SET ptcnt = 0
 SELECT DISTINCT INTO "nl:"
  p.position_cd, cvg.child_code_value, p.location_cd
  FROM pip p,
   pip_section ps,
   pip_prefs pp,
   code_value_group cvg,
   code_value c1,
   code_value c2,
   code_value c3
  PLAN (p
   WHERE p.prsnl_id=0)
   JOIN (ps
   WHERE ps.pip_id=p.pip_id)
   JOIN (pp
   WHERE pp.parent_entity_id=ps.pip_section_id
    AND pp.pref_name="TASK_GROUP")
   JOIN (cvg
   WHERE cvg.parent_code_value=pp.merge_id)
   JOIN (c1
   WHERE c1.code_value=outerjoin(p.position_cd)
    AND c1.active_ind=outerjoin(1))
   JOIN (c2
   WHERE c2.code_value=outerjoin(p.location_cd)
    AND c2.active_ind=outerjoin(1))
   JOIN (c3
   WHERE c3.code_value=cvg.child_code_value
    AND c3.active_ind=1)
  ORDER BY p.position_cd, cvg.child_code_value, p.location_cd
  HEAD REPORT
   cnt = 0, ptcnt = 0, stat = alterlist(tpal->qual,100)
  DETAIL
   IF (((((p.position_cd > 0
    AND c1.code_value > 0) OR (p.position_cd=0)) ) OR (((p.location_cd > 0
    AND c2.code_value > 0) OR (p.location_cd=0)) )) )
    cnt = (cnt+ 1), ptcnt = (ptcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tpal->qual,(ptcnt+ 100)), cnt = 1
    ENDIF
    tpal->qual[ptcnt].pos_code = p.position_cd, tpal->qual[ptcnt].type_code = cvg.child_code_value
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
   ttrk->qual[ttcnt].pos_code = tpx.position_cd, ttrk->qual[ttcnt].type_code = tec.task_type_cd
  FOOT REPORT
   stat = alterlist(ttrk->qual,ttcnt)
  WITH nocounter
 ;end select
 SET nomatch = 0
 FOR (x = 1 TO ptcnt)
   IF (ttcnt > 0)
    SET num = 0
    SET tindex = 0
    SET tindex = locatevalsort(num,1,ttcnt,tpal->qual[x].pos_code,ttrk->qual[num].pos_code,
     tpal->qual[x].type_code,ttrk->qual[num].type_code)
    IF (tindex <= 0)
     SET reply->run_status_flag = 3
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->run_status_flag = 3
    GO TO exit_script
   ENDIF
 ENDFOR
 FOR (x = 1 TO ttcnt)
   IF (ptcnt > 0)
    SET num = 0
    SET tindex = 0
    SET tindex = locatevalsort(num,1,ptcnt,ttrk->qual[x].pos_code,tpal->qual[num].pos_code,
     ttrk->qual[x].type_code,tpal->qual[num].type_code)
    IF (tindex <= 0)
     SET reply->run_status_flag = 3
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->run_status_flag = 3
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (nomatch=0)
  SET reply->run_status_flag = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
