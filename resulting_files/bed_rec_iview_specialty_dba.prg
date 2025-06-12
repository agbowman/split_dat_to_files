CREATE PROGRAM bed_rec_iview_specialty:dba
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
 SET reply->run_status_flag = 1
 SET all_okay_ind = 0
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
 IF (allspec_cd > 0
  AND workview_cd > 0)
  SELECT INTO "nl:"
   FROM v500_event_set_canon vesc
   PLAN (vesc
    WHERE vesc.parent_event_set_cd=allspec_cd
     AND vesc.event_set_cd=workview_cd)
   DETAIL
    all_okay_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (all_okay_ind=0)
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
