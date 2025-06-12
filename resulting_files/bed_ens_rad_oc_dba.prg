CREATE PROGRAM bed_ens_rad_oc:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE specimen_type_cd = f8
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET specimen_type_cd = 0.0
 SET cnt = size(request->orderables,5)
 FOR (x = 1 TO cnt)
  IF ((request->orderables[x].accession.action_flag=2))
   SELECT INTO "nl:"
    FROM procedure_specimen_type p
    WHERE (p.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=2052
      AND cv.active_ind=1
      AND cdf_meaning="RADIOLOGY"
     DETAIL
      specimen_type_cd = cv.code_value
     WITH nocounter
    ;end select
    INSERT  FROM procedure_specimen_type p
     SET p.catalog_cd = request->orderables[x].code_value, p.specimen_type_cd = specimen_type_cd, p
      .default_collection_method_cd = 0,
      p.default_ind = null, p.accession_class_cd = request->orderables[x].accession.class_code_value,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_cnt = 0,
      p.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert orderable: ",trim(cnvtstring(request->
        orderables[x].code_value))," with accession class: ",trim(cnvtstring(request->orderables[x].
        accession.class_code_value))," into the procedure_specimen_type table.")
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM procedure_specimen_type p
     SET p.accession_class_cd = request->orderables[x].accession.class_code_value, p.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
      p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
      updt_applctx
     WHERE (p.catalog_cd=request->orderables[x].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update orderable: ",trim(cnvtstring(request->
        orderables[x].code_value))," with accession class: ",trim(cnvtstring(request->orderables[x].
        accession.class_code_value))," into the procedure_specimen_type table.")
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM accession_class a
    SET a.accession_format_cd = request->orderables[x].accession.format_code_value, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = reqinfo->
     updt_applctx
    WHERE (a.accession_class_cd=request->orderables[x].accession.class_code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update accession class: ",trim(cnvtstring(request->
       orderables[x].accession.class_code_value))," with accession format: ",trim(cnvtstring(request
       ->orderables[x].accession.format_code_value))," into the accession_class table.")
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->orderables[x].subactivity_type.action_flag=2))
   UPDATE  FROM order_catalog oc
    SET oc.activity_subtype_cd = request->orderables[x].subactivity_type.code_value, oc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
     oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->
     updt_applctx
    WHERE (oc.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update orderable: ",trim(cnvtstring(request->orderables[
       x].code_value))," with subactivity type: ",trim(cnvtstring(request->orderables[x].
       subactivity_type.code_value))," into the order_catalog table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.activity_subtype_cd = request->orderables[x].subactivity_type.code_value, ocs.updt_dt_tm
      = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
     ocs.updt_task = reqinfo->updt_task, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ocs.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update orderable: ",trim(cnvtstring(request->orderables[
       x].code_value))," with subactivity type: ",trim(cnvtstring(request->orderables[x].
       subactivity_type.code_value))," into the order_catalog_synonym table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->orderables[x].subactivity_type.action_flag=3))
   UPDATE  FROM order_catalog oc
    SET oc.activity_subtype_cd = 0, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id =
     reqinfo->updt_id,
     oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = reqinfo->
     updt_applctx
    WHERE (oc.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to delete subactivity type: ",trim(cnvtstring(request->
       orderables[x].subactivity_type.code_value))," from orderable: ",trim(cnvtstring(request->
       orderables[x].code_value))," into the order_catalog table.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.activity_subtype_cd = 0, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id =
     reqinfo->updt_id,
     ocs.updt_task = reqinfo->updt_task, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ocs.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to delete subactivity type: ",trim(cnvtstring(request->
       orderables[x].subactivity_type.code_value))," from orderable: ",trim(cnvtstring(request->
       orderables[x].code_value))," into the order_catalog_synonym table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
