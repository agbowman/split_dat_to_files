CREATE PROGRAM bed_sch_int_disp_scheme:dba
 PAINT
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=8
   AND a.cdf_meaning="AUTH"
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reqdata->data_status_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=89
   AND a.cdf_meaning="POWERCHART"
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reqdata->contributor_system_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=48
   AND a.cdf_meaning="ACTIVE"
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reqdata->active_status_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=48
   AND a.cdf_meaning="INACTIVE"
   AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reqdata->inactive_status_cd = a.code_value
  WITH nocounter
 ;end select
 FREE SET reqdata
 RECORD reqdata(
   1 data_status_cd = f8
   1 contributor_system_cd = f8
   1 active_status_cd = f8
   1 inactive_status_cd = f8
 )
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   reqinfo->updt_id = p.person_id, reqinfo->position_cd = p.position_cd
  WITH nocounter
 ;end select
 RECORD temp(
   1 qual[*]
     2 sch_state_cd = f8
     2 state_meaning = vc
     2 state_disp = c20
     2 disp_scheme_id = f8
     2 disp_scheme_disp = c50
 )
 SET totcnt = 0
 SELECT INTO "nl:"
  FROM code_value a
  PLAN (a
   WHERE a.code_set=14233
    AND a.cdf_meaning > " "
    AND a.active_ind=1
    AND a.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY a.display
  DETAIL
   totcnt = (totcnt+ 1), stat = alterlist(temp->qual,totcnt), temp->qual[totcnt].sch_state_cd = a
   .code_value,
   temp->qual[totcnt].state_meaning = a.cdf_meaning, temp->qual[totcnt].state_disp = a.display, temp
   ->qual[totcnt].disp_scheme_id = 0.0,
   temp->qual[totcnt].disp_scheme_disp = " "
  WITH nocounter
 ;end select
 SET start_cnt = 0
 SET end_cnt = 0
 SET first_time = 1
#load_sch_states
 FREE SET t_rec
 RECORD t_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 sch_state_cd = f8
     2 state_meaning = vc
     2 state_disp = c20
     2 disp_scheme_id = f8
     2 disp_scheme_disp = c50
 )
 IF (first_time=0)
  SET start_cnt = (start_cnt+ 16)
 ELSE
  SET start_cnt = (start_cnt+ 1)
  SET first_time = 0
 ENDIF
 SET a = (start_cnt+ 15)
 IF (a <= totcnt)
  SET end_cnt = a
 ELSE
  SET end_cnt = totcnt
 ENDIF
 SET t_rec->qual_cnt = 0
 FOR (x = start_cnt TO end_cnt)
   SET t_rec->qual_cnt = (t_rec->qual_cnt+ 1)
   SET stat = alterlist(t_rec->qual,t_rec->qual_cnt)
   SET t_rec->qual[t_rec->qual_cnt].sch_state_cd = temp->qual[x].sch_state_cd
   SET t_rec->qual[t_rec->qual_cnt].state_meaning = temp->qual[x].state_meaning
   SET t_rec->qual[t_rec->qual_cnt].state_disp = temp->qual[x].state_disp
   SET t_rec->qual[t_rec->qual_cnt].disp_scheme_id = temp->qual[x].disp_scheme_id
   SET t_rec->qual[t_rec->qual_cnt].disp_scheme_disp = temp->qual[x].disp_scheme_disp
 ENDFOR
 SET t_line = 2
 CALL text(t_line,1,"******************************************************************************")
 SET t_line = (t_line+ 1)
 CALL text(t_line,1,"*  This program is used to default the display scheme (for each specified    *")
 SET t_line = (t_line+ 1)
 CALL text(t_line,1,"*  state) for ALL the scheduling appointment types.  Use with Caution....    *")
 SET t_line = (t_line+ 1)
 CALL text(t_line,1,"******************************************************************************")
 SET t_line = (t_line+ 1)
 SET t_check = fillstring(100," ")
 SET t_message = fillstring(78," ")
 FREE SET add_appt_state_request
 RECORD add_appt_state_request(
   1 call_echo_ind = i2
   1 qual[*]
     2 appt_type_cd = f8
     2 sch_state_cd = f8
     2 disp_scheme_id = f8
     2 state_meaning = c12
     2 candidate_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 allow_partial_ind = i2
 )
 FREE SET add_appt_state_reply
 RECORD add_appt_state_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 candidate_id = f8
     2 status = i4
 )
 SET add_appt_state_request->call_echo_ind = false
 SET stat = alterlist(add_appt_state_reply->qual,0)
 FREE SET chg_appt_state_request
 RECORD chg_appt_state_request(
   1 call_echo_ind = i2
   1 qual[*]
     2 appt_type_cd = f8
     2 sch_state_cd = f8
     2 version_dt_tm = dq8
     2 disp_scheme_id = f8
     2 state_meaning = c12
     2 updt_cnt = i4
     2 allow_partial_ind = i2
     2 version_ind = i2
     2 force_updt_ind = i2
 )
 FREE SET chg_appt_state_reply
 RECORD chg_appt_state_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 status = i4
 )
 SET add_appt_state_request->call_echo_ind = false
 SET stat = alterlist(add_appt_state_reply->qual,0)
 SET t_line = (t_line+ 1)
 CALL disp_states(t_line)
 SET t_temp = 1
 SET t_chg_mode = 0
