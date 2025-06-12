CREATE PROGRAM bhs_udt_future_appt:dba
 DECLARE mf_bldg_loc_grp_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"
   ))
 DECLARE mf_fac_loc_grp_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY")
  )
 DECLARE ehtml = i2 WITH constant(1), protect
 DECLARE ertf = i2 WITH constant(2), protect
 DECLARE ascii_linefeed = i4 WITH constant(10), protect
 DECLARE ascii_verticaltab = i4 WITH constant(11), protect
 DECLARE ascii_formfeed = i4 WITH constant(12), protect
 DECLARE ascii_space = i4 WITH constant(32), protect
 DECLARE ascii_lessthan = i4 WITH constant(60), protect
 DECLARE ascii_greaterthan = i4 WITH constant(62), protect
 DECLARE ascii_ampersand = i4 WITH constant(38), protect
 DECLARE ascii_openbrace = i4 WITH constant(123), protect
 DECLARE ascii_closebrace = i4 WITH constant(125), protect
 DECLARE ascii_escchar = i4 WITH constant(92), protect
 SUBROUTINE (formatspecialcharacters(_nformattype=i2,_sinputdata=vc) =vc)
   DECLARE formatspecialcharacters = f8 WITH private, noconstant(curtime3)
   DECLARE sformatdata = vc WITH private, noconstant(_sinputdata)
   IF (size(_sinputdata,1) > 0)
    CASE (_nformattype)
     OF ehtml:
      SET sformatdata = replace(sformatdata,char(ascii_ampersand),"&amp;",0)
      SET sformatdata = replace(sformatdata,char(ascii_lessthan),"&lt;",0)
      SET sformatdata = replace(sformatdata,char(ascii_greaterthan),"&gt;",0)
      SET sformatdata = replace(sformatdata,char(ascii_linefeed),"<br>",0)
      SET sformatdata = replace(sformatdata,char(ascii_verticaltab),"<br>",0)
      SET sformatdata = replace(sformatdata,char(ascii_formfeed),"<br>",0)
      SET sformatdata = replace(sformatdata,char(ascii_space),"&nbsp;",0)
     OF ertf:
      SET sformatdata = replace(sformatdata,char(ascii_escchar),"\\\\",0)
      SET sformatdata = replace(sformatdata,char(ascii_linefeed),"\\par",0)
      SET sformatdata = replace(sformatdata,char(ascii_openbrace),"\\{",0)
      SET sformatdata = replace(sformatdata,char(ascii_closebrace),"\\}",0)
    ENDCASE
   ENDIF
   RETURN(sformatdata)
 END ;Subroutine
 SUBROUTINE (replacespecialcharacters(_sinputdata=vc) =vc)
   DECLARE replacespecialcharacters = f8 WITH private, noconstant(curtime3)
   DECLARE sformatdata = vc WITH private, noconstant(trim(_sinputdata))
   IF (size(sformatdata,1) > 0)
    SET sformatdata = replace(sformatdata,"&","&#38;",0)
    SET sformatdata = replace(sformatdata,"^","&#94;",0)
    SET sformatdata = replace(sformatdata,"\","&#92;",0)
    SET sformatdata = replace(sformatdata,"/","&#47;",0)
    SET sformatdata = replace(sformatdata,"|","&#124;",0)
    SET sformatdata = replace(sformatdata,'"',"&#34;",0)
    SET sformatdata = replace(sformatdata,"'","&#39;",0)
    SET sformatdata = replace(sformatdata,"<","&#60;",0)
    SET sformatdata = replace(sformatdata,">","&#62;",0)
   ENDIF
   RETURN(sformatdata)
 END ;Subroutine
 SUBROUTINE (escapejsoncharacters(_sinputdata=vc) =vc WITH protect)
   DECLARE escapejsoncharacters = f8 WITH private, noconstant(curtime3)
   DECLARE sformatdata = vc WITH private, noconstant(_sinputdata)
   IF (size(sformatdata,1) > 0)
    SET sformatdata = replace(sformatdata,"&#34;","\&#34;",0)
    SET sformatdata = replace(sformatdata,'"',"\&#34;",0)
   ENDIF
   RETURN(sformatdata)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
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
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SUBROUTINE (retrieveformattedcitystatezip(city=vc,state=vc,state_cd=f8,zipcode=vc) =vc)
   DECLARE city_state_zip = vc
   IF (textlen(formatspecialcharacters(ehtml,trim(city,3))) > 0)
    SET city_state_zip = formatspecialcharacters(ehtml,trim(city,3))
    IF (state_cd > 0.0)
     SET city_state_zip = concat(city_state_zip,",",sspace,trim(uar_get_code_display(state_cd),3))
    ELSEIF (textlen(formatspecialcharacters(ehtml,trim(state,3))) > 0)
     SET city_state_zip = concat(city_state_zip,",",sspace,formatspecialcharacters(ehtml,trim(state,3
        )))
    ENDIF
    IF (textlen(formatspecialcharacters(ehtml,trim(zipcode,3))) > 0)
     SET city_state_zip = concat(city_state_zip,",",sspace,formatspecialcharacters(ehtml,trim(zipcode,
        3)))
    ENDIF
   ELSEIF (((state_cd > 0.0) OR (textlen(formatspecialcharacters(ehtml,trim(state,3))) > 0)) )
    IF (state_cd > 0.0)
     SET city_state_zip = trim(uar_get_code_display(state_cd),3)
    ELSE
     SET city_state_zip = formatspecialcharacters(ehtml,trim(state,3))
    ENDIF
    IF (textlen(formatspecialcharacters(ehtml,trim(zipcode,3))) > 0)
     SET city_state_zip = concat(city_state_zip,",",sspace,formatspecialcharacters(ehtml,trim(zipcode,
        3)))
    ENDIF
   ELSEIF (textlen(formatspecialcharacters(ehtml,trim(zipcode,3))) > 0)
    SET city_state_zip = formatspecialcharacters(ehtml,trim(zipcode,3))
   ENDIF
   RETURN(city_state_zip)
 END ;Subroutine
 RECORD reply(
   1 text = vc
   1 format = i4
 )
 DECLARE dpersonid = f8 WITH constant(request->person_id)
 DECLARE dencntrid = f8 WITH constant(request->encntr_id)
 DECLARE bus_add = f8 WITH constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE work_phone = f8 WITH constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE fax_phone = f8 WITH constant(uar_get_code_by("MEANING",43,"FAX BUS"))
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE active = f8 WITH constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE anticipated = f8 WITH constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
 DECLARE not_done = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE beginspan = vc WITH constant("<span")
 DECLARE beginstyle = vc WITH noconstant("style='font-size:12.0pt;font-family:Arial;'>")
 DECLARE endstyle = vc WITH constant("</style>")
 DECLARE endspan = vc WITH constant("</span>")
 IF (validate(request->fontsize)=1
  AND validate(request->fontfamily)=1)
  IF (size(trim(request->fontsize),1) > 0
   AND size(trim(request->fontfamily),1) > 0)
   SET beginstyle = build("style='font-size:",request->fontsize,";font-family:",request->fontfamily,
    ";'>")
  ENDIF
 ENDIF
 DECLARE sspace = vc WITH constant("&nbsp;")
 DECLARE space = vc WITH constant("&nbsp;&nbsp;")
 DECLARE cspace = vc WITH constant(concat(":",sspace))
 DECLARE tab = vc WITH constant("&nbsp;&nbsp;&nbsp;&nbsp;")
 DECLARE comma = vc WITH constant(",")
 DECLARE bold = vc WITH constant("<b>")
 DECLARE ebold = vc WITH constant("</b>")
 DECLARE unl = vc WITH constant("<u>")
 DECLARE eunl = vc WITH constant("</u>")
 DECLARE brk = vc WITH constant("<br />")
 DECLARE htmlbegin = vc WITH constant("<html><body>")
 DECLARE htmlend = vc WITH constant("</body></html>")
 DECLARE htmlparagraph = vc WITH constant(
  "<p class=MsoNormal style='TEXT-ALIGN: center' align=center>")
 DECLARE htmlparagraphend = vc WITH constant("</p>")
 DECLARE htmlrow = vc WITH constant("<tr>")
 DECLARE htmlrowend = vc WITH constant("</tr>")
 DECLARE hdrbegin = vc WITH constant(concat(beginspan," ",beginstyle,bold))
 DECLARE hdrend = vc WITH constant(concat(ebold,endstyle,endspan))
 DECLARE subbegin = vc WITH constant(concat(beginspan," ",beginstyle,bold))
 DECLARE subend = vc WITH constant(concat(ebold,endstyle,endspan))
 DECLARE bodybegin = vc WITH constant(concat(beginspan," ",beginstyle))
 DECLARE bodyend = vc WITH constant(concat(endstyle,endspan))
 DECLARE i18nsummarytitlehdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars01",
   "Visit Summary for "))
 DECLARE i18ntitlethanks = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars02",
