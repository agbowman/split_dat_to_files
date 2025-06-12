CREATE PROGRAM dcp_rpt_driver_ops:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD visits(
   1 v_cnt = i2
   1 v[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 DECLARE drd_cnt = i4 WITH noconstant(0)
 DECLARE drd_idx = i4 WITH noconstant(0)
 DECLARE hold_batch_selection = vc WITH noconstant(fillstring(255," "))
 DECLARE object_name = vc WITH noconstant(fillstring(255," "))
 DECLARE report_type = c1 WITH noconstant(" ")
 DECLARE unit_disp_key = c40 WITH noconstant(fillstring(40," "))
 DECLARE unit_cd = f8 WITH noconstant(0.0)
 DECLARE census_type_cd = f8 WITH noconstant(0.0)
 SET hold_batch_selection = trim(request->batch_selection)
 SET census_type_cd = uar_get_code_by("MEANING",339,"CENSUS")
 SET drd_idx = findstring(";",hold_batch_selection)
 IF (drd_idx > 0)
  SET object_name = substring(1,(drd_idx - 1),hold_batch_selection)
  SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid object name or missing semicolon"
  GO TO exit_program
 ENDIF
 SET drd_idx = findstring(";",hold_batch_selection)
 IF (drd_idx > 0)
  SET report_type = substring(1,(drd_idx - 1),hold_batch_selection)
  SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid Report Type or missing semicolon"
  GO TO exit_program
 ENDIF
 IF (report_type="0")
  SET drd_idx = findstring(";",hold_batch_selection)
  IF (drd_idx > 0)
   SET request->output_device = substring(1,(drd_idx - 1),hold_batch_selection)
   SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Invalid Printer Name or missing semicolon"
   GO TO exit_program
  ENDIF
  SET exec_state = concat("execute ",trim(object_name)," go")
  CALL parser(exec_state)
  GO TO exit_program
 ENDIF
 WHILE (hold_batch_selection > " ")
   SET drd_idx = findstring(";",hold_batch_selection)
   IF (drd_idx > 0)
    SET unit_disp_key = trim(cnvtupper(substring(1,(drd_idx - 1),hold_batch_selection)))
    SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Invalid Nurse Station or missing semicolon"
    GO TO exit_program
   ENDIF
   IF (cnvtint(unit_disp_key) > 0)
    SET unit_cd = cnvtreal(unit_disp_key)
   ELSE
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=220
      AND c.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
      AND c.display_key=unit_disp_key
      AND c.active_ind=1
     DETAIL
      unit_cd = c.code_value
     WITH nocounter
    ;end select
    IF (unit_cd=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Nurse Station"
     GO TO exit_program
    ENDIF
   ENDIF
   SET drd_idx = findstring(";",hold_batch_selection)
   IF (drd_idx > 0)
    SET request->output_device = substring(1,(drd_idx - 1),hold_batch_selection)
    SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Invalid Printer Name or missing semicolon"
    GO TO exit_program
   ENDIF
   IF (report_type="1")
    SET exec_state = concat("execute ",trim(object_name)," go")
    CALL parser(exec_state)
   ELSEIF (report_type="2")
    SELECT INTO "nl:"
     loc_room_disp = uar_get_code_display(ed.loc_room_cd), loc_bed_disp = uar_get_code_display(ed
      .loc_bed_cd)
     FROM encntr_domain ed
     PLAN (ed
      WHERE ed.encntr_domain_type_cd=census_type_cd
       AND ed.loc_nurse_unit_cd=unit_cd
       AND ed.active_ind=1
       AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY loc_room_disp, loc_bed_disp
     HEAD REPORT
      drd_cnt = 0
     DETAIL
      drd_cnt = (drd_cnt+ 1), stat = alterlist(visits->v,drd_cnt), visits->v[drd_cnt].person_id = ed
      .person_id,
      visits->v[drd_cnt].encntr_id = ed.encntr_id
     FOOT REPORT
      visits->v_cnt = drd_cnt
     WITH nocounter
    ;end select
    IF ((visits->v_cnt > 0))
     SET request->person_cnt = 1
     SET stat = alterlist(request->person,1)
     SET request->visit_cnt = 1
     SET stat = alterlist(request->visit,1)
     FOR (drd_x = 1 TO visits->v_cnt)
       SET request->person[1].person_id = visits->v[drd_x].person_id
       SET request->visit[1].encntr_id = visits->v[drd_x].encntr_id
       SET exec_state = concat("execute ",trim(object_name)," go")
       CALL parser(exec_state)
     ENDFOR
    ENDIF
   ENDIF
 ENDWHILE
#exit_program
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
