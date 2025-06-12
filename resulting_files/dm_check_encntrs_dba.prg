CREATE PROGRAM dm_check_encntrs:dba
 SET dm_first_person_id =  $1
 SET dm_last_person_id =  $2
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
     2 from_person_flag = i2
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
 SET dm_enc_cnt = 0
 SET dm_pers_cnt = 0
 SELECT INTO "nl:"
  e1.encntr_id, e2.encntr_id
  FROM encounter e1,
   encounter e2,
   encntr_alias ea1,
   encntr_alias ea2,
   (dummyt d  WITH seq = 1),
   encntr_alias ea3
  PLAN (e1
   WHERE e1.active_ind=1
    AND e1.person_id BETWEEN dm_first_person_id AND dm_last_person_id)
   JOIN (e2
   WHERE (e2.person_id=(e1.person_id+ 0))
    AND ((e1.encntr_id+ 0) != (e2.encntr_id+ 0))
    AND e2.active_ind=1)
   JOIN (ea1
   WHERE ((e1.encntr_id+ 0)=ea1.encntr_id)
    AND ea1.encntr_alias_type_cd=dm_fin_nbr_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ea2
   WHERE ((e2.encntr_id+ 0)=ea2.encntr_id)
    AND ea2.encntr_alias_type_cd=dm_fin_nbr_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea2.alias_pool_cd=ea1.alias_pool_cd
    AND cnvtupper(ea2.alias)=cnvtupper(ea1.alias))
   JOIN (d)
   JOIN (ea3
   WHERE ea3.encntr_id=e1.encntr_id
    AND ea3.active_ind=1
    AND ea3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea3.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea3.encntr_alias_type_cd=dm_visit_cd)
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
     rencntrs->enc[dm_enc_cnt].from_person_flag = 2, rencntrs->enc[dm_enc_cnt].visit_alias = ea3
     .alias, rencntrs->enc[dm_enc_cnt].visit_alias_pool = ea3.alias_pool_cd
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  e1.encntr_id, e2.encntr_id
  FROM encounter e1,
   encounter e2,
   encntr_alias ea1,
   encntr_alias ea2,
   (dummyt d  WITH seq = 1),
   encntr_alias ea3
  PLAN (e1
   WHERE e1.active_ind=1
    AND e1.person_id BETWEEN dm_first_person_id AND dm_last_person_id)
   JOIN (e2
   WHERE (e2.person_id=(e1.person_id+ 0))
    AND ((e1.encntr_id+ 0) != (e2.encntr_id+ 0))
    AND e2.active_ind=1)
   JOIN (ea1
   WHERE ((e1.encntr_id+ 0)=ea1.encntr_id)
    AND ea1.encntr_alias_type_cd=dm_visit_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ea2
   WHERE ((e2.encntr_id+ 0)=ea2.encntr_id)
    AND ea2.encntr_alias_type_cd=dm_visit_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea2.alias_pool_cd=ea1.alias_pool_cd
    AND cnvtupper(ea2.alias)=cnvtupper(ea1.alias))
   JOIN (d)
   JOIN (ea3
   WHERE e1.encntr_id=ea3.encntr_id
    AND ea3.active_ind=1
    AND ea3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea3.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea3.encntr_alias_type_cd=dm_fin_nbr_cd)
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
    dm_y = 1, dm_found2 = 0
    WHILE ((dm_y <= rcmbenc->enc_size)
     AND dm_found2 != 1)
      IF ((rcmbenc->enc[dm_y].from_encntr_id=e1.encntr_id))
       dm_found2 = 1
      ELSE
       dm_y += 1
      ENDIF
    ENDWHILE
    IF (dm_found=0
     AND dm_found2=0)
     dm_enc_cnt += 1, stat = alterlist(rencntrs->enc,dm_enc_cnt), rencntrs->enc[dm_enc_cnt].person_id
      = e1.person_id,
     rencntrs->enc[dm_enc_cnt].encntr_id = e1.encntr_id, rencntrs->enc[dm_enc_cnt].updt_dt_tm = e1
     .updt_dt_tm, rencntrs->enc[dm_enc_cnt].visit_alias = ea1.alias,
     rencntrs->enc[dm_enc_cnt].visit_alias_pool = ea1.alias_pool_cd
     IF (e1.data_status_cd=dm_auth_cd)
      rencntrs->enc[dm_enc_cnt].data_status = 2
     ELSEIF (e1.data_status_cd=dm_unauth_cd)
      rencntrs->enc[dm_enc_cnt].data_status = 1
     ELSE
      rencntrs->enc[dm_enc_cnt].data_status = 0
     ENDIF
     rencntrs->enc[dm_enc_cnt].from_person_flag = 2, rencntrs->enc[dm_enc_cnt].fin_alias = ea3.alias,
     rencntrs->enc[dm_enc_cnt].fin_alias_pool = ea3.alias_pool_cd
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (dm_enc_cnt=0)
  GO TO exit_dm_check_encntrs
 ENDIF
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(dm_encupdt_cnt)),
   (dummyt d2  WITH seq = value(dm_enc_cnt))
  PLAN (d2)
   JOIN (d1
   WHERE (rencupdt->enc[d1.seq].encntr_id=rencntrs->enc[d2.seq].encntr_id))
  DETAIL
   rencntrs->enc[d2.seq].updt_dt_tm = rencupdt->enc[d1.seq].updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(dm_enc_cnt)),
   person_combine_det pcd
  PLAN (d)
   JOIN (pcd
   WHERE (pcd.person_combine_id=request->xxx_combine[icombine].xxx_combine_id)
    AND pcd.entity_name="ENCOUNTER"
    AND (pcd.entity_id=rencntrs->enc[d.seq].encntr_id))
  DETAIL
   rencntrs->enc[d.seq].from_person_flag = 1
  WITH nocounter
 ;end select
 FOR (dm_z = 1 TO dm_enc_cnt)
   SET dm_found2 = 0
   SET dm_n = 1
   WHILE (dm_n <= dm_pers_cnt
    AND dm_found2 != 1)
     IF ((rencntrs->pers[dm_n].person_id=rencntrs->enc[dm_z].person_id)
      AND (rencntrs->pers[dm_n].fin_alias=rencntrs->enc[dm_z].fin_alias)
      AND (rencntrs->pers[dm_n].fin_alias_pool=rencntrs->enc[dm_z].fin_alias_pool)
      AND (rencntrs->pers[dm_n].visit_alias=rencntrs->enc[dm_z].visit_alias)
      AND (rencntrs->pers[dm_n].visit_alias_pool=rencntrs->enc[dm_z].visit_alias_pool))
      SET dm_found2 = 1
     ELSE
      SET dm_n += 1
     ENDIF
   ENDWHILE
   IF (dm_found2=0)
    SET dm_pers_cnt += 1
    SET stat = alterlist(rencntrs->pers,dm_pers_cnt)
    SET rencntrs->pers[dm_pers_cnt].person_id = rencntrs->enc[dm_z].person_id
    SET rencntrs->pers[dm_pers_cnt].fin_alias = rencntrs->enc[dm_z].fin_alias
    SET rencntrs->pers[dm_pers_cnt].fin_alias_pool = rencntrs->enc[dm_z].fin_alias_pool
    SET rencntrs->pers[dm_pers_cnt].visit_alias = rencntrs->enc[dm_z].visit_alias
    SET rencntrs->pers[dm_pers_cnt].visit_alias_pool = rencntrs->enc[dm_z].visit_alias_pool
   ENDIF
 ENDFOR
 FOR (dm_m = 1 TO dm_pers_cnt)
   SET stat = alterlist(rencntrs->temp_enc,0)
   SET dm_temp_enc_cnt = 0
   SELECT INTO "nl:"
    dstatus = rencntrs->enc[d.seq].data_status, udate = rencntrs->enc[d.seq].updt_dt_tm, from_to =
    rencntrs->enc[d.seq].from_person_flag
    FROM (dummyt d  WITH seq = value(dm_enc_cnt))
    WHERE (rencntrs->enc[d.seq].person_id=rencntrs->pers[dm_m].person_id)
     AND (rencntrs->enc[d.seq].fin_alias=rencntrs->pers[dm_m].fin_alias)
     AND (rencntrs->enc[d.seq].fin_alias_pool=rencntrs->pers[dm_m].fin_alias_pool)
     AND (rencntrs->enc[d.seq].visit_alias=rencntrs->pers[dm_m].visit_alias)
     AND (rencntrs->enc[d.seq].visit_alias_pool=rencntrs->pers[dm_m].visit_alias_pool)
    ORDER BY dstatus, from_to, udate
    DETAIL
     IF (dstatus != 0)
      dm_temp_enc_cnt += 1, stat = alterlist(rencntrs->temp_enc,dm_temp_enc_cnt), rencntrs->temp_enc[
      dm_temp_enc_cnt].encntr_id = rencntrs->enc[d.seq].encntr_id
     ENDIF
    WITH nocounter
   ;end select
   IF (dm_temp_enc_cnt > 1)
    SET dm_end_cntr = (dm_temp_enc_cnt - 1)
    IF (validate(request->parent_table,"Z") != "Z")
     SET dm_nbr_enc_combines = size(request->xxx_combine,5)
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
       SET rcmbenc->enc[rcmbenc->enc_size].person_combine_id = request->xxx_combine[icombine].
       xxx_combine_id
       SET rcmbenc->enc[rcmbenc->enc_size].from_encntr_id = rencntrs->temp_enc[dm_p].encntr_id
       SET rcmbenc->enc[rcmbenc->enc_size].to_encntr_id = rencntrs->temp_enc[dm_temp_enc_cnt].
       encntr_id
      ENDIF
     ENDFOR
    ELSE
     FOR (dm_p = 1 TO dm_end_cntr)
       IF (dm_m=1
        AND dm_p=1)
        SELECT INTO "ENCNTR_BATCH_CMB_INSERT"
         d.seq
         FROM (dummyt d  WITH seq = 1)
         DETAIL
          "insert into dm_combine_queue d set d.parent_table = ", '"', "ENCOUNTER",
          '"', ",", " d.FROM_ID= ",
          rencntrs->temp_enc[dm_p].encntr_id, ", ", " d.TO_ID = ",
          rencntrs->temp_enc[dm_temp_enc_cnt].encntr_id, ", ", row + 1,
          "d.create_dt_tm = ", "cnvtdatetime(curdate, curtime3), ",
          "d.QUEUE_ID = seq(combine_queue_seq, nextval) GO "
         WITH nocounter, maxcol = 200, formfeed = none,
          format = variable, noheading
        ;end select
       ELSE
        SELECT INTO "ENCNTR_BATCH_CMB_INSERT"
         d.seq
         FROM (dummyt d  WITH seq = 1)
         DETAIL
          "insert into dm_combine_queue d set d.parent_table = ", '"', "ENCOUNTER",
          '"', ",", " d.FROM_ID= ",
          rencntrs->temp_enc[dm_p].encntr_id, ", ", " d.TO_ID = ",
          rencntrs->temp_enc[dm_temp_enc_cnt].encntr_id, ", ", row + 1,
          "d.create_dt_tm = ", "cnvtdatetime(curdate, curtime3), ",
          "d.QUEUE_ID = seq(combine_queue_seq, nextval) GO "
         WITH nocounter, maxcol = 200, formfeed = none,
          format = variable, noheading, append
        ;end select
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_dm_check_encntrs
END GO
