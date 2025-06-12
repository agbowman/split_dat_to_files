CREATE PROGRAM bed_rec_iview_code_w_dta:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
   1 pelist[*]
     2 section_name = vc
     2 event_set_name = vc
     2 event_set_cd = f8
     2 event_cd = f8
     2 display_association_ind = i2
     2 more_than_one_ind = i2
     2 more_than_one_dta_ind = i2
     2 inactive_ind = i2
     2 missing_ind = i2
     2 not_exist_ind = i2
 )
 SET reply->run_status_flag = 1
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SET active_cd = 0
 SET active_cd = get_code_value(48,"ACTIVE")
 SET tcnt = 0
 SET sectioncnt = 0
 SELECT INTO "nl:"
  FROM working_view_section wvs,
   working_view_item wvi,
   v500_event_set_code vesc
  PLAN (wvs
   WHERE wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vesc
   WHERE vesc.event_set_name=wvi.primitive_event_set_name)
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD wvs.display_name
   sectioncnt = (sectioncnt+ 1)
  HEAD wvi.primitive_event_set_name
   tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].section_name = wvs
   .display_name,
   temp->pelist[tcnt].event_set_name = wvi.primitive_event_set_name, temp->pelist[tcnt].event_set_cd
    = vesc.event_set_cd, temp->pelist[tcnt].display_association_ind = vesc.display_association_ind,
   temp->pelist[tcnt].more_than_one_ind = 0, temp->pelist[tcnt].inactive_ind = 0, temp->pelist[tcnt].
   missing_ind = 1,
   temp->pelist[tcnt].not_exist_ind = 0
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    v500_event_set_explode vese,
    v500_event_code vec
   PLAN (d
    WHERE (temp->pelist[d.seq].event_set_cd > 0))
    JOIN (vese
    WHERE (vese.event_set_cd=temp->pelist[d.seq].event_set_cd))
    JOIN (vec
    WHERE vec.event_cd=vese.event_cd)
   HEAD d.seq
    active_cnt = 0
   DETAIL
    temp->pelist[d.seq].missing_ind = 0
    IF (vec.code_status_cd=active_cd)
     active_cnt = (active_cnt+ 1)
    ELSE
     temp->pelist[d.seq].inactive_ind = 1
    ENDIF
   FOOT  d.seq
    temp->pelist[d.seq].event_cd = vec.event_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    code_value_event_r cver
   PLAN (d
    WHERE (temp->pelist[d.seq].event_cd > 0))
    JOIN (cver
    WHERE (cver.event_cd=temp->pelist[d.seq].event_cd))
   HEAD d.seq
    dta_cnt = 0
   DETAIL
    dta_cnt = (dta_cnt+ 1)
   FOOT  d.seq
    IF (dta_cnt > 1)
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
  IF ((reply->run_status_flag=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tcnt),
     discrete_task_assay dta
    PLAN (d
     WHERE (temp->pelist[d.seq].event_cd > 0)
      AND (temp->pelist[d.seq].more_than_one_dta_ind=0))
     JOIN (dta
     WHERE (dta.event_cd=temp->pelist[d.seq].event_cd))
    ORDER BY d.seq
    HEAD d.seq
     dta_cnt = 0
    DETAIL
     dta_cnt = (dta_cnt+ 1)
    FOOT  d.seq
     IF (dta_cnt > 1)
      reply->run_status_flag = 3
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
