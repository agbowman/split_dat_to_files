CREATE PROGRAM bed_rec_iview_all_results:dba
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
 SET allresult_cd = 0.0
 SET allspec_cd = 0.0
 SET workview_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc
  PLAN (vesc
   WHERE vesc.event_set_name_key IN ("ALLSPECIALTYSECTIONS", "WORKINGVIEWSECTIONS",
   "ALLRESULTSECTIONS"))
  DETAIL
   IF (vesc.event_set_name_key="ALLSPECIALTYSECTIONS")
    allspec_cd = vesc.event_set_cd
   ELSEIF (vesc.event_set_name_key="ALLRESULTSECTIONS")
    allresult_cd = vesc.event_set_cd
   ELSE
    workview_cd = vesc.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
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
    v500_event_set_canon vesc1,
    v500_event_set_canon vesc2,
    v500_event_set_canon vesc3,
    v500_event_set_canon vesc4,
    v500_event_set_canon vesc5,
    v500_event_set_canon vesc6,
    v500_event_set_canon vesc7,
    v500_event_set_canon vesc8,
    v500_event_set_canon vesc9,
    v500_event_set_canon vesc10,
    v500_event_set_canon vesc11,
    v500_event_set_canon vesc12,
    v500_event_set_canon vesc13,
    v500_event_set_canon vesc14,
    v500_event_set_canon vesc15,
    v500_event_set_canon vesc16,
    v500_event_set_canon vesc17,
    v500_event_set_canon vesc18,
    v500_event_set_canon vesc19
   PLAN (d
    WHERE (temp->pelist[d.seq].event_set_cd > 0))
    JOIN (vesc1
    WHERE (vesc1.event_set_cd=temp->pelist[d.seq].event_set_cd))
    JOIN (vesc2
    WHERE vesc2.event_set_cd=outerjoin(vesc1.parent_event_set_cd))
    JOIN (vesc3
    WHERE vesc3.event_set_cd=outerjoin(vesc2.parent_event_set_cd))
    JOIN (vesc4
    WHERE vesc4.event_set_cd=outerjoin(vesc3.parent_event_set_cd))
    JOIN (vesc5
    WHERE vesc5.event_set_cd=outerjoin(vesc4.parent_event_set_cd))
    JOIN (vesc6
    WHERE vesc6.event_set_cd=outerjoin(vesc5.parent_event_set_cd))
    JOIN (vesc7
    WHERE vesc7.event_set_cd=outerjoin(vesc6.parent_event_set_cd))
    JOIN (vesc8
    WHERE vesc8.event_set_cd=outerjoin(vesc7.parent_event_set_cd))
    JOIN (vesc9
    WHERE vesc9.event_set_cd=outerjoin(vesc8.parent_event_set_cd))
    JOIN (vesc10
    WHERE vesc10.event_set_cd=outerjoin(vesc9.parent_event_set_cd))
    JOIN (vesc11
    WHERE vesc11.event_set_cd=outerjoin(vesc10.parent_event_set_cd))
    JOIN (vesc12
    WHERE vesc12.event_set_cd=outerjoin(vesc11.parent_event_set_cd))
    JOIN (vesc13
    WHERE vesc13.event_set_cd=outerjoin(vesc12.parent_event_set_cd))
    JOIN (vesc14
    WHERE vesc14.event_set_cd=outerjoin(vesc13.parent_event_set_cd))
    JOIN (vesc15
    WHERE vesc15.event_set_cd=outerjoin(vesc14.parent_event_set_cd))
    JOIN (vesc16
    WHERE vesc16.event_set_cd=outerjoin(vesc15.parent_event_set_cd))
    JOIN (vesc17
    WHERE vesc17.event_set_cd=outerjoin(vesc16.parent_event_set_cd))
    JOIN (vesc18
    WHERE vesc18.event_set_cd=outerjoin(vesc17.parent_event_set_cd))
    JOIN (vesc19
    WHERE vesc19.event_set_cd=outerjoin(vesc18.parent_event_set_cd))
   HEAD REPORT
    found = "N"
   HEAD d.seq
    found = "N"
   DETAIL
    IF (((vesc19.parent_event_set_cd=allresult_cd) OR (((vesc18.parent_event_set_cd=allresult_cd) OR
    (((vesc17.parent_event_set_cd=allresult_cd) OR (((vesc16.parent_event_set_cd=allresult_cd) OR (((
    vesc15.parent_event_set_cd=allresult_cd) OR (((vesc14.parent_event_set_cd=allresult_cd) OR (((
    vesc13.parent_event_set_cd=allresult_cd) OR (((vesc12.parent_event_set_cd=allresult_cd) OR (((
    vesc11.parent_event_set_cd=allresult_cd) OR (((vesc10.parent_event_set_cd=allresult_cd) OR (((
    vesc9.parent_event_set_cd=allresult_cd) OR (((vesc8.parent_event_set_cd=allresult_cd) OR (((vesc7
    .parent_event_set_cd=allresult_cd) OR (((vesc6.parent_event_set_cd=allresult_cd) OR (((vesc5
    .parent_event_set_cd=allresult_cd) OR (((vesc4.parent_event_set_cd=allresult_cd) OR (((vesc3
    .parent_event_set_cd=allresult_cd) OR (((vesc2.parent_event_set_cd=allresult_cd) OR (vesc1
    .parent_event_set_cd=allresult_cd)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
     found = "Y"
    ENDIF
   FOOT  d.seq
    IF (found="N")
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
