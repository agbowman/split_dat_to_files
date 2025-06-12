CREATE PROGRAM bed_rec_iv_ce_notin_all_result
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET active_cd = get_code_value(48,"ACTIVE")
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
 SET allresult_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc
  PLAN (vesc
   WHERE vesc.event_set_name_key IN ("ALLSPECIALTYSECTIONS", "WORKINGVIEWSECTIONS",
   "ALLRESULTSECTIONS"))
  DETAIL
   IF (vesc.event_set_name_key="ALLRESULTSECTIONS")
    allresult_cd = vesc.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 SET sectioncnt = 0
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM working_view_section wvs,
   working_view_item wvi,
   v500_event_set_code vesc,
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
  PLAN (wvs
   WHERE wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vesc
   WHERE vesc.event_set_name=wvi.primitive_event_set_name
    AND vesc.display_association_ind=0)
   JOIN (vesc1
   WHERE vesc1.event_set_cd=vesc.event_set_cd
    AND  NOT ( EXISTS (
   (SELECT
    parent_event_set_cd
    FROM v500_event_set_canon
    WHERE parent_event_set_cd=vesc1.event_set_cd))))
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
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD REPORT
   found = "N"
  HEAD vesc1.event_set_cd
   found = "N"
  DETAIL
   IF (((vesc19.parent_event_set_cd=allresult_cd) OR (((vesc18.parent_event_set_cd=allresult_cd) OR (
   ((vesc17.parent_event_set_cd=allresult_cd) OR (((vesc16.parent_event_set_cd=allresult_cd) OR (((
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
  FOOT  vesc1.event_set_cd
   IF (found="N")
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
