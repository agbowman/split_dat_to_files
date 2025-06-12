CREATE PROGRAM bhs_chg_cis_position:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Current User:" = "",
  "Select Position to Change To:" = 0
  WITH outdev, s_username, f_position_cd
 FREE RECORD m_rec
 RECORD m_rec(
   1 pos[*]
     2 f_pos_cd = f8
     2 s_pos_display = vc
 )
 DECLARE mf_person_id = f8 WITH protect, constant(reqinfo->updt_id)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_prev_pos = vc WITH protect, noconstant(" ")
 DECLARE ms_name_full = vc WITH protect, noconstant(" ")
 IF (( $F_POSITION_CD <= 0))
  SET ms_log = "No new position selected."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=mf_person_id
    AND p.active_ind=1
    AND (p.username= $S_USERNAME))
  DETAIL
   ms_prev_pos = trim(uar_get_code_display(p.position_cd)), ms_name_full = trim(p.name_full_formatted
    )
  WITH nocounter
 ;end select
 UPDATE  FROM prsnl p
  SET p.position_cd =  $F_POSITION_CD, p.updt_id = mf_person_id, p.updt_task = reqinfo->updt_task,
   p.updt_dt_tm = sysdate
  WHERE (p.person_id=reqinfo->updt_id)
  WITH nocounter
 ;end update
 COMMIT
 SELECT INTO value( $OUTDEV)
  HEAD REPORT
   row + 2, col 0, "User Name: ",
   ms_name_full, ms_tmp = fillstring(75,"-"), row + 1,
   col 0, ms_tmp, ms_tmp = concat("Position changed from ",ms_prev_pos," to ",trim(
     uar_get_code_display( $F_POSITION_CD))),
   row + 1, col 0, ms_tmp,
   ms_tmp = fillstring(75,"-"), row + 1, col 0,
   ms_tmp
  WITH nocounter
 ;end select
 SET ms_log = "SUCCESS"
#exit_script
 IF (ms_log != "SUCCESS")
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
END GO
