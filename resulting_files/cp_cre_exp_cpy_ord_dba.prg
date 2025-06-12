CREATE PROGRAM cp_cre_exp_cpy_ord:dba
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
 DECLARE order_doc_cd = f8 WITH noconstant(0.0)
 DECLARE size_params = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 SELECT INTO "nl:"
  di.info_name
  FROM dm_info di
  WHERE di.info_domain="EXP - UPD ORDDOC"
   AND di.info_name="1"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("in dminfo")
  SET x = 1
  SET failed = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=333
   AND cv.cdf_meaning="ORDERDOC"
   AND cv.active_ind=1
  HEAD REPORT
   order_doc_cd = cv.code_value
  WITH nocounter
 ;end select
 FREE RECORD param_rec
 RECORD param_rec(
   1 qual[*]
     2 param_id = f8
     2 dup_ind = i2
 )
 UPDATE  FROM expedite_params ep
  SET ep.copy_ind = 1
  WHERE ep.output_flag=6
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  ep.expedite_params_id, ec.expedite_params_id, ec.encntr_prsnl_r_cd
  FROM expedite_params ep,
   expedite_copy ec
  PLAN (ep
   WHERE ep.output_flag=6)
   JOIN (ec
   WHERE ec.expedite_params_id=outerjoin(ep.expedite_params_id))
  ORDER BY ep.expedite_params_id
  HEAD REPORT
   param_cnt = 0, param = 0
  DETAIL
   IF (ep.expedite_params_id != param)
    param_cnt = (param_cnt+ 1)
    IF (mod(param_cnt,10)=1)
     stat = alterlist(param_rec->qual,(param_cnt+ 9))
    ENDIF
    param_rec->qual[param_cnt].param_id = ep.expedite_params_id
    IF (ec.encntr_prsnl_r_cd=order_doc_cd)
     param_rec->qual[param_cnt].dup_ind = 1
    ENDIF
   ELSEIF (ec.encntr_prsnl_r_cd=order_doc_cd)
    param_rec->qual[param_cnt].dup_ind = 1
   ENDIF
   param = ep.expedite_params_id
  FOOT REPORT
   stat = alterlist(param_rec->qual,param_cnt)
  WITH nocounter
 ;end select
 SET size_params = size(param_rec->qual,5)
 IF (size_params=0)
  SET failed = "Z"
  GO TO exit_script
 ENDIF
 INSERT  FROM expedite_copy ec,
   (dummyt d  WITH seq = value(size_params))
  SET ec.expedite_params_id = param_rec->qual[d.seq].param_id, ec.encntr_prsnl_r_cd = order_doc_cd,
   ec.updt_applctx = 0,
   ec.updt_task = 0, ec.updt_id = 0, ec.updt_cnt = 0,
   ec.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (param_rec->qual[d.seq].dup_ind != 1))
   JOIN (ec)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "Z"
  GO TO exit_script
 ENDIF
#exit_script
 IF (x=0)
  CALL echo("in insert")
  INSERT  FROM dm_info di
   SET di.info_domain = "EXP - UPD ORDDOC", di.info_name = "1", di.info_date = cnvtdatetime(curdate,
     curtime3),
    di.updt_id = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 0,
    di.updt_applctx = 0, di.updt_cnt = 1
   WITH nocounter
  ;end insert
 ENDIF
 IF (failed="Z")
  SET readme_data->message = "No rows to add to expedite_copy - ZERO ROWS"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("ZERO ROWS")
  COMMIT
 ELSE
  SET readme_data->message = "Successfully added expedite_copy rows - SUCCESSFUL"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  CALL echo("SUCCESSFUL")
  COMMIT
 ENDIF
END GO
