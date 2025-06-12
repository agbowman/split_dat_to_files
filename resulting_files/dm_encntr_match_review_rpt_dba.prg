CREATE PROGRAM dm_encntr_match_review_rpt:dba
 PAINT
 CALL clear(1,1)
 SET sdate = fillstring(50," ")
 SET edate = fillstring(50," ")
 SET start_date = fillstring(50," ")
 SET end_date = fillstring(50," ")
 CALL text(1,1,"Start of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(2,1,"p(50);cu")
 SET sdate = curaccept
 SET start_date = build(sdate," 23:59:59")
 CALL text(4,1,"End of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(5,1,"p(50);cu")
 SET edate = curaccept
 SET end_date = build(edate," 23:59:59")
 CALL clear(1,1)
 RECORD rpersons(
   1 qual[*]
     2 person_id = f8
 )
 RECORD rencntrs(
   1 enc[*]
     2 person_id = f8
     2 encntr_id = f8
     2 data_status = i2
     2 updt_dt_tm = dq8
     2 fin_alias = vc
     2 fin_alias_pool = f8
     2 visit_alias = vc
     2 visit_alias_pool = f8
     2 disch_dt_tm = dq8
     2 nurse_unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 encntr_type_cd = f8
     2 med_service_cd = f8
     2 reg_dt_tm = f8
     2 data_status_cd = f8
     2 name = vc
     2 cmrn = vc
     2 birth_dt_tm = dq8
     2 contrib_sys_cd = f8
     2 emrn = vc
     2 attend_doc = vc
   1 pers[*]
     2 person_id = f8
     2 fin_alias = vc
     2 fin_alias_pool = f8
     2 visit_alias = vc
     2 visit_alias_pool = f8
   1 temp_enc[*]
     2 encntr_id = f8
 )
 SET dm_auth_cd = 0
 SET dm_unauth_cd = 0
 SET dm_fin_nbr_cd = 0
 SET dm_visit_cd = 0
 SET dm_cmrn_cd = 0
 SET dm_emrn_cd = 0
 SET dm_attenddoc_cd = 0
 SET dm_no_dups = 0
 RECORD rcmbenc(
   1 enc[*]
     2 person_combine_id = f8
     2 from_encntr_id = f8
     2 to_encntr_id = f8
     2 encntr_combine_id = f8
   1 enc_size = i2
 )
 SET rcmbenc->enc_size = 0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_auth_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="UNAUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_unauth_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="FIN NBR"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_fin_nbr_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="VISITID"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_visit_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="MRN"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_emrn_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="CMRN"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_cmrn_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=333
   AND c.cdf_meaning="ATTENDDOC"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_attenddoc_cd = c.code_value
  WITH nocounter
 ;end select
 SET dm_enc_cnt = 0
 SET dm_pers_cnt = 0
 SET pcnt = 0
 SELECT DISTINCT INTO "nl:"
  pc.to_person_id
  FROM person_combine pc
  PLAN (pc
   WHERE pc.updt_dt_tm >= cnvtdatetime(start_date)
    AND pc.updt_dt_tm <= cnvtdatetime(end_date)
    AND pc.active_ind=1)
  DETAIL
   pcnt += 1, stat = alterlist(rpersons->qual,pcnt), rpersons->qual[pcnt].person_id = pc.to_person_id
  WITH nocounter
 ;end select
 IF (pcnt=0)
  SET dm_no_dups = 1
  GO TO dm_exit_script
 ENDIF
 SELECT INTO "nl:"
  e1.encntr_id, e2.encntr_id
  FROM encounter e1,
   encounter e2,
   encntr_alias ea1,
   encntr_alias ea2,
   (dummyt d  WITH seq = value(pcnt))
  PLAN (d)
   JOIN (e1
   WHERE e1.active_ind=1
    AND (e1.person_id=rpersons->qual[d.seq].person_id))
   JOIN (e2
   WHERE e2.person_id=e1.person_id
    AND e1.encntr_id != e2.encntr_id
    AND e2.active_ind=1)
   JOIN (ea1
   WHERE e1.encntr_id=ea1.encntr_id
    AND ea1.encntr_alias_type_cd=dm_fin_nbr_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ea2
   WHERE e2.encntr_id=ea2.encntr_id
    AND ea2.encntr_alias_type_cd=dm_fin_nbr_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea2.alias_pool_cd=ea1.alias_pool_cd
    AND ea2.alias=ea1.alias)
  DETAIL
   dm_found = 0, dm_z = 1
   WHILE (dm_z <= dm_enc_cnt
    AND dm_found != 1)
     IF ((rencntrs->enc[dm_z].encntr_id=e1.encntr_id))
      dm_found = 1
     ELSE
      dm_z += 1
     ENDIF
   ENDWHILE
   IF (dm_found=0)
    dm_z = 1
    WHILE ((dm_z <= rcmbenc->enc_size)
     AND dm_found != 1)
      IF ((rcmbenc->enc[dm_z].from_encntr_id=e1.encntr_id))
       dm_found = 1
      ELSE
       dm_z += 1
      ENDIF
    ENDWHILE
    IF (dm_found=0)
     dm_enc_cnt += 1, stat = alterlist(rencntrs->enc,dm_enc_cnt), rencntrs->enc[dm_enc_cnt].person_id
      = e1.person_id,
     rencntrs->enc[dm_enc_cnt].encntr_id = e1.encntr_id, rencntrs->enc[dm_enc_cnt].updt_dt_tm = e1
     .updt_dt_tm, rencntrs->enc[dm_enc_cnt].fin_alias = ea1.alias,
     rencntrs->enc[dm_enc_cnt].fin_alias_pool = ea1.alias_pool_cd
     IF (e1.data_status_cd=dm_auth_cd)
      rencntrs->enc[dm_enc_cnt].data_status = 2
     ELSEIF (e1.data_status_cd=dm_unauth_cd)
      rencntrs->enc[dm_enc_cnt].data_status = 1
     ELSE
      rencntrs->enc[dm_enc_cnt].data_status = 0
     ENDIF
     rencntrs->enc[dm_enc_cnt].disch_dt_tm = e1.disch_dt_tm, rencntrs->enc[dm_enc_cnt].nurse_unit_cd
      = e1.loc_nurse_unit_cd, rencntrs->enc[dm_enc_cnt].room_cd = e1.loc_room_cd,
     rencntrs->enc[dm_enc_cnt].bed_cd = e1.loc_bed_cd, rencntrs->enc[dm_enc_cnt].encntr_type_cd = e1
     .encntr_type_cd, rencntrs->enc[dm_enc_cnt].med_service_cd = e1.med_service_cd,
     rencntrs->enc[dm_enc_cnt].reg_dt_tm = e1.reg_dt_tm, rencntrs->enc[dm_enc_cnt].data_status_cd =
     e1.data_status_cd, rencntrs->enc[dm_enc_cnt].contrib_sys_cd = e1.contributor_system_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_enc_cnt=0)
  SET dm_no_dups = 1
  GO TO dm_exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   person p
  PLAN (d)
   JOIN (p
   WHERE (rencntrs->enc[d.seq].person_id=p.person_id))
  DETAIL
   rencntrs->enc[d.seq].name = p.name_full_formatted, rencntrs->enc[d.seq].birth_dt_tm = p
   .birth_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (rencntrs->enc[d.seq].person_id=pa.person_id)
    AND pa.person_alias_type_cd=dm_cmrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   rencntrs->enc[d.seq].cmrn = pa.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (rencntrs->enc[d.seq].encntr_id=ea.encntr_id)
    AND ea.encntr_alias_type_cd=dm_emrn_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   rencntrs->enc[d.seq].emrn = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   encntr_prsnl_reltn epr,
   person p
  PLAN (d)
   JOIN (epr
   WHERE (rencntrs->enc[d.seq].encntr_id=epr.encntr_id)
    AND epr.encntr_prsnl_r_cd=dm_attenddoc_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE epr.prsnl_person_id=p.person_id)
  DETAIL
   rencntrs->enc[d.seq].attend_doc = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=rencntrs->enc[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=dm_visit_cd)
  DETAIL
   rencntrs->enc[d.seq].visit_alias = ea.alias, rencntrs->enc[d.seq].visit_alias_pool = ea
   .alias_pool_cd, dm_found2 = 0,
   dm_n = 1
   WHILE (dm_n <= dm_pers_cnt
    AND dm_found2 != 1)
     IF ((rencntrs->pers[dm_n].person_id=rencntrs->enc[d.seq].person_id)
      AND (rencntrs->pers[dm_n].fin_alias=rencntrs->enc[d.seq].fin_alias)
      AND (rencntrs->pers[dm_n].fin_alias_pool=rencntrs->enc[d.seq].fin_alias_pool)
      AND (rencntrs->pers[dm_n].visit_alias=rencntrs->enc[d.seq].visit_alias)
      AND (rencntrs->pers[dm_n].visit_alias_pool=rencntrs->enc[d.seq].visit_alias_pool))
      dm_found2 = 1
     ELSE
      dm_n += 1
     ENDIF
   ENDWHILE
   IF (dm_found2=0)
    dm_pers_cnt += 1, stat = alterlist(rencntrs->pers,dm_pers_cnt), rencntrs->pers[dm_pers_cnt].
    person_id = rencntrs->enc[d.seq].person_id,
    rencntrs->pers[dm_pers_cnt].fin_alias = rencntrs->enc[d.seq].fin_alias, rencntrs->pers[
    dm_pers_cnt].fin_alias_pool = rencntrs->enc[d.seq].fin_alias_pool, rencntrs->pers[dm_pers_cnt].
    visit_alias = rencntrs->enc[d.seq].visit_alias,
    rencntrs->pers[dm_pers_cnt].visit_alias_pool = rencntrs->enc[d.seq].visit_alias_pool
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 FOR (dm_m = 1 TO dm_pers_cnt)
   SET stat = alterlist(rencntrs->temp_enc,0)
   SET dm_temp_enc_cnt = 0
   SELECT INTO "nl:"
    dstatus = rencntrs->enc[d.seq].data_status, udate = rencntrs->enc[d.seq].updt_dt_tm
    FROM (dummyt d  WITH seq = value(dm_enc_cnt))
    WHERE (rencntrs->enc[d.seq].person_id=rencntrs->pers[dm_m].person_id)
     AND (rencntrs->enc[d.seq].fin_alias=rencntrs->pers[dm_m].fin_alias)
     AND (rencntrs->enc[d.seq].fin_alias_pool=rencntrs->pers[dm_m].fin_alias_pool)
     AND (rencntrs->enc[d.seq].visit_alias=rencntrs->pers[dm_m].visit_alias)
     AND (rencntrs->enc[d.seq].visit_alias_pool=rencntrs->pers[dm_m].visit_alias_pool)
    ORDER BY dstatus, udate
    DETAIL
     IF (dstatus != 0)
      dm_temp_enc_cnt += 1, stat = alterlist(rencntrs->temp_enc,dm_temp_enc_cnt), rencntrs->temp_enc[
      dm_temp_enc_cnt].encntr_id = rencntrs->enc[d.seq].encntr_id
     ENDIF
    WITH nocounter
   ;end select
   IF (dm_temp_enc_cnt > 1)
    SET dm_end_cntr = (dm_temp_enc_cnt - 1)
    FOR (dm_p = 1 TO dm_end_cntr)
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = value(rcmbenc->enc_size))
      WHERE (rcmbenc->enc[d.seq].from_encntr_id=rencntrs->temp_enc[dm_p].encntr_id)
       AND (rcmbenc->enc[d.seq].to_encntr_id=rencntrs->temp_enc[dm_temp_enc_cnt].encntr_id)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET rcmbenc->enc_size += 1
      SET stat = alterlist(rcmbenc->enc,rcmbenc->enc_size)
      SET rcmbenc->enc[rcmbenc->enc_size].from_encntr_id = rencntrs->temp_enc[dm_p].encntr_id
      SET rcmbenc->enc[rcmbenc->enc_size].to_encntr_id = rencntrs->temp_enc[dm_temp_enc_cnt].
      encntr_id
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET disp = fillstring(20," ")
 SELECT
  dstatus1 = uar_get_code_meaning(rencntrs->enc[d2.seq].data_status_cd), etype1 =
  uar_get_code_display(rencntrs->enc[d2.seq].encntr_type_cd), medsvc1 = uar_get_code_display(rencntrs
   ->enc[d2.seq].med_service_cd),
  nunit1 = uar_get_code_display(rencntrs->enc[d2.seq].nurse_unit_cd), room1 = uar_get_code_display(
   rencntrs->enc[d2.seq].room_cd), bed1 = uar_get_code_display(rencntrs->enc[d2.seq].bed_cd),
  csys1 = uar_get_code_display(rencntrs->enc[d2.seq].contrib_sys_cd), dstatus2 = uar_get_code_meaning
  (rencntrs->enc[d3.seq].data_status_cd), etype2 = uar_get_code_display(rencntrs->enc[d3.seq].
   encntr_type_cd),
  medsvc2 = uar_get_code_display(rencntrs->enc[d3.seq].med_service_cd), nunit2 = uar_get_code_display
  (rencntrs->enc[d3.seq].nurse_unit_cd), room2 = uar_get_code_display(rencntrs->enc[d3.seq].room_cd),
  bed2 = uar_get_code_display(rencntrs->enc[d3.seq].bed_cd), csys2 = uar_get_code_display(rencntrs->
   enc[d3.seq].contrib_sys_cd)
  FROM (dummyt d1  WITH seq = value(rcmbenc->enc_size)),
   (dummyt d2  WITH seq = value(dm_enc_cnt)),
   (dummyt d3  WITH seq = value(dm_enc_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE (rencntrs->enc[d2.seq].encntr_id=rcmbenc->enc[d1.seq].from_encntr_id))
   JOIN (d3
   WHERE (rencntrs->enc[d3.seq].encntr_id=rcmbenc->enc[d1.seq].to_encntr_id))
  DETAIL
   col 20, "Encntr A", col 50,
   "Encntr B", row + 1, col 20,
   "--------", col 50, "--------",
   row + 1, col 1, "PersonID",
   col 20, rencntrs->enc[d2.seq].person_id"########;l", col 50,
   rencntrs->enc[d3.seq].person_id"########;l", row + 1, col 1,
   "Name", col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].name)),
   col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].name)), row + 1,
   col 1, "CMRN", col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].cmrn)), col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].cmrn)),
   row + 1, col 1, "BirthDtTm",
   col 20,
   CALL print(format(rencntrs->enc[d2.seq].birth_dt_tm,"MM/DD/YYYY HH:MM;;d")), col 50,
   CALL print(format(rencntrs->enc[d3.seq].birth_dt_tm,"MM/DD/YYYY HH:MM;;d")), row + 1, col 1,
   "EncntrID", col 20, rencntrs->enc[d2.seq].encntr_id"########;l",
   col 50, rencntrs->enc[d3.seq].encntr_id"########;l", row + 1,
   col 1, "ContribSys", col 20,
   CALL print(substring(1,28,csys1)), col 50,
   CALL print(substring(1,28,csys2)),
   row + 1, col 1, "EncntrMRN",
   col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].emrn)), col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].emrn)), row + 1, col 1,
   "EncntrStatus", col 20, dstatus1,
   col 50, dstatus2, row + 1,
   col 1, "UpdtDtTm", col 20,
   CALL print(format(rencntrs->enc[d2.seq].updt_dt_tm,"MM/DD/YYYY HH:MM;;d")), col 50,
   CALL print(format(rencntrs->enc[d3.seq].updt_dt_tm,"MM/DD/YYYY HH:MM;;d")),
   row + 1, col 1, "FinNbr",
   col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].fin_alias)), col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].fin_alias)), row + 1, col 1,
   "VisitID", col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].visit_alias)),
   col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].visit_alias)), row + 1,
   col 1, "DschDtTm", col 20,
   CALL print(format(rencntrs->enc[d2.seq].disch_dt_tm,"MM/DD/YYYY HH:MM;;d")), col 50,
   CALL print(format(rencntrs->enc[d3.seq].disch_dt_tm,"MM/DD/YYYY HH:MM;;d")),
   row + 1, col 1, "AttendDoc",
   col 20,
   CALL print(substring(1,28,rencntrs->enc[d2.seq].attend_doc)), col 50,
   CALL print(substring(1,28,rencntrs->enc[d3.seq].attend_doc)), row + 1, col 1,
   "EncntrType", col 20,
   CALL print(substring(1,28,etype1)),
   col 50,
   CALL print(substring(1,28,etype2)), row + 1,
   col 1, "MedService", col 20,
   CALL print(substring(1,28,medsvc1)), col 50,
   CALL print(substring(1,28,medsvc2)),
   row + 1, col 1, "NurseUnit",
   col 20,
   CALL print(substring(1,28,nunit1)), col 50,
   CALL print(substring(1,28,nunit2)), row + 1, col 1,
   "Room", col 20,
   CALL print(substring(1,28,room1)),
   col 50,
   CALL print(substring(1,28,room2)), row + 1,
   col 1, "Bed", col 20,
   CALL print(substring(1,28,bed1)), col 50,
   CALL print(substring(1,28,bed2)),
   row + 1, col 1, "RegDtTm",
   col 20,
   CALL print(format(rencntrs->enc[d2.seq].reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), col 50,
   CALL print(format(rencntrs->enc[d3.seq].reg_dt_tm,"MM/DD/YYYY HH:MM;;d")), row + 1, row + 1
  WITH nocounter
 ;end select
#dm_exit_script
 IF (dm_no_dups=1)
  SELECT
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    row + 1, "No potential duplicate encounters found on persons combined during", row + 1,
    "the specified date range."
   WITH nocounter
  ;end select
 ENDIF
END GO
