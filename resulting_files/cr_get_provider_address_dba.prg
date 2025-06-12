CREATE PROGRAM cr_get_provider_address:dba
 DECLARE last_mod = c5 WITH noconstant(""), private
 SET last_mod = "000  "
 FREE RECORD reply
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
     2 country_disp = vc
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
 SET reply->status_data.status = "F"
 DECLARE dtypecd = f8 WITH noconstant(0.0)
 DECLARE stemp = vc WITH noconstant("")
 DECLARE serror = vc WITH noconstant("")
 SET stemp = cnvtupper(trim(request->address_type_meaning,3))
 IF (textlen(stemp)=0)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cr_get_provider_address"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Address type meaning"
  GO TO 9999_end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(212,nullterm(stemp),1,dtypecd)
 SELECT INTO "nl:"
  a.address_id
  FROM address a
  WHERE (a.parent_entity_id=request->parent_entity_id)
   AND (a.parent_entity_name=request->parent_entity_name)
   AND a.address_type_cd=dtypecd
   AND a.active_ind=1
   AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY a.address_type_seq
  DETAIL
   reply->qual[1].address_id = a.address_id, reply->qual[1].active_ind = a.active_ind, reply->qual[1]
   .active_status_cd = a.active_status_cd,
   reply->qual[1].active_status_dt_tm = cnvtdatetime(a.active_status_dt_tm), reply->qual[1].
   active_status_prsnl_id = a.active_status_prsnl_id, reply->qual[1].address_format_cd = a
   .address_format_cd,
   reply->qual[1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm), reply->qual[1].
   end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm), reply->qual[1].contact_name = a
   .contact_name,
   reply->qual[1].residence_type_cd = a.residence_type_cd, reply->qual[1].comment_txt = a.comment_txt,
   reply->qual[1].residence_type_cd = a.residence_type_cd,
   reply->qual[1].street_addr = a.street_addr, reply->qual[1].street_addr2 = a.street_addr2, reply->
   qual[1].street_addr3 = a.street_addr3,
   reply->qual[1].street_addr4 = a.street_addr4, reply->qual[1].city = a.city, reply->qual[1].state
    = a.state,
   reply->qual[1].state_cd = a.state_cd, reply->qual[1].zipcode = a.zipcode, reply->qual[1].
   zip_code_group_cd = a.zip_code_group_cd,
   reply->qual[1].postal_barcode_info = a.postal_barcode_info, reply->qual[1].mail_stop = a.mail_stop,
   reply->qual[1].county = a.county,
   reply->qual[1].county_cd = a.county_cd, reply->qual[1].country = a.country, reply->qual[1].
   country_cd = a.country_cd,
   reply->qual[1].residence_cd = a.residence_cd, reply->qual[1].updt_cnt = a.updt_cnt
  WITH nocounter, maxrec = 1
 ;end select
 CALL echorecord(reply)
 SET lerrrorcd = error(serror,1)
 IF (lerrrorcd != 0)
  SET reply->status_data.targetobjectname = "ErrorMessage"
  SET reply->status_data.targetobjectvalue = serror
  GO TO 9999_end_program
 ENDIF
 SELECT INTO "nl:"
  u.table_name
  FROM user_tables u
  WHERE u.table_name="PRSNL_RELTN_ACTIVITY"
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO 9999_end_program
 ENDIF
 FREE RECORD tempreq
 RECORD tempreq(
   1 prsnl_id = f8
   1 person_id = f8
   1 encntr_id = f8
 )
 SET tempreq->prsnl_id = request->parent_entity_id
 SET tempreq->person_id = request->person_id
 SET tempreq->encntr_id = request->encntr_id
 EXECUTE cr_get_correspondence_address  WITH replace("REQUEST","TEMPREQ")
 SET lerrrorcd = error(serror,1)
 IF (lerrrorcd != 0)
  SET reply->status_data.targetobjectname = "ErrorMessage"
  SET reply->status_data.targetobjectvalue = serror
  GO TO 9999_end_program
 ENDIF
 SET reply->status_data.status = "S"
#9999_end_program
 CALL echorecord(reply)
END GO
