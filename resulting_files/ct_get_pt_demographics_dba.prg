CREATE PROGRAM ct_get_pt_demographics:dba
 FREE RECORD reply
 RECORD reply(
   1 plist[*]
     2 person_id = f8
     2 salutation = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 ssn = vc
     2 birth_dt_tm = dq8
     2 language_cd = f8
     2 language_disp = c40
     2 language_mean = c25
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 country_cd = f8
     2 country_disp = c40
     2 country_mean = c25
     2 state_cd = f8
     2 state_disp = c40
     2 state_mean = c12
     2 city = vc
     2 zipcode = c25
     2 email = vc
     2 home_phone_num = vc
     2 work_phone_num = vc
     2 mobile_phone_num = vc
     2 fax_num = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE person_entity_name = vc WITH protect, constant("PERSON")
 DECLARE current_name_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE home_address_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE email_address_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"EMAIL"))
 DECLARE home_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE work_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mobile_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"MOBILE"))
 DECLARE fax_phone_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"FAX PERS"))
 DECLARE ssn_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE script_version = vc WITH protect, noconstant(" ")
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET cnt = size(request->person_list,5)
 SET stat = alterlist(reply->plist,cnt)
 FOR (i = 1 TO cnt)
   SELECT INTO "nl:"
    p.person_id
    FROM person p,
     person_name pn,
     person_alias pa
    PLAN (p
     WHERE (p.person_id=request->person_list[i].person_id))
     JOIN (pn
     WHERE pn.person_id=outerjoin(p.person_id)
      AND pn.name_type_cd=outerjoin(current_name_type_cd)
      AND pn.active_ind=outerjoin(1)
      AND pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND pn.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
     JOIN (pa
     WHERE pa.person_id=outerjoin(p.person_id)
      AND pa.person_alias_type_cd=outerjoin(ssn_alias_type_cd)
      AND pa.active_ind=outerjoin(1)
      AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
    DETAIL
     reply->plist[i].person_id = p.person_id, reply->plist[i].birth_dt_tm = p.birth_dt_tm, reply->
     plist[i].name_first = p.name_first,
     reply->plist[i].name_last = p.name_last, reply->plist[i].language_cd = p.language_cd, reply->
     plist[i].name_first = pn.name_first,
     reply->plist[i].name_last = pn.name_last, reply->plist[i].name_middle = pn.name_middle, reply->
     plist[i].salutation = pn.name_prefix,
     reply->plist[i].ssn = pa.alias
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("SELECT","Z","ct_get_pt_demographics","No demographics information.")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    a.address_id
    FROM address a
    WHERE (a.parent_entity_id=request->person_list[i].person_id)
     AND a.parent_entity_name=person_entity_name
     AND a.address_type_cd IN (home_address_type_cd, email_address_type_cd)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     IF (a.address_type_cd=home_address_type_cd)
      reply->plist[i].street_addr = a.street_addr, reply->plist[i].street_addr2 = a.street_addr2,
      reply->plist[i].street_addr3 = a.street_addr3,
      reply->plist[i].city = a.city, reply->plist[i].zipcode = a.zipcode, reply->plist[i].state_cd =
      a.state_cd
      IF (a.state_cd=0)
       reply->plist[i].state_disp = a.state
      ENDIF
      reply->plist[i].country_cd = a.country_cd
      IF (a.country_cd=0)
       reply->plist[i].country_disp = a.country
      ENDIF
     ELSE
      reply->plist[i].email = a.street_addr
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ph.phone_id
    FROM phone ph
    WHERE (ph.parent_entity_id=request->person_list[i].person_id)
     AND ph.parent_entity_name=person_entity_name
     AND ph.phone_type_cd IN (home_phone_type_cd, work_phone_type_cd, mobile_phone_type_cd,
    fax_phone_type_cd)
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     IF (ph.phone_type_cd=home_phone_type_cd)
      reply->plist[i].home_phone_num = ph.phone_num
     ELSEIF (ph.phone_type_cd=work_phone_type_cd)
      reply->plist[i].work_phone_num = ph.phone_num
     ELSEIF (ph.phone_type_cd=fax_phone_type_cd)
      reply->plist[i].fax_num = ph.phone_num
     ELSE
      reply->plist[i].mobile_phone_num = ph.phone_num
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus != "S")
    SET failed = opstatus
   ENDIF
   IF ((validate(cnt,- (1000))=- (1000)))
    DECLARE cnt = i4 WITH private, noconstant(0)
   ENDIF
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed != "S")
  SET reply->status_data.status = failed
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET script_version = "001 02/12/2009 BL010629"
END GO
