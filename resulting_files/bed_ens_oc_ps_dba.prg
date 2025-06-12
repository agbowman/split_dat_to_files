CREATE PROGRAM bed_ens_oc_ps:dba
 RECORD requestin(
   1 list_0[*]
     2 description = vc
     2 hna_mnemonic = vc
     2 dept_name = vc
     2 catalog_type_cd = vc
     2 activity_type_cd = vc
     2 activity_subtype_cd = vc
     2 order_entry_format = vc
     2 mnemonic = vc
     2 cpt4 = c25
     2 loinc = vc
     2 concept_cki = vc
     2 catalog_cki = vc
     2 catalog_type_mean = vc
     2 activity_type_mean = vc
     2 activity_subtype_mean = vc
     2 dcp_mean = vc
     2 mnemonic_type_mean = vc
     2 rad_ind = vc
     2 lab_ind = vc
     2 patient_care_ind = vc
     2 surgery_ind = vc
     2 cardio_ind = vc
     2 bb_process = vc
     2 bb_process_mean = vc
 )
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
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET catalog_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET activity_subtype_code_value = 0.0
 SET dcp_code_value = 0.0
 SET oe_format_id = 0.0
 SET mnemonic_type_code_value = 0.0
 SET new_id = 0.0
 SET new_synonym_id = 0.0
 SET catalog_type_mean = fillstring(40," ")
 SET activity_type_mean = fillstring(40," ")
 SET activity_subtype_mean = fillstring(40," ")
 SET catalog_type_disp = fillstring(40," ")
 SET activity_type_disp = fillstring(40," ")
 SET activity_subtype_disp = fillstring(40," ")
 SET dcp_mean = fillstring(40," ")
 SET oe_format_desc = fillstring(40," ")
 SET mnemonic_type_mean = fillstring(40," ")
 SET primary_code_value = 0.0
 SET direct_code_value = 0.0
 SET ancillary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning IN ("PRIMARY", "DCP", "ANCILLARY")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "PRIMARY":
     primary_code_value = cv.code_value
    OF "DCP":
     direct_code_value = cv.code_value
    OF "ANCILLARY":
     ancillary_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET orc_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO orc_cnt)
   IF (cnvtupper(requestin->list_0[x].mnemonic_type_mean)="PRIMARY")
    SET mnemonic_type_code_value = primary_code_value
    SET mnemonic_type_desc = fillstring(40," ")
    IF (((catalog_type_code_value=0) OR (((catalog_type_disp != cnvtupper(requestin->list_0[x].
     catalog_type_cd)) OR (catalog_type_mean != cnvtupper(requestin->list_0[x].catalog_type_mean)))
    )) )
     SET catalog_type_code_value = 0
     SET catalog_type_mean = fillstring(40," ")
     SET catalog_type_mean = cnvtupper(requestin->list_0[x].catalog_type_mean)
     SET catalog_type_disp = fillstring(40," ")
     SET catalog_type_disp = cnvtupper(requestin->list_0[x].catalog_type_cd)
     SELECT DISTINCT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=6000
       AND cv.cdf_meaning=catalog_type_mean
       AND cv.active_ind=1
      ORDER BY cv.code_value
      DETAIL
       catalog_type_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (((curqual=0) OR (catalog_type_code_value=0)) )
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=6000
        AND cnvtupper(cv.display)=catalog_type_disp
        AND cv.active_ind=1
       ORDER BY cv.code_value
       DETAIL
        catalog_type_code_value = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual > 1)
       SET catalog_type_code_value = 0
      ENDIF
     ENDIF
    ENDIF
    IF (((activity_type_code_value=0) OR (((activity_type_disp != cnvtupper(requestin->list_0[x].
     activity_type_cd)) OR (activity_type_mean != cnvtupper(requestin->list_0[x].activity_type_mean)
    )) )) )
     SET activity_type_code_value = 0
     SET activity_type_mean = fillstring(40," ")
     SET activity_type_mean = cnvtupper(requestin->list_0[x].activity_type_mean)
     SET activity_type_disp = fillstring(40," ")
     SET activity_type_disp = cnvtupper(requestin->list_0[x].activity_type_cd)
     SELECT DISTINCT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=106
       AND cv.cdf_meaning=activity_type_mean
       AND cv.active_ind=1
      ORDER BY cv.code_value
      DETAIL
       activity_type_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (((curqual=0) OR (activity_type_code_value=0)) )
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=106
        AND cnvtupper(cv.display)=activity_type_disp
        AND cv.active_ind=1
       ORDER BY cv.code_value
       DETAIL
        activity_type_code_value = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual > 1)
       SET activity_type_code_value = 0
      ENDIF
     ENDIF
    ENDIF
    SET bb_process_cd = 0.0
    IF (activity_type_mean="BB"
     AND (requestin->list_0[x].bb_process_mean > " "))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.active_ind=1
       AND (cv.cdf_meaning=requestin->list_0[x].bb_process_mean)
       AND cv.code_set=1635
      ORDER BY cv.code_value
      DETAIL
       bb_process_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.active_ind=1
        AND cnvtupper(cv.display)=cnvtupper(requestin->list_0[x].bb_process)
        AND cv.code_set=1635
       ORDER BY cv.code_value
       DETAIL
        bb_process_cd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual > 1)
       SET bb_process_cd = 0.0
      ENDIF
     ENDIF
    ENDIF
    SET activity_subtype_code_value = 0.0
    SET activity_subtype_mean = fillstring(40," ")
    IF (((activity_subtype_code_value=0) OR (((activity_subtype_disp != cnvtupper(requestin->list_0[x
     ].activity_subtype_cd)) OR (activity_subtype_mean != cnvtupper(requestin->list_0[x].
     activity_subtype_mean))) )) )
     SET activity_subtype_mean = cnvtupper(requestin->list_0[x].activity_subtype_mean)
     SET activity_subtype_disp = fillstring(40," ")
     SET activity_subtype_disp = cnvtupper(requestin->list_0[x].activity_subtype_cd)
     SELECT DISTINCT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=5801
       AND cv.cdf_meaning=activity_subtype_mean
       AND cv.active_ind=1
      ORDER BY cv.code_value
      DETAIL
       activity_subtype_code_value = cv.code_value
      WITH nocounter
     ;end select
     IF (((curqual=0) OR (activity_subtype_code_value=0)) )
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=106
        AND cnvtupper(cv.display)=activity_subtype_disp
        AND cv.active_ind=1
       ORDER BY cv.code_value
       DETAIL
        activity_subtype_code_value = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual > 1)
       SET activity_subtype_code_value = 0
      ENDIF
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
      substring(1,100,requestin->list_0[x].description), b.oe_format_id = oe_format_id,
      b.dcp_clin_cat_cd = dcp_code_value, b.bb_processing_cd = bb_process_cd, b.cpt4 = substring(1,25,
       requestin->list_0[x].cpt4),
      b.loinc = substring(1,10,requestin->list_0[x].loinc), b.dept_name =
      IF ((requestin->list_0[x].dept_name > "   *")) substring(1,100,requestin->list_0[x].dept_name)
      ELSE substring(1,100,requestin->list_0[x].hna_mnemonic)
      ENDIF
      , b.laboratory_ind =
      IF ((((requestin->list_0[x].lab_ind="1")) OR ((requestin->list_0[x].lab_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      ,
      b.radiology_ind =
      IF ((((requestin->list_0[x].rad_ind="1")) OR ((requestin->list_0[x].rad_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      , b.surgery_ind =
      IF ((((requestin->list_0[x].surgery_ind="1")) OR ((requestin->list_0[x].surgery_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      , b.cardiology_ind =
      IF ((((requestin->list_0[x].cardio_ind="1")) OR ((requestin->list_0[x].cardio_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      ,
      b.patient_care_ind =
      IF ((((requestin->list_0[x].patient_care_ind="1")) OR ((requestin->list_0[x].patient_care_ind=
      "Y"))) ) 1
      ELSE 0
      ENDIF
      , b.catalog_type_display = substring(1,40,requestin->list_0[x].catalog_type_cd), b
      .activity_type_display = substring(1,40,requestin->list_0[x].activity_type_cd),
      b.activity_subtype_display = substring(1,40,requestin->list_0[x].activity_subtype_cd), b
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
     WHERE (b.concept_cki=requestin->list_0[x].concept_cki)
     WITH nocounter
    ;end update
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
      b.oe_format_id = oe_format_id, b.dcp_clin_cat_cd = dcp_code_value, b.bb_processing_cd =
      bb_process_cd,
      b.cpt4 = substring(1,25,requestin->list_0[x].cpt4), b.loinc = substring(1,10,requestin->list_0[
       x].loinc), b.dept_name =
      IF ((requestin->list_0[x].dept_name > "   *")) substring(1,100,requestin->list_0[x].dept_name)
      ELSE substring(1,100,requestin->list_0[x].hna_mnemonic)
      ENDIF
      ,
      b.concept_cki =
      IF ((((requestin->list_0[x].concept_cki=null)) OR ((requestin->list_0[x].concept_cki=" "))) )
       null
      ELSE requestin->list_0[x].concept_cki
      ENDIF
      , b.cki =
      IF ((((requestin->list_0[x].catalog_cki=null)) OR ((requestin->list_0[x].catalog_cki=" "))) )
       null
      ELSE requestin->list_0[x].catalog_cki
      ENDIF
      , b.laboratory_ind =
      IF ((((requestin->list_0[x].lab_ind="1")) OR ((requestin->list_0[x].lab_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      ,
      b.radiology_ind =
      IF ((((requestin->list_0[x].rad_ind="1")) OR ((requestin->list_0[x].rad_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      , b.surgery_ind =
      IF ((((requestin->list_0[x].surgery_ind="1")) OR ((requestin->list_0[x].surgery_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      , b.cardiology_ind =
      IF ((((requestin->list_0[x].cardio_ind="1")) OR ((requestin->list_0[x].cardio_ind="Y"))) ) 1
      ELSE 0
      ENDIF
      ,
      b.patient_care_ind =
      IF ((((requestin->list_0[x].patient_care_ind="1")) OR ((requestin->list_0[x].patient_care_ind=
      "Y"))) ) 1
      ELSE 0
      ENDIF
      , b.catalog_type_display = substring(1,40,requestin->list_0[x].catalog_type_cd), b
      .activity_type_display = substring(1,40,requestin->list_0[x].activity_type_cd),
      b.activity_subtype_display = substring(1,40,requestin->list_0[x].activity_subtype_cd), b
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->oc_list[x].hna_mnemonic),
      " into br_auto_order_catalog table.")
     GO TO exit_script
    ENDIF
   ELSEIF (((cnvtupper(requestin->list_0[x].mnemonic_type)="DIRECT CARE PROVIDER") OR (cnvtupper(
    requestin->list_0[x].mnemonic_type)="DCP")) )
    SET mnemonic_type_code_value = direct_code_value
    SET mnemonic_type_desc = fillstring(40," ")
   ELSEIF (cnvtupper(requestin->list_0[x].mnemonic_type)="ANCILLARY")
    SET mnemonic_type_code_value = ancillary_code_value
    SET mnemonic_type_desc = fillstring(40," ")
   ELSEIF (((mnemonic_type_code_value=0) OR (mnemonic_type_mean != cnvtupper(requestin->list_0[x].
    mnemonic_type_mean))) )
    SET mnemonic_type_code_value = 0
    SET mnemonic_type_mean = fillstring(40," ")
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
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable generate new synonym_id when processing ",trim(requestin->list_0[
       x].hna_mnemonic))
     GO TO exit_script
    ENDIF
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
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert synonym ",trim(requestin->list_0[x].hna_mnemonic),
      " for ",trim(requestin->list_0[x].hna_mnemonic)," into the br_auto_oc_synonym table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_PS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
