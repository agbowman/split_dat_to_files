CREATE PROGRAM cp_get_address_page:dba
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE address_type_cd = f8 WITH noconstant(0.0)
 DECLARE nametitle = vc
 DECLARE citystatezip = vc
 DECLARE rows = i4 WITH noconstant(1)
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
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(212,request->address_type_meaning,1,address_type_cd)
 RECORD temp_request(
   1 person_id = f8
   1 person_flag = i2
 )
 RECORD temp_reply(
   1 name_full = vc
   1 name_initials = vc
   1 name_first = vc
   1 name_last = vc
   1 name_middle = vc
   1 name_title = vc
   1 username = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->prsnl_person_id > 0))
  SET temp_request->person_id = request->prsnl_person_id
  SET temp_request->person_flag = 0
 ELSEIF ((request->chart_person_id > 0))
  SET temp_request->person_id = request->chart_person_id
  SET temp_request->person_flag = 1
 ENDIF
 EXECUTE cp_get_prsnl_ident_by_id  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
  "TEMP_REPLY")
 IF ((temp_reply->status_data.status="Z"))
  GO TO exit_script
 ELSEIF ((temp_reply->status_data.status="F"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  title = trim(temp_reply->name_title,3), first_name = trim(temp_reply->name_first,3), last_name =
  trim(temp_reply->name_last,3),
  street_addr = trim(a.street_addr,3), street_addr2 = trim(a.street_addr2,3), street_addr3 = trim(a
   .street_addr3,3),
  street_addr4 = trim(a.street_addr4,3), city = trim(a.city,3), state = evaluate(a.state_cd,0.00,trim
   (a.state,3),uar_get_code_display(a.state_cd)),
  country = evaluate(a.country_cd,0.00,trim(a.country,3),uar_get_code_display(a.country_cd)), zipcode
   = trim(a.zipcode,3)
  FROM (dummyt d1  WITH seq = value(1)),
   address a
  PLAN (d1)
   JOIN (a
   WHERE (a.parent_entity_id=temp_request->person_id)
    AND a.parent_entity_name IN ("PRSNL", "PERSON")
    AND a.address_type_cd=address_type_cd
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1
    AND a.address_id != 0)
  ORDER BY a.address_type_seq
  HEAD REPORT
   address_cnt = 0
  DETAIL
   address_cnt = (address_cnt+ 1)
   IF (address_cnt=1)
    stat = alterlist(reply->qual,7)
    IF (size(title) > 0)
     nametitle = concat(title," ",first_name," ",last_name)
    ELSE
     nametitle = concat(first_name," ",last_name)
    ENDIF
    reply->qual[rows].line = trim(nametitle,3), rows = (rows+ 1)
    IF (size(trim(street_addr,3)) > 0)
     reply->qual[rows].line = street_addr, rows = (rows+ 1)
    ENDIF
    IF (size(trim(street_addr2,3)) > 0)
     reply->qual[rows].line = street_addr2, rows = (rows+ 1)
    ENDIF
    IF (size(trim(street_addr3,3)) > 0)
     reply->qual[rows].line = street_addr3, rows = (rows+ 1)
    ENDIF
    IF (size(trim(street_addr4,3)) > 0)
     reply->qual[rows].line = street_addr4, rows = (rows+ 1)
    ENDIF
    citystatezip = concat(trim(city,3)," ",trim(state,3)," ",trim(zipcode,3)), reply->qual[rows].line
     = citystatezip, rows = (rows+ 1),
    reply->qual[rows].line = country
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,rows)
  WITH nocounter
 ;end select
 SET reply->num_lines = rows
 IF (curqual=0)
  SET stat = alterlist(reply->qual,2)
  IF (size(trim(temp_reply->name_title,3)) > 0)
   SET reply->qual[rows].line = concat(trim(temp_reply->name_title,3)," ",trim(temp_reply->name_first,
     3)," ",trim(temp_reply->name_last,3))
  ELSE
   SET reply->qual[rows].line = concat(trim(temp_reply->name_first,3)," ",trim(temp_reply->name_last,
     3))
  ENDIF
  SET rows = (rows+ 1)
  SET reply->qual[rows].line = uar_i18ngetmessage(i18nhandle,"NOADD","No address located.")
  SET reply->num_lines = rows
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 IF ((request->prsnl_person_id > 0))
  FREE RECORD temp_request
  FREE RECORD temp_reply
  RECORD temp_request(
    1 prsnl_id = f8
    1 encntr_id = f8
    1 person_id = f8
  )
  RECORD temp_reply(
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
  SET temp_request->prsnl_id = request->prsnl_person_id
  SET temp_request->person_id = request->chart_person_id
  SET temp_request->encntr_id = request->encntr_id
  EXECUTE cr_get_correspondence_address  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
   "TEMP_REPLY")
  DECLARE state = vc
  DECLARE country = vc
  IF ((temp_reply->qual[1].address_id > 0))
   SET rows = 1
   SET stat = alterlist(reply->qual,1)
   SET stat = alterlist(reply->qual,7)
   SET rows = (rows+ 1)
   IF (size(trim(temp_reply->qual[1].street_addr,3)) > 0)
    SET reply->qual[rows].line = trim(temp_reply->qual[1].street_addr,3)
    SET rows = (rows+ 1)
   ENDIF
   IF (size(trim(temp_reply->qual[1].street_addr2,3)) > 0)
    SET reply->qual[rows].line = trim(temp_reply->qual[1].street_addr2,3)
    SET rows = (rows+ 1)
   ENDIF
   IF (size(trim(temp_reply->qual[1].street_addr3,3)) > 0)
    SET reply->qual[rows].line = trim(temp_reply->qual[1].street_addr3,3)
    SET rows = (rows+ 1)
   ENDIF
   IF (size(trim(temp_reply->qual[1].street_addr4,3)) > 0)
    SET reply->qual[rows].line = trim(temp_reply->qual[1].street_addr4,3)
    SET rows = (rows+ 1)
   ENDIF
   SET state = evaluate(temp_reply->qual[1].state_cd,0.00,trim(temp_reply->qual[1].state,3),
    uar_get_code_display(temp_reply->qual[1].state_cd))
   SET reply->qual[rows].line = concat(trim(temp_reply->qual[1].city,3)," ",trim(state,3)," ",trim(
     temp_reply->qual[1].zipcode,3))
   SET rows = (rows+ 1)
   SET country = evaluate(temp_reply->qual[1].country_cd,0.00,trim(temp_reply->qual[1].country,3),
    uar_get_code_display(temp_reply->qual[1].country_cd))
   SET reply->qual[rows].line = country
   SET stat = alterlist(reply->qual,rows)
   SET reply->num_lines = rows
  ENDIF
 ENDIF
#exit_script
 FREE SET temp_request
 FREE SET temp_reply
 CALL echorecord(reply)
END GO
