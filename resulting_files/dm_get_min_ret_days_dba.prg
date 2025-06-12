CREATE PROGRAM dm_get_min_ret_days:dba
 RECORD reply(
   1 min_day = i4
   1 qual[*]
     2 ret_criteria_id = i4
     2 min_days = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET value = 0
 SET min_value = 0
 SET cnt = 0
 SET cntp = 0
 SET index = 0
 SET index1 = 0
 SET index2 = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=18249
   AND cv.cdf_meaning="MINDAYS"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  drc.retention_days, drc.retention_criteria_id
  FROM dm_retention_criteria drc
  WHERE drc.criteria_type_cd=value
   AND drc.active_ind=1
  ORDER BY beg_effective_dt_tm DESC
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].ret_criteria_id = drc
   .retention_criteria_id,
   reply->qual[index].min_days = drc.retention_days
   IF (index=1)
    reply->min_day = reply->qual[index].min_days
   ENDIF
  WITH nocounter
 ;end select
 SET check = 0
 SET check = index
 IF (check=0)
  SELECT INTO "nl:"
   cve.field_value
   FROM code_value_extension cve
   WHERE cve.field_name="MIN_DAYS"
    AND cve.code_value=value
   DETAIL
    min_value = cnvtint(cve.field_value), reply->min_day = min_value
   WITH nocounter
  ;end select
  INSERT  FROM dm_retention_criteria drc
   SET drc.retention_criteria_id = seq(dm_retention_criteria_seq,nextval), drc.criteria_type_cd =
    value, drc.retention_days = min_value,
    drc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), drc.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), drc.organization_id = 0,
    drc.encntr_type_cd = 0, drc.event_cd = 0, drc.parent_ret_criteria_id = 0,
    drc.active_ind = 1
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET reply->status_data.status = "F"
   GO TO end_script
  ENDIF
 ENDIF
 WHILE (check > 1)
   FOR (cnt = 2 TO check)
     UPDATE  FROM dm_retention_criteria drc
      SET drc.active_ind = 0
      WHERE drc.criteria_type_cd=value
       AND drc.active_ind=1
       AND (drc.retention_criteria_id=reply->qual[cnt].ret_criteria_id)
      WITH nocounter
     ;end update
   ENDFOR
   SELECT INTO "nl:"
    drc.retention_days
    FROM dm_retention_criteria drc
    WHERE drc.criteria_type_cd=value
     AND drc.active_ind=1
     AND (drc.retention_criteria_id=reply->qual[1].ret_criteria_id)
    DETAIL
     reply->min_day = drc.retention_days
    WITH nocounter
   ;end select
   SET check = curqual
 ENDWHILE
 SET reply->status_data.status = "S"
 COMMIT
#end_script
END GO
