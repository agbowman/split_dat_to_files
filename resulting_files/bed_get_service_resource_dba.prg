CREATE PROGRAM bed_get_service_resource:dba
 FREE SET reply
 RECORD reply(
   1 rlist[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 mean = vc
     2 multiplexor_ind = f8
   1 error_msg = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE max_limit_cnt = i4 WITH protect, constant(3000)
 DECLARE max_cnt = i4
 DECLARE index = i4
 SET load_all = 0
 SET reply->too_many_results_ind = 0
 IF (validate(request->load_all_subsections))
  SET load_all = request->load_all_subsections
 ENDIF
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE ierrcode = i4
 DECLARE high_volume_cnt = i4
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET error_msg = fillstring(132," ")
 SET ierrcode = error(error_msg,1)
 DECLARE sr_parse = vc WITH protect, noconstant("")
 DECLARE act_type_hlx = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLX"))
 DECLARE act_type_glb = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE act_type_ptl = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PTL"))
 DECLARE act_type_ci = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"CI"))
 SET tot_sr = 0
 SET sr_count = 0
 SET stat = alterlist(reply->rlist,100)
 SET scnt = size(request->slist,5)
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = max_limit_cnt
 ENDIF
 IF (scnt=0)
  IF (uar_get_code_meaning(request->activity_type_code_value)="HLX")
   SET sr_parse = concat("s.active_ind = 1",
    " and s.activity_type_cd in (ACT_TYPE_HLX, ACT_TYPE_GLB, ACT_TYPE_PTL, ACT_TYPE_CI)")
  ELSE
   SET sr_parse = build("s.active_ind = 1 and s.activity_type_cd = ",request->
    activity_type_code_value)
  ENDIF
  SELECT INTO "NL:"
   tot_sr = count(*)
   FROM code_value cv,
    service_resource s
   PLAN (s
    WHERE parser(sr_parse))
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT")) )
  ;end select
  IF (tot_sr > max_limit_cnt)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value cv,
    service_resource s
   PLAN (s
    WHERE parser(sr_parse))
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT")) )
   ORDER BY cv.cdf_meaning, cv.display_key
   DETAIL
    tot_sr = (tot_sr+ 1), sr_count = (sr_count+ 1)
    IF (sr_count > 100)
     stat = alterlist(reply->rlist,(tot_sr+ 100)), sr_count = 0
    ENDIF
    reply->rlist[tot_sr].code_value = cv.code_value, reply->rlist[tot_sr].display = cv.display, reply
    ->rlist[tot_sr].description = cv.description,
    reply->rlist[tot_sr].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SET ierrcode = error(error_msg,1)
  IF (ierrcode > 0)
   CALL logerror("Error reading all active service resources.",error_msg)
  ENDIF
  SELECT INTO "NL:"
   FROM code_value cv,
    service_resource s,
    sub_section ss
   PLAN (s
    WHERE parser(sr_parse))
    JOIN (ss
    WHERE ((ss.multiplexor_ind=1) OR (load_all=1))
     AND ss.service_resource_cd=s.service_resource_cd)
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND cv.cdf_meaning="SUBSECTION")
   ORDER BY cv.cdf_meaning, cv.display_key
   DETAIL
    tot_sr = (tot_sr+ 1), sr_count = (sr_count+ 1)
    IF (sr_count > 100)
     stat = alterlist(reply->rlist,(tot_sr+ 100)), sr_count = 0
    ENDIF
    reply->rlist[tot_sr].code_value = cv.code_value, reply->rlist[tot_sr].display = cv.display, reply
    ->rlist[tot_sr].description = cv.description,
    reply->rlist[tot_sr].mean = cv.cdf_meaning, reply->rlist[tot_sr].multiplexor_ind = ss
    .multiplexor_ind
   WITH nocounter
  ;end select
  SET ierrcode = error(error_msg,1)
  IF (ierrcode > 0)
   CALL logerror("Error reading multiplexor resources.",error_msg)
  ENDIF
 ELSE
  SELECT INTO "NL:"
   tot_sr = count(*)
   FROM code_value cv,
    resource_group r
   PLAN (r
    WHERE expand(index,1,scnt,r.parent_service_resource_cd,request->slist[index].code_value))
    JOIN (cv
    WHERE cv.code_value=r.child_service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT")) )
  ;end select
  IF (tot_sr > max_limit_cnt)
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM code_value cv,
    resource_group r
   PLAN (r
    WHERE expand(index,1,scnt,r.parent_service_resource_cd,request->slist[index].code_value))
    JOIN (cv
    WHERE cv.code_value=r.child_service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT")) )
   ORDER BY cv.cdf_meaning, cv.display_key
   DETAIL
    tot_sr = (tot_sr+ 1), sr_count = (sr_count+ 1)
    IF (sr_count > 100)
     stat = alterlist(reply->rlist,(tot_sr+ 100)), sr_count = 0
    ENDIF
    reply->rlist[tot_sr].code_value = cv.code_value, reply->rlist[tot_sr].display = cv.display, reply
    ->rlist[tot_sr].description = cv.description,
    reply->rlist[tot_sr].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SET ierrcode = error(error_msg,1)
  IF (ierrcode > 0)
   CALL logerror("Error reading sub section service resources.",error_msg)
  ENDIF
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
 SET stat = alterlist(reply->rlist,tot_sr)
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
 ELSE
  IF (tot_sr > 0)
   IF (tot_sr > max_cnt)
    SET reply->too_many_results_ind = 1
    SET stat = alterlist(reply->rlist,0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
