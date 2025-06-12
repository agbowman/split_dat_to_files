CREATE PROGRAM dcp_upt_ppr_end_eff_dt_tm:dba
 RECORD reply(
   1 new_end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 DECLARE nfailed = i4 WITH noconstant(1)
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr
  WHERE (ppr.person_prsnl_reltn_id=request->person_prsnl_reltn_id)
   AND ppr.active_ind=1
  DETAIL
   IF (datetimediff(cnvtdatetime(request->orig_end_effective_dt_tm),ppr.end_effective_dt_tm,5) > 0)
    reply->status_data.status = "F", nfailed = 1
   ELSEIF (datetimediff(ppr.end_effective_dt_tm,cnvtdatetime(request->new_end_effective_dt_tm),5) > 0
   )
    reply->status_data.status = "F", reply->new_end_effective_dt_tm = ppr.end_effective_dt_tm,
    nfailed = 1
   ELSE
    nfailed = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (nfailed=0)
  FREE RECORD person_prsnl_reltn_req
  RECORD person_prsnl_reltn_req(
    1 person_prsnl_reltn_qual = i4
    1 esi_ensure_type = c3
    1 person_prsnl_reltn[*]
      2 action_type = c3
      2 new_person = c1
      2 person_prsnl_reltn_id = f8
      2 person_id = f8
      2 person_prsnl_r_cd = f8
      2 prsnl_person_id = f8
      2 active_ind_ind = i2
      2 active_ind = i2
      2 active_status_cd = f8
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 data_status_cd = f8
      2 data_status_dt_tm = dq8
      2 data_status_prsnl_id = f8
      2 contributor_system_cd = f8
      2 free_text_cd = f8
      2 ft_prsnl_name = c100
      2 priority_seq = i4
      2 internal_seq = i4
      2 updt_cnt = i4
      2 manual_create_by_id = f8
      2 manual_inact_by_id = f8
      2 manual_create_dt_tm = dq8
      2 manual_inact_dt_tm = dq8
      2 manual_create_ind_ind = i2
      2 manual_create_ind = i2
      2 manual_inact_ind_ind = i2
      2 manual_inact_ind = i2
      2 notification_cd = f8
      2 transaction_dt_tm = dq8
      2 pm_hist_tracking_id = f8
      2 demog_reltn_id = f8
    1 mode = i2
    1 access_sensitive_data_ind = i2
  )
  SET person_prsnl_reltn_req->person_prsnl_reltn_qual = 1
  SET stat = alterlist(person_prsnl_reltn_req->person_prsnl_reltn,person_prsnl_reltn_req->
   person_prsnl_reltn_qual)
  SET person_prsnl_reltn_req->person_prsnl_reltn[1].person_prsnl_reltn_id = request->
  person_prsnl_reltn_id
  SET person_prsnl_reltn_req->person_prsnl_reltn[1].end_effective_dt_tm = request->
  new_end_effective_dt_tm
  SET person_prsnl_reltn_req->person_prsnl_reltn[1].ft_prsnl_name = " "
  FREE SET person_prsnl_reply
  RECORD person_prsnl_reply(
    1 person_prsnl_reltn_qual = i4
    1 person_prsnl_reltn[*]
      2 person_prsnl_reltn_id = f8
      2 pm_hist_tracking_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE pm_upt_person_prsnl_reltn  WITH replace("REQUEST","PERSON_PRSNL_RELTN_REQ"), replace(
   "REPLY","PERSON_PRSNL_REPLY")
  IF ((person_prsnl_reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ELSE
   SET reply->new_end_effective_dt_tm = request->new_end_effective_dt_tm
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 COMMIT
#exit_script
 SET dcp_script_version = "001 12/02/09 NC014668"
END GO
