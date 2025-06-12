CREATE PROGRAM bbd_rdm_update_reg_conv:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE conv_id = f8 WITH protect, noconstant(0.0)
 DECLARE mothers_prompt_id = f8 WITH protect, noconstant(0.0)
 DECLARE seq_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sub_sequence = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  pfc.conversation_id
  FROM pm_flx_conversation pfc
  PLAN (pfc
   WHERE pfc.conversation_id > 0.0
    AND pfc.task=225596
    AND pfc.active_ind=1)
  DETAIL
   conv_id = pfc.conversation_id
  WITH nocounter
 ;end select
 IF (conv_id > 0.0)
  SELECT INTO "nl:"
   pfp.prompt_id
   FROM pm_flx_prompt pfp
   PLAN (pfp
    WHERE pfp.prompt_id > 0.0
     AND pfp.parent_entity_id=conv_id
     AND pfp.active_ind=1
     AND pfp.field="PERSON.MAIDEN_NAME.NAME_LAST")
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    pfp.prompt_id
    FROM pm_flx_prompt pfp
    PLAN (pfp
     WHERE pfp.prompt_id > 0.0
      AND pfp.parent_entity_id=conv_id
      AND pfp.active_ind=1
      AND pfp.field="PERSON.MOTHER_MAIDEN_NAME")
    DETAIL
     mothers_prompt_id = pfp.prompt_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     pfp.prompt_id
     FROM pm_flx_prompt pfp
     PLAN (pfp
      WHERE pfp.prompt_id=mothers_prompt_id)
     WITH nocounter, forupdate(pfp)
    ;end select
    IF (curqual=0)
     CALL echo("Unable to lock row for update on PM_FLX_PROMPT table.")
     SET readme_data->status = "F"
     SET readme_data->message = "Unable to lock row for update on PM_FLX_PROMPT table."
    ELSE
     UPDATE  FROM pm_flx_prompt pfp
      SET pfp.description = "Maiden Name", pfp.field = "PERSON.MAIDEN_NAME.NAME_LAST", pfp.label =
       "Maiden Name:",
       pfp.updt_applctx = reqinfo->updt_applctx, pfp.updt_cnt = (pfp.updt_cnt+ 1), pfp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pfp.updt_id = reqinfo->updt_id, pfp.updt_task = reqinfo->updt_task, pfp.hl7_description = ""
      PLAN (pfp
       WHERE pfp.prompt_id=mothers_prompt_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL echo("Unable to update row on PM_FLX_PROMPT table.")
      SET readme_data->status = "F"
      SET readme_data->message = "Unable to update row on pm_flx_prompt table"
     ELSE
      CALL echo("PM_FLX_PROMPT row update successful.")
     ENDIF
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=48
       AND cv.cdf_meaning="ACTIVE"
       AND cv.active_ind=1)
     DETAIL
      active_cd = cv.code_value
     WITH nocounter
    ;end select
    SET seq_id = 0.0
    SELECT INTO "nl:"
     y = seq(pm_flx_prompt_id_seq,nextval)
     FROM dual
     DETAIL
      seq_id = y
     WITH format, counter
    ;end select
    SELECT INTO "nl:"
     FROM pm_flx_prompt pfp
     PLAN (pfp
      WHERE pfp.prompt_id > 0
       AND pfp.parent_entity_id=conv_id
       AND pfp.active_ind=1)
     DETAIL
      IF (pfp.sequence > sub_sequence)
       sub_sequence = (pfp.sequence+ 1)
      ENDIF
     WITH nocounter
    ;end select
    INSERT  FROM pm_flx_prompt pfp
     SET pfp.prompt_id = seq_id, pfp.parent_entity_name = "PM_FLX_CONVERSATION", pfp.parent_entity_id
       = conv_id,
      pfp.description = "Maiden Name", pfp.field = "PERSON.MAIDEN_NAME.NAME_LAST", pfp.label =
      "Maiden Name:",
      pfp.prompt_type = "TEXT", pfp.sequence = sub_sequence, pfp.active_ind = 1,
      pfp.active_status_cd = active_cd, pfp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pfp
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      pfp.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pfp.updt_applctx = reqinfo->
      updt_applctx, pfp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pfp.updt_id = reqinfo->updt_id, pfp.updt_task = reqinfo->updt_task, pfp.hl7_description = ""
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("Unable to insert row into PM_FLX_PROMPT table.")
     SET readme_data->status = "F"
     SET readme_data->message = "Unable to insert row into PM_FLX_PROMPT table"
    ELSE
     CALL echo("PM_FLX_PROMPT row insert successful")
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
