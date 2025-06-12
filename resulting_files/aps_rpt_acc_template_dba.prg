CREATE PROGRAM aps_rpt_acc_template:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rptaps = vc
   1 pathnet = vc
   1 dt = vc
   1 dir = vc
   1 time = vc
   1 refdata = vc
   1 bycd = vc
   1 pageno = vc
   1 audparam = vc
   1 incacc = vc
   1 exacc = vc
   1 inctemp = vc
   1 extemp = vc
   1 incpref = vc
   1 expref = vc
   1 stat = vc
   1 desc = vc
   1 act = vc
   1 inact = vc
   1 rptaccess = vc
   1 cont = vc
   1 endrep = vc
   1 acctemp = vc
   1 accform = vc
   1 casepar = vc
   1 field = vc
   1 defval = vc
   1 carfor = vc
   1 prior = vc
   1 yes = vc
   1 no = vc
   1 none = vc
   1 reqdoc = vc
   1 respath = vc
   1 resres = vc
   1 ordloc = vc
   1 copyphys = vc
   1 speclab = vc
   1 specpara = vc
   1 speccode = vc
   1 colldt = vc
   1 recdt = vc
   1 specad = vc
   1 fix = vc
   1 tempassoc = vc
   1 acctemp2 = vc
   1 assocto = vc
   1 prefpara = vc
   1 prefix = vc
   1 aat = vc
   1 dat = vc
   1 codefail = vc
   1 template = vc
   1 statind = vc
   1 paratype = vc
   1 paraval = vc
   1 carry = vc
   1 tempname = vc
   1 prefname = vc
   1 selfail = vc
   1 deftemp = vc
   1 selfail2 = vc
   1 admdoc = vc
   1 admloc = vc
   1 curdttm = vc
   1 caryspecfwd = vc
   1 carcasefwd = vc
   1 attdoc = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"T1","REPORT: APS_RPT_ACC_TEMPLATE.PRG")
 SET captions->pathnet = uar_i18ngetmessage(i18nhandle,"T2","PathNet Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"T3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"T4","DIRECTORY:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"T5","TIME:")
 SET captions->refdata = uar_i18ngetmessage(i18nhandle,"T6","REFERENCE DATABASE AUDIT")
 SET captions->bycd = uar_i18ngetmessage(i18nhandle,"T7","BY:")
 SET captions->pageno = uar_i18ngetmessage(i18nhandle,"T8","PAGE:")
 SET captions->audparam = uar_i18ngetmessage(i18nhandle,"T9","AUDIT PARAMETERS:")
 SET captions->incacc = uar_i18ngetmessage(i18nhandle,"T10","INCLUDE ACCESSIONING TEMPLATE FORMATS")
 SET captions->exacc = uar_i18ngetmessage(i18nhandle,"T11","EXCLUDE ACCESSIONING TEMPLATE FORMATS")
 SET captions->inctemp = uar_i18ngetmessage(i18nhandle,"T12","INCLUDE TEMPLATE ASSOCIATIONS")
 SET captions->extemp = uar_i18ngetmessage(i18nhandle,"T13","EXCLUDE TEMPLATE ASSOCIATIONS")
 SET captions->incpref = uar_i18ngetmessage(i18nhandle,"T14","INCLUDE PREFIX PARAMETERS")
 SET captions->expref = uar_i18ngetmessage(i18nhandle,"T15","EXCLUDE PREFIX PARAMETERS")
 SET captions->stat = uar_i18ngetmessage(i18nhandle,"T16","STATUS:")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"T17","DESCRIPTION:")
 SET captions->act = uar_i18ngetmessage(i18nhandle,"T18","ACTIVE")
 SET captions->inact = uar_i18ngetmessage(i18nhandle,"T19","INACTIVE")
 SET captions->rptaccess = uar_i18ngetmessage(i18nhandle,"T20",
  "REPORT: ACCESSIONING TEMPLATES DATABASE AUDIT")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"T21","CONTINUED...")
 SET captions->endrep = uar_i18ngetmessage(i18nhandle,"T22","### END OF REPORT ###")
 SET captions->acctemp = uar_i18ngetmessage(i18nhandle,"T23","ACCESSIONING TEMPLATES TOOL")
 SET captions->accform = uar_i18ngetmessage(i18nhandle,"T24","ACCESSIONING TEMPLATE FORMATS")
 SET captions->casepar = uar_i18ngetmessage(i18nhandle,"T25","CASE PARAMETERS:")
 SET captions->field = uar_i18ngetmessage(i18nhandle,"T26","FIELD")
 SET captions->defval = uar_i18ngetmessage(i18nhandle,"T27","DEFAULT VALUE")
 SET captions->carfor = uar_i18ngetmessage(i18nhandle,"T28","CARRY FORWARD?")
 SET captions->prior = uar_i18ngetmessage(i18nhandle,"T29","PRIORITY")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"T30","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"T31","NO")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"T32","(NONE)")
 SET captions->reqdoc = uar_i18ngetmessage(i18nhandle,"T33","REQUESTING DOCTOR")
 SET captions->respath = uar_i18ngetmessage(i18nhandle,"T34","RESPONSIBLE PATHOLOGIST")
 SET captions->resres = uar_i18ngetmessage(i18nhandle,"T35","RESPONSIBLE RESIDENT")
 SET captions->ordloc = uar_i18ngetmessage(i18nhandle,"T36","ORDERING LOCATION")
 SET captions->copyphys = uar_i18ngetmessage(i18nhandle,"T37","COPY TO PHYSICIAN")
 SET captions->speclab = uar_i18ngetmessage(i18nhandle,"T38","SPECIMEN LABEL INDICATOR")
 SET captions->specpara = uar_i18ngetmessage(i18nhandle,"T39","SPECIMEN PARAMETERS:")
 SET captions->speccode = uar_i18ngetmessage(i18nhandle,"T40","SPECIMEN CODE")
 SET captions->colldt = uar_i18ngetmessage(i18nhandle,"T41","COLLECTED DATE AND TIME")
 SET captions->recdt = uar_i18ngetmessage(i18nhandle,"T42","RECEIVED DATE AND TIME")
 SET captions->specad = uar_i18ngetmessage(i18nhandle,"T43","SPECIMEN ADEQUACY")
 SET captions->fix = uar_i18ngetmessage(i18nhandle,"T44","FIXATIVE")
 SET captions->tempassoc = uar_i18ngetmessage(i18nhandle,"T45","TEMPLATE ASSOCIATIONS")
 SET captions->acctemp2 = uar_i18ngetmessage(i18nhandle,"T46","ACCESSIONING TEMPLATE:")
 SET captions->assocto = uar_i18ngetmessage(i18nhandle,"T47","ASSOCIATED TO:")
 SET captions->prefpara = uar_i18ngetmessage(i18nhandle,"T48","PREFIX PARAMETERS")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"T49","PREFIX")
 SET captions->aat = uar_i18ngetmessage(i18nhandle,"T50","ASSOCIATED ACCESSIONING TEMPLATES")
 SET captions->dat = uar_i18ngetmessage(i18nhandle,"T51","DEFAULT ACCESSIONING TEMPLATE")
 SET captions->codefail = uar_i18ngetmessage(i18nhandle,"T52","Code_Value select failed.")
 SET captions->template = uar_i18ngetmessage(i18nhandle,"T53","Template   :")
 SET captions->statind = uar_i18ngetmessage(i18nhandle,"T54","Status Ind :")
 SET captions->paratype = uar_i18ngetmessage(i18nhandle,"T55"," * Param Type    :")
 SET captions->paraval = uar_i18ngetmessage(i18nhandle,"T56","   Param Value   :")
 SET captions->carry = uar_i18ngetmessage(i18nhandle,"T57","   Carry for Ind :")
 SET captions->tempname = uar_i18ngetmessage(i18nhandle,"T58","Template Name :")
 SET captions->prefname = uar_i18ngetmessage(i18nhandle,"T59","  Prefix Name:")
 SET captions->selfail = uar_i18ngetmessage(i18nhandle,"T60",
  "Select on AP_PREFIX_ACCN_TEMPLATE failed.")
 SET captions->deftemp = uar_i18ngetmessage(i18nhandle,"T61","  * Default Template :")
 SET captions->selfail2 = uar_i18ngetmessage(i18nhandle,"T62",
  "Select on AP_PREFIX_ACCN_TEMPLATE failed again.")
 SET captions->admdoc = uar_i18ngetmessage(i18nhandle,"T63","ADMITTING DOCTOR")
 SET captions->admloc = uar_i18ngetmessage(i18nhandle,"T64","ADMITTING LOCATION")
 SET captions->curdttm = uar_i18ngetmessage(i18nhandle,"T65","CURRENT DATE/TIME")
 SET captions->caryspecfwd = uar_i18ngetmessage(i18nhandle,"T66","CARRY SPECIMEN FORWARD?")
 SET captions->carcasefwd = uar_i18ngetmessage(i18nhandle,"T67","CARRY CASE FORWARD?")
 SET captions->attdoc = uar_i18ngetmessage(i18nhandle,"T68","ATTENDING DOCTOR")
 RECORD temp(
   1 acc_format_cnt = i4
   1 acc_format_qual[*]
     2 description = c40
     2 status_ind = i2
     2 param_cnt = i4
     2 param_qual[*]
       3 param_type = c16
       3 param_flag = i2
       3 code_value = f8
       3 field = c40
       3 carry_forward_ind = i2
       3 carry_forward_spec_ind = i2
   1 template_assoc_cnt = i4
   1 template_assoc_qual[*]
     2 template_name = c40
     2 assoc_prefix_cnt = i4
     2 assoc_prefix_qual[*]
       3 prefix_display = c40
   1 prefix_param_cnt = i4
   1 prefix_param_qual[*]
     2 prefix_name = c40
     2 default_template_name = c40
     2 assoc_template_cnt = i4
     2 assoc_template_qual[*]
       3 template_name = c40
   1 print_line44 = c44
 )
 RECORD reply(
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ndx = 0
 SET ndx2 = 0
 SET cnt = 0
 SET cnt2 = 0
 SET debug = 0
 SET debug2 = 0
 IF ((request->acc_format_ind=1))
  SELECT INTO "nl:"
   cv.code_set, cv.code_value, cv.display,
   cv.active_ind
   FROM code_value cv,
    ap_accn_template_detail aatd
   PLAN (cv
    WHERE cv.code_set=16689)
    JOIN (aatd
    WHERE aatd.template_cd=cv.code_value)
   ORDER BY cv.display
   HEAD cv.code_value
    cnt = (cnt+ 1), cnt2 = 0, temp->acc_format_cnt = cnt,
    stat = alterlist(temp->acc_format_qual,cnt), temp->acc_format_qual[cnt].description = cv.display,
    temp->acc_format_qual[cnt].status_ind = cv.active_ind,
    temp->acc_format_qual[cnt].param_cnt = 0
   DETAIL
    cnt2 = (cnt2+ 1), temp->acc_format_qual[cnt].param_cnt = cnt2, stat = alterlist(temp->
     acc_format_qual[cnt].param_qual,cnt2),
    temp->acc_format_qual[cnt].param_qual[cnt2].param_type = aatd.detail_name, temp->acc_format_qual[
    cnt].param_qual[cnt2].param_flag = aatd.detail_flag, temp->acc_format_qual[cnt].param_qual[cnt2].
    code_value = aatd.detail_id,
    temp->acc_format_qual[cnt].param_qual[cnt2].field = "", temp->acc_format_qual[cnt].param_qual[
    cnt2].carry_forward_ind = aatd.carry_forward_ind, temp->acc_format_qual[cnt].param_qual[cnt2].
    carry_forward_spec_ind = aatd.carry_forward_spec_ind
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
   SET reply->status_data.status = "P"
   IF (debug=1)
    CALL echo(captions->codefail)
   ENDIF
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  FOR (cnt = 1 TO size(temp->acc_format_qual,5))
   IF (debug=1)
    CALL echo(build("Template   :",temp->acc_format_qual[cnt].description))
    CALL echo(build("Status Ind :",temp->acc_format_qual[cnt].status_ind))
   ENDIF
   FOR (cnt2 = 1 TO size(temp->acc_format_qual[cnt].param_qual,5))
    IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=0))
     SET temp->acc_format_qual[cnt].param_qual[cnt2].field = "(NONE)"
     IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_type="SPECIMEN_LABEL"))
      SET temp->acc_format_qual[cnt].param_qual[cnt2].field = "NO"
     ENDIF
    ELSE
     CASE (temp->acc_format_qual[cnt].param_qual[cnt2].param_type)
      OF "REQ_PHYSICIAN":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->admdoc
       ENDIF
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=3))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->attdoc
       ENDIF
      OF "COPYTO_PHYSICIAN":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->admdoc
       ENDIF
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=3))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->attdoc
       ENDIF
      OF "ORDER_LOCATION":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->admloc
       ENDIF
      OF "SPECIMEN_LABEL":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->yes
       ENDIF
      OF "COLLECTED_DATE":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->curdttm
       ENDIF
      OF "RECEIVED_DATE":
       IF ((temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=2))
        SET temp->acc_format_qual[cnt].param_qual[cnt2].field = captions->curdttm
       ENDIF
     ENDCASE
     IF ((((temp->acc_format_qual[cnt].param_qual[cnt2].param_type="REQ_PHYSICIAN")) OR ((((temp->
     acc_format_qual[cnt].param_qual[cnt2].param_type="COPYTO_PHYSICIAN")) OR ((((temp->
     acc_format_qual[cnt].param_qual[cnt2].param_type="RESP_PATHOLOGIST")) OR ((temp->
     acc_format_qual[cnt].param_qual[cnt2].param_type="RESP_RESIDENT"))) )) ))
      AND (temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=1))
      SELECT INTO "nl:"
       prsnl.person_id
       FROM prsnl p
       PLAN (p
        WHERE (temp->acc_format_qual[cnt].param_qual[cnt2].code_value=p.person_id))
       DETAIL
        temp->acc_format_qual[cnt].param_qual[cnt2].field = p.name_full_formatted
       WITH nocounter
      ;end select
     ENDIF
     IF ((((temp->acc_format_qual[cnt].param_qual[cnt2].param_type="SPECIMEN_CODE")) OR ((((temp->
     acc_format_qual[cnt].param_qual[cnt2].param_type="ORDER_LOCATION")) OR ((((temp->
     acc_format_qual[cnt].param_qual[cnt2].param_type="SPEC_PRIORITY")) OR ((((temp->acc_format_qual[
     cnt].param_qual[cnt2].param_type="SPEC_ADEQUACY")) OR ((temp->acc_format_qual[cnt].param_qual[
     cnt2].param_type="SPEC_FIXATIVE"))) )) )) ))
      AND (temp->acc_format_qual[cnt].param_qual[cnt2].param_flag=1))
      SELECT INTO "nl:"
       cv.code_value, cv.display
       FROM code_value cv
       PLAN (cv
        WHERE (temp->acc_format_qual[cnt].param_qual[cnt2].code_value=cv.code_value))
       DETAIL
        temp->acc_format_qual[cnt].param_qual[cnt2].field = cv.display
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (debug=1)
     CALL echo(build(" * Param Type    :",temp->acc_format_qual[cnt].param_qual[cnt2].param_type))
     CALL echo(build("   Param Value   :",temp->acc_format_qual[cnt].param_qual[cnt2].field))
     CALL echo(build("   Carry For Ind :",temp->acc_format_qual[cnt].param_qual[cnt2].
       carry_forward_ind))
    ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 IF ((request->template_assoc_ind=1))
  SET cnt = 0
  SET cnt2 = 0
  SELECT INTO "nl:"
   apatr.template_cd, cv.display, ap.prefix_name,
   cv2.display
   FROM ap_prefix_accn_template_r apatr,
    code_value cv,
    ap_prefix ap,
    code_value cv2
   PLAN (apatr)
    JOIN (cv
    WHERE cv.code_value=apatr.template_cd)
    JOIN (ap
    WHERE ap.prefix_id=apatr.prefix_id)
    JOIN (cv2
    WHERE cv2.code_value=ap.site_cd)
   ORDER BY cv.display, cv2.display, ap.prefix_name
   HEAD cv.code_value
    cnt = (cnt+ 1), cnt2 = 0, temp->template_assoc_cnt = cnt,
    stat = alterlist(temp->template_assoc_qual,cnt), temp->template_assoc_qual[cnt].template_name =
    cv.display
    IF (debug=1)
     CALL echo(build("Template Name :",temp->template_assoc_qual[cnt].template_name))
    ENDIF
   HEAD ap.prefix_id
    cnt2 = (cnt2+ 1), temp->template_assoc_qual[cnt].assoc_prefix_cnt = cnt2, stat = alterlist(temp->
     template_assoc_qual[cnt].assoc_prefix_qual,cnt2)
   DETAIL
    IF (ap.site_cd > 0)
     temp->template_assoc_qual[cnt].assoc_prefix_qual[cnt2].prefix_display = concat(trim(cv2.display),
      ap.prefix_name,", ",trim(ap.prefix_desc))
    ELSE
     temp->template_assoc_qual[cnt].assoc_prefix_qual[cnt2].prefix_display = concat(ap.prefix_name,
      ", ",trim(ap.prefix_desc))
    ENDIF
    IF (debug=1)
     CALL echo(build("  Prefix Name :",temp->template_assoc_qual[cnt].assoc_prefix_qual[cnt2].
      prefix_display))
    ENDIF
   WITH nocounter, outerjoin = cv2
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
   SET reply->status_data.status = "P"
   IF (debug=1)
    CALL echo("Select on AP_PREFIX_ACCN_TEMPLATE failed.")
   ENDIF
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->prefix_param_ind=1))
  SET cnt = 0
  SET cnt2 = 0
  SELECT INTO "nl:"
   apatr.template_cd, apatr.prefix_id, cv.code_value,
   ap.prefix_id, ap.site_cd, cv2.code_value
   FROM ap_prefix_accn_template_r apatr,
    ap_prefix ap,
    code_value cv,
    code_value cv2
   PLAN (apatr)
    JOIN (ap
    WHERE ap.prefix_id=apatr.prefix_id)
    JOIN (cv
    WHERE cv.code_value=ap.site_cd)
    JOIN (cv2
    WHERE cv2.code_value=apatr.template_cd)
   ORDER BY cv.display, ap.prefix_name, cv2.display
   HEAD ap.prefix_id
    cnt = (cnt+ 1), cnt2 = 0, temp->prefix_param_cnt = cnt,
    stat = alterlist(temp->prefix_param_qual,cnt)
    IF (ap.site_cd > 0)
     temp->prefix_param_qual[cnt].prefix_name = concat(trim(cv.display),ap.prefix_name,", ",trim(ap
       .prefix_desc))
    ELSE
     temp->prefix_param_qual[cnt].prefix_name = concat(ap.prefix_name,", ",trim(ap.prefix_desc))
    ENDIF
    IF (debug=1)
     CALL echo(build("Prefix Name :",temp->prefix_param_qual[cnt].prefix_name))
    ENDIF
   DETAIL
    cnt2 = (cnt2+ 1), temp->prefix_param_qual[cnt].assoc_template_cnt = cnt2, stat = alterlist(temp->
     prefix_param_qual[cnt].assoc_template_qual,cnt2),
    temp->prefix_param_qual[cnt].assoc_template_qual[cnt2].template_name = cv2.display
    IF (apatr.default_ind > 0)
     temp->prefix_param_qual[cnt].default_template_name = cv2.display
     IF (debug=1)
      CALL echo(build("  * Default Template :",temp->prefix_param_qual[cnt].default_template_name))
     ENDIF
    ENDIF
    IF (debug=1)
     CALL echo(build("  Template Name :",temp->prefix_param_qual[cnt].assoc_template_qual[cnt2].
      template_name))
    ENDIF
   WITH nocounter, outerjoin = cv
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
   SET reply->status_data.status = "P"
   IF (debug=1)
    CALL echo("Select on AP_PREFIX_ACCN_TEMPLATE failed again.")
   ENDIF
  ELSE
   IF ((reply->status_data.status != "P"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbAccTemplate", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF (debug2=1)
  CALL echo(value(reply->print_status_data.print_dir_and_filename))
 ENDIF
 SET line44 = fillstring(44,"-")
 SET line39 = fillstring(39,"-")
 SET line40 = fillstring(40,"-")
 SET line14 = fillstring(14,"-")
 SET line19 = fillstring(19,"-")
 SET line23 = fillstring(23,"-")
 SET string1 = fillstring(40," ")
 SET string2 = fillstring(40," ")
 SET string3 = fillstring(40," ")
 SELECT INTO value(reply->print_status_data.print_filename)
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), row + 1,
   col 1, captions->rptaps, col 56,
   CALL center(captions->pathnet,1,132), col 110, captions->dt,
   col 117, curdate"@SHORTDATE;;D", row + 1,
   col 1, captions->dir, col 110,
   captions->time, col 117, curtime,
   row + 1, col 54,
   CALL center(captions->refdata,1,132),
   col 112, captions->bycd, col 117,
   request->scuruser, row + 1, col 50,
   CALL center(captions->acctemp,1,132), col 110, captions->pageno,
   col 117, curpage"###", row + 1,
   row + 1, col 1, captions->audparam,
   row + 1, col 3
   IF ((request->acc_format_ind=1))
    captions->incacc
   ELSE
    captions->exacc
   ENDIF
   row + 1, col 3
   IF ((request->template_assoc_ind=1))
    captions->inctemp
   ELSE
    captions->extemp
   ENDIF
   row + 1, col 3
   IF ((request->prefix_param_ind=1))
    captions->incpref
   ELSE
    captions->expref
   ENDIF
   row + 1
  HEAD PAGE
   IF (curpage > 1)
    row + 1, col 1, captions->rptaps,
    col 56,
    CALL center(captions->pathnet,1,132), col 110,
    captions->dt, col 117, curdate"@SHORTDATE;;D",
    row + 1, col 1, captions->dir,
    col 110, captions->time, col 117,
    curtime, row + 1, col 54,
    CALL center(captions->refdata,1,132), col 112, captions->bycd,
    col 117, request->scuruser, row + 1,
    col 50,
    CALL center(captions->acctemp,1,132), col 110,
    captions->pageno, col 117, curpage"###",
    row + 1
   ENDIF
  DETAIL
   IF ((request->acc_format_ind=1))
    IF (((row+ 3) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, col 50,
    CALL center(captions->accform,1,132),
    row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132),
    row + 1, ndx = 0
    FOR (ndx = 1 TO temp->acc_format_cnt)
      IF (((row+ 24) >= (maxrow - 4)))
       BREAK
      ENDIF
      row + 1, col 1, captions->desc,
      col 15, temp->acc_format_qual[ndx].description, row + 1,
      col 1, captions->stat
      IF ((temp->acc_format_qual[ndx].status_ind > 0))
       col 10, captions->act
      ELSE
       col 10, captions->inact
      ENDIF
      row + 1, row + 1, col 1,
      captions->casepar, row + 1, row + 1,
      col 1, captions->field, col 46,
      captions->defval, col 86, captions->carfor,
      row + 1, col 1, line44,
      col 46, line39, col 86,
      line14, row + 1, col 1,
      captions->reqdoc, found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("REQ_PHYSICIAN"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 91, captions->yes
         ELSE
          col 91, captions->no
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, col 1, captions->respath,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("RESP_PATHOLOGIST"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 91, captions->yes
         ELSE
          col 91, captions->no
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, col 1, captions->resres,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("RESP_RESIDENT"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 91, captions->yes
         ELSE
          col 91, captions->no
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, col 1, captions->ordloc,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("ORDER_LOCATION"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 91, captions->yes
         ELSE
          col 91, captions->no
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, col 1, captions->copyphys,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("COPYTO_PHYSICIAN"))
         IF (found=1)
          row + 1
         ENDIF
         col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF (found=0)
          IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
           col 91, captions->yes
          ELSE
           col 91, captions->no
          ENDIF
         ENDIF
         found = 1
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, col 1, captions->speclab,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("SPECIMEN_LABEL"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 91, captions->yes
         ELSE
          col 91, captions->no
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 91,
       captions->no
      ENDIF
      row + 1, row + 1, col 1,
      captions->specpara, row + 1, row + 1,
      col 1, captions->field, col 46,
      captions->defval, col 86, captions->carcasefwd,
      col 106, captions->caryspecfwd, row + 1,
      col 1, line44, col 46,
      line39, col 86, line19,
      col 106, line23, row + 1,
      col 1, captions->speccode, found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("SPECIMEN_CODE"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, col 1, captions->colldt,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("COLLECTED_DATE"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, col 1, captions->recdt,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("RECEIVED_DATE"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, col 1, captions->specad,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("SPEC_ADEQUACY"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, col 1, captions->fix,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("SPEC_FIXATIVE"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, col 1, captions->prior,
      found = 0
      FOR (ndx2 = 1 TO temp->acc_format_qual[ndx].param_cnt)
        IF (trim(temp->acc_format_qual[ndx].param_qual[ndx2].param_type)=trim("SPEC_PRIORITY"))
         found = 1, col 46, temp->acc_format_qual[ndx].param_qual[ndx2].field
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_ind > 0))
          col 86, captions->yes
         ELSE
          col 86, captions->no
         ENDIF
         IF ((temp->acc_format_qual[ndx].param_qual[ndx2].carry_forward_spec_ind > 0))
          col 106, "YES"
         ELSE
          col 106, "NO"
         ENDIF
        ENDIF
      ENDFOR
      IF (found=0)
       col 46, captions->none, col 86,
       captions->no, col 106, captions->no
      ENDIF
      row + 1, row + 1, col 60,
      CALL center(fillstring(10,"*"),1,132)
    ENDFOR
   ENDIF
   IF ((request->template_assoc_ind=1))
    IF (((row+ 4) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->tempassoc,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), ndx = 0
    FOR (ndx = 1 TO temp->template_assoc_cnt)
      IF ((((row+ 6)+ temp->template_assoc_qual[ndx].assoc_prefix_cnt) >= (maxrow - 4)))
       BREAK
      ENDIF
      row + 1, row + 1, col 1,
      captions->acctemp2, col 25, temp->template_assoc_qual[ndx].template_name,
      row + 1, row + 1, col 1,
      captions->assocto
      IF ((temp->template_assoc_qual[ndx].assoc_prefix_cnt > 0))
       col 25, temp->template_assoc_qual[ndx].assoc_prefix_qual[1].prefix_display
       FOR (ndx2 = 2 TO temp->template_assoc_qual[ndx].assoc_prefix_cnt)
         row + 1, col 25, temp->template_assoc_qual[ndx].assoc_prefix_qual[ndx2].prefix_display
       ENDFOR
      ELSE
       col 25, captions->none
      ENDIF
      row + 1, row + 1, col 60,
      CALL center(fillstring(10,"*"),1,132)
    ENDFOR
   ENDIF
   IF ((request->prefix_param_ind=1))
    IF (((row+ 9) >= (maxrow - 4)))
     BREAK
    ENDIF
    row + 1, row + 1, col 40,
    CALL center(fillstring(41,"-"),1,132), row + 1, col 50,
    CALL center(captions->prefpara,1,132), row + 1, col 39,
    CALL center(fillstring(41,"-"),1,132), row + 1, row + 1,
    col 1, captions->prefix, col 42,
    captions->aat, col 83, captions->dat,
    row + 1, col 1, line40,
    col 42, line40, col 83,
    line40, ndx = 0
    FOR (ndx = 1 TO temp->prefix_param_cnt)
      IF ((((row+ 1)+ temp->prefix_param_qual[ndx].assoc_template_cnt) >= (maxrow - 4)))
       BREAK
      ENDIF
      row + 1, col 1, temp->prefix_param_qual[ndx].prefix_name
      IF ((temp->prefix_param_qual[ndx].assoc_template_cnt > 0))
       col 42, temp->prefix_param_qual[ndx].assoc_template_qual[1].template_name
       IF (textlen(trim(temp->prefix_param_qual[ndx].default_template_name))=0)
        col 83, "(NONE)"
       ELSE
        col 83, temp->prefix_param_qual[ndx].default_template_name
       ENDIF
       FOR (ndx2 = 2 TO temp->prefix_param_qual[ndx].assoc_template_cnt)
         row + 1, col 42, temp->prefix_param_qual[ndx].assoc_template_qual[ndx2].template_name
       ENDFOR
      ELSE
       col 42, captions->none, col 83,
       captions->none
      ENDIF
      row + 1
    ENDFOR
    row + 1, col 60,
    CALL center(fillstring(10,"*"),1,132)
   ENDIF
  FOOT PAGE
   row 60, col 1, line1,
   row + 1, col 1, captions->rptaccess,
   newday = format(curdate,"@WEEKDAYABBREV;;D"), newdate = format(curdate,"@MEDIUMDATE4YR;;D"), col
   58,
   newday, " ", newdate,
   col 110, captions->pageno, col 117,
   curpage"###", row + 1, col 55,
   CALL center(captions->cont,1,132)
  FOOT REPORT
   col 55,
   CALL center(captions->endrep,1,132)
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  IF ((reply->status_data.status != "P"))
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
