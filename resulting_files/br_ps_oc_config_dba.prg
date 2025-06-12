CREATE PROGRAM br_ps_oc_config:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_ps_oc_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_cd = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET catalog_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET activity_subtype_code_value = 0.0
 SET dcp_code_value = 0.0
 SET oe_format_id = 0.0
 SET mnemonic_type_code_value = 0.0
 SET new_id = 0.0
 SET new_synonym_id = 0.0
 SET bb_process_code_value = 0.0
 SET catalog_type_mean = fillstring(40," ")
 SET activity_type_mean = fillstring(40," ")
 SET activity_subtype_mean = fillstring(40," ")
 SET dcp_mean = fillstring(40," ")
 SET oe_format_desc = fillstring(40," ")
 SET mnemonic_type_mean = fillstring(40," ")
 SET bb_process_type_mean = fillstring(40," ")
 SET surg_dept_name = fillstring(100," ")
 SET primary_code_value = 0.0
 SET direct_code_value = 0.0
 SET ancillary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning IN ("PRIMARY", "DCP", "ANCILLARY")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="PRIMARY")
    primary_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="ANCILLARY")
    ancillary_code_value = cv.code_value
   ELSE
    direct_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET orc_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO orc_cnt)
   SET error_flag = "N"
   IF (cnvtupper(requestin->list_0[x].mnemonic_type_mean)="PRIMARY")
    SET mnemonic_type_code_value = primary_code_value
    SET mnemonic_type_mean = cnvtupper(requestin->list_0[x].mnemonic_type_mean)
    SET cvcnt = 0
    IF (((catalog_type_code_value=0) OR (catalog_type_mean != cnvtupper(requestin->list_0[x].
     catalog_type_mean))) )
     SET catalog_type_code_value = 0
     SET catalog_type_mean = fillstring(40," ")
     SET catalog_type_mean = cnvtupper(requestin->list_0[x].catalog_type_mean)
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=6000
       AND cv.cdf_meaning=catalog_type_mean
       AND cv.active_ind=1
      DETAIL
       cvcnt = (cvcnt+ 1), catalog_type_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (cvcnt > 1)
      SET catalog_type_code_value = 0.0
     ENDIF
    ENDIF
    SET cvcnt = 0
    IF (((activity_type_code_value=0) OR (activity_type_mean != cnvtupper(requestin->list_0[x].
     activity_type_mean))) )
     SET activity_type_code_value = 0
     SET activity_type_mean = fillstring(40," ")
     SET activity_type_mean = cnvtupper(requestin->list_0[x].activity_type_mean)
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=106
       AND cv.cdf_meaning=activity_type_mean
       AND cv.active_ind=1
      DETAIL
       cvcnt = (cvcnt+ 1), activity_type_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (cvcnt > 1)
      SET activity_type_code_value = 0.0
     ENDIF
    ENDIF
    SET cvcnt = 0
    SET bb_process_code_value = 0.0
    IF (cnvtupper(trim(requestin->list_0[x].activity_type_mean))="BB")
     IF (((bb_process_code_value=0) OR (bb_process_type_mean != cnvtupper(requestin->list_0[x].
      bb_process_mean))) )
      SET bb_process_type_mean = fillstring(40," ")
      SET bb_process_type_mean = cnvtupper(requestin->list_0[x].bb_process_mean)
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=1635
        AND cv.cdf_meaning=bb_process_type_mean
        AND cv.active_ind=1
       DETAIL
        cvcnt = (cvcnt+ 1), bb_process_code_value = cv.code_value
       WITH nocounter
      ;end select
      IF (cvcnt > 1)
       SET bb_process_code_value = 0.0
      ENDIF
     ENDIF
    ENDIF
    SET cvcnt = 0
    IF (((activity_subtype_code_value=0) OR (activity_subtype_mean != cnvtupper(requestin->list_0[x].
     activity_subtype_mean))) )
     SET activity_subtype_code_value = 0.0
     SET activity_subtype_mean = fillstring(40," ")
     SET activity_subtype_mean = cnvtupper(requestin->list_0[x].activity_subtype_mean)
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=5801
       AND cv.cdf_meaning=activity_subtype_mean
       AND cv.active_ind=1
      DETAIL
       cvcnt = (cvcnt+ 1), activity_subtype_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (cvcnt > 1)
      SET activity_subtype_code_value = 0.0
     ENDIF
    ENDIF
    IF (((dcp_code_value=0) OR (dcp_mean != cnvtupper(requestin->list_0[x].dcp_mean))) )
     SET dcp_code_value = 0.0
     SET dcp_mean = fillstring(40," ")
     SET dcp_mean = cnvtupper(requestin->list_0[x].dcp_mean)
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=16389
       AND cv.cdf_meaning=dcp_mean
       AND cv.active_ind=1
      DETAIL
       dcp_code_value = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF (((oe_format_id=0) OR (oe_format_desc != trim(requestin->list_0[x].order_entry_format))) )
     SET oe_format_id = 0.0
     SET oe_format_desc = fillstring(40," ")
     SET oe_format_desc = cnvtupper(trim(requestin->list_0[x].order_entry_format))
     SELECT INTO "NL:"
      FROM order_entry_format oe
      WHERE cnvtupper(oe.oe_format_name)=oe_format_desc
      DETAIL
       oe_format_id = oe.oe_format_id
      WITH nocounter
     ;end select
    ENDIF
    UPDATE  FROM br_auto_order_catalog b
     SET b.catalog_type_cd = catalog_type_code_value, b.activity_type_cd = activity_type_code_value,
      b.activity_subtype_cd = activity_subtype_code_value,
      b.primary_mnemonic = substring(1,100,requestin->list_0[x].hna_mnemonic), b.description =
      substring(1,100,requestin->list_0[x].description), b.catalog_type_display = substring(1,40,
       requestin->list_0[x].catalog_type_cd),
      b.activity_type_display = substring(1,40,requestin->list_0[x].activity_type_cd), b
      .activity_subtype_display = substring(1,40,requestin->list_0[x].activity_subtype_cd), b
      .oe_format_id = oe_format_id,
      b.dcp_clin_cat_cd = dcp_code_value, b.cpt4 = substring(1,25,requestin->list_0[x].cpt4), b.loinc
       = substring(1,10,requestin->list_0[x].loinc),
      b.laboratory_ind =
      IF ((requestin->list_0[x].lab_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.radiology_ind =
      IF ((requestin->list_0[x].rad_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.patient_care_ind =
      IF ((requestin->list_0[x].patient_care_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      ,
      b.surgery_ind =
      IF ((requestin->list_0[x].surgery_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.cardiology_ind =
      IF ((requestin->list_0[x].cardio_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.bb_processing_cd = bb_process_code_value,
      b.dept_name =
      IF ((requestin->list_0[x].dept_name > "   *")) substring(1,100,requestin->list_0[x].dept_name)
      ELSEIF (cnvtupper(requestin->list_0[x].catalog_type_cd)="SURGERY") surg_dept_name
      ELSE substring(1,100,requestin->list_0[x].hna_mnemonic)
      ENDIF
      , b.cki =
      IF ((((requestin->list_0[x].catalog_cki=null)) OR ((requestin->list_0[x].catalog_cki=" "))) )
       null
      ELSE requestin->list_0[x].catalog_cki
      ENDIF
      , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
      b.updt_applctx = reqinfo->updt_applctx
     WHERE (b.concept_cki=requestin->list_0[x].concept_cki)
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Updating into br_auto_order_catalog: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
    SET new_id = 0.0
    SELECT INTO "NL:"
     FROM br_auto_order_catalog b
     WHERE (b.concept_cki=requestin->list_0[x].concept_cki)
     DETAIL
      new_id = b.catalog_cd
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0)
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_auto_order_catalog b
     SET b.catalog_cd = new_id, b.catalog_type_cd = catalog_type_code_value, b.activity_type_cd =
      activity_type_code_value,
      b.activity_subtype_cd = activity_subtype_code_value, b.primary_mnemonic = substring(1,100,
       requestin->list_0[x].hna_mnemonic), b.description = substring(1,100,requestin->list_0[x].
       description),
      b.catalog_type_display = substring(1,40,requestin->list_0[x].catalog_type_cd), b
      .activity_type_display = substring(1,40,requestin->list_0[x].activity_type_cd), b
      .activity_subtype_display = substring(1,40,requestin->list_0[x].activity_subtype_cd),
      b.oe_format_id = oe_format_id, b.dcp_clin_cat_cd = dcp_code_value, b.cpt4 = substring(1,25,
       requestin->list_0[x].cpt4),
      b.loinc = substring(1,10,requestin->list_0[x].loinc), b.laboratory_ind =
      IF ((requestin->list_0[x].lab_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.radiology_ind =
      IF ((requestin->list_0[x].rad_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      ,
      b.patient_care_ind =
      IF ((requestin->list_0[x].patient_care_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.surgery_ind =
      IF ((requestin->list_0[x].surgery_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      , b.cardiology_ind =
      IF ((requestin->list_0[x].cardio_ind IN ("1", "Y"))) 1
      ELSE 0
      ENDIF
      ,
      b.bb_processing_cd = bb_process_code_value, b.dept_name =
      IF ((requestin->list_0[x].dept_name > "   *")) substring(1,100,requestin->list_0[x].dept_name)
      ELSEIF (cnvtupper(requestin->list_0[x].catalog_type_cd)="SURGERY") surg_dept_name
      ELSE substring(1,100,requestin->list_0[x].hna_mnemonic)
      ENDIF
      , b.concept_cki =
      IF ((((requestin->list_0[x].concept_cki=null)) OR ((requestin->list_0[x].concept_cki=" "))) )
       null
      ELSE requestin->list_0[x].concept_cki
      ENDIF
      ,
      b.cki =
      IF ((((requestin->list_0[x].catalog_cki=null)) OR ((requestin->list_0[x].catalog_cki=" "))) )
       null
      ELSE requestin->list_0[x].catalog_cki
      ENDIF
      , b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_auto_order_catalog: ",errmsg
      )
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ELSEIF (cnvtupper(trim(requestin->list_0[x].mnemonic_type_mean))="DCP")
    SET mnemonic_type_code_value = direct_code_value
    SET mnemonic_type_mean = cnvtupper(requestin->list_0[x].mnemonic_type_mean)
   ELSEIF (cnvtupper(trim(requestin->list_0[x].mnemonic_type_mean))="ANCILLARY")
    SET mnemonic_type_code_value = ancillary_code_value
    SET mnemonic_type_mean = cnvtupper(requestin->list_0[x].mnemonic_type_mean)
   ELSEIF (((mnemonic_type_code_value=0) OR (mnemonic_type_mean != cnvtupper(requestin->list_0[x].
    mnemonic_type_mean))) )
    SET mnemonic_type_code_value = 0
    SET mnemonic_type_mean = cnvtupper(requestin->list_0[x].mnemonic_type_mean)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=6011
      AND cv.cdf_meaning=mnemonic_type_mean
      AND cv.active_ind=1
     DETAIL
      mnemonic_type_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (new_id > 0)
    SET new_synonym_id = 0.0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_synonym_id = cnvtreal(y)
     WITH format, nocounter
    ;end select
    INSERT  FROM br_auto_oc_synonym b
     SET b.synonym_id = new_synonym_id, b.catalog_cd = new_id, b.catalog_type_cd =
      catalog_type_code_value,
      b.activity_type_cd = activity_type_code_value, b.activity_subtype_cd =
      activity_subtype_code_value, b.oe_format_id = oe_format_id,
      b.mnemonic = requestin->list_0[x].mnemonic, b.mnemonic_key_cap = trim(cnvtupper(requestin->
        list_0[x].mnemonic)), b.mnemonic_type_cd = mnemonic_type_code_value,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_auto_oc_synonym: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 FREE SET oc
 RECORD oc(
   1 olist[*]
     2 name = c100
     2 parent_name = c32
     2 code_value = f8
 )
 SET tot_oc = 0
 SET oc_count = 0
 SET stat = alterlist(oc->olist,100)
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.description)
   AND o.description != cnvtupper(o.description)
   AND o.description > "  *"
  ORDER BY o.description
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.description), oc->olist[tot_oc].parent_name = "ORDER_CATALOG", oc
   ->olist[tot_oc].code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.dept_display_name)
   AND cnvtupper(o.dept_display_name) != cnvtupper(o.description)
   AND o.dept_display_name != cnvtupper(o.dept_display_name)
   AND o.dept_display_name > "  *"
  ORDER BY o.dept_display_name
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.dept_display_name), oc->olist[tot_oc].parent_name =
   "ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_auto_order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.description)
   AND o.description > "  *"
   AND o.description != cnvtupper(o.description)
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.description), oc->olist[tot_oc].parent_name =
   "BR_AUTO_ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_auto_order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.dept_name)
   AND o.dept_name != cnvtupper(o.dept_name)
   AND cnvtupper(o.dept_name) != cnvtupper(o.description)
   AND o.dept_name > "  *"
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.dept_name), oc->olist[tot_oc].parent_name =
   "BR_AUTO_ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH skipbedrock = 1, nocounter
 ;end select
 SET stat = alterlist(oc->olist,tot_oc)
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ps_oc_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
