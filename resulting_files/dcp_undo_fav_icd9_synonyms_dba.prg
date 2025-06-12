CREATE PROGRAM dcp_undo_fav_icd9_synonyms:dba
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
 SET readme_data->message = "FAIL:dcp_undo_fav_icd9_synonyms.prg failed"
 FREE RECORD favorite
 RECORD favorite(
   1 favorite[*]
     2 nomen_cat_list_id = f8
     2 new_nomen_id = f8
 )
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE ifavoritecnt = i4 WITH noconstant(0), protect
 DECLARE ifavoritesize = i4 WITH protect, noconstant(0)
 DECLARE ibatchsize = i4 WITH protect, constant(20)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE dvocabtypecodeset = i4 WITH protect, constant(400)
 DECLARE dicd9 = f8 WITH protect, noconstant(0.00)
 DECLARE dimo = f8 WITH protect, noconstant(0.00)
 DECLARE dhli = f8 WITH protect, noconstant(0.00)
 DECLARE dsnmct = f8 WITH protect, noconstant(0.00)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=dvocabtypecodeset
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.cdf_meaning IN ("ICD9", "IMO", "HLI.PFT", "SNMCT")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ICD9":
     dicd9 = cv.code_value
    OF "IMO":
     dimo = cv.code_value
    OF "HLI.PFT":
     dhli = cv.code_value
    OF "SNMCT":
     dsnmct = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail:Failed to select code values from code value table",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM nomen_cat_list ncl,
   nomenclature n1,
   cmt_term_map ctm,
   nomenclature n2
  PLAN (ncl
   WHERE ncl.child_flag=2)
   JOIN (n1
   WHERE n1.nomenclature_id=ncl.nomenclature_id
    AND n1.active_ind=1
    AND n1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dimo > 0.0
    AND n1.source_vocabulary_cd=dimo) OR (dhli > 0.0
    AND n1.source_vocabulary_cd=dhli)) )
   JOIN (ctm
   WHERE ctm.cmti=n1.cmti)
   JOIN (n2
   WHERE n2.cmti=ctm.target_cmti
    AND n2.active_ind=1
    AND n2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dicd9 > 0.0
    AND n2.source_vocabulary_cd=dicd9) OR (dsnmct > 0.0
    AND n2.source_vocabulary_cd=dsnmct)) )
  HEAD REPORT
   ifavoritecnt = 0, stat = alterlist(favorite->favorite,ibatchsize), ifavoritesize = ibatchsize
  DETAIL
   IF (((n1.source_vocabulary_cd=dimo
    AND n2.source_vocabulary_cd=dicd9) OR (n1.source_vocabulary_cd=dhli
    AND n2.source_vocabulary_cd=dsnmct)) )
    ifavoritecnt = (ifavoritecnt+ 1)
    IF (ifavoritecnt > ifavoritesize)
     ifavoritesize = (ifavoritecnt+ (ibatchsize - 1)), stat = alterlist(favorite->favorite,
      ifavoritesize)
    ENDIF
    favorite->favorite[ifavoritecnt].nomen_cat_list_id = ncl.nomen_cat_list_id, favorite->favorite[
    ifavoritecnt].new_nomen_id = n2.nomenclature_id
   ENDIF
  FOOT REPORT
   stat = alterlist(favorite->favorite,ifavoritecnt), ifavoritesize = ifavoritecnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail:Failed to select nomenclature_id's from nomen_cat_list",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (ifavoritecnt > 0)
  UPDATE  FROM (dummyt d1  WITH seq = value(ifavoritecnt)),
    nomen_cat_list ncl
   SET ncl.nomenclature_id = favorite->favorite[d1.seq].new_nomen_id, ncl.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), ncl.updt_id = reqinfo->updt_id,
    ncl.updt_task = reqinfo->updt_task, ncl.updt_applctx = reqinfo->updt_applctx, ncl.updt_cnt = (ncl
    .updt_cnt+ 1)
   PLAN (d1)
    JOIN (ncl
    WHERE (ncl.nomen_cat_list_id=favorite->favorite[d1.seq].nomen_cat_list_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update NOMEN_CAT_LIST table",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success:  Readme dcp_undo_fav_icd9_synonyms.prg completed successfully"
#exit_script
 FREE RECORD favorite
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