"We would like to thank you for allowing us to assist you with your healthcare needs. Our entire staff strives to provide a\
n   excellent experience for our patients and their families. The following includes information regarding your visit.\
"))
 DECLARE i18n_visithdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars03",
   "Visit Information"))
 DECLARE i18n_ftrappthdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars04",
   "Future Appointments"))
 DECLARE i18n_diaghdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars05",
   "Diagnoses This Visit"))
 DECLARE i18n_medprobhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars06","Problems")
  )
 DECLARE i18n_smokestatushdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars07",
   "Smoking Status"))
 DECLARE i18n_prochdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars08","Procedures"))
 DECLARE i18n_immunhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars09",
   "Immunizations"))
 DECLARE i18n_allergyhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars10","Allergies"
   ))
 DECLARE i18n_labradhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars11",
   "Laboratory or Other Results This Visit"))
 DECLARE i18n_futureappt = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars12",
   "No Future Appointments Scheduled"))
 DECLARE i18n_labrad = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars13",
   "No Laboratory or Other Results This Visit"))
 DECLARE i18n_allergy = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars14",
   "No Allergies Documented"))
 DECLARE i18n_diag = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars15",
   "No Visit Diagnoses Documented"))
 DECLARE i18n_medprob = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars16",
   "No Problems Documented"))
 DECLARE i18n_pated = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars17",
   "No Patient Education Material Documented"))
 DECLARE i18n_smokestatus = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars18",
   "No Smoking Status Documented"))
 DECLARE i18n_proc = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars19",
   "No Procedures Documented"))
 DECLARE i18n_immun = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars20",
   "No Immunizations Documented This Visit"))
 DECLARE i18n_defaultnone = vc WITH constant(uar_i18ngetmessage(i18nhandle,"fn_udt_vars01","None"))
 DECLARE i18n_schedprovtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars21",
   "Scheduled Provider"))
 DECLARE i18n_agetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars22","Age"))
 DECLARE i18n_gendertitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars23","Sex"))
 DECLARE i18n_dobtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars24","DOB"))
 DECLARE i18n_mrntitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars25","MRN"))
 DECLARE i18n_addresstitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars26","Address"
   ))
 DECLARE i18n_homephtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars27","Home"))
 DECLARE i18n_workphtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars28","Work"))
 DECLARE i18n_mobilephtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars29","Mobile"
   ))
 DECLARE i18n_pcptitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars30",
   "Primary Care Provider"))
 DECLARE i18n_racetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars31","Race"))
 DECLARE i18n_ethnicitytitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars32",
   "Ethnicity"))
 DECLARE i18n_languagetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars33",
   "Language"))
 DECLARE i18n_healthplantitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars34",
   "Health plan"))
 DECLARE i18n_locphtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars35","Phone"))
 DECLARE i18n_locfaxtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars36","Fax"))
 DECLARE i18n_visdatetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars37",
   "Visit Date"))
 DECLARE i18n_apptdttitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars38",
   "Appt. Date"))
 DECLARE i18n_apploctitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars39","Location"
   ))
 DECLARE i18n_apptypetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars40","Type"))
 DECLARE i18n_appdesctitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars41",
   "Description"))
 DECLARE i18n_primaryphysiciantitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"fn_udt_vars02",
   "Primary Physician:"))
 DECLARE i18n_primarynursetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"fn_udt_vars03",
   "Primary Nurse:"))
 DECLARE i18n_lastchartedstr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars42",
   "last charted value for your"))
 DECLARE i18n_visitstr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars43","visit"))
 DECLARE i18n_fax = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars44","Fax"))
 DECLARE i18n_normalrangebetween = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars45",
   "Normal range between"))
 DECLARE i18n_and = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars46","and"))
 DECLARE i18n_sentto = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars47","Sent to"))
 DECLARE i18n_take = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars48","Take"))
 DECLARE i18n_deceasedon = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars49",
   "Deceased on"))
 DECLARE i18n_deceased = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars50","Deceased"))
 DECLARE i18n_notgiven = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mu_udt_vars51","Not Given"))
 DECLARE title_thanks = vc WITH constant(concat(bodybegin,i18ntitlethanks,bodyend))
 DECLARE future_appt_str = vc WITH noconstant(concat(bodybegin,tab,i18n_futureappt,bodyend))
 DECLARE lab_rad_str = vc WITH noconstant(concat(bodybegin,tab,i18n_labrad,bodyend))
 DECLARE allergy_str = vc WITH noconstant(concat(bodybegin,tab,i18n_allergy,bodyend))
 DECLARE diag_str = vc WITH noconstant(concat(bodybegin,tab,i18n_diag,bodyend))
 DECLARE medprob_str = vc WITH noconstant(concat(bodybegin,tab,i18n_medprob,bodyend))
 DECLARE smoke_status_str = vc WITH noconstant(concat(bodybegin,tab,i18n_smokestatus,bodyend))
 DECLARE proc_str = vc WITH noconstant(concat(bodybegin,tab,i18n_proc,bodyend))
 DECLARE immun_str = vc WITH noconstant(concat(bodybegin,tab,i18n_immun,bodyend))
 DECLARE primary_physician_str = vc WITH noconstant(concat(bodybegin,i18n_defaultnone,bodyend))
 DECLARE primary_nurse_str = vc WITH noconstant(concat(bodybegin,i18n_defaultnone,bodyend))
 DECLARE dnurseloccd = i4 WITH noconstant(0)
 DECLARE encntr_date_val = vc
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=dencntrid)
  DETAIL
   encntr_date_val = format(e.reg_dt_tm,"@SHORTDATE4YR"), dnurseloccd = e.loc_nurse_unit_cd
  WITH nocounter
 ;end select
 DECLARE visit_header = vc WITH constant(concat(hdrbegin,i18n_visithdr,hdrend))
 DECLARE ftrappt_header = vc WITH constant(concat(hdrbegin,i18n_ftrappthdr,hdrend))
 DECLARE diag_header = vc WITH constant(concat(hdrbegin,i18n_diaghdr,hdrend))
 DECLARE medprob_header = vc WITH constant(concat(hdrbegin,i18n_medprobhdr,hdrend))
 DECLARE smoke_status_header = vc WITH constant(concat(hdrbegin,i18n_smokestatushdr,hdrend))
 DECLARE proc_header = vc WITH constant(concat(hdrbegin,i18n_prochdr,hdrend))
 DECLARE immun_header = vc WITH constant(concat(hdrbegin,i18n_immunhdr,hdrend))
 DECLARE allergy_header = vc WITH constant(concat(hdrbegin,i18n_allergyhdr,hdrend))
 DECLARE visit_reason_header = vc WITH constant(concat(hdrbegin,i18nsummarytitlehdr,hdrend))
 DECLARE lab_rad_header = vc WITH constant(concat(hdrbegin,i18n_labradhdr,hdrend,bodybegin,sspace,
   "(",i18n_lastchartedstr,sspace,encntr_date_val,sspace,
   i18n_visitstr,")",bodyend))
 DECLARE primary_physician_header = vc WITH constant(concat(hdrbegin,i18n_primaryphysiciantitle,
   hdrend))
 DECLARE primary_nurse_header = vc WITH constant(concat(hdrbegin,i18n_primarynursetitle,hdrend))
 DECLARE sched_prov_title = vc WITH constant(concat(bold,i18n_schedprovtitle,cspace,ebold))
 DECLARE age_title = vc WITH constant(concat(bold,i18n_agetitle,cspace,ebold))
 DECLARE gender_title = vc WITH constant(concat(bold,i18n_gendertitle,cspace,ebold))
 DECLARE dob_title = vc WITH constant(concat(bold,i18n_dobtitle,cspace,ebold))
 DECLARE mrn_title = vc WITH constant(concat(bold,i18n_mrntitle,cspace,ebold))
 DECLARE address_title = vc WITH constant(concat(bold,i18n_addresstitle,cspace,ebold))
 DECLARE home_ph_title = vc WITH constant(concat(bold,i18n_homephtitle,cspace,ebold))
 DECLARE work_ph_title = vc WITH constant(concat(bold,i18n_workphtitle,cspace,ebold))
 DECLARE mobile_ph_title = vc WITH constant(concat(bold,i18n_mobilephtitle,cspace,ebold))
 DECLARE pcp_title = vc WITH constant(concat(bold,i18n_pcptitle,cspace,ebold))
 DECLARE race_title = vc WITH constant(concat(bold,i18n_racetitle,cspace,ebold))
 DECLARE ethnicity_title = vc WITH constant(concat(bold,i18n_ethnicitytitle,cspace,ebold))
 DECLARE language_title = vc WITH constant(concat(bold,i18n_languagetitle,cspace,ebold))
 DECLARE hp_title = vc WITH constant(concat(bold,i18n_healthplantitle,cspace,ebold))
 DECLARE loc_ph_title = vc WITH constant(concat(bold,i18n_locphtitle,cspace,ebold))
 DECLARE loc_fax_title = vc WITH constant(concat(bold,i18n_locfaxtitle,cspace,ebold))
 DECLARE vis_date_title = vc WITH constant(concat(bold,i18n_visdatetitle,cspace,ebold))
 DECLARE appt_dt_title = vc WITH constant(concat(bold,i18n_apptdttitle,cspace,ebold))
 DECLARE appt_loc_title = vc WITH constant(concat(bold,i18n_apploctitle,cspace,ebold))
 DECLARE appt_type_title = vc WITH constant(concat(bold,i18n_apptypetitle,cspace,ebold))
 DECLARE appt_desc_title = vc WITH constant(concat(bold,i18n_appdesctitle,cspace,ebold))
 DECLARE result_val = vc
 DECLARE vs_meas_val = vc
 DECLARE loc_final_addr_str = vc
 DECLARE loc_final_phone_str = vc
 DECLARE loc_street_addr1 = vc
 DECLARE loc_city_state_zip = vc
 DECLARE nof_def = vc WITH constant("--")
 DECLARE loc_fax = vc WITH noconstant(concat(loc_fax_title,nof_def))
 DECLARE loc_phone = vc WITH noconstant(concat(loc_ph_title,nof_def))
 DECLARE vdose_id = i4 WITH noconstant(0)
 DECLARE vdoseunit_id = i4 WITH noconstant(0)
 DECLARE sdose_id = i4 WITH noconstant(0)
 DECLARE sdoseunit_id = i4 WITH noconstant(0)
 DECLARE fdose_id = i4 WITH noconstant(0)
 DECLARE rxroute_id = i4 WITH noconstant(0)
 DECLARE freq_id = i4 WITH noconstant(0)
 DECLARE duration_id = i4 WITH noconstant(0)
 DECLARE durationunit_id = i4 WITH noconstant(0)
 DECLARE prninst_id = i4 WITH noconstant(0)
 DECLARE specinst_id = i4 WITH noconstant(0)
 DECLARE totref_id = i4 WITH noconstant(0)
 DECLARE reqrteloc_id = i4 WITH noconstant(0)
 DECLARE refreas_id = i4 WITH noconstant(0)
 DECLARE refto_id = i4 WITH noconstant(0)
 DECLARE rqstdttm_id = i4 WITH noconstant(0)
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 IF (validate(schuar_def,999)=999)
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security(sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=f8(ref),parent3_id
   =f8(ref),sec_id=f8(ref),
   user_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security",
  persist
  DECLARE uar_sch_security_insert(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=
   f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_security_insert",
  persist
  DECLARE uar_sch_security_perform() = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_perform",
  persist
  DECLARE uar_sch_check_security_ex(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id
   =f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security_ex",
  persist
  DECLARE uar_sch_check_security_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_check_security_ex2",
  persist
  DECLARE uar_sch_security_insert_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_insert_ex2",
  persist
 ENDIF
 DECLARE getpersonneladdress(null) = null
 DECLARE getpersonnelphone(null) = null
 DECLARE getserviceresourcedata(null) = null
 DECLARE napptlocpref = i2 WITH noconstant(0)
 FREE RECORD pref_request
 RECORD pref_request(
   1 context = vc
   1 context_id = vc
   1 section = vc
   1 section_id = vc
   1 groups[*]
     2 name = vc
   1 debug = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 entries[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (loadpreferences(param=i4) =null)
   DECLARE fnpreferencequery = f8 WITH private, noconstant(curtime3)
   DECLARE nprefcnt = i4 WITH noconstant(0)
   DECLARE ncurpref = i4 WITH noconstant(0)
   DECLARE ncurvalue = i4 WITH noconstant(0)
   SET pref_request->context = "default"
   SET pref_request->context_id = "system"
   SET pref_request->section = "module"
   SET pref_request->section_id = "cwd"
   SET stat = alterlist(pref_request->groups,2)
   SET pref_request->groups[1].name = "depart tokens"
   SET pref_request->groups[2].name = "mu_udt_future_appt"
   SET pref_request->debug = "0"
   EXECUTE fn_get_prefs  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   SET nprefcnt = size(pref_reply->entries,5)
   FOR (ncurpref = 1 TO nprefcnt)
     IF ((pref_reply->entries[ncurpref].name="show_appt_loc_address"))
      FOR (ncurvalue = 1 TO size(pref_reply->entries[ncurpref].values,5))
        IF ((pref_reply->entries[ncurpref].values[ncurvalue].value="1"))
         SET napptlocpref = 1
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getpersonneladdress(null)
   DECLARE getpersonneladdress = f8 WITH private, noconstant(curtime3)
   IF (napptlocpref=1)
    SELECT INTO "nl:"
     address_sort =
     IF (a.parent_entity_id=l.location_cd) 1
     ELSEIF (a.parent_entity_id=amb.parent_loc_cd) 2
     ELSEIF (a.parent_entity_id=bldg.parent_loc_cd) 3
     ENDIF
     FROM (dummyt d1  WITH seq = size(rscheduleappt->list,5)),
      location l,
      location_group amb,
      location_group bldg,
      address a
     PLAN (d1)
      JOIN (l
      WHERE (l.location_cd=rscheduleappt->list[d1.seq].appt_location_cd))
      JOIN (amb
      WHERE amb.child_loc_cd=l.location_cd
       AND amb.location_group_type_cd=mf_bldg_loc_grp_type_cd)
      JOIN (bldg
      WHERE bldg.child_loc_cd=amb.parent_loc_cd
       AND bldg.location_group_type_cd=mf_fac_loc_grp_type_cd)
      JOIN (a
      WHERE a.parent_entity_id IN (l.location_cd, amb.parent_loc_cd, bldg.parent_loc_cd)
       AND a.parent_entity_name="LOCATION"
       AND a.parent_entity_id != 0.0
       AND a.address_type_cd=bus_add
       AND a.active_ind=1
       AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY d1.seq, address_sort, a.address_type_seq
     HEAD d1.seq
      loc_city_state_zip = sspace, loc_street_addr1 = sspace, loc_final_addr_str = sspace,
      CALL echo(build2(build(uar_get_code_display(l.location_cd))))
      IF (((textlen(trim(a.street_addr2,3)) > 0) OR (((textlen(trim(a.street_addr3,3)) > 0) OR (
      textlen(trim(a.street_addr4,3)) > 0)) )) )
       loc_street_addr1 = tab
       IF (textlen(trim(a.street_addr,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr,3
           )),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr2,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr2,
           3)),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr3,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr3,
           3)),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr4,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr4,
           3)),brk,tab,tab)
       ENDIF
      ELSEIF (textlen(trim(a.street_addr,3)) > 0)
       loc_street_addr1 = concat(tab,formatspecialcharacters(ehtml,trim(a.street_addr,3)),sspace)
      ENDIF
      loc_city_state_zip = retrieveformattedcitystatezip(a.city,a.state,a.state_cd,a.zipcode),
      loc_final_addr_str = concat(loc_street_addr1,loc_city_state_zip,brk),
      CALL echo(build2("address: ",replace(loc_final_addr_str,sspace," "))),
      CALL echo(build2("person_id: ",build(rscheduleappt->list[d1.seq].person_id))),
      CALL echo(build2("service_resource_cd: ",build(rscheduleappt->list[d1.seq].service_resource_cd)
       )), rscheduleappt->list[d1.seq].loc_final_addr_str = loc_final_addr_str
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = size(rscheduleappt->list,5)),
      address a
     PLAN (d1)
      JOIN (a
      WHERE (a.parent_entity_id=rscheduleappt->list[d1.seq].person_id)
       AND a.parent_entity_name="PERSON"
       AND a.parent_entity_id != 0.0
       AND a.address_type_cd=bus_add
       AND a.active_ind=1
       AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY d1.seq, a.address_type_seq
     HEAD d1.seq
      loc_city_state_zip = sspace, loc_street_addr1 = sspace, loc_final_addr_str = sspace
      IF (((textlen(trim(a.street_addr2,3)) > 0) OR (((textlen(trim(a.street_addr3,3)) > 0) OR (
      textlen(trim(a.street_addr4,3)) > 0)) )) )
       loc_street_addr1 = tab
       IF (textlen(trim(a.street_addr,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr,3
           )),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr2,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr2,
           3)),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr3,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr3,
           3)),brk,tab,tab)
       ENDIF
       IF (textlen(trim(a.street_addr4,3)) > 0)
        loc_street_addr1 = concat(loc_street_addr1,formatspecialcharacters(ehtml,trim(a.street_addr4,
           3)),brk,tab,tab)
       ENDIF
      ELSEIF (textlen(trim(a.street_addr,3)) > 0)
       loc_street_addr1 = concat(tab,formatspecialcharacters(ehtml,trim(a.street_addr,3)),sspace)
      ENDIF
      loc_city_state_zip = retrieveformattedcitystatezip(a.city,a.state,a.state_cd,a.zipcode),
      loc_final_addr_str = concat(loc_street_addr1,loc_city_state_zip,brk)
      IF ((rscheduleappt->list[d1.seq].person_id != 0.0))
       rscheduleappt->list[d1.seq].loc_final_addr_str = loc_final_addr_str
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("GetPersonnelAddress -> ",build2(cnvtint((curtime3 - getpersonneladdress))),"0 ms"
     ))
 END ;Subroutine
 SUBROUTINE getpersonnelphone(null)
   DECLARE getpersonnelphone = f8 WITH private, noconstant(curtime3)
   SELECT
    IF (napptlocpref=1)
     WHERE expand(nidx,1,napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].appt_location_cd)
      AND ph.parent_entity_name="LOCATION"
      AND ph.parent_entity_id != 0.0
      AND ph.phone_type_cd IN (work_phone, fax_phone)
      AND ph.active_ind=1
      AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ELSE
     WHERE expand(nidx,1,napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].person_id)
      AND ph.parent_entity_name="PERSON"
      AND ph.parent_entity_id != 0.0
      AND ph.phone_type_cd IN (work_phone, fax_phone)
      AND ph.active_ind=1
      AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ENDIF
    INTO "nl:"
    FROM phone ph
    ORDER BY ph.parent_entity_id
    HEAD ph.parent_entity_id
     loc_phone = concat(loc_ph_title,nof_def), loc_fax = concat(loc_fax_title,nof_def),
     loc_final_phone_str = concat(tab,loc_phone,tab,loc_fax,brk)
    DETAIL
     CASE (ph.phone_type_cd)
      OF work_phone:
       loc_phone = concat(loc_ph_title,trim(formatspecialcharacters(ehtml,trim(cnvtphone(ph.phone_num,
            ph.phone_format_cd,2),3)),3))
      OF fax_phone:
       loc_fax = concat(loc_fax_title,trim(formatspecialcharacters(ehtml,trim(cnvtphone(ph.phone_num,
            ph.phone_format_cd,2),3)),3))
     ENDCASE
     loc_final_phone_str = concat(tab,loc_phone,tab,loc_fax,brk)
    FOOT  ph.parent_entity_id
     IF (napptlocpref=1)
      lvindex = locateval(nidx,1,napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].
       appt_location_cd)
     ELSE
      lvindex = locateval(nidx,1,napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].person_id)
     ENDIF
     WHILE (lvindex > 0)
      IF ((rscheduleappt->list[lvindex].person_id != 0.0))
       rscheduleappt->list[lvindex].loc_final_phone_str = loc_final_phone_str
      ENDIF
      ,
      IF (napptlocpref=1)
       lvindex = locateval(nidx,(lvindex+ 1),napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].
        appt_location_cd)
      ELSE
       lvindex = locateval(nidx,(lvindex+ 1),napptcnt,ph.parent_entity_id,rscheduleappt->list[nidx].
        person_id)
      ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   CALL echo(build("GetPersonnelPhone -> ",build2(cnvtint((curtime3 - getpersonnelphone))),"0 ms"))
 END ;Subroutine
 SUBROUTINE getserviceresourcedata(null)
   DECLARE getserviceresourcedata = f8 WITH private, noconstant(curtime3)
   SELECT INTO "nl:"
    FROM service_resource sr,
     phone ph
    PLAN (sr
     WHERE expand(nidx,1,napptcnt,sr.service_resource_cd,rscheduleappt->list[nidx].
      service_resource_cd)
      AND sr.service_resource_cd != 0.0)
     JOIN (ph
     WHERE ph.parent_entity_id=sr.organization_id
      AND ph.parent_entity_name="ORGANIZATION"
      AND ph.parent_entity_id != 0.0
      AND ph.phone_type_cd IN (work_phone, fax_phone)
      AND ph.active_ind=1
      AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ph.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY sr.service_resource_cd
    HEAD sr.service_resource_cd
     loc_phone = concat(loc_ph_title,nof_def), loc_fax = concat(loc_fax_title,nof_def),
     loc_final_phone_str = concat(tab,loc_phone,tab,loc_fax,brk)
    DETAIL
     CALL echo(build2("service_resource: ",uar_get_code_display(sr.service_resource_cd)))
     CASE (ph.phone_type_cd)
      OF work_phone:
       loc_phone = concat(loc_ph_title,trim(formatspecialcharacters(ehtml,trim(cnvtphone(ph.phone_num,
            ph.phone_format_cd,2),3)),3))
      OF fax_phone:
       loc_fax = concat(loc_fax_title,trim(formatspecialcharacters(ehtml,trim(cnvtphone(ph.phone_num,
            ph.phone_format_cd,2),3)),3))
     ENDCASE
     loc_final_phone_str = concat(tab,loc_phone,tab,loc_fax,brk)
    FOOT  sr.service_resource_cd
     lvindex = locateval(nidx,1,napptcnt,sr.service_resource_cd,rscheduleappt->list[nidx].
      service_resource_cd)
     WHILE (lvindex > 0)
      rscheduleappt->list[lvindex].loc_final_phone_str = loc_final_phone_str,lvindex = locateval(nidx,
       (lvindex+ 1),napptcnt,sr.service_resource_cd,rscheduleappt->list[nidx].service_resource_cd)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL echo(build("GetServiceResourceData -> ",build2(cnvtint((curtime3 - getserviceresourcedata))),
     "0 ms"))
 END ;Subroutine
 FREE RECORD rscheduleappt
 RECORD rscheduleappt(
   1 list[*]
     2 sch_appt_id = f8
     2 appt_type_cd = f8
     2 appt_location_cd = f8
     2 appt_resource_cd = f8
     2 appt_security_ind = i2
     2 sec_validated_ind = i2
     2 appt_loc_val = vc
     2 loc_final_addr_str = vc
     2 loc_final_phone_str = vc
     2 appt_dt_val = vc
     2 sched_prov_val = vc
     2 person_id = f8
     2 service_resource_cd = f8
 )
 DECLARE future_appt_val = vc
 DECLARE final_future_appt_html = vc
 DECLARE appt_dt_val = vc
 DECLARE sched_prov_val = vc
 DECLARE appt_loc_val = vc
 DECLARE smanualtimeformat = vc
 DECLARE napptqualcount = i4 WITH noconstant(0)
 DECLARE napptcnt = i4 WITH noconstant(0)
 DECLARE igranted = i2 WITH noconstant(0)
 DECLARE lvindex = i4 WITH noconstant(0)
 DECLARE nidx = i4 WITH noconstant(0)
 DECLARE dschsecurityid = f8 WITH noconstant(0.0)
 DECLARE dviewactioncd = f8 WITH constant(uar_get_code_by("MEANING",16166,"VIEW"))
 DECLARE dappttypecd = f8 WITH constant(uar_get_code_by("MEANING",16165,"APPTTYPE"))
 DECLARE dlocationtypecd = f8 WITH constant(uar_get_code_by("MEANING",16165,"LOCATION"))
 DECLARE dresourcetypecd = f8 WITH constant(uar_get_code_by("MEANING",16165,"RESOURCE"))
 CALL loadpreferences(0)
 SELECT INTO "nl:"
  FROM sch_appt a,
   sch_appt a2,
   (left JOIN sch_event e ON e.sch_event_id=a2.sch_event_id
    AND ((e.version_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))),
   (left JOIN sch_location loc ON loc.schedule_id=a2.schedule_id
    AND loc.location_type_cd > 0.0
    AND loc.version_dt_tm=cnvtdatetime("31-DEC-2100")),
   (left JOIN sch_event_disp sed ON sed.sch_event_id=a2.sch_event_id
    AND sed.parent_table="SCH_EVENT_ATTACH")
  PLAN (a
   WHERE a.person_id=dpersonid
    AND a.beg_dt_tm > cnvtdatetime(curdate,000000)
    AND trim(a.role_meaning,3)="PATIENT"
    AND trim(a.state_meaning,3) IN ("SCHEDULED", "HOLD", "CONFIRMED")
    AND ((a.version_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
   JOIN (a2
   WHERE a2.sch_event_id=a.sch_event_id
    AND ((a2.resource_cd > 0.0) OR (a2.person_id > 0.0))
    AND trim(a2.role_meaning,3) != "PATIENT"
    AND trim(a2.state_meaning,3) IN ("SCHEDULED", "HOLD", "CONFIRMED")
    AND ((a2.version_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
   JOIN (e)
   JOIN (loc)
   JOIN (sed)
  ORDER BY cnvtdatetime(a.beg_dt_tm)
  DETAIL
   smanualtimeformat = cnvtupper(format(a.beg_dt_tm,"@TIMENOSECONDS;;s"))
   IF (substring(1,1,smanualtimeformat)="0")
    smanualtimeformat = substring(2,textlen(smanualtimeformat),smanualtimeformat)
   ENDIF
   appt_dt_val = concat(tab,appt_dt_title,format(a.beg_dt_tm,"@SHORTDATE4YR"),space,smanualtimeformat,
    brk)
   IF (textlen(formatspecialcharacters(ehtml,trim(loc.location_freetext,3))) != 0)
    appt_loc_val = concat(tab,bold,formatspecialcharacters(ehtml,trim(loc.location_freetext,3)),ebold,
     brk)
   ELSE
    appt_loc_val = concat(tab,appt_loc_title,nof_def,brk)
   ENDIF
   loc_final_phone_str = concat(tab,loc_phone,tab,loc_fax,brk), loc_final_addr_str = sspace
   IF (a2.resource_cd != 0.0)
    sched_prov_val = concat(sched_prov_title,trim(uar_get_code_display(a2.resource_cd),3),brk)
   ELSE
    sched_prov_val = concat(sched_prov_title,nof_def,brk)
   ENDIF
  FOOT  a.sch_appt_id
   IF (mod(napptcnt,10)=0)
    stat = alterlist(rscheduleappt->list,(napptcnt+ 10))
   ENDIF
   napptcnt += 1, rscheduleappt->list[napptcnt].sch_appt_id = a.sch_appt_id, rscheduleappt->list[
   napptcnt].appt_type_cd = e.appt_type_cd,
   rscheduleappt->list[napptcnt].appt_location_cd = loc.location_cd, rscheduleappt->list[napptcnt].
   appt_resource_cd = a2.resource_cd, rscheduleappt->list[napptcnt].sec_validated_ind = 0,
   rscheduleappt->list[napptcnt].appt_security_ind = 0, rscheduleappt->list[napptcnt].appt_loc_val =
   appt_loc_val, rscheduleappt->list[napptcnt].loc_final_addr_str = loc_final_addr_str,
   rscheduleappt->list[napptcnt].loc_final_phone_str = loc_final_phone_str, rscheduleappt->list[
   napptcnt].appt_dt_val = appt_dt_val, rscheduleappt->list[napptcnt].sched_prov_val = sched_prov_val,
   rscheduleappt->list[napptcnt].person_id = a2.person_id, rscheduleappt->list[napptcnt].
   service_resource_cd = a2.service_resource_cd, igranted = uar_sch_security_insert_ex2(reqinfo->
    updt_id,dappttypecd,e.appt_type_cd,dviewactioncd,0.0,
    dschsecurityid,reqinfo->position_cd)
   IF (igranted != 1
    AND dschsecurityid != 0.0)
    rscheduleappt->list[napptcnt].appt_security_ind = 1
   ENDIF
   IF (igranted=0
    AND dschsecurityid=0.0)
    rscheduleappt->list[napptcnt].sec_validated_ind = 1
   ENDIF
   igranted = uar_sch_security_insert_ex2(reqinfo->updt_id,dlocationtypecd,loc.location_cd,
    dviewactioncd,0.0,
    dschsecurityid,reqinfo->position_cd)
   IF (igranted != 1
    AND dschsecurityid != 0.0)
    rscheduleappt->list[napptcnt].appt_security_ind = 1
   ENDIF
   IF (igranted=0
    AND dschsecurityid=0.0)
    rscheduleappt->list[napptcnt].sec_validated_ind = 1
   ENDIF
   igranted = uar_sch_security_insert_ex2(reqinfo->updt_id,dresourcetypecd,a2.resource_cd,
    dviewactioncd,0.0,
    dschsecurityid,reqinfo->position_cd)
   IF (igranted != 1
    AND dschsecurityid != 0.0)
    rscheduleappt->list[napptcnt].appt_security_ind = 1
   ENDIF
   IF (igranted=0
    AND dschsecurityid=0.0)
    rscheduleappt->list[napptcnt].sec_validated_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(rscheduleappt->list,napptcnt), igranted = uar_sch_security_perform()
   FOR (nidx = 1 TO napptcnt)
     IF ((rscheduleappt->list[nidx].sec_validated_ind=1))
      rscheduleappt->list[nidx].sec_validated_ind = 0, igranted = uar_sch_check_security_ex2(reqinfo
       ->updt_id,dappttypecd,rscheduleappt->list[nidx].appt_type_cd,dviewactioncd,0.0,
       dschsecurityid,reqinfo->position_cd)
      IF (igranted != 1)
       rscheduleappt->list[nidx].appt_security_ind = 1
      ENDIF
      igranted = uar_sch_check_security_ex2(reqinfo->updt_id,dlocationtypecd,rscheduleappt->list[nidx
       ].appt_location_cd,dviewactioncd,0.0,
       dschsecurityid,reqinfo->position_cd)
      IF (igranted != 1)
       rscheduleappt->list[nidx].appt_security_ind = 1
      ENDIF
      igranted = uar_sch_check_security_ex2(reqinfo->updt_id,dresourcetypecd,rscheduleappt->list[nidx
       ].appt_resource_cd,dviewactioncd,0.0,
       dschsecurityid,reqinfo->position_cd)
      IF (igranted != 1)
       rscheduleappt->list[nidx].appt_security_ind = 1
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 CALL getpersonneladdress(null)
 CALL getpersonnelphone(null)
 CALL getserviceresourcedata(null)
 FOR (nidx = 1 TO napptcnt)
   IF ((rscheduleappt->list[nidx].appt_security_ind=0))
    SET napptqualcount += 1
    SET appt_loc_val = rscheduleappt->list[nidx].appt_loc_val
    SET loc_final_addr_str = rscheduleappt->list[nidx].loc_final_addr_str
    SET loc_final_phone_str = rscheduleappt->list[nidx].loc_final_phone_str
    SET appt_dt_val = rscheduleappt->list[nidx].appt_dt_val
    SET sched_prov_val = rscheduleappt->list[nidx].sched_prov_val
    IF (napptqualcount=1)
     SET future_appt_val = concat(appt_loc_val,tab,loc_final_addr_str,tab,loc_final_phone_str,
      tab,appt_dt_val,tab,space,space,
      sched_prov_val)
    ELSE
     SET future_appt_val = concat(future_appt_val,brk,appt_loc_val,tab,loc_final_addr_str,
      tab,loc_final_phone_str,tab,appt_dt_val,tab,
      space,space,sched_prov_val)
    ENDIF
   ENDIF
 ENDFOR
 IF (napptqualcount > 0)
  SET future_appt_str = substring(1,(textlen(future_appt_val) - 6),future_appt_val)
 ENDIF
 SET future_appt_str = concat(bodybegin,future_appt_str,bodyend)
 SET final_future_appt_html = concat(htmlbegin,ftrappt_header,brk,future_appt_str,htmlend)
 SET reply->text = final_future_appt_html
 SET reply->format = 1
 CALL echorecord(rscheduleappt)
 FREE RECORD rscheduleappt
END GO
