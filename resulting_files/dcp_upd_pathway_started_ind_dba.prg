CREATE PROGRAM dcp_upd_pathway_started_ind:dba
 SET modify = predeclare
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = c100
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 mrn = c100
     2 pathway_id = f8
     2 encntr_id = f8
     2 description = c100
     2 start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
 )
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
 SET readme_data->message = "Failed - Starting DCP_UPD_PATHWAY_STARTED_IND.PRG script"
 DECLARE stat = i2
 DECLARE berror = i2
 DECLARE errorcode = i4
 DECLARE ncommits = i4
 DECLARE nrows = i4
 DECLARE ncnt = i4
 DECLARE pathway_status_cs = i4
 DECLARE encntr_alias_cs = i4
 DECLARE person_alias_cs = i4
 DECLARE initiated_status_cd = f8
 DECLARE completed_status_cd = f8
 DECLARE dc_status_cd = f8
 DECLARE encntr_mrn_type_cd = f8
 DECLARE person_mrn_type_cd = f8
 DECLARE careplan_type_mean = c12
 DECLARE phase_type_mean = c12
 DECLARE subphase_type_mean = c12
 DECLARE filename = c50
 DECLARE name_full_formatted = c100
 DECLARE description = c100
 DECLARE errormsg = c132
 SET filename = "DCP_UPD_PATHWAY_STARTED_IND"
 SET careplan_type_mean = "CAREPLAN"
 SET phase_type_mean = "PHASE"
 SET subphase_type_mean = "SUBPHASE"
 SET name_full_formatted = fillstring(100," ")
 SET description = fillstring(100," ")
 SET errormsg = fillstring(132," ")
 SET errorcode = 1
 SET berror = 0
 SET stat = 0
 SET nrows = 0
 SET ncnt = 0
 SET pathway_status_cs = 16769
 SET encntr_alias_cs = 319
 SET person_alias_cs = 4
 SET initiated_status_cd = 0.0
 SET completed_status_cd = 0.0
 SET dc_status_cd = 0.0
 SET encntr_mrn_type_cd = 0.0
 SET person_mrn_type_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=pathway_status_cs
   AND cv.cdf_meaning IN ("COMPLETED", "DISCONTINUED", "INITIATED")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "COMPLETED":
     completed_status_cd = cv.code_value
    OF "DISCONTINUED":
     dc_status_cd = cv.code_value
    OF "INITIATED":
     initiated_status_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=encntr_alias_cs
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  DETAIL
   encntr_mrn_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=person_alias_cs
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  DETAIL
   person_mrn_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway pw,
   pathway_action pwa,
   person p
  PLAN (pw
   WHERE pw.pw_status_cd IN (dc_status_cd, completed_status_cd)
    AND pw.started_ind=0
    AND pw.pw_group_nbr > 0)
   JOIN (pwa
   WHERE pwa.pathway_id=pw.pathway_id
    AND pwa.pw_status_cd=initiated_status_cd)
   JOIN (p
   WHERE p.person_id=pw.person_id)
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(data->qual,5))
    stat = alterlist(data->qual,(ncnt+ 50))
   ENDIF
   data->qual[ncnt].person_id = pw.person_id, data->qual[ncnt].pathway_id = pw.pathway_id, data->
   qual[ncnt].encntr_id = pw.encntr_id,
   data->qual[ncnt].start_dt_tm = pw.start_dt_tm, data->qual[ncnt].calc_end_dt_tm = pw.calc_end_dt_tm
   IF (pw.type_mean=careplan_type_mean)
    data->qual[ncnt].description = concat(trim(pw.description))
   ELSEIF (pw.type_mean=phase_type_mean)
    data->qual[ncnt].description = concat(trim(pw.pw_group_desc)," - ",trim(pw.description))
   ELSEIF (pw.type_mean=subphase_type_mean)
    data->qual[ncnt].description = concat(trim(pw.pw_group_desc)," - ",trim(pw.parent_phase_desc),
     " - ",trim(pw.description))
   ENDIF
   data->qual[ncnt].name_full_formatted = p.name_full_formatted, data->qual[ncnt].birth_dt_tm = p
   .birth_dt_tm, data->qual[ncnt].birth_tz = p.birth_tz
  FOOT REPORT
   IF (ncnt < size(data->qual,5))
    stat = alterlist(data->qual,ncnt)
   ENDIF
  WITH nocounter
 ;end select
 SET nrows = size(data->qual,5)
 IF (nrows > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(data->qual,5))),
    encntr_alias ea,
    person_alias pa
   PLAN (d)
    JOIN (ea
    WHERE (ea.encntr_id=data->qual[d.seq].encntr_id)
     AND ea.encntr_alias_type_cd=encntr_mrn_type_cd)
    JOIN (pa
    WHERE (pa.person_id=data->qual[d.seq].person_id)
     AND pa.person_alias_type_cd=person_mrn_type_cd)
   DETAIL
    IF (ea.alias != "")
     data->qual[d.seq].mrn = ea.alias
    ELSEIF (pa.alias != "")
     data->qual[d.seq].mrn = pa.alias
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO value(filename)
   name_full_formatted = data->qual[d.seq].name_full_formatted, birth_dt_tm = format(cnvtdatetimeutc(
     datetimezone(data->qual[d.seq].birth_dt_tm,data->qual[d.seq].birth_tz),1),"@SHORTDATE"), mrn =
   data->qual[d.seq].mrn,
   description = data->qual[d.seq].description, start_dt_tm = format(data->qual[d.seq].start_dt_tm,
    "@SHORTDATETIME"), calc_end_dt_tm = format(data->qual[d.seq].calc_end_dt_tm,"@SHORTDATETIME")
   FROM (dummyt d  WITH seq = value(size(data->qual,5)))
   ORDER BY name_full_formatted, mrn, description
   HEAD REPORT
    row 0
   HEAD name_full_formatted
    person_info = fillstring(120," ")
   HEAD mrn
    person_info = build(trim(data->qual[d.seq].name_full_formatted),", DOB-",birth_dt_tm,", MRN-",
     trim(data->qual[d.seq].mrn)), col 0, person_info
   DETAIL
    plan_info = fillstring(120," "), plan_dt_tm = fillstring(120," "), plan_info = build(trim(data->
      qual[d.seq].description),", "),
    plan_dt_tm = build(start_dt_tm,"-",calc_end_dt_tm), row + 1, col 5,
    plan_info, row + 1, col 10,
    plan_dt_tm
   FOOT  mrn
    row + 2
   WITH nocounter
  ;end select
  FOR (ncnt = 1 TO nrows)
   UPDATE  FROM pathway pw
    SET pw.started_ind = 1, pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_id = reqinfo->
     updt_id,
     pw.updt_task = reqinfo->updt_task, pw.updt_cnt = (pw.updt_cnt+ 1)
    WHERE (pw.pathway_id=data->qual[ncnt].pathway_id)
   ;end update
   IF (((mod(ncnt,500)=0) OR (ncnt=nrows)) )
    WHILE (errorcode != 0)
     SET errorcode = error(errormsg,0)
     IF (errorcode != 0)
      ROLLBACK
      SET berror = 1
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed - Error occurred while updating PATHWAY: ",trim(
        errormsg))
      GO TO exit_program
     ENDIF
    ENDWHILE
    IF ((reqinfo->commit_ind=1))
     COMMIT
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
#exit_program
 FREE RECORD data
 IF (berror=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success - All required pathway rows were updated successfully."
 ENDIF
 SET modify = nopredeclare
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SET last_mod = "001"
END GO
