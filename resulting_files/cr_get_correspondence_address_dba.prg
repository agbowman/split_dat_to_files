CREATE PROGRAM cr_get_correspondence_address:dba
 DECLARE last_mod = c5 WITH noconstant(""), private
 SET last_mod = "000  "
 DECLARE bstatus = i2 WITH noconstant(false)
 DECLARE bnoreply = i2 WITH noconstant(false)
 DECLARE lcnt = i4 WITH noconstant(0)
 DECLARE daddressid = f8 WITH noconstant(0.0)
 DECLARE dmailingcd = f8 WITH noconstant(0.0)
 DECLARE dbusinesscd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(212,nullterm("MAILING"),1,dmailingcd)
 SET stat = uar_get_meaning_by_codeset(212,nullterm("BUSINESS"),1,dbusinesscd)
 DECLARE check_encntr_level(b_dummy=i2) = f8
 DECLARE check_person_level(b_dummy=i2) = f8
 IF ((validate(reply->qual[1].address_id,- (99))=- (99)))
  RECORD reply(
    1 qual[1]
      2 address_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 address_format_cd = f8
      2 beg_effective_dt_tm = di8
      2 end_effective_dt_tm = di8
      2 contact_name = c200
      2 residence_type_cd = f8
      2 comment_txt = c200
      2 residence_type_cd = f8
      2 street_addr = c100
      2 street_addr2 = c100
      2 street_addr3 = c100
      2 street_addr4 = c100
      2 city = c60
      2 state = c25
      2 state_cd = f8
      2 state_disp = vc
      2 zipcode = c11
      2 zip_code_group_cd = f8
      2 postal_barcode_info = c100
      2 county = c100
      2 county_cd = f8
      2 country = c100
      2 country_cd = f8
      2 residence_cd = f8
      2 mail_stop = c100
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET bnoreply = true
  SET reply->status_data.status = "F"
 ENDIF
 SET daddressid = check_encntr_level(0)
 IF (daddressid <= 0)
  SET daddressid = check_person_level(0)
 ENDIF
 GO TO 9999_end_program
 SUBROUTINE check_encntr_level(ddummy)
  SELECT INTO "nl:"
   a.address_id, address_type = uar_get_code_meaning(a.address_type_cd)
   FROM prsnl_reltn_activity pra,
    prsnl_reltn_child prc,
    address a
   PLAN (pra
    WHERE (pra.prsnl_id=request->prsnl_id)
     AND (pra.encntr_id=request->encntr_id)
     AND pra.encntr_id > 0
     AND pra.parent_entity_name="ENCNTR_PRSNL_RELTN")
    JOIN (prc
    WHERE prc.prsnl_reltn_id=pra.prsnl_reltn_id
     AND prc.parent_entity_name="ADDRESS"
     AND prc.parent_entity_id > 0
     AND prc.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (a
    WHERE a.address_id=prc.parent_entity_id
     AND a.address_type_cd IN (dmailingcd, dbusinesscd)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY cnvtdatetime(pra.updt_dt_tm) DESC, address_type DESC, a.address_type_seq
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (lcnt=1)
     reply->qual[1].address_id = a.address_id, reply->qual[1].active_ind = a.active_ind, reply->qual[
     1].active_status_cd = a.active_status_cd,
     reply->qual[1].active_status_dt_tm = cnvtdatetime(a.active_status_dt_tm), reply->qual[1].
     active_status_prsnl_id = a.active_status_prsnl_id, reply->qual[1].address_format_cd = a
     .address_format_cd,
     reply->qual[1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm), reply->qual[1].
     end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm), reply->qual[1].contact_name = a
     .contact_name,
     reply->qual[1].residence_type_cd = a.residence_type_cd, reply->qual[1].comment_txt = a
     .comment_txt, reply->qual[1].residence_type_cd = a.residence_type_cd,
     reply->qual[1].street_addr = a.street_addr, reply->qual[1].street_addr2 = a.street_addr2, reply
     ->qual[1].street_addr3 = a.street_addr3,
     reply->qual[1].street_addr4 = a.street_addr4, reply->qual[1].city = a.city, reply->qual[1].state
      = a.state,
     reply->qual[1].state_cd = a.state_cd, reply->qual[1].zipcode = a.zipcode, reply->qual[1].
     zip_code_group_cd = a.zip_code_group_cd,
     reply->qual[1].postal_barcode_info = a.postal_barcode_info, reply->qual[1].mail_stop = a
     .mail_stop, reply->qual[1].county = a.county,
     reply->qual[1].county_cd = a.county_cd, reply->qual[1].country = a.country, reply->qual[1].
     country_cd = a.country_cd,
     reply->qual[1].residence_cd = a.residence_cd, reply->qual[1].updt_cnt = a.updt_cnt
    ENDIF
   WITH maxqual(pra,1)
  ;end select
  IF (lcnt=0)
   RETURN(0.0)
  ELSE
   RETURN(reply->qual[1].address_id)
  ENDIF
 END ;Subroutine
 SUBROUTINE check_person_level(ddummy)
  SELECT INTO "nl:"
   a.address_id, address_type = uar_get_code_meaning(a.address_type_cd)
   FROM prsnl_reltn_activity pra,
    prsnl_reltn_child prc,
    address a
   PLAN (pra
    WHERE (pra.prsnl_id=request->prsnl_id)
     AND (pra.person_id=request->person_id)
     AND pra.person_id > 0
     AND pra.parent_entity_name="PERSON_PRSNL_RELTN")
    JOIN (prc
    WHERE prc.prsnl_reltn_id=pra.prsnl_reltn_id
     AND prc.parent_entity_name="ADDRESS"
     AND prc.parent_entity_id > 0
     AND prc.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (a
    WHERE a.address_id=prc.parent_entity_id
     AND a.address_type_cd IN (dmailingcd, dbusinesscd)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY cnvtdatetime(pra.updt_dt_tm) DESC, address_type DESC, a.address_type_seq
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (lcnt=1)
     reply->qual[1].address_id = a.address_id, reply->qual[1].active_ind = a.active_ind, reply->qual[
     1].active_status_cd = a.active_status_cd,
     reply->qual[1].active_status_dt_tm = cnvtdatetime(a.active_status_dt_tm), reply->qual[1].
     active_status_prsnl_id = a.active_status_prsnl_id, reply->qual[1].address_format_cd = a
     .address_format_cd,
     reply->qual[1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm), reply->qual[1].
     end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm), reply->qual[1].contact_name = a
     .contact_name,
     reply->qual[1].residence_type_cd = a.residence_type_cd, reply->qual[1].comment_txt = a
     .comment_txt, reply->qual[1].residence_type_cd = a.residence_type_cd,
     reply->qual[1].street_addr = a.street_addr, reply->qual[1].street_addr2 = a.street_addr2, reply
     ->qual[1].street_addr3 = a.street_addr3,
     reply->qual[1].street_addr4 = a.street_addr4, reply->qual[1].city = a.city, reply->qual[1].state
      = a.state,
     reply->qual[1].state_cd = a.state_cd, reply->qual[1].zipcode = a.zipcode, reply->qual[1].
     zip_code_group_cd = a.zip_code_group_cd,
     reply->qual[1].postal_barcode_info = a.postal_barcode_info, reply->qual[1].mail_stop = a
     .mail_stop, reply->qual[1].county = a.county,
     reply->qual[1].county_cd = a.county_cd, reply->qual[1].country = a.country, reply->qual[1].
     country_cd = a.country_cd,
     reply->qual[1].residence_cd = a.residence_cd, reply->qual[1].updt_cnt = a.updt_cnt
    ENDIF
   WITH maxqual(pra,1)
  ;end select
  IF (lcnt=0)
   RETURN(0.0)
  ELSE
   RETURN(reply->qual[1].address_id)
  ENDIF
 END ;Subroutine
#9999_end_program
END GO
