CREATE PROGRAM bed_ens_vvl_vv_by_syn:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 vv_relations[*]
     2 synonym_id = f8
     2 facility_cd = f8
     2 updt_count = i4
     2 updt_dt_tm = dq8
 )
 SET reply->status_data.status = "F"
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH noconstant(error(serrmsg,1))
 DECLARE error_flag = vc WITH noconstant("N")
 SET req_cnt = size(request->synonyms,5)
 FOR (x = 1 TO req_cnt)
  SET f_size = size(request->synonyms[x].facilities,5)
  IF (f_size > 0)
   SET insert_fac = 0
   SET insert_all_fac = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(f_size))
    PLAN (d
     WHERE (request->synonyms[x].facilities[d.seq].action_flag=1))
    ORDER BY d.seq
    HEAD d.seq
     IF ((request->synonyms[x].facilities[d.seq].all_facs_ind=1))
      insert_all_fac = 1
     ENDIF
     IF ((request->synonyms[x].facilities[d.seq].facility_code_value > 0))
      insert_fac = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(insert_all_fac)
   CALL echo(insert_fac)
   IF (insert_all_fac=1)
    DELETE  FROM ocs_facility_r o
     WHERE (o.synonym_id=request->synonyms[x].synonym_id)
     WITH nocounter
    ;end delete
   ENDIF
   IF (insert_fac=1)
    DELETE  FROM ocs_facility_r o
     WHERE (o.synonym_id=request->synonyms[x].synonym_id)
      AND o.facility_cd=0
     WITH nocounter
    ;end delete
   ENDIF
   SET ierrcode = 0
   DELETE  FROM ocs_facility_r ofr,
     (dummyt d  WITH seq = value(f_size))
    SET ofr.seq = 1
    PLAN (d
     WHERE (request->synonyms[x].facilities[d.seq].action_flag=3))
     JOIN (ofr
     WHERE (ofr.synonym_id=request->synonyms[x].synonym_id)
      AND (ofr.facility_cd=request->synonyms[x].facilities[d.seq].facility_code_value))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   INSERT  FROM ocs_facility_r ofr,
     (dummyt d  WITH seq = value(f_size))
    SET ofr.synonym_id = request->synonyms[x].synonym_id, ofr.facility_cd = request->synonyms[x].
     facilities[d.seq].facility_code_value, ofr.updt_applctx = reqinfo->updt_applctx,
     ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->updt_id,
     ofr.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->synonyms[x].facilities[d.seq].action_flag=1))
     JOIN (ofr)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
    PLAN (ocs
     WHERE (ocs.synonym_id=request->synonyms[x].synonym_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
