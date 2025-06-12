CREATE PROGRAM bbt_get_upload_data:dba
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
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "BBT_GET_UPLOAD_DATA"
 RECORD reply(
   1 location_cd = f8
   1 location_disp = vc
   1 location_found_ind = i2
   1 street_addr = vc
   1 street_addr2 = vc
   1 street_addr3 = vc
   1 street_addr4 = vc
   1 city = vc
   1 state = vc
   1 zipcode = c25
   1 country = vc
   1 products[*]
     2 supplier = vc
     2 supplier_prefix = vc
     2 product_nbr = vc
     2 product_sub_nbr = vc
     2 product_cd = f8
     2 product_disp = vc
     2 abo_cd = f8
     2 abo_disp = vc
     2 rh_cd = f8
     2 rh_disp = vc
     2 expire_dt_tm = dq8
     2 volume = i4
     2 unit_meas_cd = f8
     2 unit_meas_disp = vc
     2 owner_area_cd = f8
     2 owner_area_disp = vc
     2 inv_area_cd = f8
     2 inv_area_disp = vc
     2 cross_reference = vc
     2 contributer_system_cd = f8
     2 contributer_system_disp = vc
     2 final_disp_type_cd = f8
     2 final_disp_type_disp = vc
     2 final_disp_tech = vc
     2 final_disp_reason_cd = f8
     2 final_disp_reason_disp = vc
     2 final_disp_dt_tm = dq8
     2 final_disp_volume = i4
     2 final_disp_qty = i4
     2 final_disp_bag_return_ind = i2
     2 final_disp_tag_return_ind = i2
     2 product_comment = vc
     2 product_transfused_ind = i2
     2 patient_name = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 mrn = vc
     2 ssn = vc
     2 sex_cd = f8
     2 sex_disp = vc
     2 antigens[*]
       3 antigen_cd = f8
       3 antigen_disp = vc
     2 attributes[*]
       3 attribute_cd = f8
       3 attribute_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE g_num_products = i4 WITH public, noconstant(0)
 DECLARE num_antigens = i4 WITH public, noconstant(0)
 DECLARE num_attributes = i4 WITH public, noconstant(0)
 DECLARE h = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE ssn_cd = f8 WITH public, noconstant(0.0)
 DECLARE transfused_cd = f8 WITH public, noconstant(0.0)
 DECLARE addr_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE stext = vc WITH public, noconstant(fillstring(254," "))
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE antigen_cdf1 = vc WITH public, constant("+")
 DECLARE antigen_cdf2 = vc WITH public, constant("-")
 DECLARE attribute_cdf = vc WITH public, constant("SPTYP")
 DECLARE mrn_ssn_code_set = i4 WITH public, constant(4)
 DECLARE address_type_code_set = i4 WITH public, constant(212)
 DECLARE transfused_code_set = i4 WITH public, constant(1610)
 DECLARE comment_entity_name = vc WITH public, constant("BBHIST_PRODUCT")
 DECLARE address_entity_name = vc WITH public, constant("LOCATION")
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET cdf_meaning = "MRN"
 CALL uar_get_meaning_by_codeset(mrn_ssn_code_set,cdf_meaning,1,mrn_cd)
 SET cdf_meaning = "SSN"
 CALL uar_get_meaning_by_codeset(mrn_ssn_code_set,cdf_meaning,1,ssn_cd)
 SET cdf_meaning = "BUSINESS"
 CALL uar_get_meaning_by_codeset(address_type_code_set,cdf_meaning,1,addr_type_cd)
 SET cdf_meaning = "7"
 CALL uar_get_meaning_by_codeset(transfused_code_set,cdf_meaning,1,transfused_cd)
 IF (mrn_cd=0.0)
  SET stext = uar_i18ngetmessage(i18nhandle,"MRNError","Error retrieving MRN code value, code set 4")
  CALL log_message(stext,log_level_error)
  GO TO exit_script
 ENDIF
 IF (ssn_cd=0.0)
  SET stext = uar_i18ngetmessage(i18nhandle,"SSNError","Error retrieving SSN code value, code set 4")
  CALL log_message(stext,log_level_error)
  GO TO exit_script
 ENDIF
 IF (addr_type_cd=0.0)
  SET stext = uar_i18ngetmessage(i18nhandle,"addr_type_cdError",
   "Error retrieving BUSINESS code value, code set 212")
  CALL log_message(stext,log_level_error)
  GO TO exit_script
 ENDIF
 IF (transfused_cd=0.0)
  SET stext = uar_i18ngetmessage(i18nhandle,"transfused_cdError",
   "Error retrieving Transfused (7) code value, code set 1610")
  CALL log_message(stext,log_level_error)
  GO TO exit_script
 ENDIF
 IF ((request->address_location_cd > 0.0))
  SELECT INTO "nl:"
   adr.parent_entity_id, adr.address_type_cd
   FROM address adr
   PLAN (adr
    WHERE (adr.parent_entity_id=request->address_location_cd)
     AND adr.active_ind=1
     AND adr.address_type_cd=addr_type_cd
     AND adr.parent_entity_name=address_entity_name)
   ORDER BY adr.parent_entity_id
   HEAD adr.parent_entity_id
    reply->location_cd = request->address_location_cd, reply->location_found_ind = 1, reply->
    street_addr = adr.street_addr,
    reply->street_addr2 = adr.street_addr2, reply->street_addr3 = adr.street_addr3, reply->
    street_addr4 = adr.street_addr4,
    reply->city = adr.city, reply->state = adr.state, reply->zipcode = adr.zipcode,
    reply->country = adr.country
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  bbprod.product_id, bbprod.product_cd, bbprod.product_nbr,
  org.organization_id, bbprodevnt.person_id, bbprodevnt.event_type_cd,
  psnl.person_id, p.person_id, pa.alias,
  pa2.alias, lt.parent_entity_id, lt.parent_entity_name,
  bbspectst.product_id, bbspectst.special_testing_cd, cv.code_value
  FROM bbhist_product bbprod,
   organization org,
   bbhist_product_event bbprodevnt,
   prsnl psnl,
   person p,
   person_alias pa,
   person_alias pa2,
   long_text lt,
   bbhist_special_testing bbspectst,
   code_value cv
  PLAN (bbprod
   WHERE ((bbprod.product_id+ 0) > 0.0)
    AND bbprod.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=bbprod.owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=bbprod.inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (org
   WHERE org.organization_id=bbprod.supplier_id)
   JOIN (bbprodevnt
   WHERE bbprodevnt.product_id=bbprod.product_id)
   JOIN (psnl
   WHERE psnl.person_id=bbprodevnt.prsnl_id)
   JOIN (p
   WHERE (p.person_id= Outerjoin(bbprodevnt.person_id)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(mrn_cd)) )
   JOIN (pa2
   WHERE (pa2.person_id= Outerjoin(p.person_id))
    AND (pa2.person_alias_type_cd= Outerjoin(ssn_cd)) )
   JOIN (lt
   WHERE (lt.parent_entity_id= Outerjoin(bbprod.product_id))
    AND (lt.parent_entity_name= Outerjoin(comment_entity_name)) )
   JOIN (bbspectst
   WHERE (bbspectst.product_id= Outerjoin(bbprod.product_id)) )
   JOIN (cv
   WHERE (cv.code_value= Outerjoin(bbspectst.special_testing_cd)) )
  ORDER BY bbprod.product_id, bbspectst.special_testing_cd
  HEAD bbprod.product_id
   g_num_products += 1
   IF (mod(g_num_products,10)=1)
    stat = alterlist(reply->products,(g_num_products+ 10))
   ENDIF
   reply->products[g_num_products].supplier_prefix = bbprod.supplier_prefix, reply->products[
   g_num_products].product_nbr = bbprod.product_nbr, reply->products[g_num_products].product_sub_nbr
    = bbprod.product_sub_nbr,
   reply->products[g_num_products].product_cd = bbprod.product_cd, reply->products[g_num_products].
   abo_cd = bbprod.abo_cd, reply->products[g_num_products].rh_cd = bbprod.rh_cd,
   reply->products[g_num_products].expire_dt_tm = bbprod.expire_dt_tm, reply->products[g_num_products
   ].volume = bbprod.volume, reply->products[g_num_products].unit_meas_cd = bbprod.unit_meas_cd,
   reply->products[g_num_products].owner_area_cd = bbprod.owner_area_cd, reply->products[
   g_num_products].inv_area_cd = bbprod.inv_area_cd, reply->products[g_num_products].cross_reference
    = bbprod.cross_reference,
   reply->products[g_num_products].contributer_system_cd = bbprod.contributor_system_cd, reply->
   products[g_num_products].supplier = org.org_name, reply->products[g_num_products].
   final_disp_type_cd = bbprodevnt.event_type_cd,
   reply->products[g_num_products].final_disp_reason_cd = bbprodevnt.reason_cd, reply->products[
   g_num_products].final_disp_tech = psnl.username, reply->products[g_num_products].final_disp_volume
    = bbprodevnt.volume,
   reply->products[g_num_products].final_disp_dt_tm = bbprodevnt.event_dt_tm, reply->products[
   g_num_products].final_disp_qty = bbprodevnt.qty, reply->products[g_num_products].
   final_disp_bag_return_ind = bbprodevnt.bag_returned_ind,
   reply->products[g_num_products].final_disp_tag_return_ind = bbprodevnt.tag_returned_ind
   IF (lt.long_text_id > 0.0)
    reply->products[g_num_products].product_comment = lt.long_text
   ENDIF
   IF (p.person_id > 0.0
    AND bbprodevnt.event_type_cd=transfused_cd)
    reply->products[g_num_products].product_transfused_ind = 1, reply->products[g_num_products].
    patient_name = p.name_full_formatted, reply->products[g_num_products].birth_dt_tm = p.birth_dt_tm,
    reply->products[g_num_products].birth_tz = validate(p.birth_tz,0), reply->products[g_num_products
    ].sex_cd = p.sex_cd
    IF (pa.person_alias_id != 0.0)
     reply->products[g_num_products].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
    IF (pa2.person_alias_id != 0.0)
     reply->products[g_num_products].ssn = cnvtalias(pa2.alias,pa2.alias_pool_cd)
    ENDIF
   ENDIF
   num_antigens = 0, num_attributes = 0
  HEAD bbspectst.special_testing_cd
   IF (bbspectst.special_testing_cd > 0.0)
    IF (trim(cv.cdf_meaning) IN (antigen_cdf1, antigen_cdf2))
     num_antigens += 1
     IF (mod(num_antigens,5)=1)
      stat = alterlist(reply->products[g_num_products].antigens,(num_antigens+ 5))
     ENDIF
     reply->products[g_num_products].antigens[num_antigens].antigen_cd = bbspectst.special_testing_cd
    ENDIF
    IF (trim(cv.cdf_meaning)=attribute_cdf)
     num_attributes += 1
     IF (mod(num_attributes,5)=1)
      stat = alterlist(reply->products[g_num_products].attributes,(num_attributes+ 5))
     ENDIF
     reply->products[g_num_products].attributes[num_attributes].attribute_cd = bbspectst
     .special_testing_cd
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  bbspectst.special_testing_cd
   row + 0
  FOOT  bbprod.product_id
   IF (num_antigens > 0)
    stat = alterlist(reply->products[g_num_products].antigens,num_antigens)
   ENDIF
   IF (num_attributes > 0)
    stat = alterlist(reply->products[g_num_products].attributes,num_attributes)
   ENDIF
  WITH nocounter, outerjoin = d1, memsort
 ;end select
 IF (error_message(1)=1)
  GO TO exit_script
 ENDIF
 IF (g_num_products > 0)
  SET stat = alterlist(reply->products,g_num_products)
  SET reply->status_data.status = "S"
 ELSEIF (g_num_products=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
