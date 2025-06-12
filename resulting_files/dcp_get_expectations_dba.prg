CREATE PROGRAM dcp_get_expectations:dba
 SET modify = predeclare
 RECORD reply(
   1 event_cd_list[*]
     2 event_cd = f8
     2 expect_list[*]
       3 expect_id = f8
       3 expect_meaning = vc
       3 expect_name = vc
       3 min_age_days = i4
       3 max_age_days = i4
       3 result_count = i4
       3 seq_nbr = i4
       3 step_count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE expect_cnt = i4 WITH noconstant(0)
 DECLARE event_cnt = i4 WITH noconstant(0)
 DECLARE age_days = i4 WITH noconstant(0)
 DECLARE lidx = i4 WITH noconstant(0)
 DECLARE infinite_age_days = i4 WITH constant(100000)
 DECLARE cunchart = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE cnotdone = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cimmun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.birth_dt_tm, p.birth_tz
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   IF ((((request->admin_dt_tm=0.0)) OR ((request->admin_dt_tm=null))) )
    CALL echo("*****request->admin_dt_tm not filled out.  Get age with current date and time."),
    age_days = datetimediff(cnvtdatetime(curdate,curtime),p.birth_dt_tm)
   ELSE
    age_days = datetimediff(request->admin_dt_tm,p.birth_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("*****age_days=",age_days))
 SELECT INTO "nl:"
  FROM hm_expect_sat hmsat,
   hm_expect_step hmstep,
   hm_expect hm,
   v500_event_code vec,
   immunization_modifier im,
   clinical_event ce,
   dummyt d
  PLAN (vec
   WHERE expand(lidx,1,size(request->event_cd_list,5),vec.event_cd,request->event_cd_list[lidx].
    event_cd))
   JOIN (hmsat
   WHERE hmsat.parent_type_flag=0
    AND hmsat.parent_value=vec.event_set_name
    AND ((hmsat.active_ind+ 0)=1))
   JOIN (hm
   WHERE hm.expect_id=hmsat.expect_id
    AND ((hm.interval_only_ind+ 0)=0)
    AND ((hm.active_ind+ 0)=1))
   JOIN (hmstep
   WHERE hmstep.expect_id=hm.expect_id
    AND ((hmstep.active_ind+ 0)=1)
    AND ((hmstep.min_age+ 0)=
   (SELECT
    min(hmstep2.min_age)
    FROM hm_expect_step hmstep2
    WHERE hmstep2.expect_id=hm.expect_id
     AND ((hmstep2.active_ind+ 0)=1))))
   JOIN (d)
   JOIN (im
   WHERE (im.person_id=request->person_id)
    AND im.expect_meaning=hm.expect_meaning)
   JOIN (ce
   WHERE ce.event_id=im.event_id
    AND  NOT (ce.result_status_cd IN (cunchart, cnotdone))
    AND (ce.updt_cnt=
   (SELECT
    max(ce2.updt_cnt)
    FROM clinical_event ce2
    WHERE ce2.event_id=im.event_id)))
  ORDER BY vec.event_cd, hmstep.expect_id, ce.event_id
  HEAD REPORT
   event_cnt = 0
  HEAD vec.event_cd
   expect_cnt = 0, event_cnt = (event_cnt+ 1), stat = alterlist(reply->event_cd_list,event_cnt),
   reply->event_cd_list[event_cnt].event_cd = vec.event_cd
  HEAD hmstep.expect_id
   CALL echo(build("HM_MAX_AGE IS : ",hm.max_age))
   IF (hmstep.min_age <= age_days
    AND ((age_days <= hm.max_age) OR (hm.max_age=0)) )
    expect_cnt = (expect_cnt+ 1), stat = alterlist(reply->event_cd_list[event_cnt].expect_list,
     expect_cnt), reply->event_cd_list[event_cnt].expect_list[expect_cnt].expect_id = hm.expect_id,
    reply->event_cd_list[event_cnt].expect_list[expect_cnt].expect_meaning = hm.expect_meaning, reply
    ->event_cd_list[event_cnt].expect_list[expect_cnt].expect_name = hm.expect_name, reply->
    event_cd_list[event_cnt].expect_list[expect_cnt].seq_nbr = hm.seq_nbr,
    reply->event_cd_list[event_cnt].expect_list[expect_cnt].step_count = hm.step_count, reply->
    event_cd_list[event_cnt].expect_list[expect_cnt].min_age_days = hmstep.min_age
    IF (hm.max_age=0)
     reply->event_cd_list[event_cnt].expect_list[expect_cnt].max_age_days = infinite_age_days
    ELSE
     reply->event_cd_list[event_cnt].expect_list[expect_cnt].max_age_days = hm.max_age
    ENDIF
   ENDIF
  HEAD ce.event_id
   IF (ce.event_id > 0)
    IF (expect_cnt > 0)
     reply->event_cd_list[event_cnt].expect_list[expect_cnt].result_count = (reply->event_cd_list[
     event_cnt].expect_list[expect_cnt].result_count+ 1)
    ENDIF
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (expect_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "03/08/2011"
 SET modify = nopredeclare
END GO
