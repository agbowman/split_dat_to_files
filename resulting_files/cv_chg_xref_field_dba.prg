CREATE PROGRAM cv_chg_xref_field:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD short_name(
   1 list[*]
     2 xref_field_id = f8
     2 display_name = vc
 )
 DECLARE cxf_failure = c1 WITH private, noconstant("F")
 DECLARE file_nbr = i4 WITH private, noconstant(0)
 DECLARE position = i4 WITH private, noconstant(0)
 DECLARE dataset_internal_name = vc WITH private, noconstant(" ")
 SELECT INTO "nl:"
  dataset_internal_name = requestin->list_0[d.seq].dataset_name, file_nbr = trim(requestin->list_0[d
   .seq].file_nbr), field_internal_name = requestin->list_0[d.seq].field_internal_name,
  display_name = requestin->list_0[d.seq].display_name, position = cnvtint(requestin->list_0[d.seq].
   position), length = cnvtint(requestin->list_0[d.seq].length),
  start = cnvtint(requestin->list_0[d.seq].start)
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5))),
   cv_dataset cd,
   cv_xref cx,
   cv_xref_field cxf
  PLAN (d)
   JOIN (cd
   WHERE (cd.dataset_internal_name=requestin->list_0[d.seq].dataset_name))
   JOIN (cx
   WHERE cx.dataset_id=cd.dataset_id
    AND (cx.xref_internal_name=requestin->list_0[d.seq].field_internal_name))
   JOIN (cxf
   WHERE cxf.xref_id=cx.xref_id)
  ORDER BY dataset_internal_name, file_nbr, position
  HEAD REPORT
   fld_cnt = 0, stat = alterlist(short_name->list,10)
  DETAIL
   fld_cnt = (fld_cnt+ 1)
   IF (fld_cnt > size(short_name->list,5))
    stat = alterlist(short_name->list,(fld_cnt+ 9))
   ENDIF
   short_name->list[fld_cnt].xref_field_id = cxf.xref_field_id, short_name->list[fld_cnt].
   display_name = requestin->list_0[d.seq].display_name
  FOOT REPORT
   stat = alterlist(short_name->list,fld_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Check input data, cv_xref, cv_xref_field, Exit!")
  SET cxf_failure = "T"
  GO TO exit_script
 ELSE
  CALL echo("Data loading - successful!")
 ENDIF
 IF (size(short_name->list,5) > 0)
  UPDATE  FROM cv_xref_field cxf,
    (dummyt d  WITH seq = value(size(short_name->list,5)))
   SET cxf.display_name = short_name->list[d.seq].display_name, cxf.active_status_cd = reqdata->
    active_status_cd, cxf.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    cxf.active_status_prsnl_id = reqinfo->updt_id, cxf.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), cxf.updt_app = 0,
    cxf.updt_req = 0, cxf.updt_dt_tm = cnvtdatetime(curdate,curtime3), cxf.updt_cnt = (cxf.updt_cnt+
    1),
    cxf.updt_id = reqinfo->updt_id, cxf.updt_task = reqinfo->updt_task, cxf.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (short_name->list[d.seq].xref_field_id > 0))
    JOIN (cxf
    WHERE (cxf.xref_field_id=short_name->list[d.seq].xref_field_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("No records were updated in table cv_xref_field")
   SET cxf_failure = "T"
   GO TO exit_script
  ELSE
   CALL echo("Records were updated in table cv_xref_field")
  ENDIF
 ENDIF
#exit_script
 IF (cxf_failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
  CALL echo("Update Rollback!")
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
  CALL echo("Update commited!")
 ENDIF
END GO