#accept_screen
 IF ((t_temp > t_rec->qual_cnt))
  GO TO correct
 ENDIF
 CALL accept_disp_scheme(((t_line+ t_temp) - 1),24,t_temp)
 CALL disp_states(t_line)
 CASE (curscroll)
  OF 0:
   IF (t_chg_mode=1)
    GO TO line_number
   ELSE
    IF ((t_temp < t_rec->qual_cnt))
     SET t_temp = (t_temp+ 1)
     GO TO accept_screen
    ELSE
     GO TO correct
    ENDIF
   ENDIF
  OF 1:
   IF ((t_temp < t_rec->qual_cnt))
    SET t_temp = (t_temp+ 1)
    GO TO accept_screen
   ELSE
    GO TO accept_screen
   ENDIF
  OF 2:
   IF (t_temp > 1)
    SET t_temp = (t_temp - 1)
    GO TO accept_screen
   ELSE
    GO TO accept_screen
   ENDIF
  ELSE
   GO TO accept_screen
 ENDCASE
#line_number
 SET t_message = "Line Number:"
 CALL text(24,1,t_message)
 CALL accept(24,14,"99","00"
  WHERE cnvtint(curaccept) BETWEEN 0 AND t_rec->qual_cnt)
 IF (cnvtint(curaccept) > 0)
  SET t_temp = cnvtint(curaccept)
  GO TO accept_screen
 ENDIF
#correct
 SET t_chg_mode = 1
 SET t_message = "Correct? (Y/N)"
 CALL text(24,1,t_message)
 CALL accept(24,17,"X;CU","Y"
  WHERE curaccept IN ("N", "Y"))
 IF (curaccept="N")
  GO TO line_number
 ENDIF
