CREATE PROGRAM aps_get_rpt_versions:dba
 RECORD reply(
   1 qual[*]
     2 result_status_cd = f8
     2 result_status_disp = vc
     2 result_status_desc = vc
     2 result_status_mean = vc
     2 valid_from_dt_tm = dq8
     2 verified_dt_tm = dq8
     2 verified_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE auth_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modified_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inerror_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inerrnoview_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE hnam_contrib_sys_cd = f8 WITH protect, noconstant(0.0)
 SET auth_status_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET modified_status_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET inerror_status_cd = uar_get_code_by("MEANING",8,"INERRNOVIEW")
 SET inerrnoview_status_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET hnam_contrib_sys_cd = uar_get_code_by("MEANING",89,"POWERCHART")
 SELECT INTO "nl:"
  ce.valid_from_dt_tm
  FROM clinical_event ce
  WHERE (request->event_id=ce.event_id)
   AND ce.result_status_cd IN (auth_status_cd, inerror_status_cd, inerrnoview_status_cd,
  modified_status_cd)
  ORDER BY ce.valid_from_dt_tm
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (ce.result_status_cd IN (inerror_status_cd, inerrnoview_status_cd))
    prev_result_status_cd = 0.0
   ELSEIF (((ce.contributor_system_cd != hnam_contrib_sys_cd) OR (ce.result_status_cd !=
   prev_result_status_cd)) )
    cnt = (cnt+ 1)
    IF (mod(cnt,5)=1)
     stat = alterlist(reply->qual,(cnt+ 4))
    ENDIF
    reply->qual[cnt].result_status_cd = ce.result_status_cd, reply->qual[cnt].valid_from_dt_tm =
    cnvtdatetime(ce.valid_from_dt_tm), reply->qual[cnt].verified_prsnl_id = ce.verified_prsnl_id,
    reply->qual[cnt].verified_dt_tm = ce.verified_dt_tm, prev_result_status_cd = ce.result_status_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_EVENT"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
