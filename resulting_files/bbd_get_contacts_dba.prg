CREATE PROGRAM bbd_get_contacts:dba
 RECORD reply(
   1 contactlist[*]
     2 active_ind = i2
     2 contact_dt_tm = dq8
     2 contact_id = f8
     2 contact_outcome_cd = f8
     2 contact_outcome_disp = c40
     2 contact_outcome_desc = c60
     2 contact_outcome_mean = c12
     2 contact_status_cd = f8
     2 contact_status_disp = c40
     2 contact_status_desc = c60
     2 contact_status_mean = c12
     2 contact_type_cd = f8
     2 contact_type_disp = c40
     2 contact_type_desc = c60
     2 contact_type_mean = c12
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_desc = c60
     2 contributor_system_mean = c12
     2 encounter_id = f8
     2 init_contact_prsnl_id = f8
     2 inventory_area_cd = f8
     2 inventory_area_disp = c40
     2 inventory_area_desc = c60
     2 inventory_area_mean = c12
     2 needed_dt_tm = dq8
     2 organization_id = f8
     2 owner_area_cd = f8
     2 owner_area_disp = c40
     2 owner_area_desc = c60
     2 owner_area_mean = c12
     2 person_id = f8
     2 updt_cnt = i4
     2 counsel_other_ind = i2
     2 donation_ind = i2
     2 recruitment_ind = i2
     2 note_ind = i2
     2 contactcounselingother
       3 contact_prsnl_id = f8
       3 contact_user_name = vc
       3 contact_name_formatted = vc
       3 follow_up_ind = i2
       3 method_cd = f8
       3 method_disp = c40
       3 method_desc = c60
       3 method_mean = c12
       3 other_contact_id = f8
       3 updt_cnt = i4
       3 donation_ident = c20
     2 contactdonation
       3 bag_type_cd = f8
       3 bag_type_disp = c40
       3 bag_type_desc = c60
       3 bag_type_mean = c12
       3 donation_result_id = f8
       3 drawn_dt_tm = dq8
       3 draw_station_cd = f8
       3 draw_station_disp = c40
       3 draw_station_desc = c60
       3 draw_station_mean = c12
       3 inv_area_cd = f8
       3 inv_area_disp = c40
       3 inv_area_desc = c60
       3 inv_area_mean = c12
       3 owner_area_cd = f8
       3 owner_area_disp = c40
       3 owner_area_desc = c60
       3 owner_area_mean = c12
       3 phleb_prsnl_id = f8
       3 phleb_user_name = vc
       3 phleb_name_formatted = vc
       3 procedure_cd = f8
       3 procedure_disp = c40
       3 procedure_desc = c60
       3 procedure_mean = c12
       3 specimen_unit_meas_cd = f8
       3 specimen_unit_meas_disp = c40
       3 specimen_unit_meas_desc = c60
       3 specimen_unit_meas_mean = c12
       3 specimen_volume = i4
       3 start_dt_tm = dq8
       3 stop_dt_tm = dq8
       3 total_volume = i4
       3 venipuncture_site_cd = f8
       3 venipuncture_site_disp = c40
       3 venipuncture_site_desc = c60
       3 venipuncture_site_mean = c12
       3 updt_cnt = i4
       3 donationproductlist[*]
         4 active_ind = i2
         4 donation_product_id = f8
         4 product_id = f8
         4 updt_cnt = i4
         4 product_nbr = c20
         4 product_sub_nbr = c5
         4 product_cd = f8
         4 product_disp = c40
         4 product_desc = vc
         4 product_mean = c12
     2 contactrecruitment
       3 recruit_list_id = f8
       3 recruit_prsnl_id = f8
       3 recruit_user_name = vc
       3 recruit_name_formatted = vc
       3 recruit_result_id = f8
       3 contact_method_cd = f8
       3 contact_method_disp = vc
       3 contact_method_desc = vc
       3 contact_method_mean = vc
       3 updt_cnt = i4
     2 contactnote
       3 active_ind = i2
       3 contact_note_id = f8
       3 create_dt_tm = dq8
       3 long_text_id = f8
       3 note_text = vc
       3 updt_cnt = i4
       3 long_text_updt_cnt = i4
     2 relatedcontactlist[*]
       3 active_ind = i2
       3 contact_reltn_id = f8
       3 related_contact_id = f8
       3 updt_cnt = i4
     2 donoreligibility
       3 eligibility_id = f8
       3 eligibility_type_cd = f8
       3 eligibility_type_disp = c40
       3 eligibility_type_desc = c60
       3 eligibility_type_mean = c12
       3 eligible_dt_tm = dq8
       3 updt_cnt = i4
       3 deferralreasonlist[*]
         4 active_ind = i2
         4 calc_elig_dt_tm = dq8
         4 deferral_reason_id = f8
         4 eligible_dt_tm = dq8
         4 occurred_dt_tm = dq8
         4 reason_cd = f8
         4 reason_disp = c40
         4 reason_desc = c60
         4 reason_mean = c12
         4 updt_cnt = i4
     2 exceptionlist[*]
       3 active_ind = i2
       3 exception_id = f8
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 override_reason_cd = f8
       3 override_reason_disp = c40
       3 override_reason_desc = c60
       3 override_reason_mean = c12
       3 updt_cnt = i4
       3 donor_abo_cd = f8
       3 donor_abo_disp = c40
       3 donor_abo_desc = c60
       3 donor_abo_mean = c12
       3 donor_rh_cd = f8
       3 donor_rh_disp = c40
       3 donor_rh_desc = c60
       3 donor_rh_mean = c12
       3 recipient_abo_cd = f8
       3 recipient_abo_disp = c40
       3 recipient_abo_desc = c60
       3 recipient_abo_mean = c12
       3 recipient_rh_cd = f8
       3 recipient_rh_disp = c40
       3 recipient_rh_desc = c60
       3 recipient_rh_mean = c12
       3 ineligible_until_dt_tm = dq8
       3 procedure_cd = f8
       3 donation_ident = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c16 WITH constant("bbd_get_contacts")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE contact_type_cs = i4 WITH constant(14220)
 DECLARE contact_counsel_mean = c12 WITH constant("COUNSEL")
 DECLARE contact_counsel_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_donate_mean = c12 WITH constant("DONATE")
 DECLARE contact_donate_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_other_mean = c12 WITH constant("OTHER")
 DECLARE contact_other_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_recruit_mean = c12 WITH constant("RECRUIT")
 DECLARE contact_recruit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_conf_mean = c12 WITH constant("CONFIDENTIAL")
 DECLARE contact_conf_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_interview_mean = c12 WITH constant("INTERVIEW")
 DECLARE contact_interview_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_donate_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_other_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_recruit_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_conf_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_counsel_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_interview_ind = i2 WITH protect, noconstant(0)
 DECLARE contact_count = i4 WITH protect, noconstant(0)
 DECLARE related_count = i4 WITH protect, noconstant(0)
 DECLARE product_count = i4 WITH protect, noconstant(0)
 DECLARE eligibility_count = i4 WITH protect, noconstant(0)
 DECLARE reason_count = i4 WITH protect, noconstant(0)
 DECLARE exception_count = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lactualsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE lexpandstart = i4 WITH protect, noconstant(1)
 SET contact_counsel_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_counsel_mean))
 IF (contact_counsel_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_counsel_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_donate_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_donate_mean))
 IF (contact_donate_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_donate_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_other_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_other_mean))
 IF (contact_other_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_other_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_recruit_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_recruit_mean))
 IF (contact_recruit_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_recruit_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_conf_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_conf_mean))
 IF (contact_conf_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_conf_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_interview_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_interview_mean
   ))
 IF (contact_interview_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_interview_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SELECT
  IF (size(request->contactlist,5) > 0)
   PLAN (dc
    WHERE expand(i_idx,1,size(request->contactlist,5),dc.contact_id,request->contactlist[i_idx].
     contact_id)
     AND dc.active_ind=1)
  ELSEIF (size(request->donorlist,5) > 0)
   PLAN (dc
    WHERE expand(i_idx,1,size(request->donorlist,5),dc.person_id,request->donorlist[i_idx].person_id)
     AND (((request->from_dt_tm != 0)
     AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->from_dt_tm) AND cnvtdatetime(request->
     to_dt_tm)) OR ((request->from_dt_tm=0)))
     AND (((request->contact_type_cd > 0.0)
     AND (dc.contact_type_cd=request->contact_type_cd)) OR ((request->contact_type_cd=0.0)))
     AND (((request->contact_status_cd > 0.0)
     AND (dc.contact_status_cd=request->contact_status_cd)) OR ((request->contact_status_cd=0.0)))
     AND dc.active_ind=1)
  ELSEIF ((request->from_dt_tm != 0))
   PLAN (dc
    WHERE dc.contact_dt_tm BETWEEN cnvtdatetime(request->from_dt_tm) AND cnvtdatetime(request->
     to_dt_tm)
     AND (((request->contact_type_cd > 0.0)
     AND (dc.contact_type_cd=request->contact_type_cd)) OR ((request->contact_type_cd=0.0)))
     AND (((request->contact_status_cd > 0.0)
     AND ((dc.contact_status_cd+ 0)=request->contact_status_cd)) OR ((request->contact_status_cd=0.0)
    ))
     AND dc.active_ind=1)
  ELSEIF ((request->contact_type_cd > 0.0))
   PLAN (dc
    WHERE (dc.contact_type_cd=request->contact_type_cd)
     AND (((request->contact_status_cd > 0.0)
     AND (dc.contact_status_cd=request->contact_status_cd)) OR ((request->contact_status_cd=0.0)))
     AND dc.active_ind=1)
  ELSE
   PLAN (dc
    WHERE dc.contact_id=0.0)
  ENDIF
  INTO "nl:"
  dc.*
  FROM bbd_donor_contact dc
  ORDER BY dc.contact_id
  HEAD REPORT
   contact_count = 0
  HEAD dc.contact_id
   IF (dc.contact_id > 0.0)
    contact_count = (contact_count+ 1)
    IF (mod(contact_count,10)=1)
     stat = alterlist(reply->contactlist,(contact_count+ 9))
    ENDIF
    CASE (dc.contact_type_cd)
     OF contact_counsel_cd:
      contact_counsel_ind = 1
     OF contact_other_cd:
      contact_other_ind = 1
     OF contact_donate_cd:
      contact_donate_ind = 1
     OF contact_recruit_cd:
      contact_recruit_ind = 1
     OF contact_conf_cd:
      contact_conf_ind = 1
     OF contact_interview_cd:
      contact_interview_ind = 1
    ENDCASE
    reply->contactlist[contact_count].active_ind = dc.active_ind, reply->contactlist[contact_count].
    contact_dt_tm = dc.contact_dt_tm, reply->contactlist[contact_count].contact_id = dc.contact_id,
    reply->contactlist[contact_count].contact_outcome_cd = dc.contact_outcome_cd, reply->contactlist[
    contact_count].contact_status_cd = dc.contact_status_cd, reply->contactlist[contact_count].
    contact_type_cd = dc.contact_type_cd,
    reply->contactlist[contact_count].encounter_id = dc.encntr_id, reply->contactlist[contact_count].
    init_contact_prsnl_id = dc.init_contact_prsnl_id, reply->contactlist[contact_count].
    inventory_area_cd = dc.inventory_area_cd,
    reply->contactlist[contact_count].needed_dt_tm = dc.needed_dt_tm, reply->contactlist[
    contact_count].organization_id = dc.organization_id, reply->contactlist[contact_count].
    owner_area_cd = dc.owner_area_cd,
    reply->contactlist[contact_count].person_id = dc.person_id, reply->contactlist[contact_count].
    updt_cnt = dc.updt_cnt, reply->contactlist[contact_count].contributor_system_cd = dc
    .contributor_system_cd
   ENDIF
  DETAIL
   row + 0
  FOOT  dc.contact_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->contactlist,contact_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select contacts",errmsg)
 ENDIF
 IF (contact_count=0)
  GO TO set_status
 ENDIF
 SET lexpandstart = 1
 SET lactualsize = contact_count
 SET lexpandsize = determineexpandsize(lactualsize,100)
 SET lexpandtotal = determineexpandtotal(lactualsize,lexpandsize)
 SET stat = alterlist(reply->contactlist,lexpandtotal)
 FOR (i = (lactualsize+ 1) TO lexpandtotal)
   SET reply->contactlist[i].contact_id = reply->contactlist[lactualsize].contact_id
 ENDFOR
 SELECT INTO "nl:"
  cr.*, llocatestart = lexpandstart
  FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
   bbd_donor_contact_r cr
  PLAN (d
   WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
   JOIN (cr
   WHERE expand(lcnt,lexpandstart,((lexpandstart+ lexpandsize) - 1),cr.contact_id,reply->contactlist[
    lcnt].contact_id)
    AND cr.active_ind=1)
  HEAD cr.contact_id
   lcontactindex = locateval(lcnt,llocatestart,((llocatestart+ lexpandsize) - 1),cr.contact_id,reply
    ->contactlist[lcnt].contact_id), related_count = 0
  DETAIL
   related_count = (related_count+ 1)
   IF (mod(related_count,10)=1)
    stat = alterlist(reply->contactlist[lcontactindex].relatedcontactlist,(related_count+ 9))
   ENDIF
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].active_ind = cr.active_ind,
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].contact_reltn_id = cr
   .contact_reltn_id, reply->contactlist[lcontactindex].relatedcontactlist[related_count].
   related_contact_id = cr.related_contact_id,
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].updt_cnt = cr.updt_cnt
  FOOT  cr.contact_id
   stat = alterlist(reply->contactlist[lcontactindex].relatedcontactlist,related_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select related contacts",errmsg)
 ENDIF
 SET lexpandstart = 1
 SET lactualsize = contact_count
 SET lexpandsize = determineexpandsize(lactualsize,100)
 SET lexpandtotal = determineexpandtotal(lactualsize,lexpandsize)
 SET stat = alterlist(reply->contactlist,lexpandtotal)
 FOR (i = (lactualsize+ 1) TO lexpandtotal)
   SET reply->contactlist[i].contact_id = reply->contactlist[lactualsize].contact_id
 ENDFOR
 SELECT INTO "nl:"
  cr.*, llocatestart = lexpandstart
  FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
   bbd_donor_contact_r cr
  PLAN (d
   WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
   JOIN (cr
   WHERE expand(lcnt,lexpandstart,((lexpandstart+ lexpandsize) - 1),cr.related_contact_id,reply->
    contactlist[lcnt].contact_id)
    AND cr.active_ind=1)
  HEAD cr.related_contact_id
   lcontactindex = locateval(lcnt,llocatestart,((llocatestart+ lexpandsize) - 1),cr
    .related_contact_id,reply->contactlist[lcnt].contact_id), related_count = size(reply->
    contactlist[lcontactindex].relatedcontactlist,5), stat = alterlist(reply->contactlist[
    lcontactindex].relatedcontactlist,((10 - mod(related_count,10))+ related_count))
  DETAIL
   related_count = (related_count+ 1)
   IF (mod(related_count,10)=1)
    stat = alterlist(reply->contactlist[lcontactindex].relatedcontactlist,(related_count+ 9))
   ENDIF
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].active_ind = cr.active_ind,
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].contact_reltn_id = cr
   .contact_reltn_id, reply->contactlist[lcontactindex].relatedcontactlist[related_count].
   related_contact_id = cr.contact_id,
   reply->contactlist[lcontactindex].relatedcontactlist[related_count].updt_cnt = cr.updt_cnt
  FOOT  cr.related_contact_id
   stat = alterlist(reply->contactlist[lcontactindex].relatedcontactlist,related_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select related contacts",errmsg)
 ENDIF
 SET stat = alterlist(reply->contactlist,lactualsize)
 IF (((contact_other_ind=1) OR (((contact_conf_ind=1) OR (((contact_counsel_ind=1) OR (
 contact_interview_ind=1)) )) )) )
  SELECT INTO "nl:"
   oc.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_other_contact oc,
    prsnl p
   PLAN (d
    WHERE (reply->contactlist[d.seq].donation_ind != 1)
     AND (reply->contactlist[d.seq].recruitment_ind != 1))
    JOIN (oc
    WHERE (oc.contact_id=reply->contactlist[d.seq].contact_id)
     AND oc.active_ind=1)
    JOIN (p
    WHERE p.person_id=oc.contact_prsnl_id)
   ORDER BY d.seq
   DETAIL
    reply->contactlist[d.seq].counsel_other_ind = 1, reply->contactlist[d.seq].contactcounselingother
    .contact_prsnl_id = oc.contact_prsnl_id, reply->contactlist[d.seq].contactcounselingother.
    contact_user_name = p.username,
    reply->contactlist[d.seq].contactcounselingother.contact_name_formatted = p.name_full_formatted,
    reply->contactlist[d.seq].contactcounselingother.follow_up_ind = oc.follow_up_ind, reply->
    contactlist[d.seq].contactcounselingother.method_cd = oc.method_cd,
    reply->contactlist[d.seq].contactcounselingother.other_contact_id = oc.other_contact_id, reply->
    contactlist[d.seq].contactcounselingother.updt_cnt = oc.updt_cnt, reply->contactlist[d.seq].
    contactcounselingother.donation_ident = oc.donation_ident
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select counsel/other",errmsg)
  ENDIF
 ENDIF
 IF (contact_recruit_ind=1)
  SELECT INTO "nl:"
   rr.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_recruitment_rslts rr,
    prsnl p2
   PLAN (d
    WHERE (reply->contactlist[d.seq].counsel_other_ind != 1)
     AND (reply->contactlist[d.seq].donation_ind != 1))
    JOIN (rr
    WHERE (rr.contact_id=reply->contactlist[d.seq].contact_id)
     AND rr.active_ind=1)
    JOIN (p2
    WHERE p2.person_id=rr.recruit_prsnl_id)
   ORDER BY d.seq
   DETAIL
    reply->contactlist[d.seq].recruitment_ind = 1, reply->contactlist[d.seq].contactrecruitment.
    recruit_list_id = rr.recruit_list_id, reply->contactlist[d.seq].contactrecruitment.
    recruit_prsnl_id = rr.recruit_prsnl_id,
    reply->contactlist[d.seq].contactrecruitment.recruit_user_name = p2.username, reply->contactlist[
    d.seq].contactrecruitment.recruit_name_formatted = p2.name_full_formatted, reply->contactlist[d
    .seq].contactrecruitment.recruit_result_id = rr.recruit_result_id,
    reply->contactlist[d.seq].contactrecruitment.contact_method_cd = rr.contact_method_cd, reply->
    contactlist[d.seq].contactrecruitment.updt_cnt = rr.updt_cnt
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select Recruitment",errmsg)
  ENDIF
 ENDIF
 IF (contact_donate_ind=1)
  SELECT INTO "nl:"
   dr.*, dp.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_donation_results dr,
    prsnl p3,
    bbd_don_product_r dp,
    product p,
    bbhist_product bhp
   PLAN (d
    WHERE (reply->contactlist[d.seq].counsel_other_ind != 1)
     AND (reply->contactlist[d.seq].recruitment_ind != 1))
    JOIN (dr
    WHERE (dr.contact_id=reply->contactlist[d.seq].contact_id)
     AND dr.active_ind=1)
    JOIN (p3
    WHERE p3.person_id=dr.phleb_prsnl_id)
    JOIN (dp
    WHERE outerjoin(dr.donation_result_id)=dp.donation_results_id
     AND outerjoin(1)=dp.active_ind)
    JOIN (p
    WHERE outerjoin(dp.product_id)=p.product_id
     AND outerjoin(1)=p.active_ind)
    JOIN (bhp
    WHERE outerjoin(dp.product_id)=bhp.product_id
     AND outerjoin(1)=bhp.active_ind)
   ORDER BY d.seq, dr.donation_result_id, dp.donation_product_id
   HEAD dr.donation_result_id
    product_count = 0, reply->contactlist[d.seq].donation_ind = 1, reply->contactlist[d.seq].
    contactdonation.bag_type_cd = dr.bag_type_cd,
    reply->contactlist[d.seq].contactdonation.donation_result_id = dr.donation_result_id, reply->
    contactlist[d.seq].contactdonation.drawn_dt_tm = dr.drawn_dt_tm, reply->contactlist[d.seq].
    contactdonation.draw_station_cd = dr.draw_station_cd,
    reply->contactlist[d.seq].contactdonation.inv_area_cd = dr.inv_area_cd, reply->contactlist[d.seq]
    .contactdonation.owner_area_cd = dr.owner_area_cd, reply->contactlist[d.seq].contactdonation.
    phleb_prsnl_id = dr.phleb_prsnl_id,
    reply->contactlist[d.seq].contactdonation.phleb_user_name = p3.username, reply->contactlist[d.seq
    ].contactdonation.phleb_name_formatted = p3.name_full_formatted, reply->contactlist[d.seq].
    contactdonation.procedure_cd = dr.procedure_cd,
    reply->contactlist[d.seq].contactdonation.specimen_unit_meas_cd = dr.specimen_unit_meas_cd, reply
    ->contactlist[d.seq].contactdonation.specimen_volume = dr.specimen_volume, reply->contactlist[d
    .seq].contactdonation.start_dt_tm = dr.start_dt_tm,
    reply->contactlist[d.seq].contactdonation.stop_dt_tm = dr.stop_dt_tm, reply->contactlist[d.seq].
    contactdonation.total_volume = dr.total_volume, reply->contactlist[d.seq].contactdonation.
    venipuncture_site_cd = dr.venipuncture_site_cd,
    reply->contactlist[d.seq].contactdonation.updt_cnt = dr.updt_cnt
   HEAD dp.donation_product_id
    IF (dp.donation_product_id > 0.0)
     product_count = (product_count+ 1)
     IF (mod(product_count,10)=1)
      stat = alterlist(reply->contactlist[d.seq].contactdonation.donationproductlist,(product_count+
       9))
     ENDIF
     reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].active_ind = dp
     .active_ind, reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].
     donation_product_id = dp.donation_product_id, reply->contactlist[d.seq].contactdonation.
     donationproductlist[product_count].product_id = dp.product_id,
     reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].updt_cnt = dp
     .updt_cnt
     IF (p.product_id > 0.0)
      reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].product_nbr = p
      .product_nbr, reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].
      product_sub_nbr = p.product_sub_nbr, reply->contactlist[d.seq].contactdonation.
      donationproductlist[product_count].product_cd = p.product_cd
     ELSEIF (bhp.product_id > 0.0)
      reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].product_nbr = bhp
      .product_nbr, reply->contactlist[d.seq].contactdonation.donationproductlist[product_count].
      product_sub_nbr = bhp.product_sub_nbr, reply->contactlist[d.seq].contactdonation.
      donationproductlist[product_count].product_cd = bhp.product_cd
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  dp.donation_product_id
    row + 0
   FOOT  dr.donation_result_id
    stat = alterlist(reply->contactlist[d.seq].contactdonation.donationproductlist,product_count)
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select donation results",errmsg)
  ENDIF
 ENDIF
 IF (contact_counsel_ind=1)
  SELECT INTO "nl:"
   cn.*, lt.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_counseling_note cn,
    long_text lt
   PLAN (d)
    JOIN (cn
    WHERE (cn.contact_id=reply->contactlist[d.seq].contact_id)
     AND cn.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=cn.long_text_id
     AND lt.active_ind=1)
   ORDER BY d.seq
   DETAIL
    reply->contactlist[d.seq].note_ind = 1, reply->contactlist[d.seq].contactnote.active_ind = cn
    .active_ind, reply->contactlist[d.seq].contactnote.contact_note_id = cn.counseling_note_id,
    reply->contactlist[d.seq].contactnote.create_dt_tm = cn.create_dt_tm, reply->contactlist[d.seq].
    contactnote.long_text_id = cn.long_text_id, reply->contactlist[d.seq].contactnote.updt_cnt = cn
    .updt_cnt,
    reply->contactlist[d.seq].contactnote.note_text = lt.long_text, reply->contactlist[d.seq].
    contactnote.long_text_updt_cnt = lt.updt_cnt
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select counseling notes",errmsg)
  ENDIF
 ENDIF
 IF (contact_conf_ind=1)
  SELECT INTO "nl:"
   cn.*, lt.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_confidential_note cn,
    long_text lt
   PLAN (d)
    JOIN (cn
    WHERE (cn.contact_id=reply->contactlist[d.seq].contact_id)
     AND cn.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=cn.long_text_id
     AND lt.active_ind=1)
   ORDER BY d.seq
   DETAIL
    reply->contactlist[d.seq].note_ind = 1, reply->contactlist[d.seq].contactnote.active_ind = cn
    .active_ind, reply->contactlist[d.seq].contactnote.contact_note_id = cn.confidential_id,
    reply->contactlist[d.seq].contactnote.create_dt_tm = cn.create_dt_tm, reply->contactlist[d.seq].
    contactnote.long_text_id = cn.long_text_id, reply->contactlist[d.seq].contactnote.updt_cnt = cn
    .updt_cnt,
    reply->contactlist[d.seq].contactnote.note_text = lt.long_text, reply->contactlist[d.seq].
    contactnote.long_text_updt_cnt = lt.updt_cnt
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select confidential notes",errmsg)
  ENDIF
 ENDIF
 IF (((contact_recruit_ind=1) OR (((contact_donate_ind=1) OR (((contact_other_ind=1) OR (
 contact_interview_ind=1)) )) )) )
  SELECT INTO "nl:"
   cn.*, lt.*
   FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
    bbd_contact_note cn,
    long_text lt
   PLAN (d)
    JOIN (cn
    WHERE (cn.contact_id=reply->contactlist[d.seq].contact_id)
     AND cn.contact_type_cd IN (contact_recruit_cd, contact_other_cd, contact_donate_cd,
    contact_interview_cd)
     AND cn.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=cn.long_text_id
     AND lt.active_ind=1)
   ORDER BY d.seq
   DETAIL
    reply->contactlist[d.seq].note_ind = 1, reply->contactlist[d.seq].contactnote.active_ind = cn
    .active_ind, reply->contactlist[d.seq].contactnote.contact_note_id = cn.contact_note_id,
    reply->contactlist[d.seq].contactnote.create_dt_tm = cn.create_dt_tm, reply->contactlist[d.seq].
    contactnote.long_text_id = cn.long_text_id, reply->contactlist[d.seq].contactnote.updt_cnt = cn
    .updt_cnt,
    reply->contactlist[d.seq].contactnote.note_text = lt.long_text, reply->contactlist[d.seq].
    contactnote.long_text_updt_cnt = lt.updt_cnt
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select contact notes",errmsg)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  de.*, df.*
  FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
   bbd_donor_eligibility de,
   bbd_deferral_reason df
  PLAN (d)
   JOIN (de
   WHERE (de.contact_id=reply->contactlist[d.seq].contact_id)
    AND de.active_ind=1)
   JOIN (df
   WHERE outerjoin(de.eligibility_id)=df.eligibility_id
    AND outerjoin(1)=df.active_ind)
  ORDER BY d.seq, de.eligibility_id, df.deferral_reason_id
  HEAD de.eligibility_id
   reason_count = 0, reply->contactlist[d.seq].donoreligibility.eligible_dt_tm = de.eligible_dt_tm,
   reply->contactlist[d.seq].donoreligibility.eligibility_id = de.eligibility_id,
   reply->contactlist[d.seq].donoreligibility.eligibility_type_cd = de.eligibility_type_cd, reply->
   contactlist[d.seq].donoreligibility.updt_cnt = de.updt_cnt
  HEAD df.deferral_reason_id
   IF (df.deferral_reason_id > 0.0)
    reason_count = (reason_count+ 1)
    IF (mod(reason_count,10)=1)
     stat = alterlist(reply->contactlist[d.seq].donoreligibility.deferralreasonlist,(reason_count+ 9)
      )
    ENDIF
    reply->contactlist[d.seq].donoreligibility.deferralreasonlist[reason_count].active_ind = df
    .active_ind, reply->contactlist[d.seq].donoreligibility.deferralreasonlist[reason_count].
    calc_elig_dt_tm = df.calc_elig_dt_tm, reply->contactlist[d.seq].donoreligibility.
    deferralreasonlist[reason_count].deferral_reason_id = df.deferral_reason_id,
    reply->contactlist[d.seq].donoreligibility.deferralreasonlist[reason_count].eligible_dt_tm = df
    .eligible_dt_tm, reply->contactlist[d.seq].donoreligibility.deferralreasonlist[reason_count].
    occurred_dt_tm = df.occurred_dt_tm, reply->contactlist[d.seq].donoreligibility.
    deferralreasonlist[reason_count].reason_cd = df.reason_cd,
    reply->contactlist[d.seq].donoreligibility.deferralreasonlist[reason_count].updt_cnt = df
    .updt_cnt
   ENDIF
  DETAIL
   row + 0
  FOOT  df.deferral_reason_id
   row + 0
  FOOT  de.eligibility_id
   stat = alterlist(reply->contactlist[d.seq].donoreligibility.deferralreasonlist,reason_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select eligibility and reasons",errmsg)
 ENDIF
 SELECT INTO "nl:"
  be.*
  FROM (dummyt d  WITH seq = value(size(reply->contactlist,5))),
   bb_exception be
  PLAN (d)
   JOIN (be
   WHERE (be.donor_contact_id=reply->contactlist[d.seq].contact_id)
    AND be.active_ind=1)
  ORDER BY d.seq, be.exception_id
  HEAD d.seq
   exception_count = 0
  HEAD be.exception_id
   exception_count = (exception_count+ 1)
   IF (mod(exception_count,10)=1)
    stat = alterlist(reply->contactlist[d.seq].exceptionlist,(exception_count+ 9))
   ENDIF
   reply->contactlist[d.seq].exceptionlist[exception_count].active_ind = be.active_ind, reply->
   contactlist[d.seq].exceptionlist[exception_count].exception_id = be.exception_id, reply->
   contactlist[d.seq].exceptionlist[exception_count].exception_type_cd = be.exception_type_cd,
   reply->contactlist[d.seq].exceptionlist[exception_count].override_reason_cd = be
   .override_reason_cd, reply->contactlist[d.seq].exceptionlist[exception_count].updt_cnt = be
   .updt_cnt, reply->contactlist[d.seq].exceptionlist[exception_count].donor_abo_cd = be
   .product_abo_cd,
   reply->contactlist[d.seq].exceptionlist[exception_count].donor_rh_cd = be.product_rh_cd, reply->
   contactlist[d.seq].exceptionlist[exception_count].recipient_abo_cd = be.person_abo_cd, reply->
   contactlist[d.seq].exceptionlist[exception_count].recipient_rh_cd = be.person_rh_cd,
   reply->contactlist[d.seq].exceptionlist[exception_count].ineligible_until_dt_tm = cnvtdatetime(be
    .ineligible_until_dt_tm), reply->contactlist[d.seq].exceptionlist[exception_count].procedure_cd
    = be.procedure_cd, reply->contactlist[d.seq].exceptionlist[exception_count].donation_ident = be
   .donation_ident
  DETAIL
   row + 0
  FOOT  be.exception_id
   row + 0
  FOOT  d.seq
   stat = alterlist(reply->contactlist[d.seq].exceptionlist,exception_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select contact exceptions",errmsg)
 ENDIF
 GO TO set_status
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 DECLARE determineexpandtotal(lactualsize=i4,lexpandsize=i4) = i4 WITH protect, noconstant(0)
 SUBROUTINE determineexpandtotal(lactualsize,lexpandsize)
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 DECLARE determineexpandsize(lrecordsize=i4,lmaximumsize=i4) = i4 WITH protect, noconstant(0)
 SUBROUTINE determineexpandsize(lrecordsize,lmaximumsize)
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
#set_status
 IF (contact_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
