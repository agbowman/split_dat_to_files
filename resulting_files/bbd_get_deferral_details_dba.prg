CREATE PROGRAM bbd_get_deferral_details:dba
 EXECUTE cclseclogin
 RECORD reply(
   1 deferral_qual[*]
     2 deferral_reason = vc
     2 deferr_until_dt_tm = dq8
     2 contact_dt_tm = dq8
     2 contact_id = vc
     2 patient_name = vc
     2 contact_outcome_cd = f8
     2 contact_outcome_disp = c40
     2 contact_outcome_desc = vc
     2 contact_outcome_mean = c12
     2 contact_upload_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE data_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  p.name_full_formatted, deferral_reason = uar_get_code_display(bdr.reason_cd), bdc
  .contact_outcome_cd,
  bdr.updt_dt_tm, psl.username
  FROM bbd_deferral_reason bdr,
   bbd_donor_contact bdc,
   prsnl psl,
   person p
  PLAN (bdr
   WHERE (bdr.person_id=request->person_id)
    AND bdr.active_ind=1)
   JOIN (bdc
   WHERE bdc.contact_id=bdr.contact_id)
   JOIN (psl
   WHERE psl.person_id=outerjoin(bdr.updt_id))
   JOIN (p
   WHERE p.person_id=bdc.person_id)
  HEAD REPORT
   data_cnt = 0
  DETAIL
   data_cnt = (data_cnt+ 1)
   IF (size(reply->deferral_qual,5) < data_cnt)
    stat = alterlist(reply->deferral_qual,(data_cnt+ 10))
   ENDIF
   reply->deferral_qual[data_cnt].deferral_reason = deferral_reason
   IF (nullind(bdr.calc_elig_dt_tm)=0)
    reply->deferral_qual[data_cnt].deferr_until_dt_tm = bdr.calc_elig_dt_tm
   ELSEIF (nullind(bdr.eligible_dt_tm)=0)
    reply->deferral_qual[data_cnt].deferr_until_dt_tm = bdr.eligible_dt_tm
   ELSE
    reply->deferral_qual[data_cnt].deferr_until_dt_tm = bdr.occurred_dt_tm
   ENDIF
   reply->deferral_qual[data_cnt].contact_dt_tm = bdr.updt_dt_tm, reply->deferral_qual[data_cnt].
   contact_outcome_cd = bdc.contact_outcome_cd, reply->deferral_qual[data_cnt].contact_id = psl
   .username,
   reply->deferral_qual[data_cnt].patient_name = p.name_full_formatted
   IF (bdc.contributor_system_cd > 0.0)
    reply->deferral_qual[data_cnt].contact_upload_ind = 1
   ELSE
    reply->deferral_qual[data_cnt].contact_upload_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->deferral_qual,data_cnt)
  WITH maxcol = 500
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BBD_GET_DEFERRAL_DETAILS",errmsg)
 ENDIF
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, nonconstat(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSEIF (data_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
