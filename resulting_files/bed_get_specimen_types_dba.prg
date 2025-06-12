CREATE PROGRAM bed_get_specimen_types:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 categories[*]
      2 category_code_value = f8
      2 category_display = vc
      2 category_active_ind = i2
      2 sections[*]
        3 section_code_value = f8
        3 section_display = vc
        3 section_active_ind = i2
        3 specimen_types[*]
          4 specimen_code_value = f8
          4 specimen_display = vc
          4 specimen_active_ind = i2
          4 specimen_group_id = f8
    1 unassigned_types[*]
      2 code_value = f8
      2 display = vc
      2 active_ind = i2
      2 group_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD assignedspecimentypes(
   1 specimen_types[*]
     2 specimen_code_value = f8
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
 DECLARE indx = i4
 SELECT INTO "nl:"
  FROM code_value c2052,
   code_value_group g1,
   code_value c1151,
   code_value_group g2,
   code_value c1150,
   lh_cnt_ic_antibgrm_group_r r,
   lh_cnt_ic_antibgrm_group g
  PLAN (c2052
   WHERE c2052.code_set=2052)
   JOIN (g1
   WHERE g1.child_code_value=c2052.code_value)
   JOIN (c1151
   WHERE c1151.code_value=g1.parent_code_value)
   JOIN (g2
   WHERE g2.child_code_value=c1151.code_value)
   JOIN (c1150
   WHERE c1150.code_value=g2.parent_code_value)
   JOIN (r
   WHERE r.parent_entity_id=outerjoin(c2052.code_value)
    AND r.parent_entity_name=outerjoin("CODE_VALUE"))
   JOIN (g
   WHERE g.lh_cnt_ic_antibgrm_group_id=outerjoin(r.lh_cnt_ic_antibgrm_group_id))
  ORDER BY c1150.code_value, c1151.code_value, c2052.code_value
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->categories,10)
  HEAD c1150.code_value
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->categories,(tcnt+ 10))
   ENDIF
   reply->categories[tcnt].category_code_value = c1150.code_value, reply->categories[tcnt].
   category_display = c1150.display, reply->categories[tcnt].category_active_ind = c1150.active_ind,
   scnt = 0, stcnt = 0, stat = alterlist(reply->categories[tcnt].sections,10)
  HEAD c1151.code_value
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 10)
    scnt = 1, stat = alterlist(reply->categories[tcnt].sections,(stcnt+ 10))
   ENDIF
   reply->categories[tcnt].sections[stcnt].section_code_value = c1151.code_value, reply->categories[
   tcnt].sections[stcnt].section_display = c1151.display, reply->categories[tcnt].sections[stcnt].
   section_active_ind = c1151.active_ind,
   dcnt = 0, dtcnt = 0, stat = alterlist(reply->categories[tcnt].sections[stcnt].specimen_types,10)
  HEAD c2052.code_value
   dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
   IF (dcnt > 10)
    dcnt = 1, stat = alterlist(reply->categories[tcnt].sections[stcnt].specimen_types,(dtcnt+ 10))
   ENDIF
   reply->categories[tcnt].sections[stcnt].specimen_types[dtcnt].specimen_code_value = c2052
   .code_value, reply->categories[tcnt].sections[stcnt].specimen_types[dtcnt].specimen_display =
   c2052.description, reply->categories[tcnt].sections[stcnt].specimen_types[dtcnt].
   specimen_active_ind = c2052.active_ind,
   reply->categories[tcnt].sections[stcnt].specimen_types[dtcnt].specimen_group_id = g
   .lh_cnt_ic_antibgrm_group_id
  FOOT  c1151.code_value
   stat = alterlist(reply->categories[tcnt].sections[stcnt].specimen_types,dtcnt)
  FOOT  c1150.code_value
   stat = alterlist(reply->categories[tcnt].sections,stcnt)
  FOOT REPORT
   stat = alterlist(reply->categories,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failure on assigned")
 SELECT INTO "nl:"
  FROM code_value c2052,
   code_value_group g1,
   code_value c1151,
   code_value_group g2,
   code_value c1150,
   lh_cnt_ic_antibgrm_group_r r,
   lh_cnt_ic_antibgrm_group g
  PLAN (c2052
   WHERE c2052.code_set=2052)
   JOIN (g1
   WHERE g1.child_code_value=c2052.code_value)
   JOIN (c1151
   WHERE c1151.code_value=g1.parent_code_value)
   JOIN (g2
   WHERE g2.child_code_value=c1151.code_value)
   JOIN (c1150
   WHERE c1150.code_value=g2.parent_code_value)
   JOIN (r
   WHERE r.parent_entity_id=outerjoin(c2052.code_value)
    AND r.parent_entity_name=outerjoin("CODE_VALUE"))
   JOIN (g
   WHERE g.lh_cnt_ic_antibgrm_group_id=outerjoin(r.lh_cnt_ic_antibgrm_group_id))
  ORDER BY c2052.code_value
  HEAD REPORT
   cnt = 0, stat = alterlist(assignedspecimentypes->specimen_types,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(assignedspecimentypes->specimen_types,(cnt+ 9))
   ENDIF
   assignedspecimentypes->specimen_types[cnt].specimen_code_value = c2052.code_value
  FOOT REPORT
   stat = alterlist(assignedspecimentypes->specimen_types,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(assignedspecimentypes)
 SELECT INTO "nl:"
  FROM code_value c,
   lh_cnt_ic_antibgrm_group_r r,
   lh_cnt_ic_antibgrm_group g
  PLAN (c
   WHERE c.code_set=2052
    AND  NOT (expand(indx,1,size(assignedspecimentypes->specimen_types,5),c.code_value,cnvtreal(
     assignedspecimentypes->specimen_types[indx].specimen_code_value))))
   JOIN (r
   WHERE r.parent_entity_id=outerjoin(c.code_value)
    AND r.parent_entity_name=outerjoin("CODE_VALUE"))
   JOIN (g
   WHERE g.lh_cnt_ic_antibgrm_group_id=outerjoin(r.lh_cnt_ic_antibgrm_group_id))
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->unassigned_types,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(reply->unassigned_types,(tcnt+ 10))
   ENDIF
   reply->unassigned_types[tcnt].code_value = c.code_value, reply->unassigned_types[tcnt].display = c
   .description, reply->unassigned_types[tcnt].active_ind = c.active_ind,
   reply->unassigned_types[tcnt].group_id = g.lh_cnt_ic_antibgrm_group_id
  FOOT REPORT
   stat = alterlist(reply->unassigned_types,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failure on unassigned")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
