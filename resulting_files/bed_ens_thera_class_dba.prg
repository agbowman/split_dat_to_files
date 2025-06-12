CREATE PROGRAM bed_ens_thera_class:dba
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
 FREE SET temploc
 RECORD temploc(
   1 locations[*]
     2 action_flag = i2
     2 cms_critical_location_id = f8
     2 organization_id = f8
     2 location_cd = f8
     2 thera_classes[*]
       3 action_flag = i2
       3 thera_id = f8
     2 children[*]
       3 action_flag = i2
       3 cms_critical_location_id = f8
       3 organization_id = f8
       3 location_cd = f8
       3 thera_classes[*]
         4 action_flag = i2
         4 thera_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE location_size = i4 WITH protect
 DECLARE child_index = i4 WITH protect
 DECLARE child_size = i4 WITH protect
 DECLARE deleteparenttcs(deleteditems=i4) = null
 SET location_size = size(request->locations,5)
 IF (location_size=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = location_size)
  PLAN (d)
  ORDER BY d.seq
  HEAD REPORT
   stat = alterlist(temploc->locations,location_size)
  HEAD d.seq
   temploc->locations[d.seq].action_flag = 1, temploc->locations[d.seq].organization_id = request->
   locations[d.seq].organization_id, temploc->locations[d.seq].location_cd = request->locations[d.seq
   ].location_cd,
   stat = moverec(request->locations[d.seq].thera_classes,temploc->locations[d.seq].thera_classes)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to populate temp struct.")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = location_size),
   cms_critical_location cloc
  PLAN (d)
   JOIN (cloc
   WHERE (cloc.organization_id=temploc->locations[d.seq].organization_id)
    AND (cloc.location_cd=temploc->locations[d.seq].location_cd))
  DETAIL
   temploc->locations[d.seq].cms_critical_location_id = cloc.cms_critical_location_id, temploc->
   locations[d.seq].action_flag = 2
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to populate cms_critical_location_id.")
 IF ((request->is_facility=1))
  FOR (x = 0 TO location_size)
   IF ((temploc->locations[x].cms_critical_location_id=0))
    FREE SET list_request
    RECORD list_request(
      1 facility_code_value = f8
    )
    FREE SET list_reply
    RECORD list_reply(
      1 buildings[*]
        2 building_code_value = f8
        2 building_display = vc
        2 building_seq = i4
        2 units[*]
          3 unit_code_value = f8
          3 unit_display = vc
          3 unit_seq = i4
          3 type_code_value = f8
          3 type_mean = vc
          3 type_display = vc
          3 defined_ind = i2
          3 thera_classes[*]
            4 id = f8
            4 name = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET list_request->facility_code_value = temploc->locations[x].location_cd
    EXECUTE bed_get_thera_class_units  WITH replace("REQUEST",list_request), replace("REPLY",
     list_reply)
    IF ((list_reply->status_data.status="F"))
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     unit_cd = list_reply->buildings[d1.seq].units[d2.seq].unit_code_value
     FROM (dummyt d1  WITH seq = size(list_reply->buildings,5)),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(list_reply->buildings[d1.seq].units,5)))
      JOIN (d2)
     ORDER BY unit_cd
     HEAD REPORT
      child_index = 0, child_size = 0, stat = alterlist(temploc->locations[x].children,10)
     HEAD unit_cd
      child_size = (child_size+ 1), child_index = (child_index+ 1)
      IF (child_index=10)
       child_index = 0, stat = alterlist(temploc->locations[x].children,(child_size+ 10))
      ENDIF
      temploc->locations[x].children[child_size].cms_critical_location_id = 0, temploc->locations[x].
      children[child_size].action_flag = 1, temploc->locations[x].children[child_size].
      organization_id = temploc->locations[x].organization_id,
      temploc->locations[x].children[child_size].location_cd = list_reply->buildings[d1.seq].units[d2
      .seq].unit_code_value, stat = moverec(temploc->locations[x].thera_classes,temploc->locations[x]
       .children[child_size].thera_classes)
     FOOT REPORT
      stat = alterlist(temploc->locations[x].children,child_size)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error getting facility units.")
    IF (child_size > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = child_size),
       cms_critical_location cloc
      PLAN (d)
       JOIN (cloc
       WHERE (cloc.organization_id=temploc->locations[x].children[d.seq].organization_id)
        AND (cloc.location_cd=temploc->locations[x].children[d.seq].location_cd))
      DETAIL
       temploc->locations[x].children[d.seq].cms_critical_location_id = cloc.cms_critical_location_id,
       temploc->locations[x].children[d.seq].action_flag = 2
      WITH nocounter
     ;end select
     CALL bederrorcheck("Failed to populate cms_critical_location_id for children.")
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM cms_critical_location cloc
     PLAN (cloc
      WHERE (cloc.organization_id=temploc->locations[x].organization_id)
       AND  NOT ((cloc.location_cd=temploc->locations[x].location_cd)))
     HEAD REPORT
      child_index = 0, child_size = 0, stat = alterlist(temploc->locations[x].children,10)
     DETAIL
      child_size = (child_size+ 1), child_index = (child_index+ 1)
      IF (child_index=10)
       child_index = 0, stat = alterlist(temploc->locations[x].children,(child_size+ 10))
      ENDIF
      temploc->locations[x].children[child_size].cms_critical_location_id = cloc
      .cms_critical_location_id, temploc->locations[x].children[child_size].action_flag = 2, temploc
      ->locations[x].children[child_size].organization_id = cloc.organization_id,
      temploc->locations[x].children[child_size].location_cd = cloc.location_cd, stat = moverec(
       request->locations[x].thera_classes,temploc->locations[x].children[child_size].thera_classes)
     FOOT REPORT
      stat = alterlist(temploc->locations[x].children,child_size)
     WITH nocounter
    ;end select
    CALL bederrorcheck("CMS_CRITICAL_LOCATION table child selection error.")
   ENDIF
   IF (child_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(temploc->locations[x].children,5)),
      (dummyt d2  WITH seq = 1),
      cms_critical_category ccat
     PLAN (d1
      WHERE maxrec(d2,size(temploc->locations[x].children[d1.seq].thera_classes,5)))
      JOIN (d2)
      JOIN (ccat
      WHERE (ccat.cms_critical_location_id=temploc->locations[x].children[d1.seq].
      cms_critical_location_id)
       AND (temploc->locations[x].children[d1.seq].cms_critical_location_id > 0)
       AND (ccat.multum_category_id=temploc->locations[x].children[d1.seq].thera_classes[d2.seq].
      thera_id))
     DETAIL
      IF ((temploc->locations[x].children[d1.seq].thera_classes[d2.seq].action_flag=1))
       temploc->locations[x].children[d1.seq].thera_classes[d2.seq].action_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to update child thera_classes flags.")
   ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM (dummyt d  WITH seq = location_size),
   dual dl
  PLAN (d
   WHERE (temploc->locations[d.seq].action_flag=1))
   JOIN (dl)
  DETAIL
   temploc->locations[d.seq].cms_critical_location_id = cnvtreal(j)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting id's.")
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   dual dl
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].children,5)))
   JOIN (d2
   WHERE (temploc->locations[d1.seq].children[d2.seq].action_flag=1))
   JOIN (dl)
  DETAIL
   temploc->locations[d1.seq].children[d2.seq].cms_critical_location_id = cnvtreal(j)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting id's.")
 INSERT  FROM (dummyt d  WITH seq = location_size),
   cms_critical_location cloc
  SET cloc.cms_critical_location_id = temploc->locations[d.seq].cms_critical_location_id, cloc
   .organization_id = temploc->locations[d.seq].organization_id, cloc.location_cd = temploc->
   locations[d.seq].location_cd,
   cloc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cloc.updt_id = reqinfo->updt_id, cloc.updt_task
    = reqinfo->updt_task,
   cloc.updt_cnt = 0, cloc.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (temploc->locations[d.seq].action_flag=1))
   JOIN (cloc)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("CMS_CRITICAL_LOCATION table insertion error.")
 INSERT  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   cms_critical_location cloc
  SET cloc.cms_critical_location_id = temploc->locations[d1.seq].children[d2.seq].
   cms_critical_location_id, cloc.organization_id = temploc->locations[d1.seq].children[d2.seq].
   organization_id, cloc.location_cd = temploc->locations[d1.seq].children[d2.seq].location_cd,
   cloc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cloc.updt_id = reqinfo->updt_id, cloc.updt_task
    = reqinfo->updt_task,
   cloc.updt_cnt = 0, cloc.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].children,5)))
   JOIN (d2
   WHERE (temploc->locations[d1.seq].children[d2.seq].action_flag=1))
   JOIN (cloc)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("CMS_CRITICAL_LOCATION child table insertion error.")
 INSERT  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   cms_critical_category ccat
  SET ccat.cms_critical_category_id = seq(reference_seq,nextval), ccat.multum_category_id = temploc->
   locations[d1.seq].thera_classes[d2.seq].thera_id, ccat.cms_critical_location_id = temploc->
   locations[d1.seq].cms_critical_location_id,
   ccat.updt_dt_tm = cnvtdatetime(curdate,curtime3), ccat.updt_id = reqinfo->updt_id, ccat.updt_task
    = reqinfo->updt_task,
   ccat.updt_cnt = 0, ccat.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].thera_classes,5)))
   JOIN (d2
   WHERE (temploc->locations[d1.seq].thera_classes[d2.seq].action_flag=1))
   JOIN (ccat)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("CMS_CRITICAL_CATEGORY table insertion error.")
 INSERT  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   cms_critical_category ccat
  SET ccat.cms_critical_category_id = seq(reference_seq,nextval), ccat.multum_category_id = temploc->
   locations[d1.seq].children[d2.seq].thera_classes[d3.seq].thera_id, ccat.cms_critical_location_id
    = temploc->locations[d1.seq].children[d2.seq].cms_critical_location_id,
   ccat.updt_dt_tm = cnvtdatetime(curdate,curtime3), ccat.updt_id = reqinfo->updt_id, ccat.updt_task
    = reqinfo->updt_task,
   ccat.updt_cnt = 0, ccat.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].children,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temploc->locations[d1.seq].children[d2.seq].thera_classes,5)))
   JOIN (d3
   WHERE (temploc->locations[d1.seq].children[d2.seq].thera_classes[d3.seq].action_flag=1))
   JOIN (ccat)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("CMS_CRITICAL_CATEGORY child insertion error.")
 DELETE  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   cms_critical_category ccat
  SET ccat.seq = 1
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].thera_classes,5)))
   JOIN (d2
   WHERE (temploc->locations[d1.seq].thera_classes[d2.seq].action_flag=3))
   JOIN (ccat
   WHERE (ccat.cms_critical_location_id=temploc->locations[d1.seq].cms_critical_location_id)
    AND (ccat.multum_category_id=temploc->locations[d1.seq].thera_classes[d2.seq].thera_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("CMS_CRITICAL_CATEGORY table deletion error.")
 DELETE  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   cms_critical_category ccat
  SET ccat.seq = 1
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].children,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temploc->locations[d1.seq].children[d2.seq].thera_classes,5)))
   JOIN (d3
   WHERE (temploc->locations[d1.seq].children[d2.seq].thera_classes[d3.seq].action_flag=3))
   JOIN (ccat
   WHERE (ccat.cms_critical_location_id=temploc->locations[d1.seq].children[d2.seq].
   cms_critical_location_id)
    AND (ccat.multum_category_id=temploc->locations[d1.seq].children[d2.seq].thera_classes[d3.seq].
   thera_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("CMS_CRITICAL_CATEGORY table child deletion error.")
 FREE SET deleted_tcs
 RECORD deleted_tcs(
   1 thera_classes[*]
     2 action_flag = i2
     2 thera_id = f8
     2 cms_critical_location_id = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].thera_classes,5)))
   JOIN (d2
   WHERE (temploc->locations[d1.seq].thera_classes[d2.seq].action_flag=3))
  ORDER BY d1.seq, d2.seq
  HEAD REPORT
   child_index = 0, child_size = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
  DETAIL
   child_size = (child_size+ 1), child_index = (child_index+ 1)
   IF (child_index=10)
    child_index = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
   ENDIF
   deleted_tcs->thera_classes[child_size].thera_id = temploc->locations[d1.seq].thera_classes[d2.seq]
   .thera_id, deleted_tcs->thera_classes[child_size].action_flag = 4, deleted_tcs->thera_classes[
   child_size].cms_critical_location_id = temploc->locations[d1.seq].cms_critical_location_id
  FOOT REPORT
   stat = alterlist(deleted_tcs->thera_classes,child_size)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Deleted tc selection error")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = location_size),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(temploc->locations[d1.seq].children,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temploc->locations[d1.seq].children[d2.seq].thera_classes,5)))
   JOIN (d3
   WHERE (temploc->locations[d1.seq].children[d2.seq].thera_classes[d3.seq].action_flag=3))
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   child_index = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
  DETAIL
   child_size = (child_size+ 1), child_index = (child_index+ 1)
   IF (child_index=10)
    child_index = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
   ENDIF
   deleted_tcs->thera_classes[child_size].thera_id = temploc->locations[d1.seq].children[d2.seq].
   thera_classes[d3.seq].thera_id, deleted_tcs->thera_classes[child_size].action_flag = 4,
   deleted_tcs->thera_classes[child_size].cms_critical_location_id = temploc->locations[d1.seq].
   children[d2.seq].cms_critical_location_id
  FOOT REPORT
   stat = alterlist(deleted_tcs->thera_classes,child_size)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Deleted child selection error")
 CALL deleteparenttcs(child_size)
 SUBROUTINE deleteparenttcs(deleteditems)
  IF (deleteditems=0)
   RETURN
  ELSE
   SET deleteditems = 0
  ENDIF
  IF (child_size > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = child_size),
     mltm_category_sub_xref mcat,
     cms_critical_category ccat
    PLAN (d
     WHERE (deleted_tcs->thera_classes[d.seq].action_flag=4))
     JOIN (mcat
     WHERE (mcat.sub_category_id=deleted_tcs->thera_classes[d.seq].thera_id))
     JOIN (ccat
     WHERE (ccat.cms_critical_location_id=deleted_tcs->thera_classes[d.seq].cms_critical_location_id)
      AND ccat.multum_category_id=mcat.multum_category_id)
    ORDER BY d.seq
    HEAD REPORT
     child_index = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
    DETAIL
     child_size = (child_size+ 1), child_index = (child_index+ 1)
     IF (child_index=10)
      child_index = 0, stat = alterlist(deleted_tcs->thera_classes,(child_size+ 10))
     ENDIF
     deleted_tcs->thera_classes[d.seq].action_flag = 5, deleted_tcs->thera_classes[child_size].
     thera_id = ccat.multum_category_id, deleted_tcs->thera_classes[child_size].action_flag = 3,
     deleted_tcs->thera_classes[child_size].cms_critical_location_id = ccat.cms_critical_location_id
    FOOT REPORT
     stat = alterlist(deleted_tcs->thera_classes,child_size)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Child parent selection error")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = child_size),
     mltm_category_sub_xref mcat,
     cms_critical_category ccat
    PLAN (d
     WHERE (deleted_tcs->thera_classes[d.seq].action_flag=3))
     JOIN (mcat
     WHERE (mcat.multum_category_id=deleted_tcs->thera_classes[d.seq].thera_id))
     JOIN (ccat
     WHERE (ccat.cms_critical_location_id=deleted_tcs->thera_classes[d.seq].cms_critical_location_id)
      AND outerjoin(ccat.multum_category_id)=mcat.sub_category_id)
    DETAIL
     deleted_tcs->thera_classes[d.seq].action_flag = 2
    WITH nocounter
   ;end select
   CALL bederrorcheck("Parent delete flag selection error")
   DELETE  FROM (dummyt d  WITH seq = child_size),
     cms_critical_category ccat
    SET ccat.seq = 1, deleted_tcs->thera_classes[d.seq].action_flag = 4, deleteditems = (deleteditems
     + 1)
    PLAN (d
     WHERE (deleted_tcs->thera_classes[d.seq].action_flag=3))
     JOIN (ccat
     WHERE (ccat.cms_critical_location_id=deleted_tcs->thera_classes[d.seq].cms_critical_location_id)
      AND (ccat.multum_category_id=deleted_tcs->thera_classes[d.seq].thera_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Parent Deletion Error")
   CALL deleteparenttcs(deleteditems)
  ENDIF
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
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
