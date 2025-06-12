CREATE PROGRAM ams_ads_cleanup:dba
 DECLARE passport_number_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",356,
   "PASSPORTNUMBER"))
 DECLARE absher_id_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",356,"ABSHERID"))
 DECLARE mobile_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"MOBILE"))
 DECLARE home_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE business_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE pager_personal_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"PAGERPERSONAL"
   ))
 DECLARE alternate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"ALTERNATE"))
 DECLARE speed_dial_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",43,"SPEEDDIAL"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD passport
 RECORD passport(
   1 qual[*]
     2 passport_id = f8
 )
 SELECT INTO "nl:"
  FROM person_info p,
   long_text l
  PLAN (p
   WHERE p.info_sub_type_cd=passport_number_cd
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (l
   WHERE p.long_text_id=l.long_text_id)
  ORDER BY l.long_text_id
  HEAD REPORT
   cntp = 0, stat = alterlist(passport->qual,100)
  HEAD l.long_text_id
   cntp = (cntp+ 1)
   IF (mod(cntp,10)=1
    AND cntp > 100)
    stat = alterlist(passport->qual,(cntp+ 9))
   ENDIF
   passport->qual[cntp].passport_id = l.long_text_id
  FOOT REPORT
   stat = alterlist(passport->qual,cntp)
  WITH nocounter
 ;end select
 SET passport_cnt = value(size(passport->qual,5))
 IF (passport_cnt > 0)
  UPDATE  FROM long_text lt,
    (dummyt d  WITH seq = value(passport_cnt))
   SET lt.long_text = " ", lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1),
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=passport->qual[d.seq].passport_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 FREE RECORD absher
 RECORD absher(
   1 qual[*]
     2 absher_id = f8
 )
 SELECT INTO "nl:"
  FROM person_info p,
   long_text l
  PLAN (p
   WHERE p.info_sub_type_cd=absher_id_cd
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (l
   WHERE p.long_text_id=l.long_text_id)
  ORDER BY l.long_text_id
  HEAD REPORT
   cnta = 0, stat = alterlist(absher->qual,100)
  HEAD l.long_text_id
   cnta = (cnta+ 1)
   IF (mod(cnta,10)=1
    AND cnta > 100)
    stat = alterlist(absher->qual,(cnta+ 9))
   ENDIF
   absher->qual[cnta].absher_id = l.long_text_id
  FOOT REPORT
   stat = alterlist(absher->qual,cnta)
  WITH nocounter
 ;end select
 SET absher_cnt = value(size(absher->qual,5))
 IF (absher_cnt > 0)
  UPDATE  FROM long_text lt,
    (dummyt d  WITH seq = value(absher_cnt))
   SET lt.long_text = " ", lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1),
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=absher->qual[d.seq].absher_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 FREE RECORD emirates
 RECORD emirates(
   1 qual[*]
     2 emirates_id = f8
     2 alias = vc
     2 new_alias = vc
 )
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_alias_type_cd=ssn_cd
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY pa.person_alias_id
  HEAD REPORT
   cntpa = 0, stat = alterlist(emirates->qual,100)
  HEAD pa.person_alias_id
   cntpa = (cntpa+ 1)
   IF (mod(cntpa,10)=1
    AND cntpa > 100)
    stat = alterlist(emirates->qual,(cntpa+ 9))
   ENDIF
   emirates->qual[cntpa].emirates_id = pa.person_alias_id, emirates->qual[cntpa].alias = substring(4,
    20,pa.alias), emirates->qual[cntpa].new_alias = concat("784",emirates->qual[cntpa].alias)
  FOOT REPORT
   stat = alterlist(emirates->qual,cntpa)
  WITH nocounter
 ;end select
 SET emirates_cnt = value(size(emirates->qual,5))
 IF (emirates_cnt > 0)
  UPDATE  FROM person_alias pa,
    (dummyt d  WITH seq = value(emirates_cnt))
   SET pa.alias = emirates->qual[d.seq].new_alias, pa.updt_applctx = reqinfo->updt_applctx, pa
    .updt_cnt = (pa.updt_cnt+ 1),
    pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (pa
    WHERE (pa.person_alias_id=emirates->qual[d.seq].emirates_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 FREE RECORD phone
 RECORD phone(
   1 qual[*]
     2 phone_id = f8
     2 phone_num = vc
     2 new_phone_num = vc
     2 phone_num_key = vc
 )
 SELECT INTO "nl:"
  FROM phone p
  WHERE p.parent_entity_name="PERSON"
   AND p.phone_num != null
   AND p.phone_num != "0"
   AND p.active_ind=1
   AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY p.phone_id
  HEAD REPORT
   cntph = 0, stat = alterlist(phone->qual,100)
  HEAD p.phone_id
   cntph = (cntph+ 1)
   IF (mod(cntph,10)=1
    AND cntph > 100)
    stat = alterlist(phone->qual,(cntph+ 9))
   ENDIF
   IF (p.phone_type_cd=mobile_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"1111111"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSEIF (p.phone_type_cd=home_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"2222222"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSEIF (p.phone_type_cd=business_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"3333333"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSEIF (p.phone_type_cd=pager_personal_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"4444444"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSEIF (p.phone_type_cd=alternate_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"5555555"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSEIF (p.phone_type_cd=speed_dial_cd)
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"6666"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ELSE
    phone->qual[cntph].phone_id = p.phone_id, phone->qual[cntph].phone_num = substring(1,1,p
     .phone_num), phone->qual[cntph].new_phone_num = concat(phone->qual[cntph].phone_num,"7777777"),
    phone->qual[cntph].phone_num_key = phone->qual[cntph].new_phone_num
   ENDIF
  FOOT REPORT
   stat = alterlist(phone->qual,cntph)
  WITH nocounter
 ;end select
 SET phone_cnt = value(size(phone->qual,5))
 IF (phone_cnt > 0)
  UPDATE  FROM phone ph,
    (dummyt d  WITH seq = value(phone_cnt))
   SET ph.phone_num = phone->qual[d.seq].new_phone_num, ph.phone_num_key = phone->qual[d.seq].
    phone_num_key, ph.updt_applctx = reqinfo->updt_applctx,
    ph.updt_cnt = (ph.updt_cnt+ 1), ph.updt_dt_tm = cnvtdatetime(curdate,curtime3), ph.updt_id =
    reqinfo->updt_id,
    ph.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ph
    WHERE (ph.phone_id=phone->qual[d.seq].phone_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
