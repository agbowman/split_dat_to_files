CREATE PROGRAM dcp_upd_probdx_icd9_synonyms:dba
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
 SET readme_data->message = "FAIL:dcp_upd_probdx_icd9_synonyms.prg failed"
 FREE RECORD diagnosis
 RECORD diagnosis(
   1 diagnosis[*]
     2 diagnosis_id = f8
     2 new_orig_nomen_id = f8
 )
 FREE RECORD problem
 RECORD problem(
   1 problem[*]
     2 problem_instance_id = f8
     2 new_orig_nomen_id = f8
 )
 FREE RECORD favorite
 RECORD favorite(
   1 favorite[*]
     2 nomen_cat_list_id = f8
     2 new_nomen_id = f8
 )
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE idiagnosiscnt = i4 WITH noconstant(0), protect
 DECLARE iproblemcnt = i4 WITH noconstant(0), protect
 DECLARE ifavoritecnt = i4 WITH noconstant(0), protect
 DECLARE idiagnosissize = i4 WITH protect, noconstant(0)
 DECLARE iproblemsize = i4 WITH protect, noconstant(0)
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
  FROM diagnosis d,
   nomenclature n1,
   cmt_term_map ctm,
   nomenclature n2
  PLAN (d)
   JOIN (n1
   WHERE ((n1.nomenclature_id=d.originating_nomenclature_id) OR (d.originating_nomenclature_id <= 0.0
    AND n1.nomenclature_id=d.nomenclature_id))
    AND n1.active_ind=1
    AND n1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dicd9 > 0.0
    AND n1.source_vocabulary_cd=dicd9) OR (dsnmct > 0.0
    AND n1.source_vocabulary_cd=dsnmct)) )
   JOIN (ctm
   WHERE ctm.target_cmti=n1.cmti)
   JOIN (n2
   WHERE n2.cmti=ctm.cmti
    AND n2.active_ind=1
    AND n2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dimo > 0.0
    AND n2.source_vocabulary_cd=dimo) OR (dhli > 0.0
    AND n2.source_vocabulary_cd=dhli)) )
  HEAD REPORT
   idiagnosiscnt = 0, stat = alterlist(diagnosis->diagnosis,ibatchsize), idiagnosissize = ibatchsize
  DETAIL
   IF (((n1.source_vocabulary_cd=dicd9
    AND n2.source_vocabulary_cd=dimo) OR (n1.source_vocabulary_cd=dsnmct
    AND n2.source_vocabulary_cd=dhli)) )
    idiagnosiscnt = (idiagnosiscnt+ 1)
    IF (idiagnosiscnt > idiagnosissize)
     idiagnosissize = (idiagnosiscnt+ (ibatchsize - 1)), stat = alterlist(diagnosis->diagnosis,
      idiagnosissize)
    ENDIF
    diagnosis->diagnosis[idiagnosiscnt].diagnosis_id = d.diagnosis_id, diagnosis->diagnosis[
    idiagnosiscnt].new_orig_nomen_id = n2.nomenclature_id
   ENDIF
  FOOT REPORT
   stat = alterlist(diagnosis->diagnosis,idiagnosiscnt), idiagnosissize = idiagnosiscnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail:Failed to select diagnosis_id's from diagnosis",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n1,
   cmt_term_map ctm,
   nomenclature n2
  PLAN (p)
   JOIN (n1
   WHERE ((n1.nomenclature_id=p.originating_nomenclature_id) OR (p.originating_nomenclature_id <= 0.0
    AND n1.nomenclature_id=p.nomenclature_id))
    AND n1.active_ind=1
    AND n1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dicd9 > 0.0
    AND n1.source_vocabulary_cd=dicd9) OR (dsnmct > 0.0
    AND n1.source_vocabulary_cd=dsnmct)) )
   JOIN (ctm
   WHERE ctm.target_cmti=n1.cmti)
   JOIN (n2
   WHERE n2.cmti=ctm.cmti
    AND n2.active_ind=1
    AND n2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dimo > 0.0
    AND n2.source_vocabulary_cd=dimo) OR (dhli > 0.0
    AND n2.source_vocabulary_cd=dhli)) )
  HEAD REPORT
   iproblemcnt = 0, stat = alterlist(problem->problem,ibatchsize), iproblemsize = ibatchsize
  DETAIL
   IF (((n1.source_vocabulary_cd=dicd9
    AND n2.source_vocabulary_cd=dimo) OR (n1.source_vocabulary_cd=dsnmct
    AND n2.source_vocabulary_cd=dhli)) )
    iproblemcnt = (iproblemcnt+ 1)
    IF (iproblemcnt > iproblemsize)
     iproblemsize = (iproblemcnt+ (ibatchsize - 1)), stat = alterlist(problem->problem,iproblemsize)
    ENDIF
    problem->problem[iproblemcnt].problem_instance_id = p.problem_instance_id, problem->problem[
    iproblemcnt].new_orig_nomen_id = n2.nomenclature_id
   ENDIF
  FOOT REPORT
   stat = alterlist(problem->problem,iproblemcnt), iproblemsize = iproblemcnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail:Failed to select problem_instance_id's from problem",errmsg
   )
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
    AND ((dicd9 > 0.0
    AND n1.source_vocabulary_cd=dicd9) OR (dsnmct > 0.0
    AND n1.source_vocabulary_cd=dsnmct)) )
   JOIN (ctm
   WHERE ctm.target_cmti=n1.cmti)
   JOIN (n2
   WHERE n2.cmti=ctm.cmti
    AND n2.active_ind=1
    AND n2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dimo > 0.0
    AND n2.source_vocabulary_cd=dimo) OR (dhli > 0.0
    AND n2.source_vocabulary_cd=dhli)) )
  HEAD REPORT
   ifavoritecnt = 0, stat = alterlist(favorite->favorite,ibatchsize), ifavoritesize = ibatchsize
  DETAIL
   IF (((n1.source_vocabulary_cd=dicd9
    AND n2.source_vocabulary_cd=dimo) OR (n1.source_vocabulary_cd=dsnmct
    AND n2.source_vocabulary_cd=dhli)) )
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
  SET readme_data->message = concat("Fail:Failed to select problem_instance_id's from problem",errmsg
   )
  GO TO exit_script
 ENDIF
 IF (idiagnosiscnt > 0)
  UPDATE  FROM (dummyt d1  WITH seq = value(idiagnosiscnt)),
    diagnosis d
   SET d.originating_nomenclature_id = diagnosis->diagnosis[d1.seq].new_orig_nomen_id, d.updt_dt_tm
     = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
    d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
    .updt_cnt+ 1)
   PLAN (d1)
    JOIN (d
    WHERE (d.diagnosis_id=diagnosis->diagnosis[d1.seq].diagnosis_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update DIAGNOSIS table",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 IF (iproblemcnt > 0)
  UPDATE  FROM (dummyt d1  WITH seq = value(iproblemcnt)),
    problem p
   SET p.originating_nomenclature_id = problem->problem[d1.seq].new_orig_nomen_id, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
    .updt_cnt+ 1)
   PLAN (d1)
    JOIN (p
    WHERE (p.problem_instance_id=problem->problem[d1.seq].problem_instance_id))
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update PROBLEM table",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
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
 SET readme_data->message =
 "Success:  Readme dcp_upd_probdx_icd9_synonyms.prg completed successfully"
#exit_script
 FREE RECORD diagnosis
 FREE RECORD problem
 FREE RECORD favorite
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
