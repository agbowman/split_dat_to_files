CREATE PROGRAM dcp_readme_pop_med_diluents:dba
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
 CALL echo("Starting dcp_readme_pop_med_diluents")
 RECORD primary_synonyms(
   1 qual[*]
     2 synonym_id = f8
 )
 DECLARE primary_cnt = i4 WITH noconstant(0)
 DECLARE asl_cnt = i4 WITH noconstant(0)
 DECLARE founddesc = i2 WITH noconstant(0)
 DECLARE tmp_alt_sel_cat_id = f8 WITH public, noconstant(0.0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE rdm_errcode = i4
 DECLARE rdm_errmsg = c132
 DECLARE errmsg = c132
 DECLARE readme_status = c1
 SET rdm_errcode = 0
 SET rdm_errmsg = fillstring(132," ")
 SET errmsg = fillstring(132," ")
 SET readme_status = "S"
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET primary_cd = code_value
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  PLAN (a
   WHERE a.long_description_key_cap="IVPB_CHARTING_DILUENTS")
  DETAIL
   founddesc = 1
  WITH nocounter
 ;end select
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  SET readme_status = "F"
  GO TO exit_program
 ELSE
  IF (founddesc=1)
   SET readme_status = "Q"
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.mnemonic_type_cd=primary_cd
    AND ocs.mnemonic_key_cap IN ("DEXTROSE 5%", "D5W", "SODIUM CHLORIDE 0.9%", "NS", "NACL 0.9%",
   "NORMAL SALINE"))
  HEAD REPORT
   primary_cnt = 0
  DETAIL
   primary_cnt = (primary_cnt+ 1)
   IF (primary_cnt > size(primary_synonyms->qual,5))
    stat = alterlist(primary_synonyms->qual,(primary_cnt+ 5))
   ENDIF
   primary_synonyms->qual[primary_cnt].synonym_id = ocs.synonym_id
  WITH nocounter
 ;end select
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  SET readme_status = "F"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   tmp_alt_sel_cat_id = nextseqnum
  WITH nocounter
 ;end select
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  SET readme_status = "F"
  GO TO exit_program
 ENDIF
 INSERT  FROM alt_sel_cat a
  SET a.alt_sel_category_id = tmp_alt_sel_cat_id, a.short_description = "IVPB_CHARTING_DILUENTS", a
   .long_description = "IVPB_CHARTING_DILUENTS",
   a.long_description_key_cap = "IVPB_CHARTING_DILUENTS", a.owner_id = 0, a.security_flag = 2,
   a.ahfs_ind = 0, a.adhoc_ind = 0, a.child_cat_ind = 0,
   a.source_component_flag = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime), a.updt_id = reqinfo->
   updt_id,
   a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
  WITH nocounter
 ;end insert
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  SET readme_status = "F"
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM alt_sel_list asl
  WHERE asl.alt_sel_category_id=tmp_alt_sel_cat_id
  WITH nocounter
 ;end delete
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  SET errmsg = rdm_errmsg
  SET readme_status = "F"
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 FOR (asl_cnt = 1 TO primary_cnt)
   INSERT  FROM alt_sel_list asl
    SET asl.alt_sel_category_id = tmp_alt_sel_cat_id, asl.sequence = asl_cnt, asl.list_type = 2,
     asl.synonym_id = primary_synonyms->qual[asl_cnt].synonym_id, asl.child_alt_sel_cat_id = 0, asl
     .order_sentence_id = 0,
     asl.reference_task_id = 0, asl.updt_dt_tm = cnvtdatetime(curdate,curtime), asl.updt_id = reqinfo
     ->updt_id,
     asl.updt_task = reqinfo->updt_task, asl.updt_applctx = reqinfo->updt_applctx, asl.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET rdm_errcode = error(rdm_errmsg,0)
   IF (rdm_errcode != 0)
    SET errmsg = rdm_errmsg
    SET readme_status = "F"
    GO TO exit_program
   ELSE
    COMMIT
   ENDIF
 ENDFOR
#exit_program
 FREE RECORD primary_synonyms
 CALL echo("Updating readme status")
 IF (readme_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
  ROLLBACK
 ELSEIF (readme_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "Successfully updated the alt_sel_cat alt_sel_list tables."
 ELSEIF (readme_status="Q")
  SET readme_data->status = "S"
  SET readme_data->message = "IVPB_CHARTING_DILUENTS category already existed. Nothing altered."
 ENDIF
 SET last_mod = "002"
 SET mod_date = "10/25/2011"
 EXECUTE dm_readme_status
END GO
