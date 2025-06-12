CREATE PROGRAM bbt_rdm_add_antigens:dba
 DECLARE insertresultentry(special_cd=f8,antigen_cd=f8) = null
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
 DECLARE serrormsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE lerrorcode = i4 WITH public, noconstant(0)
 DECLARE sreadme_name = c25 WITH constant("BBT_RDM_ADD_ANTIGENS")
 DECLARE sfield_name_pos = c15 WITH constant("Positive")
 DECLARE sfield_name_neg = c15 WITH constant("Negative")
 DECLARE sfield_name_res = c25 WITH constant("ResultEntry")
 DECLARE sfield_name_ops = c25 WITH constant("Opposite")
 DECLARE special_testing_cs = i4 WITH protect, constant(1612)
 DECLARE antigen_type_cs = i4 WITH protect, constant(4502006)
 DECLARE cv_cnt = i4 WITH noconstant(0)
 DECLARE ant_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE antigen_cd_1 = f8 WITH noconstant(0.0)
 DECLARE special_cd_1 = f8 WITH noconstant(0.0)
 DECLARE special_cd_2 = f8 WITH noconstant(0.0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script BBT_RDM_ADD_ANTIGENS..."
 FREE RECORD request
 RECORD request(
   1 code_set = i4
   1 qual[*]
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 authentic_ind = i2
     2 extension_cnt = i4
     2 extension_data[*]
       3 field_name = c32
       3 field_type = i4
       3 field_value = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 qual[1]
     2 code_value = f8
     2 display_key = c40
     2 rec_status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning, cv.display,
  cv.display_key, cv.description, cv.definition,
  cv.collation_seq, cv.active_type_cd, cv.active_ind,
  cve.field_value
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=special_testing_cs
    AND cv.code_value > 0.0
    AND cv.cdf_meaning="+"
    AND cv.display="*+"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cve
   WHERE  NOT ( EXISTS (
   (SELECT
    "x"
    FROM code_value_extension cve1
    WHERE cve1.code_set=antigen_type_cs
     AND cve1.field_name IN (sfield_name_pos, sfield_name_neg)
     AND cve1.field_value=cnvtstring(cve.code_value))))
    AND cve.code_value=cv.code_value
    AND cve.code_set=special_testing_cs
    AND cve.field_name=sfield_name_ops)
  ORDER BY cv.code_value
  HEAD REPORT
   cv_cnt = 0, stat = alterlist(request->qual,10), request->code_set = antigen_type_cs
  HEAD cv.code_value
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1
    AND cv_cnt != 1)
    stat = alterlist(request->qual,(cv_cnt+ 9))
   ENDIF
   request->qual[cv_cnt].display = replace(cv.display,"+","",2), request->qual[cv_cnt].display_key =
   cv.display_key, request->qual[cv_cnt].description = request->qual[cv_cnt].display,
   request->qual[cv_cnt].definition = request->qual[cv_cnt].display, request->qual[cv_cnt].
   collation_seq = cv.collation_seq, request->qual[cv_cnt].active_type_cd = cv.active_type_cd,
   request->qual[cv_cnt].active_ind = 1, request->qual[cv_cnt].authentic_ind = 1, request->qual[
   cv_cnt].extension_cnt = 2
  DETAIL
   stat = alterlist(request->qual[cv_cnt].extension_data,request->qual[cv_cnt].extension_cnt),
   request->qual[cv_cnt].extension_data[1].field_name = sfield_name_pos, request->qual[cv_cnt].
   extension_data[1].field_type = 1,
   request->qual[cv_cnt].extension_data[1].field_value = cnvtstring(cv.code_value), request->qual[
   cv_cnt].extension_data[2].field_name = sfield_name_neg, request->qual[cv_cnt].extension_data[2].
   field_type = 1,
   request->qual[cv_cnt].extension_data[2].field_value = cve.field_value
  FOOT REPORT
   stat = alterlist(request->qual,cv_cnt)
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode != 0)
  SET readme_data->message = concat("Error selecting from the code_value table: ",serrormsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->message = "No results from the code_value table."
  SET readme_data->status = "S"
  GO TO exit_script
 ENDIF
 EXECUTE cs_add_code
 IF ((reply->status_data.status != "S"))
  ROLLBACK
  SET readme_data->message = build("Error inserting code values to codeset 4502006")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_set_extension cse
  WHERE cse.code_set=special_testing_cs
   AND cse.field_name=sfield_name_res
  WITH nocounter
 ;end select
 SET lerrorcode = error(serrormsg,0)
 IF (lerrorcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find ResultEntry: ",serrormsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->message = "'ResultEntry' not found"
  GO TO exit_script
 ENDIF
 FOR (ant_cnt = 1 TO size(request->qual,5))
   SELECT DISTINCT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=antigen_type_cs
      AND cv.code_value > 0.0
      AND (cv.display=request->qual[ant_cnt].display)
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     antigen_cd_1 = cv.code_value
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,0)
   IF (lerrorcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find antigen_cd: ",serrormsg)
    GO TO exit_script
   ENDIF
   SET special_cd_1 = cnvtint(trim(request->qual[ant_cnt].extension_data[1].field_value))
   SET special_cd_2 = cnvtint(trim(request->qual[ant_cnt].extension_data[2].field_value))
   CALL insertresultentry(special_cd_1,antigen_cd_1)
   CALL insertresultentry(special_cd_2,antigen_cd_1)
 ENDFOR
 SUBROUTINE insertresultentry(special_cd,antigen_cd)
   DECLARE sfield_value = c25 WITH noconstant("")
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_set=special_testing_cs
      AND cve.code_value=special_cd
      AND cve.field_name=sfield_name_res
      AND cve.field_value != null)
    DETAIL
     sfield_value = cve.field_value
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,0)
   IF (lerrorcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to insert code_value_extension table: ",serrormsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0
    AND special_cd > 0.0)
    INSERT  FROM code_value_extension cve
     SET cve.code_value = special_cd, cve.field_name = sfield_name_res, cve.code_set =
      special_testing_cs,
      cve.field_type = 1, cve.field_value = cnvtstring(antigen_cd), cve.updt_applctx = 0,
      cve.updt_task = 0, cve.updt_cnt = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cve.updt_id = 0.0
     WITH nocounter
    ;end insert
   ELSEIF (size(trim(sfield_value),1)=0)
    UPDATE  FROM code_value_extension cve
     SET cve.field_type = 1, cve.field_value = cnvtstring(antigen_cd), cve.updt_applctx = 0,
      cve.updt_task = 0, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      cve.updt_id = 0.0
     WHERE cve.code_value=special_cd
      AND cve.field_name=sfield_name_res
      AND cve.code_set=special_testing_cs
     WITH nocounter
    ;end update
   ENDIF
   SET lerrorcode = error(serrormsg,0)
   IF (lerrorcode != 0)
    ROLLBACK
    SET readme_data->message = concat("Failed to insert/update code_value_extension table: ",
     serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->message = "Readme successful: Tables updated successfully"
 SET readme_data->status = "S"
 COMMIT
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 FREE RECORD request
 FREE RECORD reply
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
