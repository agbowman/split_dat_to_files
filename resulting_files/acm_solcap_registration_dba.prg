CREATE PROGRAM acm_solcap_registration:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00115.1"
 SELECT INTO "nl:"
  eligibility_trans_cnt = count(te.transaction_eligibility_id), prsnl_cnt = count(DISTINCT te
   .submitter_prsnl_id)
  FROM transaction_eligibility te
  WHERE ((te.transaction_eligibility_id+ 0) > 0.0)
   AND te.sent_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND ((te.submitter_prsnl_id+ 0) > 0.0)
  DETAIL
   reply->solcap[1].degree_of_use_num = eligibility_trans_cnt, reply->solcap[1].distinct_user_count
    = prsnl_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  eligibility_trans_per_facility = count(e.loc_facility_cd), e.loc_facility_cd
  FROM transaction_eligibility te,
   encounter e
  WHERE ((te.transaction_eligibility_id+ 0) > 0.0)
   AND te.sent_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND e.encntr_id=te.encntr_id
   AND ((te.encntr_id+ 0) > 0.0)
   AND ((te.submitter_prsnl_id+ 0) > 0.0)
   AND ((e.loc_facility_cd+ 0) > 0.0)
  GROUP BY e.loc_facility_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].facility,(index+ 9))
   ENDIF
   reply->solcap[1].facility[index].display = uar_get_code_display(e.loc_facility_cd), reply->solcap[
   1].facility[index].value_num = eligibility_trans_per_facility
  FOOT REPORT
   stat = alterlist(reply->solcap[1].facility,index)
 ;end select
 SELECT INTO "nl:"
  eligibility_trans_per_position = count(p.position_cd), p.position_cd
  FROM transaction_eligibility te,
   prsnl p
  WHERE ((te.transaction_eligibility_id+ 0) > 0.0)
   AND te.sent_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND p.person_id=te.submitter_prsnl_id
   AND te.submitter_prsnl_id > 0.0
   AND ((p.position_cd+ 0) > 0.0)
  GROUP BY p.position_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].position,(index+ 9))
   ENDIF
   reply->solcap[1].position[index].display = uar_get_code_display(p.position_cd), reply->solcap[1].
   position[index].value_num = eligibility_trans_per_position
  FOOT REPORT
   stat = alterlist(reply->solcap[1].position,index)
 ;end select
END GO
