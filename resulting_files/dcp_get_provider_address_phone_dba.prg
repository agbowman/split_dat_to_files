CREATE PROGRAM dcp_get_provider_address_phone:dba
 RECORD reply(
   1 email[*]
     2 email_id = f8
     2 email = vc
   1 addresses[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_disp = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state_cd = f8
     2 state_disp = vc
     2 zipcode = c25
     2 country_cd = f8
     2 country_disp = vc
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = vc
     2 phone_num = vc
   1 prsnl[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 position_cd = f8
     2 position_disp = vc
     2 relationships = vc
     2 email[*]
       3 email_id = f8
     2 addresses[*]
       3 address_id = f8
     2 phone[*]
       3 phone_id = f8
     2 organizations[*]
       3 org_id = f8
       3 org_name = vc
       3 email[*]
         4 email_id = f8
       3 addresses[*]
         4 address_id = f8
       3 phone[*]
         4 phone_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE extensionprefix = vc WITH noconstant(fillstring(50," "))
 SET i18nhandle = 0
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET extensionprefix = uar_i18ngetmessage(i18nhandle,"phone_extension"," x")
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE prsnlcnt2 = i4 WITH noconstant(0)
 DECLARE addcnt = i4 WITH noconstant(0)
 DECLARE emailcnt = i4 WITH noconstant(0)
 DECLARE phonecnt = i4 WITH noconstant(0)
 DECLARE emailcnt2 = i4 WITH noconstant(0)
 DECLARE addresscnt2 = i4 WITH noconstant(0)
 DECLARE phonecnt2 = i4 WITH noconstant(0)
 DECLARE orgcnt = i4 WITH noconstant(0)
 DECLARE phonetypecnt = i4 WITH noconstant(size(request->phone_types,5))
 DECLARE addtypecnt = i4 WITH noconstant(size(request->address_types,5))
 DECLARE emailcd = f8 WITH noconstant(0.0)
 DECLARE fmtphone = c22 WITH noconstant(fillstring(22," "))
 DECLARE tmpphone = c22 WITH noconstant(fillstring(22," "))
 DECLARE defaultphonecd = f8 WITH noconstant(0.0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE foundprsnl = i2 WITH noconstant(0)
 DECLARE findrecord(prsnlid=f8) = i4
 DECLARE index = i4 WITH noconstant(0)
 SET prsnlcnt = size(request->prsnl,5)
 SET emailcd = uar_get_code_by("MEANING",212,"EMAIL")
 SET defaultphonecd = uar_get_code_by("MEANING",281,"DEFAULT")
 SET stat = alterlist(reply->prsnl,prsnlcnt)
 SELECT INTO "nl:"
  FROM prsnl_reltn pr,
   organization o,
   prsnl_reltn_child prc,
   dummyt d1,
   address a,
   dummyt d2,
   phone p
  PLAN (pr
   WHERE expand(x,1,prsnlcnt,pr.person_id,request->prsnl[x].prsnl_id)
    AND pr.parent_entity_name="ORGANIZATION"
    AND pr.active_ind=1)
   JOIN (o
   WHERE o.organization_id=pr.parent_entity_id)
   JOIN (prc
   WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
    AND ((prc.parent_entity_name="ADDRESS") OR (prc.parent_entity_name="PHONE"
    AND prc.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))) )
   JOIN (((d1)
   JOIN (a
   WHERE a.address_id=prc.parent_entity_id
    AND expand(x,1,addtypecnt,a.address_type_cd,request->address_types[x].address_type_cd))
   ) ORJOIN ((d2)
   JOIN (p
   WHERE p.phone_id=prc.parent_entity_id
    AND expand(x,1,phonetypecnt,p.phone_type_cd,request->phone_types[x].phone_type_cd))
   ))
  ORDER BY pr.person_id, pr.display_seq, pr.parent_entity_id,
   pr.reltn_type_cd, prc.display_seq
  HEAD pr.person_id
   prsnlcnt2 = (prsnlcnt2+ 1), reply->prsnl[prsnlcnt2].prsnl_id = pr.person_id, orgcnt = 0
  HEAD pr.parent_entity_id
   CALL echo(orgcnt), orgcnt = (orgcnt+ 1)
   IF (mod(orgcnt,50)=1)
    stat = alterlist(reply->prsnl[prsnlcnt2].organizations,(orgcnt+ 49))
   ENDIF
   reply->prsnl[prsnlcnt2].organizations[orgcnt].org_id = pr.parent_entity_id, reply->prsnl[prsnlcnt2
   ].organizations[orgcnt].org_name = o.org_name, addcnt = 0,
   phonecnt = 0
  DETAIL
   IF (prc.parent_entity_name="ADDRESS")
    IF (a.address_type_cd=emailcd)
     emailcnt = (emailcnt+ 1)
     IF (mod(emailcnt,50)=1)
      stat = alterlist(reply->prsnl[prsnlcnt2].organizations[orgcnt].addresses,(emailcnt+ 49))
     ENDIF
     reply->prsnl[prsnlcnt2].organizations[orgcnt].addresses[emailcnt].address_id = prc
     .parent_entity_id
    ELSE
     addcnt = (addcnt+ 1)
     IF (mod(addcnt,50)=1)
      stat = alterlist(reply->prsnl[prsnlcnt2].organizations[orgcnt].addresses,(addcnt+ 49))
     ENDIF
     reply->prsnl[prsnlcnt2].organizations[orgcnt].addresses[addcnt].address_id = prc
     .parent_entity_id
    ENDIF
   ELSE
    phonecnt = (phonecnt+ 1)
    IF (mod(phonecnt,50)=1)
     stat = alterlist(reply->prsnl[prsnlcnt2].organizations[orgcnt].phone,(phonecnt+ 49))
    ENDIF
    reply->prsnl[prsnlcnt2].organizations[orgcnt].phone[phonecnt].phone_id = prc.parent_entity_id
   ENDIF
  FOOT  pr.parent_entity_id
   stat = alterlist(reply->prsnl[prsnlcnt2].organizations[orgcnt].addresses,addcnt), stat = alterlist
   (reply->prsnl[prsnlcnt2].organizations[orgcnt].phone,phonecnt)
  FOOT  pr.person_id
   stat = alterlist(reply->prsnl[prsnlcnt2].organizations,orgcnt)
  WITH nocounter
 ;end select
 SET prsnlcnt2 = 0
 SET addcnt = 0
 SET emailcnt = 0
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(x,1,prsnlcnt,a.parent_entity_id,request->prsnl[x].prsnl_id)
    AND a.parent_entity_name="PERSON"
    AND expand(x,1,addtypecnt,a.address_type_cd,request->address_types[x].address_type_cd)
    AND a.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1)
  ORDER BY a.address_type_cd, a.address_type_seq
  DETAIL
   IF (a.address_type_cd=emailcd)
    emailcnt = (emailcnt+ 1)
    IF (mod(emailcnt,50)=1)
     stat = alterlist(reply->email,(emailcnt+ 49))
    ENDIF
    reply->email[emailcnt].email_id = a.address_id, reply->email[emailcnt].email = a.street_addr
   ELSE
    addcnt = (addcnt+ 1)
    IF (mod(addcnt,50)=1)
     stat = alterlist(reply->addresses,(addcnt+ 49))
    ENDIF
    reply->addresses[addcnt].address_id = a.address_id, reply->addresses[addcnt].address_type_cd = a
    .address_type_cd, reply->addresses[addcnt].street_addr = a.street_addr,
    reply->addresses[addcnt].street_addr2 = a.street_addr2, reply->addresses[addcnt].street_addr3 = a
    .street_addr3, reply->addresses[addcnt].street_addr4 = a.street_addr4,
    reply->addresses[addcnt].city = a.city, reply->addresses[addcnt].state_cd = a.state_cd
    IF (a.state_cd=0)
     reply->addresses[addcnt].state_disp = a.state
    ENDIF
    reply->addresses[addcnt].zipcode = a.zipcode, reply->addresses[addcnt].country_cd = a.country_cd
    IF (a.country_cd=0)
     reply->addresses[addcnt].country_disp = a.country
    ENDIF
   ENDIF
   index = findrecord(a.parent_entity_id)
   IF (index > 0)
    reply->prsnl[index].prsnl_id = a.parent_entity_id
    IF (a.address_type_cd=emailcd)
     emailcnt2 = size(reply->prsnl[index].email,5), emailcnt2 = (emailcnt2+ 1), stat = alterlist(
      reply->prsnl[index].email,emailcnt2),
     reply->prsnl[index].email[emailcnt2].email_id = a.address_id
    ELSE
     addresscnt2 = size(reply->prsnl[index].addresses,5), addresscnt2 = (addresscnt2+ 1), stat =
     alterlist(reply->prsnl[index].addresses,addresscnt2),
     reply->prsnl[index].addresses[addresscnt2].address_id = a.address_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->addresses,addcnt), stat = alterlist(reply->email,emailcnt), stat =
   alterlist(reply->prsnl[index].email,emailcnt2),
   stat = alterlist(reply->prsnl[index].addresses,addresscnt2)
  WITH nocounter
 ;end select
 SET prsnlcnt2 = 0
 SET phonecnt = 0
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(x,1,prsnlcnt,p.parent_entity_id,request->prsnl[x].prsnl_id)
    AND p.parent_entity_name="PERSON"
    AND expand(x,1,phonetypecnt,p.phone_type_cd,request->phone_types[x].phone_type_cd)
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.active_ind=1)
  ORDER BY p.phone_type_cd, p.phone_type_seq
  DETAIL
   phonecnt = (phonecnt+ 1)
   IF (mod(phonecnt,50)=1)
    stat = alterlist(reply->phone,(phonecnt+ 49))
   ENDIF
   reply->phone[phonecnt].phone_id = p.phone_id, reply->phone[phonecnt].phone_type_cd = p
   .phone_type_cd, tmpphone = cnvtalphanum(p.phone_num)
   IF (tmpphone != p.phone_num)
    fmtphone = p.phone_num
   ELSE
    IF (p.phone_format_cd > 0)
     fmtphone = cnvtphone(trim(p.phone_num),p.phone_format_cd)
    ELSEIF (defaultphonecd > 0)
     fmtphone = cnvtphone(trim(p.phone_num),defaultphonecd)
    ELSEIF (size(tmpphone) < 8)
     fmtphone = format(trim(p.phone_num),"###-####")
    ELSE
     fmtphone = format(trim(p.phone_num),"(###) ###-####")
    ENDIF
   ENDIF
   IF (fmtphone <= " ")
    fmtphone = p.phone_num
   ENDIF
   IF (p.extension > " ")
    fmtphone = concat(trim(fmtphone),extensionprefix,p.extension)
   ENDIF
   reply->phone[phonecnt].phone_num = fmtphone, index = findrecord(p.parent_entity_id)
   IF (index > 0)
    reply->prsnl[index].prsnl_id = p.parent_entity_id, phonecnt2 = size(reply->prsnl[index].phone,5),
    phonecnt2 = (phonecnt2+ 1),
    stat = alterlist(reply->prsnl[index].phone,phonecnt2), reply->prsnl[index].phone[phonecnt2].
    phone_id = p.phone_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->phone,phonecnt), stat = alterlist(reply->prsnl[index].phone,phonecnt2)
  WITH nocounter
 ;end select
 SUBROUTINE findrecord(prsnlid)
   DECLARE prsnlsize = i4 WITH noconstant(0)
   DECLARE foundzeroprsnl = i4 WITH noconstant(0)
   SET prsnlsize = size(reply->prsnl,5)
   FOR (z = 1 TO prsnlsize)
     IF ((reply->prsnl[z].prsnl_id=prsnlid))
      RETURN(z)
     ELSEIF ((reply->prsnl[z].prsnl_id=0))
      SET foundzeroprsnl = z
     ENDIF
   ENDFOR
   RETURN(foundzeroprsnl)
 END ;Subroutine
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE expand(x,1,prsnlcnt,p.person_id,request->prsnl[x].prsnl_id))
  ORDER BY p.person_id
  DETAIL
   foundprsnl = 0
   FOR (y = 1 TO prsnlcnt)
     IF ((reply->prsnl[y].prsnl_id=p.person_id))
      foundprsnl = 1, reply->prsnl[y].name_full_formatted = p.name_full_formatted, reply->prsnl[y].
      position_cd = p.position_cd
     ELSEIF ((reply->prsnl[y].prsnl_id=0))
      foundzeroprsnl = y
     ENDIF
   ENDFOR
   IF (foundprsnl=0
    AND foundzeroprsnl > 0)
    reply->prsnl[foundzeroprsnl].prsnl_id = p.person_id, reply->prsnl[foundzeroprsnl].
    name_full_formatted = p.name_full_formatted, reply->prsnl[foundzeroprsnl].position_cd = p
    .position_cd
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
