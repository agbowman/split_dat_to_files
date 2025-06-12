CREATE PROGRAM dm_code_value_alias:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 IF (size(dmrequest->cdf_meaning) > 12)
  SET cdf_meaning = substring(1,12,dmrequest->cdf_meaning)
 ELSE
  SET cdf_meaning = dmrequest->cdf_meaning
 ENDIF
 IF (size(dmrequest->display) > 40)
  SET display = substring(1,40,dmrequest->display)
 ELSE
  SET display = dmrequest->display
 ENDIF
 SET ret_code_value = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (cv.code_set=dmrequest->code_set)
   AND (cv.cki=dmrequest->cki)
  DETAIL
   ret_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET ret_contrib_cd = 0.00
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=73
   AND (cv.cki=dmrequest->contributor_source_cki)
  DETAIL
   ret_contrib_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET len = 0
  SET len = size(trim(dmrequest->alias_type_meaning),1)
  IF (len > 2)
   UPDATE  FROM code_value_alias cva
    SET cva.code_value = ret_code_value, cva.primary_ind = 1, cva.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_cnt = (cva.updt_cnt
     + 1),
     cva.updt_applctx = reqinfo->updt_applctx
    WHERE (cva.alias=dmrequest->alias)
     AND (cva.code_set=dmrequest->code_set)
     AND cva.contributor_source_cd=ret_contrib_cd
     AND (cva.alias_type_meaning=dmrequest->alias_type_meaning)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM code_value_alias cva
    SET cva.code_value = ret_code_value, cva.primary_ind = 1, cva.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_cnt = (cva.updt_cnt
     + 1),
     cva.updt_applctx = reqinfo->updt_applctx
    WHERE (cva.alias=dmrequest->alias)
     AND (cva.code_set=dmrequest->code_set)
     AND cva.contributor_source_cd=ret_contrib_cd
    WITH nocounter
   ;end update
  ENDIF
  IF (curqual=0)
   INSERT  FROM code_value_alias cva
    SET cva.code_value = ret_code_value, cva.primary_ind = 1, cva.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_cnt = 0,
     cva.updt_applctx = reqinfo->updt_applctx, cva.alias = dmrequest->alias, cva.code_set = dmrequest
     ->code_set,
     cva.contributor_source_cd = ret_contrib_cd, cva.alias_type_meaning = dmrequest->
     alias_type_meaning
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
