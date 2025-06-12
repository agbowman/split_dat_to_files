CREATE PROGRAM bed_get_ic_antibiotics:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 antibiotics[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 active_ind = i2
      2 specimen_type_groups[*]
        3 group_id = f8
        3 group_name = vc
        3 disclaimer_txt = vc
        3 suppression_ind = i2
      2 all_disclaimer_txt = vc
      2 all_suppression_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE tcnt = i2 WITH protect
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=1011
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->antibiotics,100)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    cnt = 1, stat = alterlist(reply->antibiotics,(tcnt+ 100))
   ENDIF
   reply->antibiotics[tcnt].active_ind = c.active_ind, reply->antibiotics[tcnt].code_value = c
   .code_value, reply->antibiotics[tcnt].description = c.description,
   reply->antibiotics[tcnt].display = c.display
  FOOT REPORT
   stat = alterlist(reply->antibiotics,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   lh_cnt_ic_antibgrm_org_dsc ld,
   lh_cnt_ic_antibgrm_group g,
   long_text_reference l
  PLAN (d)
   JOIN (ld
   WHERE (ld.antibiotic_cd=reply->antibiotics[d.seq].code_value)
    AND (ld.facility_cd=request->facility_code_value)
    AND (ld.organism_cd=request->organism_code_value))
   JOIN (g
   WHERE g.lh_cnt_ic_antibgrm_group_id=outerjoin(ld.lh_cnt_ic_antibgrm_group_id))
   JOIN (l
   WHERE l.long_text_id=outerjoin(ld.long_text_id)
    AND l.long_text_id > outerjoin(0.0)
    AND l.active_ind=outerjoin(1))
  ORDER BY d.seq
  HEAD d.seq
   scnt = 0, stcnt = 0, stat = alterlist(reply->antibiotics[d.seq].specimen_type_groups,10)
  DETAIL
   IF (ld.lh_cnt_ic_antibgrm_group_id=0.0)
    reply->antibiotics[d.seq].all_disclaimer_txt = trim(l.long_text), reply->antibiotics[d.seq].
    all_suppression_ind = ld.suppress_ind
   ENDIF
   IF (g.lh_cnt_ic_antibgrm_group_id > 0.0)
    scnt = (scnt+ 1), stcnt = (stcnt+ 1)
    IF (scnt > 10)
     scnt = 1, stat = alterlist(reply->antibiotics[d.seq].specimen_type_groups,(stcnt+ 10))
    ENDIF
    reply->antibiotics[d.seq].specimen_type_groups[stcnt].group_id = g.lh_cnt_ic_antibgrm_group_id,
    reply->antibiotics[d.seq].specimen_type_groups[stcnt].group_name = g.group_name, reply->
    antibiotics[d.seq].specimen_type_groups[stcnt].suppression_ind = ld.suppress_ind,
    reply->antibiotics[d.seq].specimen_type_groups[stcnt].disclaimer_txt = trim(l.long_text)
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->antibiotics[d.seq].specimen_type_groups,stcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
