CREATE PROGRAM bhs_provider_dept_maint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Action:" = 1,
  "Physician:" = 0,
  "Department" = "",
  "Title:" = "",
  "Status:" = "",
  "SMS alias:" = ""
  WITH outdev, n_action, f_phys_id,
  s_dept, s_title, s_status,
  s_sms_alias
 DECLARE mf_phys_id = f8 WITH protect, constant(cnvtreal( $F_PHYS_ID))
 DECLARE ms_dept = vc WITH protect, constant(trim(cnvtupper( $S_DEPT),3))
 DECLARE ms_title = vc WITH protect, constant(trim(cnvtupper( $S_TITLE),3))
 DECLARE ms_status = vc WITH protect, constant(trim(cnvtupper( $S_STATUS),3))
 DECLARE ml_sms_alias = i4 WITH protect, constant(cnvtint( $S_SMS_ALIAS))
 DECLARE ms_phys_name = vc WITH protect, noconstant(" ")
 DECLARE ms_message = vc WITH protect, noconstant(" ")
 DECLARE mn_exists_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=mf_phys_id
  DETAIL
   ms_phys_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 IF (trim(ms_phys_name) < " ")
  SET ms_message = "Physician Name not found."
  GO TO exit_script
 ENDIF
 IF (cnvtint( $N_ACTION)=1)
  SELECT INTO "nl:"
   FROM bhs_provider_dept b
   PLAN (b
    WHERE b.person_id=mf_phys_id)
   DETAIL
    mn_exists_ind = 1
   WITH nocounter
  ;end select
  IF (mn_exists_ind=1)
   UPDATE  FROM bhs_provider_dept b
    SET b.provider_name = ms_phys_name, b.active_ind = 1, b.updt_dt_tm = sysdate,
     b.sms_alias = ml_sms_alias, b.status = ms_status, b.title = ms_title,
     b.dept = ms_dept
    WHERE b.person_id=mf_phys_id
    WITH nocounter
   ;end update
   COMMIT
   IF (curqual > 0)
    SET ms_message = build(ms_phys_name," updated with title: ",ms_title,", department: ",ms_dept,
     ", status: ",ms_status,", active_ind: 1",", sms_alias: ",ml_sms_alias)
   ELSE
    SET ms_message = "Unable to update physician"
   ENDIF
  ELSE
   INSERT  FROM bhs_provider_dept b
    SET b.active_ind = 1, b.beg_effective_dt_tm = sysdate, b.bhs_provider_dept_id = seq(bhs_eks_seq,
      nextval),
     b.dept = ms_dept, b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.person_id = mf_phys_id,
     b.provider_name = ms_phys_name, b.sms_alias = ml_sms_alias, b.status = ms_status,
     b.title = ms_title, b.updt_dt_tm = sysdate
    WITH nocounter
   ;end insert
   COMMIT
   IF (curqual > 0)
    SET ms_message = build(ms_phys_name," added with title: ",ms_title,", department: ",ms_dept,
     ", status: ",ms_status,", active_ind: 1",", sms_alias: ",ml_sms_alias)
   ELSE
    SET ms_message = "Unable to add physician."
   ENDIF
   CALL echo(ms_message)
  ENDIF
 ELSEIF (cnvtint( $N_ACTION)=2)
  UPDATE  FROM bhs_provider_dept b
   SET b.status = "I", b.updt_dt_tm = sysdate
   WHERE b.person_id=mf_phys_id
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual > 0)
   SET ms_message = concat(ms_phys_name," inactivated.")
  ELSE
   SET ms_message = "Unable to inactivate physician"
  ENDIF
 ENDIF
#exit_script
 SELECT INTO value( $OUTDEV)
  DETAIL
   col 0, row 0, ms_message
  WITH nocounter
 ;end select
END GO
