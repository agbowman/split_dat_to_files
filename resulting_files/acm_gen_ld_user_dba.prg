CREATE PROGRAM acm_gen_ld_user:dba
 IF (validate(acm_gen_ld_user_rep)=0)
  RECORD acm_gen_ld_user_rep(
    1 person_id = f8
    1 status_block
      2 status_ind = i2
      2 status_code = i4
  )
 ENDIF
 SUBROUTINE (genlduser(user=vc(ref)) =i4)
   RETURN(failure)
 END ;Subroutine
 DECLARE success = i4 WITH protect, constant(1)
 DECLARE failure = i4 WITH protect, constant(0)
 DECLARE valid_user_set = i4 WITH protect, constant(2)
 DECLARE unknown_status = i4 WITH protect, constant(- (1))
 DECLARE invalid_ld = i4 WITH protect, constant(- (2))
 DECLARE invalid_user_set = i4 WITH protect, constant(- (3))
 DECLARE unauthorized = i4 WITH protect, constant(- (4))
 DECLARE cur_datetime = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE dba_position = f8 WITH protect, noconstant(uar_get_code_by("MEANING",88,"DBA"))
 IF (dba_position <= 0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=88
    AND cv.cdf_meaning="DBA"
    AND cv.active_ind=1
   ORDER BY cv.code_value
   HEAD REPORT
    dba_position = cv.code_value
   DETAIL
    IF (cv.display_key="DBA")
     dba_position = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE usernumber = i4 WITH protect, noconstant(0)
 DECLARE userexists = i2 WITH protect, noconstant(1)
 DECLARE genusername = vc WITH protect, noconstant(concat("CERSD",trim(cnvtstring(floor(
      acm_gen_ld_user_req->logical_domain_id)))))
 DECLARE status = i4 WITH protect, noconstant
 DECLARE hqual = i4 WITH protect, noconstant(0)
 DECLARE hrecord = i4 WITH protect, noconstant(0)
 DECLARE hlist = i4 WITH protect, noconstant(0)
 SET acm_gen_ld_user_rep->status_block.status_ind = failure
 SET acm_gen_ld_user_rep->status_block.status_code = unknown_status
 SELECT INTO "nl:"
  pnullind = nullind(p.person_id)
  FROM logical_domain ld,
   prsnl p
  PLAN (ld
   WHERE (ld.logical_domain_id=acm_gen_ld_user_req->logical_domain_id)
    AND ld.active_ind=1)
   JOIN (p
   WHERE (p.person_id= Outerjoin(ld.system_user_id)) )
  DETAIL
   IF (ld.system_user_id != 0)
    acm_gen_ld_user_rep->person_id = ld.system_user_id
    IF (((pnullind=1) OR (((p.active_ind != 1) OR ( NOT (cnvtdatetime(cur_datetime) BETWEEN p
    .beg_effective_dt_tm AND p.end_effective_dt_tm))) )) )
     acm_gen_ld_user_rep->status_block.status_ind = failure, acm_gen_ld_user_rep->status_block.
     status_code = invalid_user_set
    ELSE
     acm_gen_ld_user_rep->status_block.status_ind = success, acm_gen_ld_user_rep->status_block.
     status_code = valid_user_set
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=1
  AND (acm_gen_ld_user_rep->status_block.status_code=unknown_status))
  EXECUTE acm_sec_auth
  SET status = nfail
  WHILE (userexists > 0)
    SET status = beginauth(auth_queryuser)
    IF (status=nfail)
     SET acm_gen_ld_user_rep->status_block.status_ind = failure
     SET acm_gen_ld_user_rep->status_block.status_code = unauthorized
     GO TO exit_script
    ENDIF
    SET hqual = uar_srvadditem(mhrequest,"usernamelist")
    CALL uar_srvsetstring(hqual,"username",nullterm(genusername))
    SET status = performauth(null)
    IF (status=nfail)
     CALL endauth(null)
     SET acm_gen_ld_user_rep->status_block.status_ind = failure
     SET acm_gen_ld_user_rep->status_block.status_code = unauthorized
     GO TO exit_script
    ENDIF
    SET hlist = uar_srvgetitem(mhreply,"userlist",0)
    IF (hlist != 0
     AND char(uar_srvgetchar(hlist,"userexists"))="Y")
     SET userexists = 1
    ELSE
     SET userexists = 0
    ENDIF
    CALL endauth(null)
    SET hlist = 0
    SET status = nfail
    SET hqual = 0
    IF (userexists=0)
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE username=genusername
     ;end select
     SET userexists = curqual
    ENDIF
    IF (userexists > 0)
     IF (genlduser(genusername)=failure)
      SET acm_gen_ld_user_rep->status_block.status_ind = failure
      SET acm_gen_ld_user_rep->status_block.status_code = unknown_status
      GO TO exit_script
     ENDIF
    ENDIF
  ENDWHILE
  FREE SET request
  FREE SET reply
  RECORD request(
    1 person_id = f8
    1 person_mod_ind = i2
    1 prsnl_type_meaning = c12
    1 username = vc
    1 active_ind = i2
    1 physician_ind = i2
    1 email = vc
    1 position_cd = f8
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 prim_assign_loc_cd = f8
    1 name_last = vc
    1 name_first = vc
    1 name_middle = vc
    1 name_initials = vc
    1 name_full = vc
    1 name_original = vc
    1 name_degree = vc
    1 name_title = vc
    1 name_suffix = vc
    1 person_name_type_meaning = c12
    1 person_name_last = vc
    1 person_name_first = vc
    1 person_name_middle = vc
    1 person_name_initials = vc
    1 person_name_full = vc
    1 person_name_original = vc
    1 person_name_degree = vc
    1 person_name_title = vc
    1 person_name_suffix = vc
    1 person_person_name_type_meaning = c12
    1 birth_dt_tm = dq8
    1 sex_cd = f8
  )
  RECORD reply(
    1 person_id = f8
    1 prsnl_alias_id = f8
    1 alias = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET request->username = genusername
  SET request->position_cd = dba_position
  SET request->prsnl_type_meaning = "USER"
  SET request->active_ind = 1
  SET request->beg_effective_dt_tm = cnvtdatetime(cur_datetime)
  SET request->end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
  SET request->name_last = "DomainUser"
  SET request->name_first = "Generated"
  SET request->name_initials = "GDU"
  SET request->name_full = concat("Generated Domain User for ",trim(cnvtstring(floor(
      acm_gen_ld_user_req->logical_domain_id))))
  SET request->person_name_type_meaning = "PRSNL"
  SET request->person_name_last = request->name_last
  SET request->person_name_first = request->name_first
  SET request->person_name_initials = request->name_initials
  SET request->person_name_full = request->name_full
  SET request->person_person_name_type_meaning = "CURRENT"
  EXECUTE uzr_add_prsnl
  IF ((reply->status_data.status="S"))
   SET status = beginauth(auth_adduser)
   IF (status=nfail)
    SET acm_gen_ld_user_rep->status_block.status_ind = failure
    SET acm_gen_ld_user_rep->status_block.status_code = unauthorized
    GO TO exit_script
   ENDIF
   SET hrecord = uar_srvgetstruct(mhrequest,"userrecord")
   CALL uar_srvsetstring(hrecord,"username",nullterm(genusername))
   CALL uar_srvsetstring(hrecord,"password",nullterm(""))
   CALL uar_srvsetstring(hrecord,"owner",nullterm(curuser))
   CALL uar_srvsetchar(hrecord,"directoryind",ichar("N"))
   SET hqual = uar_srvadditem(hrecord,"restrictionlist")
   CALL uar_srvsetstring(hqual,"restriction",nullterm(""))
   SET hqual = uar_srvadditem(hrecord,"restrictionlist")
   CALL uar_srvsetstring(hqual,"restriction",nullterm("SystemAccount"))
   CALL uar_srvsetshort(hrecord,"pwdlifetime",0)
   SET status = performauth(null)
   IF (status=nfail)
    SET acm_gen_ld_user_rep->status_block.status_ind = failure
    SET acm_gen_ld_user_rep->status_block.status_code = unauthorized
    CALL endauth(null)
    GO TO exit_script
   ENDIF
   CALL endauth(null)
   UPDATE  FROM logical_domain
    SET system_user_id = reply->person_id
    WHERE (logical_domain_id=acm_gen_ld_user_req->logical_domain_id)
    WITH nocounter
   ;end update
   UPDATE  FROM prsnl
    SET logical_domain_id = acm_gen_ld_user_req->logical_domain_id
    WHERE (person_id=reply->person_id)
    WITH nocounter
   ;end update
   SET acm_gen_ld_user_rep->status_block.status_ind = success
   SET acm_gen_ld_user_rep->status_block.status_code = success
   SET acm_gen_ld_user_rep->person_id = reply->person_id
  ENDIF
 ELSEIF (curqual != 1)
  SET acm_gen_ld_user_rep->status_block.status_ind = failure
  SET acm_gen_ld_user_rep->status_block.status_code = invalid_ld
 ENDIF
#exit_script
END GO
