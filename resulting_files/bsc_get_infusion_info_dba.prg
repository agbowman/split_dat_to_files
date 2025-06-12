CREATE PROGRAM bsc_get_infusion_info:dba
 SET modify = predeclare
 RECORD reply(
   1 infusion_list[*]
     2 order_id = f8
     2 infusion_billing_event_id = f8
     2 prev_infusion_billing_event_id = f8
     2 infuse_start_dt_tm = dq8
     2 infuse_start_tz = i4
     2 infuse_end_dt_tm = dq8
     2 infuse_end_tz = i4
     2 comment = vc
     2 prsnl_id = f8
     2 infusion_duration_mins = i4
     2 infused_volume_value = f8
     2 clinical_event_list[*]
       3 clinical_event_id = f8
       3 clinical_event_seq = i4
       3 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE unchart_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE iinfusioncnt = i4 WITH protect, noconstant(0)
 DECLARE ieventcnt = i4 WITH protect, noconstant(0)
 DECLARE istat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE iord = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET order_cnt = size(request->order_list,5)
 SELECT INTO "nl:"
  FROM infusion_billing_event ibe,
   long_text lt,
   infusion_ce_reltn icr,
   clinical_event ce1
  PLAN (ibe
   WHERE expand(iord,1,order_cnt,ibe.order_id,request->order_list[iord].order_id)
    AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (lt
   WHERE lt.long_text_id=ibe.comment_long_text_id)
   JOIN (icr
   WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id)
   JOIN (ce1
   WHERE ce1.clinical_event_id=icr.clinical_event_id)
  ORDER BY ibe.infusion_billing_event_id, ce1.event_id
  HEAD REPORT
   iinfusioncnt = 0
  HEAD ibe.infusion_billing_event_id
   iinfusioncnt = (iinfusioncnt+ 1)
   IF (mod(iinfusioncnt,10)=1)
    istat = alterlist(reply->infusion_list,(iinfusioncnt+ 9))
   ENDIF
   reply->infusion_list[iinfusioncnt].order_id = ibe.order_id, reply->infusion_list[iinfusioncnt].
   infusion_billing_event_id = ibe.infusion_billing_event_id, reply->infusion_list[iinfusioncnt].
   prev_infusion_billing_event_id = ibe.prev_infusion_billing_event_id,
   reply->infusion_list[iinfusioncnt].infuse_start_dt_tm = ibe.infusion_start_dt_tm, reply->
   infusion_list[iinfusioncnt].infuse_start_tz = ibe.infusion_start_tz, reply->infusion_list[
   iinfusioncnt].infuse_end_dt_tm = ibe.infusion_end_dt_tm,
   reply->infusion_list[iinfusioncnt].infuse_end_tz = ibe.infusion_end_tz, reply->infusion_list[
   iinfusioncnt].comment = lt.long_text, reply->infusion_list[iinfusioncnt].prsnl_id = ibe
   .create_prsnl_id,
   reply->infusion_list[iinfusioncnt].infusion_duration_mins = ibe.infusion_duration_mins, reply->
   infusion_list[iinfusioncnt].infused_volume_value = ibe.infused_volume_value, ieventcnt = 0
  HEAD ce1.event_id
   ieventcnt = (ieventcnt+ 1)
   IF (mod(ieventcnt,10)=1)
    istat = alterlist(reply->infusion_list[iinfusioncnt].clinical_event_list,(ieventcnt+ 9))
   ENDIF
   reply->infusion_list[iinfusioncnt].clinical_event_list[ieventcnt].clinical_event_id = icr
   .clinical_event_id, reply->infusion_list[iinfusioncnt].clinical_event_list[ieventcnt].
   clinical_event_seq = icr.clinical_event_seq, reply->infusion_list[iinfusioncnt].
   clinical_event_list[ieventcnt].event_id = ce1.event_id
  FOOT  ibe.infusion_billing_event_id
   istat = alterlist(reply->infusion_list[iinfusioncnt].clinical_event_list,ieventcnt)
  FOOT REPORT
   istat = alterlist(reply->infusion_list,iinfusioncnt)
  WITH nocounter
 ;end select
 IF (iinfusioncnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ENDIF
 SET last_mod = "001"
 SET mod_date = "11/03/2009"
 SET modify = nopredeclare
END GO
