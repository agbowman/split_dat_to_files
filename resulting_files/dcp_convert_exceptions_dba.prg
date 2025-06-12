CREATE PROGRAM dcp_convert_exceptions:dba
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
 SET readme_data->message = "Readme Failed:  Starting script dcp_convert_exceptions"
 DECLARE findtargetrows(null) = null
 DECLARE findeventsetcodevalue(null) = null
 DECLARE attachexceptionentityname(i4) = null
 DECLARE updateexceptiongroupsforprivmaintcompatibility(null) = null
 DECLARE err_msg = vc WITH protect, noconstant("")
 FREE RECORD valid_records
 RECORD valid_records(
   1 qual[*]
     2 exception_type_cd = f8
     2 log_grouping_cd = f8
     2 log_grouping_comp_cd = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
     2 item_cd = f8
     2 dup_ind = i4
 )
 CALL findtargetrows(null)
 CALL findeventsetcodevalue(null)
 CALL updateexceptiongroupsforprivmaintcompatibility(null)
 GO TO endscript
 SUBROUTINE findtargetrows(null)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM log_group_entry lge,
     logical_grouping lg,
     code_value cv
    PLAN (lge
     WHERE lge.exception_type_cd=0
      AND trim(lge.exception_entity_name)=null)
     JOIN (lg
     WHERE lg.log_grouping_cd=lge.log_grouping_cd)
     JOIN (cv
     WHERE cv.code_value=lg.comp_type_cd
      AND cv.active_ind=1
      AND cv.code_set=6015)
    DETAIL
     IF (lg.comp_type_cd > 0
      AND trim(cv.cdf_meaning) != null)
      loop_counter = (loop_counter+ 1)
      IF (((loop_counter=1) OR (mod(loop_counter,100)=1)) )
       stat = alterlist(valid_records->qual,(loop_counter+ 99))
      ENDIF
      valid_records->qual[loop_counter].exception_type_cd = lg.comp_type_cd, valid_records->qual[
      loop_counter].log_grouping_cd = lg.log_grouping_cd, valid_records->qual[loop_counter].
      log_grouping_comp_cd = lge.log_grouping_comp_cd,
      valid_records->qual[loop_counter].exception_entity_name = cv.cdf_meaning, valid_records->qual[
      loop_counter].item_cd = lge.item_cd, valid_records->qual[loop_counter].event_set_name = lge
      .event_set_name,
      valid_records->qual[loop_counter].dup_ind = 0,
      CALL attachexceptionentityname(loop_counter)
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(valid_records->qual,loop_counter)
   IF (error(err_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindTargetRows: ",err_msg)
    GO TO endscript
   ENDIF
 END ;Subroutine
 SUBROUTINE findeventsetcodevalue(null)
  SELECT INTO "NL:"
   FROM code_value cv,
    (dummyt d  WITH seq = value(size(valid_records->qual,5)))
   PLAN (d
    WHERE (valid_records->qual[d.seq].item_cd=0)
     AND (valid_records->qual[d.seq].exception_entity_name="V500_EVENT_SET_CODE"))
    JOIN (cv
    WHERE cv.code_set=93
     AND cv.active_ind=1
     AND cnvtupper(cv.display)=cnvtupper(valid_records->qual[d.seq].event_set_name))
   DETAIL
    valid_records->qual[d.seq].dup_ind = (valid_records->qual[d.seq].dup_ind+ 1), valid_records->
    qual[d.seq].item_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (error(err_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("FindEventSetCodeValue: ",err_msg)
   GO TO endscript
  ENDIF
 END ;Subroutine
 SUBROUTINE attachexceptionentityname(i)
   IF ((valid_records->qual[i].exception_entity_name != "")
    AND (valid_records->qual[i].exception_type_cd != 0))
    SET tmp_entity_name = valid_records->qual[i].exception_entity_name
    IF (tmp_entity_name="ACTIVITYTYPE")
     SET valid_records->qual[i].exception_entity_name = "ACTIVITY TYPE"
    ELSEIF (tmp_entity_name="CASETYPE")
     SET valid_records->qual[i].exception_entity_name = "CASE TYPE"
    ELSEIF (((tmp_entity_name="CATALOGTYPE") OR (tmp_entity_name="CASECATEGORY")) )
     SET valid_records->qual[i].exception_entity_name = "CATALOG TYPE"
    ELSEIF (tmp_entity_name="CLASSIFICATI")
     SET valid_records->qual[i].exception_entity_name = "CLASSIFICATION"
    ELSEIF (tmp_entity_name="CONTENTTYPE")
     SET valid_records->qual[i].exception_entity_name = "CONTENT TYPE"
    ELSEIF (tmp_entity_name="DOCUMENTTYPE")
     SET valid_records->qual[i].exception_entity_name = "DOCUMENTTYPE"
    ELSEIF (tmp_entity_name="LOCATIONS")
     SET valid_records->qual[i].exception_entity_name = "LOCATIONS"
    ELSEIF (tmp_entity_name="OPERATIONS")
     SET valid_records->qual[i].exception_entity_name = "OPERATIONS"
    ELSEIF (tmp_entity_name="NOMENCLATURE")
     SET valid_records->qual[i].exception_entity_name = "NOMENCLATURE"
    ELSEIF (tmp_entity_name="PLANTYPECODE")
     SET valid_records->qual[i].exception_entity_name = "PLAN TYPE CODE"
    ELSEIF (tmp_entity_name="POWERFORMS")
     SET valid_records->qual[i].exception_entity_name = "POWERFORMS"
    ELSEIF (tmp_entity_name="EVENTCODES")
     SET valid_records->qual[i].exception_entity_name = "V500_EVENT_CODE"
    ELSEIF (tmp_entity_name="EVENTSETS")
     SET valid_records->qual[i].exception_entity_name = "V500_EVENT_SET_CODE"
    ELSEIF (((tmp_entity_name="SURGCATATYPE") OR (tmp_entity_name="ORDERABLES")) )
     SET valid_records->qual[i].exception_entity_name = "ORDER CATALOG"
    ELSE
     SET valid_records->qual[i].exception_entity_name = "CODE_VALUE"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updateexceptiongroupsforprivmaintcompatibility(null)
  UPDATE  FROM log_group_entry lge,
    (dummyt d  WITH seq = value(size(valid_records->qual,5)))
   SET lge.exception_type_cd = valid_records->qual[d.seq].exception_type_cd, lge
    .exception_entity_name = valid_records->qual[d.seq].exception_entity_name, lge.item_cd =
    valid_records->qual[d.seq].item_cd,
    lge.updt_dt_tm = cnvtdatetime(curdate,curtime3), lge.updt_cnt = (lge.updt_cnt+ 1), lge.updt_id =
    reqinfo->updt_id,
    lge.updt_task = 5058, lge.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (valid_records->qual[d.seq].item_cd > 0)
     AND (valid_records->qual[d.seq].dup_ind <= 1))
    JOIN (lge
    WHERE (lge.log_grouping_comp_cd=valid_records->qual[d.seq].log_grouping_comp_cd))
   WITH nocounter
  ;end update
  IF (error(err_msg,0) != 0)
   CALL echo("Readme Failed: Could not update the rows in log_group_entry table")
   SET readme_data->message = concat(
    "Readme Failed: Could not update the rows in log_group_entry table ",err_msg)
   SET readme_data->status = "F"
   ROLLBACK
  ELSE
   COMMIT
   CALL echo(build("Updated rows/Defective Rows ",curqual,"/",value(size(valid_records->qual,5))))
   SET readme_data->message = "Update successful."
   SET readme_data->status = "S"
  ENDIF
 END ;Subroutine
#endscript
 FREE RECORD valid_records
 CALL echorecord(readme_data)
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
END GO
