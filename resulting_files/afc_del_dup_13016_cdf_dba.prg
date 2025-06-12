CREATE PROGRAM afc_del_dup_13016_cdf:dba
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
 FREE SET meanings
 RECORD meanings(
   1 meanings[*]
     2 code_value = f8
     2 meaning = c12
 )
 SET readme_data->message = "Finding duplicate code values."
 SET dup_count = 0
 SELECT INTO "nl:"
  cv.cdf_meaning, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.active_ind=1
  ORDER BY cv.cdf_meaning, cv.updt_dt_tm
  HEAD cv.cdf_meaning
   firsttime = 1
  DETAIL
   IF (firsttime=0)
    dup_count = (dup_count+ 1), stat = alterlist(meanings->meanings,dup_count), meanings->meanings[
    dup_count].meaning = cv.cdf_meaning,
    meanings->meanings[dup_count].code_value = cv.code_value
   ENDIF
   firsttime = 0
  WITH nocounter
 ;end select
 IF (dup_count > 0)
  SET readme_data->message = "Now inactivate the duplicate cdf_meaning."
  UPDATE  FROM code_value cv,
    (dummyt d1  WITH seq = value(size(meanings->meanings,5)))
   SET cv.active_ind = 0, cv.inactive_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_dt_tm =
    cnvtdatetime(curdate,curtime)
   PLAN (d1)
    JOIN (cv
    WHERE (cv.code_value=meanings->meanings[d1.seq].code_value))
  ;end update
  COMMIT
  SET readme_data->message = "Now update the bill items."
  SET code_value = 0.0
  FOR (i = 1 TO value(size(meanings->meanings,5)))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=13016
      AND (cv.cdf_meaning=meanings->meanings[i].meaning)
      AND cv.active_ind=1
     DETAIL
      code_value = cv.code_value
     WITH nocounter
    ;end select
    UPDATE  FROM bill_item b,
      (dummyt d1  WITH seq = value(size(meanings->meanings,5)))
     SET b.ext_parent_contributor_cd = code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime)
     PLAN (d1)
      JOIN (b
      WHERE (b.ext_parent_contributor_cd=meanings->meanings[i].code_value))
    ;end update
    UPDATE  FROM bill_item b,
      (dummyt d1  WITH seq = value(size(meanings->meanings,5)))
     SET b.ext_child_contributor_cd = code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime)
     PLAN (d1)
      JOIN (b
      WHERE (b.ext_child_contributor_cd=meanings->meanings[i].code_value))
    ;end update
  ENDFOR
  COMMIT
 ENDIF
 SET dup_count = 0
 SELECT INTO "nl:"
  cv.cdf_meaning, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.active_ind=1
  ORDER BY cv.cdf_meaning, cv.updt_dt_tm
  HEAD cv.cdf_meaning
   firsttime = 1
  DETAIL
   IF (firsttime=0)
    dup_count = (dup_count+ 1), stat = alterlist(meanings->meanings,dup_count), meanings->meanings[
    dup_count].meaning = cv.cdf_meaning,
    meanings->meanings[dup_count].code_value = cv.code_value
   ENDIF
   firsttime = 0
  WITH nocounter
 ;end select
 IF (dup_count > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Duplicates still exist."
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "No more duplicates."
 ENDIF
 EXECUTE dm_readme_status
END GO
