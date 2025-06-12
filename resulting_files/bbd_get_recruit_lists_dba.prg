CREATE PROGRAM bbd_get_recruit_lists:dba
 RECORD reply(
   1 recruitinglist[*]
     2 list_id = f8
     2 display = vc
     2 display_key = vc
     2 donation_dt_tm = dq8
     2 product_type_cd = f8
     2 product_type_disp = c40
     2 product_type_mean = c12
     2 rare_type_cd = f8
     2 rare_type_disp = c40
     2 rare_type_mean = c12
     2 special_interest_cd = f8
     2 special_interest_disp = c40
     2 special_interest_mean = c12
     2 abo_cd = f8
     2 abo_disp = c40
     2 abo_mean = c12
     2 rh_cd = f8
     2 rh_disp = c40
     2 rh_mean = c12
     2 race_cd = f8
     2 race_disp = c40
     2 race_mean = c12
     2 organization_id = f8
     2 last_outcome_cd = f8
     2 last_outcome_disp = c40
     2 last_outcome_mean = c12
     2 contact_method_cd = f8
     2 contact_method_disp = c40
     2 contact_method_mean = c12
     2 max_donor_count = i2
     2 pref_don_loc_cd = f8
     2 pref_don_loc_disp = c40
     2 pref_don_loc_mean = c12
     2 multiple_list_ind = i2
     2 lock_ind = i2
     2 updt_cnt = i4
     2 zipcodelist[*]
       3 zip_code_id = f8
       3 zip_code = c25
       3 address_type_cd = f8
       3 address_type_disp = c40
       3 address_type_mean = c12
     2 antigenlist[*]
       3 antigen_id = f8
       3 antigen_cd = f8
       3 antigen_disp = c40
       3 antigen_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  rl.list_id, ra.recruit_antigen_id, rz.zip_code_id
  FROM bbd_recruiting_list rl,
   bbd_recruiting_antigen ra,
   bbd_recruiting_zipcode rz
  PLAN (rl
   WHERE rl.active_ind=1
    AND rl.completed_ind=0)
   JOIN (ra
   WHERE ra.list_id=outerjoin(rl.list_id))
   JOIN (rz
   WHERE rz.list_id=outerjoin(rl.list_id))
  ORDER BY rl.list_id, ra.recruit_antigen_id, rz.zip_code_id
  HEAD REPORT
   rl_cnt = 0
  HEAD rl.list_id
   ra_cnt = 0, rz_cnt = 0, rl_cnt = (rl_cnt+ 1)
   IF (size(reply->recruitinglist,5) < rl_cnt)
    lstat = alterlist(reply->recruitinglist,(rl_cnt+ 24))
   ENDIF
   reply->recruitinglist[rl_cnt].list_id = rl.list_id, reply->recruitinglist[rl_cnt].display = rl
   .display_name, reply->recruitinglist[rl_cnt].display_key = rl.display_name_key,
   reply->recruitinglist[rl_cnt].donation_dt_tm = rl.donation_dt_tm, reply->recruitinglist[rl_cnt].
   product_type_cd = rl.product_type_cd, reply->recruitinglist[rl_cnt].rare_type_cd = rl.rare_type_cd,
   reply->recruitinglist[rl_cnt].special_interest_cd = rl.special_interest_cd, reply->recruitinglist[
   rl_cnt].abo_cd = rl.abo_cd, reply->recruitinglist[rl_cnt].rh_cd = rl.rh_cd,
   reply->recruitinglist[rl_cnt].race_cd = rl.race_cd, reply->recruitinglist[rl_cnt].organization_id
    = rl.organization_id, reply->recruitinglist[rl_cnt].last_outcome_cd = rl.last_outcome_cd,
   reply->recruitinglist[rl_cnt].contact_method_cd = rl.contact_method_cd, reply->recruitinglist[
   rl_cnt].max_donor_count = rl.max_donor_cnt, reply->recruitinglist[rl_cnt].pref_don_loc_cd = rl
   .preferred_donation_location_cd,
   reply->recruitinglist[rl_cnt].multiple_list_ind = rl.multiple_list_ind, reply->recruitinglist[
   rl_cnt].lock_ind = rl.lock_ind, reply->recruitinglist[rl_cnt].updt_cnt = rl.updt_cnt
  HEAD ra.recruit_antigen_id
   IF (ra.recruit_antigen_id > 0.0)
    ra_cnt = (ra_cnt+ 1)
    IF (size(reply->recruitinglist[rl_cnt].antigenlist,5) < ra_cnt)
     lstat = alterlist(reply->recruitinglist[rl_cnt].antigenlist,(ra_cnt+ 9))
    ENDIF
    reply->recruitinglist[rl_cnt].antigenlist[ra_cnt].antigen_id = ra.recruit_antigen_id, reply->
    recruitinglist[rl_cnt].antigenlist[ra_cnt].antigen_cd = ra.antigen_cd
   ENDIF
  HEAD rz.zip_code_id
   IF (rz.zip_code_id > 0.0)
    rz_cnt = (rz_cnt+ 1)
    IF (size(reply->recruitinglist[rl_cnt].zipcodelist,5) < rz_cnt)
     lstat = alterlist(reply->recruitinglist[rl_cnt].zipcodelist,(rz_cnt+ 9))
    ENDIF
    reply->recruitinglist[rl_cnt].zipcodelist[rz_cnt].zip_code_id = rz.zip_code_id, reply->
    recruitinglist[rl_cnt].zipcodelist[rz_cnt].zip_code = rz.zip_code, reply->recruitinglist[rl_cnt].
    zipcodelist[rz_cnt].address_type_cd = rz.address_type_cd
   ENDIF
  DETAIL
   row + 0
  FOOT  rz.zip_code_id
   row + 0
  FOOT  ra.recruit_antigen_id
   row + 0
  FOOT  rl.list_id
   lstat = alterlist(reply->recruitinglist[rl_cnt].zipcodelist,rz_cnt), lstat = alterlist(reply->
    recruitinglist[rl_cnt].antigenlist,ra_cnt)
  FOOT REPORT
   lstat = alterlist(reply->recruitinglist,rl_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select Recruiting Lists",errmsg)
 ENDIF
 GO TO set_status
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
#set_status
 IF (size(reply->recruitinglist,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
