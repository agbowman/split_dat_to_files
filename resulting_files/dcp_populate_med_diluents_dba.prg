CREATE PROGRAM dcp_populate_med_diluents:dba
 SET modify = predeclare
 RECORD request(
   1 description = c50
   1 security_flag = i4
   1 list_type = i4
   1 alt_sel_category_id = f8
   1 qual[*]
     2 event_cd = f8
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = vc WITH private, noconstant(" ")
 DECLARE failed = c1
 DECLARE mnemonictypecd = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE count1 = i4
 SET failed = "F"
 SET count1 = 0
 SET request->description = "IVPB_CHARTING_DILUENTS"
 SET request->security_flag = 1
 SET request->list_type = 2
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  WHERE (a.short_description=request->description)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Category already exists")
  SET reply->status_data.status = "S"
  GO TO exit_script
 ELSE
  SELECT DISTINCT INTO "nl:"
   cv.code_value
   FROM code_value cv,
    order_catalog_synonym ocs,
    code_value_event_r cve
   PLAN (cv
    WHERE cv.display IN ("Dextrose 5%", "D5W", "NaCl 0.9%", "Sodium Chloride 0.9%",
    "Normal Saline",
    "NS")
     AND cv.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=cv.code_value
     AND ocs.active_ind=1
     AND ocs.mnemonic_type_cd=mnemonictypecd)
    JOIN (cve
    WHERE cve.parent_cd=ocs.catalog_cd)
   ORDER BY cv.code_value
   HEAD REPORT
    count1 = 0
   HEAD cv.code_value
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(request->qual,(count1+ 9))
    ENDIF
    request->qual[count1].synonym_id = ocs.synonym_id, request->qual[count1].event_cd = cve.event_cd
   FOOT REPORT
    stat = alterlist(request->qual,count1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Synonyms not found")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    request->alt_sel_category_id = cnvtreal(y)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Error while generating reference_seq")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  INSERT  FROM alt_sel_cat a
   SET a.alt_sel_category_id = request->alt_sel_category_id, a.short_description = request->
    description, a.long_description = request->description,
    a.long_description_key_cap = request->description, a.child_cat_ind = 0, a.owner_id = reqinfo->
    updt_id,
    a.security_flag = request->security_flag, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a
    .updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
   WITH nocounter, dontexist
  ;end insert
  IF (curqual=0)
   CALL echo("Error while inserting category")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (loop = 1 TO value(size(request->qual,5)))
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     request->qual[loop].child_alt_sel_cat_id = cnvtreal(y)
    WITH nocounter
   ;end select
   INSERT  FROM alt_sel_list asl
    SET asl.alt_sel_category_id = request->alt_sel_category_id, asl.sequence = d.seq, asl.list_type
      = request->list_type,
     asl.synonym_id = request->qual[d.seq].synonym_id, asl.child_alt_sel_cat_id = request->qual[d.seq
     ].child_alt_sel_cat_id, asl.reference_task_id = 0.0,
     asl.updt_dt_tm = cnvtdatetime(curdate,curtime3), asl.updt_id = reqinfo->updt_id, asl.updt_task
      = reqinfo->updt_task,
     asl.updt_applctx = reqinfo->updt_applctx, asl.updt_cnt = 0
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual=0)
    CALL echo("Error while inserting diluents")
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  SET reply->status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status = "F"
 ENDIF
 SET last_mod = "002"
 SET modify = nopredeclare
END GO
