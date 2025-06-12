CREATE PROGRAM bed_imp_oc_work_tables:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 oc_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE facility = vc
 SET error_flag = "N"
 SET reply_count = 0
 SET list_count = 0
 SET upd_short_name = fillstring(100," ")
 SET upd_long_name = fillstring(100," ")
 SET oc_cnt = size(requestin->list_0,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SET cpt4_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cki="CKI.CODEVALUE!3600"
  DETAIL
   cpt4_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET cdm_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.active_ind=1
   AND cv.cki="CKI.CODEVALUE!1308145"
  DETAIL
   cdm_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET primary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO oc_cnt)
   SET error_flag = "N"
   SET upd_short_name = requestin->list_0[x].short_name
   SET upd_long_name = requestin->list_0[x].long_name
   SET upd_short_name = replace(upd_short_name," * "," ")
   SET upd_short_name = replace(upd_short_name,"* "," ")
   SET upd_short_name = replace(upd_short_name," *"," ")
   SET upd_short_name = replace(upd_short_name,"*"," ")
   SET upd_long_name = replace(upd_long_name," * "," ")
   SET upd_long_name = replace(upd_long_name,"* "," ")
   SET upd_long_name = replace(upd_long_name," *"," ")
   SET upd_long_name = replace(upd_long_name,"*"," ")
   SET new_id = 0.0
   IF (validate(requestin->list_0[x].facility))
    SET facility = trim(requestin->list_0[x].facility)
   ELSE
    SET facility = " "
   ENDIF
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET reply->oc_list[x].oc_id = new_id
   INSERT  FROM br_oc_work b
    SET b.seq = 1, b.oc_id = new_id, b.facility = facility,
     b.short_desc =
     IF (((upd_short_name="    *") OR (upd_short_name=null)) ) trim(upd_long_name)
     ELSE trim(upd_short_name)
     ENDIF
     , b.long_desc =
     IF (((upd_long_name="    *") OR (upd_long_name=null)) ) trim(upd_short_name)
     ELSE trim(upd_long_name)
     ENDIF
     , b.org_short_name =
     IF ((((requestin->list_0[x].short_name="    *")) OR ((requestin->list_0[x].short_name=null))) )
      trim(requestin->list_0[x].long_name)
     ELSE trim(requestin->list_0[x].short_name)
     ENDIF
     ,
     b.org_long_name =
     IF ((((requestin->list_0[x].long_name="    *")) OR ((requestin->list_0[x].long_name=null))) )
      trim(requestin->list_0[x].short_name)
     ELSE trim(requestin->list_0[x].long_name)
     ENDIF
     , b.status_ind = 0, b.match_ind = 0,
     b.match_orderable_cd = 0, b.match_value = " ", b.commit_ind = 0,
     b.skip_match_ind = 0, b.catalog_type = cnvtupper(requestin->list_0[x].catalog_type), b
     .activity_type = trim(requestin->list_0[x].activity_type),
     b.activity_subtype = trim(requestin->list_0[x].activity_subtype), b.loinc_code = trim(requestin
      ->list_0[x].loinc), b.alias1 = trim(requestin->list_0[x].alias1),
     b.alias2 = trim(requestin->list_0[x].alias2), b.alias3 = trim(requestin->list_0[x].alias3), b
     .alias4 = trim(requestin->list_0[x].alias4),
     b.alias5 = trim(requestin->list_0[x].alias5), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].short_name),
     " into the br_oc_work table.")
    GO TO exit_script
   ENDIF
   IF ((requestin->list_0[x].cpt4 > "   *"))
    INSERT  FROM br_oc_pricing b
     SET b.seq = 1, b.pricing_id = cnvtint(seq(reference_seq,nextval)), b.oc_id = new_id,
      b.billcode_sched_cd = cpt4_code_value, b.billcode = requestin->list_0[x].cpt4, b.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
      b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert CPT4 for ",trim(requestin->list_0[x].short_name),
      " into the br_oc_pricing table.")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].cdm > "   *"))
    INSERT  FROM br_oc_pricing b
     SET b.seq =
      IF ((requestin->list_0[x].cpt4 > "   *")) 2
      ELSE 1
      ENDIF
      , b.pricing_id = cnvtint(seq(reference_seq,nextval)), b.oc_id = new_id,
      b.billcode_sched_cd = cdm_code_value, b.billcode = requestin->list_0[x].cdm, b.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
      b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert CDM for ",trim(requestin->list_0[x].short_name),
      " into the br_oc_pricing table.")
     GO TO exit_script
    ENDIF
   ENDIF
   INSERT  FROM br_oc_synonym bos
    SET bos.seq = 1, bos.synonym_id = cnvtint(seq(reference_seq,nextval)), bos.oc_id = new_id,
     bos.facility = facility, bos.mnemonic_type_cd = primary_code_value, bos.mnemonic =
     IF ((((requestin->list_0[x].short_name="    *")) OR ((requestin->list_0[x].short_name=null))) )
      trim(requestin->list_0[x].long_name)
     ELSE trim(requestin->list_0[x].short_name)
     ENDIF
     ,
     bos.hide_flag = 0, bos.virtual_views = " ", bos.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bos.updt_id = reqinfo->updt_id, bos.updt_task = reqinfo->updt_task, bos.updt_cnt = 0,
     bos.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert short_name =",trim(requestin->list_0[x].short_name),
     " long name = ",trim(requestin->list_0[x].short_name)," into the br_oc_synonym table.")
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*            LEGACY ORDERS FILE IMPORTED SUCCESSFULLY        *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_OC_WORK_TABLES","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*            LEGACY ORDERS FILE IMPORT HAS FAILED            *")
  CALL echo("*  Do not run additional imports, contact the BEDROCK team   *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ENDIF
END GO
