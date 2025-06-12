CREATE PROGRAM bhs_sys_get_problems_req
 PROMPT
  "Enter Mode:" = "none"
  WITH run_mode
 SET error = exit_on_error
 IF (cnvtlower( $RUN_MODE)="person")
  FREE RECORD bhs_problems_req
  RECORD bhs_problems_req(
    1 mode = vc
    1 p_cnt = i4
    1 persons[*]
      2 person_id = f8
  ) WITH persist
  SET bhs_problems_req->mode = "person"
 ELSE
  GO TO exit_on_error
 ENDIF
 GO TO exit_script
#exit_on_error
 FREE RECORD bhs_problems_req
 FREE RECORD bhs_problems_reply
#exit_script
 SET error = off
END GO
