CREATE PROGRAM bed_imp_oc_work_tables_mig:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 oc_id = f8
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
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply_count = 0
 SET list_count = 0
 SET upd_short_name = fillstring(100," ")
 SET upd_long_name = fillstring(100," ")
 SET oc_cnt = size(requestin->list_0,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SET stat = alterlist(reply->status_data.subeventstatus,oc_cnt)
 SET syn_seq = 0
 SET new_id = 0.0
 SET v_view = fillstring(15," ")
 SET lab_order_entry = 0
 SET rad_order_entry = 0
 SET micro_order_entry = 0
 SET action_code_value = 0
 SET primary_code_value = 0
 SET ancillary_code_value = 0
 SET warn_code_value = 0
 SET reject_code_value = 0
 SET cpt4_code_value = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cki="CKI.CODEVALUE!3600"
  DETAIL
   cpt4_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6001
   AND cv.cdf_meaning="REJECT"
  DETAIL
   reject_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6001
   AND cv.cdf_meaning="WARNING"
  DETAIL
   warn_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6003
   AND cv.cdf_meaning="ORDER"
  DETAIL
   action_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6011
   AND cv.cdf_meaning="ANCILLARY"
  DETAIL
   ancillary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_entry_format oef
  WHERE oef.action_type_cd=action_code_value
   AND oef.oe_format_name="Lab - Gen Lab"
  DETAIL
   lab_order_entry = oef.oe_format_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_entry_format oef
  WHERE oef.action_type_cd=action_code_value
   AND oef.oe_format_name="Lab - Micro"
  DETAIL
   micro_order_entry = oef.oe_format_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_entry_format oef
  WHERE oef.action_type_cd=action_code_value
   AND oef.oe_format_name="Radiology"
  DETAIL
   rad_order_entry = oef.oe_format_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO oc_cnt)
   SET error_flag = "N"
   SET upd_short_name = requestin->list_0[x].hna_mnemonic
   SET upd_long_name = requestin->list_0[x].description
   SET upd_short_name = replace(upd_short_name," * "," ")
   SET upd_short_name = replace(upd_short_name,"* "," ")
   SET upd_short_name = replace(upd_short_name," *"," ")
   SET upd_short_name = replace(upd_short_name,"*"," ")
   SET upd_long_name = replace(upd_long_name," * "," ")
   SET upd_long_name = replace(upd_long_name,"* "," ")
   SET upd_long_name = replace(upd_long_name," *"," ")
   SET upd_long_name = replace(upd_long_name,"*"," ")
   SET requestin->list_0[x].mnemonic = replace(requestin->list_0[x].mnemonic," * "," ")
   SET requestin->list_0[x].mnemonic = replace(requestin->list_0[x].mnemonic,"* "," ")
   SET requestin->list_0[x].mnemonic = replace(requestin->list_0[x].mnemonic," *"," ")
   SET requestin->list_0[x].mnemonic = replace(requestin->list_0[x].mnemonic,"*"," ")
   IF ((requestin->list_0[x].mnemonic_type != "Ancillary"))
    SET new_id = 0.0
    SET syn_seq = 1
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->oc_list[x].oc_id = new_id
    SET upper_catalog = fillstring(100," ")
    SET upper_catalog = cnvtupper(requestin->list_0[x].catalog_type_cd)
    SET dept_name = fillstring(100," ")
    IF (validate(requestin->list_0[x].dept_name))
     SET dept_name = requestin->list_0[x].dept_name
     SET dept_name = replace(dept_name," * "," ")
     SET dept_name = replace(dept_name,"* "," ")
     SET dept_name = replace(dept_name," *"," ")
     SET dept_name = replace(dept_name,"*"," ")
    ENDIF
    IF (validate(requestin->list_0[x].facility))
     SET facility = trim(requestin->list_0[x].facility)
    ELSE
     SET facility = " "
    ENDIF
    INSERT  FROM br_oc_work b
     SET b.seq = 1, b.oc_id = new_id, b.facility = facility,
      b.short_desc =
      IF ((requestin->list_0[x].hna_mnemonic="     *")) trim(upd_long_name)
      ELSE trim(upd_short_name)
      ENDIF
      , b.long_desc =
      IF ((requestin->list_0[x].description="      *")) trim(upd_short_name)
      ELSE trim(upd_long_name)
      ENDIF
      , b.org_short_name =
      IF ((((requestin->list_0[x].hna_mnemonic="    *")) OR ((requestin->list_0[x].hna_mnemonic=null)
      )) ) trim(requestin->list_0[x].description)
      ELSE trim(requestin->list_0[x].hna_mnemonic)
      ENDIF
      ,
      b.org_long_name =
      IF ((((requestin->list_0[x].description="    *")) OR ((requestin->list_0[x].description=null)
      )) ) trim(requestin->list_0[x].hna_mnemonic)
      ELSE trim(requestin->list_0[x].description)
      ENDIF
      , b.dept_name = dept_name, b.status_ind = 0,
      b.match_ind = 0, b.match_orderable_cd = 0, b.match_value = " ",
      b.commit_ind = 0, b.skip_match_ind = 0, b.catalog_type = upper_catalog,
      b.activity_type = trim(requestin->list_0[x].activity_type_cd), b.activity_subtype = trim(
       requestin->list_0[x].activity_subtype_cd), b.oe_format_id =
      IF ((requestin->list_0[x].order_entry_format="Lab - Gen Lab")) lab_order_entry
      ELSEIF ((requestin->list_0[x].order_entry_format="Lab - Micro")) micro_order_entry
      ELSEIF ((requestin->list_0[x].order_entry_format="Radiology")) rad_order_entry
      ELSE 0
      ENDIF
      ,
      b.dup_check_seq =
      IF ((requestin->list_0[x].dup_check_seq > "  *")) cnvtint(requestin->list_0[x].dup_check_seq)
      ELSE 0
      ENDIF
      , b.exact_hit_action_cd =
      IF ((requestin->list_0[x].exact_hit_action="REJECT")) reject_code_value
      ELSEIF ((requestin->list_0[x].exact_hit_action="WARNING")) warn_code_value
      ELSE 0
      ENDIF
      , b.min_ahead_action_cd =
      IF ((requestin->list_0[x].min_ahead_action="REJECT")) reject_code_value
      ELSEIF ((requestin->list_0[x].min_ahead_action="WARNING")) warn_code_value
      ELSE 0
      ENDIF
      ,
      b.min_ahead =
      IF ((requestin->list_0[x].min_ahead > "   *")) cnvtint(requestin->list_0[x].min_ahead)
      ELSE 0
      ENDIF
      , b.min_behind_action_cd =
      IF ((requestin->list_0[x].min_behind_action="REJECT")) reject_code_value
      ELSEIF ((requestin->list_0[x].min_behind_action="WARNING")) warn_code_value
      ELSE 0
      ENDIF
      , b.min_behind =
      IF ((requestin->list_0[x].min_behind > "    *")) cnvtint(requestin->list_0[x].min_behind)
      ELSE 0
      ENDIF
      ,
      b.alias1 = trim(requestin->list_0[x].alias_nbr), b.alias2 = trim(requestin->list_0[x].alias_mne
       ), b.bill_only_ind =
      IF ((requestin->list_0[x].bill_only_ind="Y")) 1
      ELSE 0
      ENDIF
      ,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].hna_mnemonic),
      " into the br_oc_work table.")
     GO TO exit_script
    ENDIF
    IF ((requestin->list_0[x].billcode > "   *"))
     INSERT  FROM br_oc_pricing bop
      SET bop.seq = 1, bop.pricing_id = cnvtint(seq(reference_seq,nextval)), bop.oc_id = new_id,
       bop.billcode_sched_cd = cpt4_code_value, bop.billcode = requestin->list_0[x].billcode, bop
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bop.updt_id = reqinfo->updt_id, bop.updt_task = reqinfo->updt_task, bop.updt_cnt = 0,
       bop.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].hna_mnemonic),
       " into the br_oc_synonym table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET v_view = concat(requestin->list_0[x].virtual_view1,requestin->list_0[x].virtual_view2,
    requestin->list_0[x].virtual_view3,requestin->list_0[x].virtual_view4,requestin->list_0[x].
    virtual_view5,
    requestin->list_0[x].virtual_view6,requestin->list_0[x].virtual_view7,requestin->list_0[x].
    virtual_view8,requestin->list_0[x].virtual_view9,requestin->list_0[x].virtual_view10,
    requestin->list_0[x].virtual_view11,requestin->list_0[x].virtual_view12,requestin->list_0[x].
    virtual_view13,requestin->list_0[x].virtual_view14,requestin->list_0[x].virtual_view15)
   INSERT  FROM br_oc_synonym bos
    SET bos.seq = syn_seq, bos.synonym_id = cnvtint(seq(reference_seq,nextval)), bos.oc_id = new_id,
     bos.facility = facility, bos.mnemonic_type_cd =
     IF ((requestin->list_0[x].mnemonic_type="Ancillary")) ancillary_code_value
     ELSE primary_code_value
     ENDIF
     , bos.mnemonic =
     IF ((requestin->list_0[x].mnemonic > "          *")) requestin->list_0[x].mnemonic
     ELSE upd_short_name
     ENDIF
     ,
     bos.hide_flag =
     IF ((requestin->list_0[x].hide_flag="Y")) 1
     ELSE 0
     ENDIF
     , bos.virtual_views = v_view, bos.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bos.updt_id = reqinfo->updt_id, bos.updt_task = reqinfo->updt_task, bos.updt_cnt = 0,
     bos.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET syn_seq = (syn_seq+ 1)
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].mnemonic),
     " into the br_oc_synonym table.")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_OC_WORK_TABLES_MIG","  >> ERROR MSG: ",
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
