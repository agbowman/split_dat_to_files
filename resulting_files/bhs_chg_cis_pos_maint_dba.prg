CREATE PROGRAM bhs_chg_cis_pos_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Add or Remove" = 1,
  "Begin Date:" = "CURDATE",
  "End Date:" = "",
  "Enter User Last Name:" = "",
  "Select User:" = 0,
  "User's Current Position:" = 0,
  "Positions available to user:" = 0,
  "Remove:" = 0,
  "Add:" = 0
  WITH outdev, n_add_remove, s_beg_dt,
  s_end_dt, s_user_search, f_prsnl_id,
  f_cur_pos, f_available, f_rmv_position_cd,
  f_add_position_cd
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_name_full = vc
   1 s_user_name = vc
   1 pos[*]
     2 f_pos_cd = f8
     2 s_pos_disp = vc
     2 n_exists = i2
 ) WITH protect
 DECLARE mf_prsnl_id = f8 WITH protect, constant( $F_PRSNL_ID)
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 IF (mf_prsnl_id <= 0)
  SET ms_log = "No Person Selected.  Exit"
  GO TO exit_script
 ENDIF
 IF (( $N_ADD_REMOVE=1))
  CALL echo("ADD")
 ELSEIF (( $N_ADD_REMOVE=0))
  CALL echo("REMOVE")
 ENDIF
 SET ms_beg_dt_tm = concat(trim( $S_BEG_DT)," 00:00:00")
 SET ms_end_dt_tm = concat(trim( $S_END_DT)," 23:59:59")
 CALL echo("get name")
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=mf_prsnl_id
    AND p.active_ind=1)
  HEAD p.person_id
   m_rec->s_name_full = trim(p.name_full_formatted), m_rec->s_user_name = trim(p.username)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "Person not found"
  GO TO exit_script
 ENDIF
 CALL echo("get pos list")
 IF (( $N_ADD_REMOVE=1))
  SELECT INTO "nl:"
   FROM bhs_chg_position b
   WHERE b.person_id=mf_prsnl_id
    AND (b.position_cd= $F_CUR_POS)
    AND b.active_ind=1
    AND b.end_effective_dt_tm > sysdate
   DETAIL
    ms_tmp = "found"
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_tmp = "addcur"
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=88
     AND (((cv.code_value= $F_ADD_POSITION_CD)) OR ((cv.code_value= $F_CUR_POS))) )
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    IF ((((cv.code_value !=  $F_CUR_POS)) OR (ms_tmp="addcur")) )
     pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pos,pl_cnt), m_rec->pos[pl_cnt].f_pos_cd = cv
     .code_value,
     m_rec->pos[pl_cnt].s_pos_disp = trim(cv.display)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (( $N_ADD_REMOVE=2))
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=88
     AND (cv.code_value= $F_RMV_POSITION_CD))
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pos,pl_cnt), m_rec->pos[pl_cnt].f_pos_cd = cv
    .code_value,
    m_rec->pos[pl_cnt].s_pos_disp = trim(cv.display)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual < 1)
  SET ms_log = "Positions not found.  Exit"
  GO TO exit_script
 ENDIF
 CALL echo("checking for dups")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pos,5))),
   bhs_chg_position b
  PLAN (d)
   JOIN (b
   WHERE b.person_id=mf_prsnl_id
    AND (b.position_cd=m_rec->pos[d.seq].f_pos_cd)
    AND b.active_ind=1
    AND b.end_effective_dt_tm > sysdate)
  DETAIL
   m_rec->pos[d.seq].n_exists = 1
  WITH nocounter
 ;end select
 IF (( $N_ADD_REMOVE=1))
  CALL echo("insert")
  FOR (ml_cnt = 1 TO size(m_rec->pos,5))
    IF ((m_rec->pos[ml_cnt].n_exists=0))
     INSERT  FROM bhs_chg_position b
      SET b.active_ind = 1, b.beg_effective_dt_tm = cnvtdatetime(ms_end_dt_tm), b.chg_position_id =
       seq(bhs_eks_seq,nextval),
       b.end_effective_dt_tm = cnvtdatetime(ms_end_dt_tm), b.person_id = mf_prsnl_id, b.position_cd
        = m_rec->pos[ml_cnt].f_pos_cd,
       b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task,
       b.user_name = m_rec->s_user_name
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ELSEIF (( $N_ADD_REMOVE=2))
  FOR (ml_cnt = 1 TO size(m_rec->pos,5))
   CALL echo("update")
   UPDATE  FROM bhs_chg_position b
    SET b.active_ind = 0, b.end_effective_dt_tm = sysdate, b.updt_dt_tm = sysdate,
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
    PLAN (b
     WHERE b.person_id=mf_prsnl_id
      AND b.active_ind=1
      AND (b.position_cd=m_rec->pos[ml_cnt].f_pos_cd))
    WITH nocounter
   ;end update
  ENDFOR
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  ps_pos = trim(uar_get_code_display(b.position_cd))
  FROM bhs_chg_position b
  PLAN (b
   WHERE b.person_id=mf_prsnl_id
    AND b.active_ind=1
    AND b.end_effective_dt_tm > sysdate)
  ORDER BY ps_pos
  HEAD REPORT
   pl_cnt = size(m_rec->pos,5)
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pos,pl_cnt), m_rec->pos[pl_cnt].n_exists = 2,
   m_rec->pos[pl_cnt].f_pos_cd = b.position_cd, m_rec->pos[pl_cnt].s_pos_disp = trim(
    uar_get_code_display(b.position_cd))
  WITH nocounter
 ;end select
 SET ms_log = "SUCCESS"
 CALL echo("write report")
 SELECT INTO value(ms_output)
  ps_pos = m_rec->pos[d.seq].s_pos_disp, pn_exists = m_rec->pos[d.seq].n_exists
  FROM (dummyt d  WITH seq = value(size(m_rec->pos,5)))
  ORDER BY pn_exists, ps_pos
  HEAD REPORT
   col 0, row 0, "Status: ",
   ms_log, row + 2, col 0,
   "User Name: ", m_rec->s_name_full, row + 1,
   col 0, "User ID: ", m_rec->s_user_name,
   ms_tmp = fillstring(75,"-"), row + 1, col 0,
   ms_tmp
   IF (( $N_ADD_REMOVE=1))
    ms_tmp = "Positions added to User:"
   ELSEIF (( $N_ADD_REMOVE=2))
    ms_tmp = "Positions removed from User:"
   ENDIF
   row + 2, col 0, ms_tmp,
   row + 1, col 0, "Position",
   col 50, "Position cd", ms_tmp = fillstring(75,"-"),
   row + 1, ms_tmp, pn_printed = 0
  DETAIL
   IF ((m_rec->pos[d.seq].n_exists=2)
    AND pn_printed=0)
    ms_tmp = fillstring(75,"-"), row + 1, col 0,
    ms_tmp, col 0, row + 2,
    "*** COMPLETE LIST OF POSITIONS AVAILABLE TO THIS USER ***", row + 1, col 0,
    "Position", col 50, "Position cd",
    row + 1, ms_tmp, pn_printed = 1
   ENDIF
   row + 1, col 0, m_rec->pos[d.seq].s_pos_disp,
   ms_tmp = trim(cnvtstring(m_rec->pos[d.seq].f_pos_cd)), col 50, ms_tmp
  FOOT REPORT
   IF (pn_printed=0)
    col 0, row + 2, "*** USER HAS NO ACTIVE POSITIONS AVAILABLE TO CHANGE TO ***"
   ENDIF
   ms_tmp = fillstring(75,"-"), row + 1, col 0,
   ms_tmp
  WITH nocounter
 ;end select
#exit_script
 CALL echo(ms_log)
 IF (ms_log != "SUCCESS")
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