#update_records
 SELECT INTO "nl:"
  found = decode(a2.seq,1,0), d.seq, d2.seq,
  a.appt_type_cd, a2.disp_scheme_id
  FROM sch_appt_type a,
   sch_appt_state a2,
   dummyt d2,
   (dummyt d  WITH seq = value(t_rec->qual_cnt))
  PLAN (d
   WHERE (t_rec->qual[d.seq].disp_scheme_id > 0))
   JOIN (a
   WHERE a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (a2
   WHERE a2.appt_type_cd=a.appt_type_cd
    AND (a2.sch_state_cd=t_rec->qual[d.seq].sch_state_cd)
    AND a2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   IF (found)
    chg_appt_state_reply->qual_cnt = (chg_appt_state_reply->qual_cnt+ 1)
    IF (mod(chg_appt_state_reply->qual_cnt,10)=1)
     stat = alterlist(chg_appt_state_request->qual,(chg_appt_state_reply->qual_cnt+ 9))
    ENDIF
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].appt_type_cd = a2.appt_type_cd,
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].sch_state_cd = a2.sch_state_cd,
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].version_dt_tm = cnvtdatetime(curdate,
     curtime3),
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].disp_scheme_id = t_rec->qual[d.seq].
    disp_scheme_id, chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].state_meaning = a2
    .state_meaning, chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].updt_cnt = a2
    .updt_cnt,
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].allow_partial_ind = false,
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].version_ind = false,
    chg_appt_state_request->qual[chg_appt_state_reply->qual_cnt].force_updt_ind = true
   ELSE
    add_appt_state_reply->qual_cnt = (add_appt_state_reply->qual_cnt+ 1)
    IF (mod(add_appt_state_reply->qual_cnt,10)=1)
     stat = alterlist(add_appt_state_request->qual,(add_appt_state_reply->qual_cnt+ 9))
    ENDIF
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].appt_type_cd = a.appt_type_cd,
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].sch_state_cd = t_rec->qual[d.seq].
    sch_state_cd, add_appt_state_request->qual[add_appt_state_reply->qual_cnt].disp_scheme_id = t_rec
    ->qual[d.seq].disp_scheme_id,
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].state_meaning = t_rec->qual[d.seq].
    state_meaning, add_appt_state_request->qual[add_appt_state_reply->qual_cnt].candidate_id = 0,
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].active_ind = true,
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].active_status_cd = 0,
    add_appt_state_request->qual[add_appt_state_reply->qual_cnt].allow_partial_ind = false
   ENDIF
  WITH nocounter, outerjoin = d2, dontcare = a2
 ;end select
 IF (mod(add_appt_state_reply->qual_cnt,10) != 0)
  SET stat = alterlist(add_appt_state_request->qual,add_appt_state_reply->qual_cnt)
 ENDIF
 IF (mod(chg_appt_state_reply->qual_cnt,10) != 0)
  SET stat = alterlist(chg_appt_state_request->qual,chg_appt_state_reply->qual_cnt)
 ENDIF
 IF ((add_appt_state_reply->qual_cnt > 0))
  SET t_message = "Adding new entries..."
  CALL text(24,1,t_message)
  EXECUTE sch_add_appt_state
  FOR (i = 1 TO add_appt_state_reply->qual_cnt)
    IF ((add_appt_state_reply->qual[i].status != 1))
     SET t_message =
     "An error occurred attempting to add rows to SCH_APPT_STATE, rollback in-process...."
     CALL text(24,1,t_message)
     CALL pause(1)
     ROLLBACK
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 IF ((chg_appt_state_reply->qual_cnt > 0))
  SET t_message = "Updating existing entries..."
  CALL text(24,1,t_message)
  EXECUTE sch_chg_appt_state
  FOR (i = 1 TO chg_appt_state_reply->qual_cnt)
    IF ((chg_appt_state_reply->qual[i].status != 1))
     SET t_message =
     "An error occurred attempting to update rows to SCH_APPT_STATE, rollback in-process...."
     CALL text(24,1,t_message)
     CALL pause(1)
     ROLLBACK
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 IF (totcnt > end_cnt)
  CALL clear(1,1)
  GO TO load_sch_states
 ENDIF
#subs
 GO TO exit_script
 SUBROUTINE disp_states(t_start_line)
   FOR (t_i = 1 TO t_rec->qual_cnt)
     CALL text(((t_start_line+ t_i) - 1),1,concat(format(t_i,"##;P0")))
     CALL text(((t_start_line+ t_i) - 1),4,t_rec->qual[t_i].state_disp)
     CALL text(((t_start_line+ t_i) - 1),24,t_rec->qual[t_i].disp_scheme_disp,accept)
   ENDFOR
 END ;Subroutine
 SUBROUTINE accept_disp_scheme(t_lin,t_col,t_index)
   SET t_message = "Enter/Select the display scheme  <Help> is available..."
   CALL text(24,1,t_message)
   SET validate = 1
   SET validate =
   SELECT INTO "nl:"
    a.mnemonic
    FROM sch_disp_scheme a
    WHERE a.mnemonic=curaccept
     AND a.scheme_type_flag=2
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter
   ;end select
   SET help =
   SELECT INTO "nl:"
    mnemonic = substring(1,50,a.mnemonic)
    FROM sch_disp_scheme a
    WHERE a.scheme_type_flag=2
     AND a.disp_scheme_id > 0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND a.active_ind=1
    ORDER BY mnemonic
    WITH nocounter
   ;end select
   CALL accept(t_lin,t_col,"P(50);CS",t_rec->qual[t_index].disp_scheme_disp)
   SET help = off
   SET validate = off
   IF (curscroll=0)
    IF (curaccept > " ")
     SET t_disp_scheme_cd = cnvtreal(curaccept)
     SET t_disp_scheme_disp = fillstring(40," ")
     SELECT INTO "nl:"
      a.disp_scheme_id
      FROM sch_disp_scheme a
      WHERE a.mnemonic=curaccept
       AND a.scheme_type_flag=2
       AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      DETAIL
       t_rec->qual[t_index].disp_scheme_id = a.disp_scheme_id, t_rec->qual[t_index].disp_scheme_disp
        = a.mnemonic
      WITH nocounter
     ;end select
    ELSE
     SET t_rec->qual[t_index].disp_scheme_id = 0.0
     SET t_rec->qual[t_index].disp_scheme_disp = " "
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
END GO
