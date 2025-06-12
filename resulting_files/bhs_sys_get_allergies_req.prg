CREATE PROGRAM bhs_sys_get_allergies_req
 PROMPT
  "Enter Mode:" = "none"
  WITH run_mode
 SET error = exit_on_error
 IF (cnvtlower( $RUN_MODE)="person")
  FREE RECORD bhs_allergies_req
  RECORD bhs_allergies_req(
    1 mode = vc
    1 p_cnt = i4
    1 persons[*]
      2 person_id = f8
  ) WITH persist
  SET bhs_allergies_req->mode = "person"
 ELSE
  GO TO exit_on_error
 ENDIF
 GO TO exit_script
#exit_on_error
 FREE RECORD bhs_allergies_req
 FREE RECORD bhs_allergies_reply
#exit_script
 SET error = off
END GO
