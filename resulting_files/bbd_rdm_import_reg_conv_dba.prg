CREATE PROGRAM bbd_rdm_import_reg_conv:dba
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
 DECLARE last_mod = c5 WITH noconstant(" "), private
 SET last_mod = "000  "
 DECLARE conv_id = f8 WITH protect, noconstant(0.0)
 DECLARE activecd = f8 WITH protect, noconstant(0.0)
 DECLARE seq_id = f8 WITH protect, noconstant(0.0)
 EXECUTE dm_dbimport "cer_install:bbd_flex_reg_conv.csv", "pm_imp_flx_conversation", 1000
 SELECT INTO "nl:"
  pfc.conversation_id
  FROM pm_flx_conversation pfc
  PLAN (pfc
   WHERE pfc.conversation_id > 0.0
    AND cnvtupper(pfc.description)="BLOOD BANK DONOR REGISTRATION"
    AND pfc.active_ind=1)
  DETAIL
   conv_id = pfc.conversation_id
  WITH nocounter
 ;end select
 IF (conv_id > 0.0)
  SELECT INTO "nl:"
   p.task
   FROM pm_flx_task_conv_reltn p
   PLAN (p
    WHERE p.task=225595
     AND p.active_ind=1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=48
      AND cv.cdf_meaning="ACTIVE"
      AND cv.active_ind=1)
    DETAIL
     activecd = cv.code_value
    WITH nocounter
   ;end select
   SET seq_id = 0.0
   SELECT INTO "nl:"
    y = seq(pm_task_conv_reltn_id_seq,nextval)
    FROM dual
    DETAIL
     seq_id = y
    WITH format, counter
   ;end select
   IF (curqual > 0)
    INSERT  FROM pm_flx_task_conv_reltn p
     SET p.task_conv_reltn_id = seq_id, p.task = 225595, p.organization_id = 0.0,
      p.conversation_id = conv_id, p.action = 900, p.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3),
      p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p.active_ind = 1, p
      .active_status_cd = activecd,
      p.active_status_prsnl_id = 0.0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_cnt = 0,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 0.0, p.updt_applctx = 0,
      p.updt_task = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET readme_data->status = "F"
     SET readme_data->message = "Unable to insert row into pm_flx_task_conv_reltn"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
