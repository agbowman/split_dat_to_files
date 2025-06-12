CREATE PROGRAM ct_get_person_contact_info:dba
 CALL logdebug("Beginning")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 contactinfolist[*]
      2 person_id = f8
      2 addresslist[*]
        3 address_type_cd = f8
        3 street_addr = vc
        3 street_addr2 = vc
        3 city = vc
        3 city_cd = f8
        3 state = vc
        3 state_cd = f8
        3 zipcode = vc
      2 phonelist[*]
        3 phone_type_cd = f8
        3 phone_format_cd = f8
        3 phone_num = vc
        3 extension = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE logdebug(message=vc) = null WITH protect
 DECLARE getaddresstypequalifer(null) = vc WITH protect
 DECLARE getphonetypequalifer(null) = vc WITH protect
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE personcnt = i4 WITH private, noconstant(size(request->personlist,5))
 DECLARE addresscnt = i4 WITH private, noconstant(0)
 DECLARE phonecnt = i4 WITH private, noconstant(0)
 DECLARE addressqual = vc WITH private, noconstant(getaddresstypequalifer(null))
 DECLARE phonequal = vc WITH private, noconstant(getphonetypequalifer(null))
 DECLARE stat = i2 WITH protect, noconstant(0)
 IF (personcnt > 0)
  SET stat = alterlist(reply->contactinfolist,personcnt)
  FOR (i = 1 TO personcnt)
    SET reply->contactinfolist[i].person_id = request->personlist[i].person_id
  ENDFOR
  SELECT INTO "nl:"
   FROM address a,
    (dummyt d  WITH seq = value(personcnt))
   PLAN (d)
    JOIN (a
    WHERE (a.parent_entity_id=request->personlist[d.seq].person_id)
     AND a.parent_entity_name="PERSON"
     AND parser(addressqual)
     AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND a.active_ind=1)
   HEAD a.parent_entity_id
    addresscnt = 0
   DETAIL
    IF (a.address_id > 0
     AND size(a.street_addr) > 0
     AND ((size(a.city) > 0) OR (a.city_cd > 0))
     AND ((size(a.state) > 0) OR (a.state_cd > 0))
     AND size(a.zipcode) > 0)
     addresscnt = (addresscnt+ 1)
     IF (mod(addresscnt,10)=1)
      stat = alterlist(reply->contactinfolist[d.seq].addresslist,(addresscnt+ 9))
     ENDIF
     reply->contactinfolist[d.seq].addresslist[addresscnt].address_type_cd = a.address_type_cd, reply
     ->contactinfolist[d.seq].addresslist[addresscnt].city = a.city, reply->contactinfolist[d.seq].
     addresslist[addresscnt].city_cd = a.city_cd,
     reply->contactinfolist[d.seq].addresslist[addresscnt].state = a.state, reply->contactinfolist[d
     .seq].addresslist[addresscnt].state_cd = a.state_cd, reply->contactinfolist[d.seq].addresslist[
     addresscnt].street_addr = a.street_addr,
     reply->contactinfolist[d.seq].addresslist[addresscnt].street_addr2 = a.street_addr2, reply->
     contactinfolist[d.seq].addresslist[addresscnt].zipcode = a.zipcode
    ENDIF
   FOOT  a.parent_entity_id
    stat = alterlist(reply->contactinfolist[d.seq].addresslist,addresscnt)
   WITH outerjoin = d
  ;end select
  SELECT INTO "nl:"
   FROM phone p,
    (dummyt d  WITH seq = value(personcnt))
   PLAN (d)
    JOIN (p
    WHERE (p.parent_entity_id=request->personlist[d.seq].person_id)
     AND p.parent_entity_name="PERSON"
     AND parser(phonequal)
     AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND p.active_ind=1)
   HEAD p.parent_entity_id
    phonecnt = 0
   DETAIL
    IF (p.phone_id > 0
     AND size(p.phone_num_key) > 0)
     phonecnt = (phonecnt+ 1)
     IF (mod(phonecnt,10)=1)
      stat = alterlist(reply->contactinfolist[d.seq].phonelist,(phonecnt+ 9))
     ENDIF
     reply->contactinfolist[d.seq].phonelist[phonecnt].phone_type_cd = p.phone_type_cd, reply->
     contactinfolist[d.seq].phonelist[phonecnt].phone_format_cd = p.phone_format_cd, reply->
     contactinfolist[d.seq].phonelist[phonecnt].phone_num = p.phone_num,
     reply->contactinfolist[d.seq].phonelist[phonecnt].extension = p.extension
    ENDIF
   FOOT  p.parent_entity_id
    stat = alterlist(reply->contactinfolist[d.seq].phonelist,phonecnt)
   WITH outerjoin = d
  ;end select
 ENDIF
 GO TO exit_script
 SUBROUTINE logdebug(message)
   IF (validate(debug_ind,0) > 0)
    CALL echo(build("DEBUG - ct_get_person_contact_info:",message))
   ENDIF
 END ;Subroutine
 SUBROUTINE getaddresstypequalifer(null)
   CALL logdebug("Executing GetAddressTypeQualifer()")
   DECLARE qualifier = vc WITH protect, noconstant("1=1")
   DECLARE addresstypecount = i4 WITH protect, noconstant(size(request->addresstypelist,5))
   IF (addresstypecount > 0)
    SET qualifier = build("a.address_type_cd in (",request->addresstypelist[1].address_type_cd)
    FOR (i = 2 TO addresstypecount)
      SET qualifer = build(qualifier,",",request->addresstypelist[i].address_type_cd)
    ENDFOR
    SET qualifier = build(qualifier,")")
   ENDIF
   RETURN(qualifier)
 END ;Subroutine
 SUBROUTINE getphonetypequalifer(null)
   CALL logdebug("Executing GetPhoneTypeQualifer()")
   DECLARE qualifier = vc WITH protect, noconstant("1=1")
   DECLARE phonetypecount = i4 WITH protect, noconstant(size(request->phonetypelist,5))
   IF (phonetypecount > 0)
    SET qualifier = build("p.phone_type_cd in (",request->phonetypelist[1].phone_type_cd)
    FOR (i = 2 TO phonetypecount)
      SET qualifer = build(qualifier,",",request->phonetypelist[i].phone_type_cd)
    ENDFOR
    SET qualifier = build(qualifier,")")
   ENDIF
   RETURN(qualifier)
 END ;Subroutine
#exit_script
 SET last_mod = "000"
 SET mod_date = "Feb 22, 2013"
END GO
