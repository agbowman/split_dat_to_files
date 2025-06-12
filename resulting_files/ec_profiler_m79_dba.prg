CREATE PROGRAM ec_profiler_m79:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE srecontype = vc WITH noconstant(" ")
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    order_recon r
   PLAN (r
    WHERE r.performed_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (elh
    WHERE elh.encntr_id=r.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND elh.active_ind=1
     AND r.performed_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   ORDER BY elh.loc_facility_cd, r.recon_type_flag
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
    position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
    reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
    positions[1].capability_in_use_ind = 1
   HEAD r.recon_type_flag
    CASE (r.recon_type_flag)
     OF 1:
      srecontype = "Admission"
     OF 2:
      srecontype = "Transfer"
     OF 3:
      srecontype = "Discharge"
     OF 4:
      srecontype = "Short Term Leave"
     OF 5:
      srecontype = "Return from Short Term Leave"
    ENDCASE
    ordercnt = 0
   DETAIL
    ordercnt = (ordercnt+ 1)
   FOOT  r.recon_type_flag
    detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
    facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[facilitycnt]
     .positions[1].details,detailcnt),
    reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = srecontype, reply->
    facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
      ordercnt))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
