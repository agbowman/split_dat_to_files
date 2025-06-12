CREATE PROGRAM co_readme_diseasecat_correct:dba
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
 SET readme_data->message = "Readme Failed:  Starting script co_readme_diseasecat_correct..."
 DECLARE errmsg = vc WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 FREE RECORD ra_recs
 RECORD ra_recs(
   1 qual[*]
     2 risk_adjustment_id = f8
     2 admit_diagnosis_cd = f8
     2 disease_category_cd = f8
     2 admit_diagnosis = vc
     2 disease_category = vc
 )
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   code_value cv
  PLAN (ra
   WHERE ra.disease_category_cd=0.0
    AND ra.admit_diagnosis != null
    AND ra.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=28984
    AND cv.cdf_meaning=ra.admit_diagnosis
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ra_recs->qual,(cnt+ 9))
   ENDIF
   ra_recs->qual[cnt].risk_adjustment_id = ra.risk_adjustment_id, ra_recs->qual[cnt].
   admit_diagnosis_cd = cv.code_value, ra_recs->qual[cnt].admit_diagnosis = cv.display
  FOOT REPORT
   stat = alterlist(ra_recs->qual,cnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from risk_adjustment: ",errmsg)
  GO TO exit_script
 ENDIF
 DECLARE size_ra_recs = i4 WITH noconstant(size(ra_recs->qual,5))
 IF (size_ra_recs > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size_ra_recs),
    code_value_group cvg
   PLAN (d)
    JOIN (cvg
    WHERE (cvg.child_code_value=ra_recs->qual[d.seq].admit_diagnosis_cd))
   DETAIL
    ra_recs->qual[d.seq].disease_category_cd = cvg.parent_code_value
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to select from risk_adjustment/code_value_group: ",
    errmsg)
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
  ENDIF
  FOR (i = 1 TO size_ra_recs)
    UPDATE  FROM risk_adjustment ra
     SET ra.disease_category_cd = ra_recs->qual[i].disease_category_cd, ra.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ra.updt_cnt = (ra.updt_cnt+ 1),
      ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->
      updt_applctx
     WHERE (ra.risk_adjustment_id=ra_recs->qual[i].risk_adjustment_id)
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to update risk_adjustment: ",errmsg)
     GO TO exit_script
    ELSE
     SET readme_data->status = "S"
    ENDIF
  ENDFOR
 ELSE
  SET readme_data->status = "S"
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "Readme succeeded"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
