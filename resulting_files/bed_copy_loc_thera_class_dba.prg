CREATE PROGRAM bed_copy_loc_thera_class:dba
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
 FREE SET tempmultumcategory
 RECORD tempmultumcategory(
   1 ids[*]
     2 multum_category_id = f8
 )
 FREE SET tempfacilitiestodelete
 RECORD tempfacilitiestodelete(
   1 locations[*]
     2 cms_critical_location_id = f8
 )
 FREE SET tempfacilitiestocopy
 RECORD tempfacilitiestocopy(
   1 locations[*]
     2 organization_id = f8
     2 location_cd = f8
     2 cms_critical_location_id = f8
 )
 FREE SET tempcriticalcategories
 RECORD tempcriticalcategories(
   1 categories[*]
     2 cms_critical_category_id = f8
     2 cms_critical_location_id = f8
     2 multum_category_id = f8
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
 DECLARE fac_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE build_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE deletelocationscount = i2 WITH protect, noconstant(0)
 DECLARE detailparse = vc
 DECLARE facstocopysize = i4 WITH protect
 DECLARE mltmcatsize = i4 WITH protect
 SET location_size = size(request->locations,5)
 IF ((request->organization_to_copy_id=0.0))
  CALL bederror("Facility not provided.")
 ENDIF
 SET detailparse = build("cloc.organization_id = ",request->organization_to_copy_id)
 IF ((request->unit_to_copy_id > 0))
  SET detailparse = build(detailparse," and cloc.location_cd = ",request->unit_to_copy_id)
 ELSE
  SET detailparse = build(detailparse," and cloc.location_cd = ",request->facility_to_copy_id)
 ENDIF
 SELECT INTO "nl:"
  FROM cms_critical_location cloc,
   cms_critical_category ccat
  PLAN (cloc
   WHERE parser(detailparse))
   JOIN (ccat
   WHERE cloc.cms_critical_location_id=ccat.cms_critical_location_id)
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(tempmultumcategory->ids,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(tempmultumcategory->ids,(tcnt+ 10))
   ENDIF
   tempmultumcategory->ids[tcnt].multum_category_id = ccat.multum_category_id
  FOOT REPORT
   stat = alterlist(tempmultumcategory->ids,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck(
  "Failed to get the CMS_CRITICAL_CATEGORY.multum_category_id for the organization and facility ID to copy."
  )
 IF ((request->unit_to_copy_id > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = location_size),
    cms_critical_location cloc
   PLAN (d)
    JOIN (cloc
    WHERE (request->locations[d.seq].organization_id=cloc.organization_id)
     AND (request->locations[d.seq].unit_id=cloc.location_cd))
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(tempfacilitiestodelete->locations,10)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(tempfacilitiestodelete->locations,(tcnt+ 10))
    ENDIF
    tempfacilitiestodelete->locations[tcnt].cms_critical_location_id = cloc.cms_critical_location_id
   FOOT REPORT
    stat = alterlist(tempfacilitiestodelete->locations,tcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck(
   "Failed to populate tempFacilitiesToDelete with cms_critical_location_id for units.")
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = location_size),
    cms_critical_location cloc
   PLAN (d)
    JOIN (cloc
    WHERE (request->locations[d.seq].organization_id=cloc.organization_id))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(tempfacilitiestodelete->locations,10)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(tempfacilitiestodelete->locations,(tcnt+ 10))
    ENDIF
    tempfacilitiestodelete->locations[tcnt].cms_critical_location_id = cloc.cms_critical_location_id
   FOOT REPORT
    stat = alterlist(tempfacilitiestodelete->locations,tcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck(
   "Failed to populate tempFacilitiesToDelete with cms_critical_location_id for facility.")
 ENDIF
 SET deletelocationscount = size(tempfacilitiestodelete->locations,5)
 IF (deletelocationscount > 0)
  DELETE  FROM (dummyt d  WITH seq = deletelocationscount),
    cms_critical_category ccat
   SET ccat.seq = 1
   PLAN (d)
    JOIN (ccat
    WHERE (ccat.cms_critical_location_id=tempfacilitiestodelete->locations[d.seq].
    cms_critical_location_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("CMS_CRITICAL_CATEGORY table deletion error.")
  DELETE  FROM (dummyt d  WITH seq = deletelocationscount),
    cms_critical_location cloc
   SET cloc.seq = 1
   PLAN (d)
    JOIN (cloc
    WHERE (cloc.cms_critical_location_id=tempfacilitiestodelete->locations[d.seq].
    cms_critical_location_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("CMS_CRITICAL_LOCATION table deletion error.")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = location_size)
  PLAN (d)
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(tempfacilitiestocopy->locations,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(tempfacilitiestocopy->locations,(tcnt+ 10))
   ENDIF
   tempfacilitiestocopy->locations[tcnt].organization_id = request->locations[d.seq].organization_id
   IF ((request->unit_to_copy_id > 0))
    tempfacilitiestocopy->locations[tcnt].location_cd = request->locations[d.seq].unit_id
   ELSE
    tempfacilitiestocopy->locations[tcnt].location_cd = request->locations[d.seq].facility_id
   ENDIF
  FOOT REPORT
   stat = alterlist(tempfacilitiestocopy->locations,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to populate tempFacilitiesToDelete with cms_critical_location_id.")
 IF ((request->unit_to_copy_id=0))
  SET fac_type_cd = uar_get_code_by("MEANING",222,"FACILITY")
  SET build_type_cd = uar_get_code_by("MEANING",222,"BUILDING")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(request->locations,5)),
    location_group lg1,
    location l1,
    code_value cv1,
    location_group lg2,
    location l2,
    code_value cv2
   PLAN (d)
    JOIN (lg1
    WHERE (lg1.parent_loc_cd=request->locations[d.seq].facility_id)
     AND lg1.location_group_type_cd=fac_type_cd
     AND lg1.active_ind=1
     AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND lg1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (l1
    WHERE l1.location_cd=lg1.child_loc_cd
     AND l1.active_ind=1
     AND l1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cv1
    WHERE cv1.code_value=lg1.child_loc_cd
     AND cv1.active_ind=1)
    JOIN (lg2
    WHERE lg2.parent_loc_cd=cv1.code_value
     AND lg2.location_group_type_cd=build_type_cd
     AND lg2.active_ind=1
     AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (l2
    WHERE l2.location_cd=lg2.child_loc_cd
     AND l2.active_ind=1
     AND l2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cv2
    WHERE cv2.code_value=lg2.child_loc_cd
     AND cv2.active_ind=1)
   ORDER BY d.seq, lg1.parent_loc_cd, l1.location_cd,
    cv1.code_value, lg2.parent_loc_cd, l2.location_cd,
    cv2.code_value
   HEAD REPORT
    cnt = size(tempfacilitiestocopy->locations,5), tcnt = cnt, stat = alterlist(tempfacilitiestocopy
     ->locations,(cnt+ 10))
   HEAD cv2.code_value
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(tempfacilitiestocopy->locations,(tcnt+ 10))
    ENDIF
    tempfacilitiestocopy->locations[tcnt].organization_id = l1.organization_id, tempfacilitiestocopy
    ->locations[tcnt].location_cd = cv2.code_value
   FOOT REPORT
    stat = alterlist(tempfacilitiestocopy->locations,tcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error getting units.")
 ENDIF
 SET facstocopysize = size(tempfacilitiestocopy->locations,5)
 IF (facstocopysize=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM (dummyt d  WITH seq = facstocopysize),
   dual dl
  PLAN (d)
   JOIN (dl)
  DETAIL
   tempfacilitiestocopy->locations[d.seq].cms_critical_location_id = cnvtreal(j)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting id's.")
 INSERT  FROM (dummyt d  WITH seq = facstocopysize),
   cms_critical_location cloc
  SET cloc.cms_critical_location_id = tempfacilitiestocopy->locations[d.seq].cms_critical_location_id,
   cloc.organization_id = tempfacilitiestocopy->locations[d.seq].organization_id, cloc.location_cd =
   tempfacilitiestocopy->locations[d.seq].location_cd,
   cloc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cloc.updt_id = reqinfo->updt_id, cloc.updt_task
    = reqinfo->updt_task,
   cloc.updt_cnt = 0, cloc.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (cloc)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Failed to insert into the CMS_CRITICAL_LOCATION table.")
 SET mltmcatsize = size(tempmultumcategory->ids,5)
 IF (mltmcatsize=0)
  GO TO exit_script
 ENDIF
 SET tcnt = (mltmcatsize * facstocopysize)
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM (dummyt d  WITH seq = tcnt),
   dual dl
  PLAN (d)
   JOIN (dl)
  HEAD REPORT
   stat = alterlist(tempcriticalcategories->categories,tcnt)
  DETAIL
   tempcriticalcategories->categories[d.seq].cms_critical_category_id = cnvtreal(j)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting critical category id's.")
 DECLARE x = i4 WITH private
 DECLARE y = i4 WITH private
 SET tcnt = 0
 FOR (x = 1 TO facstocopysize)
   FOR (y = 1 TO mltmcatsize)
     SET tcnt = (tcnt+ 1)
     SET tempcriticalcategories->categories[tcnt].cms_critical_location_id = tempfacilitiestocopy->
     locations[x].cms_critical_location_id
     SET tempcriticalcategories->categories[tcnt].multum_category_id = tempmultumcategory->ids[y].
     multum_category_id
   ENDFOR
 ENDFOR
 INSERT  FROM (dummyt d  WITH seq = tcnt),
   cms_critical_category ccat
  SET ccat.cms_critical_category_id = tempcriticalcategories->categories[d.seq].
   cms_critical_category_id, ccat.multum_category_id = tempcriticalcategories->categories[d.seq].
   multum_category_id, ccat.cms_critical_location_id = tempcriticalcategories->categories[d.seq].
   cms_critical_location_id,
   ccat.updt_dt_tm = cnvtdatetime(curdate,curtime3), ccat.updt_id = reqinfo->updt_id, ccat.updt_task
    = reqinfo->updt_task,
   ccat.updt_cnt = 0, ccat.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (ccat)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Failed to insert into the CMS_CRITICAL_CATEGORY table.")
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
