CREATE PROGRAM bhs_ma_amb_orders_this_visit:dba
 DECLARE ambulatoryreferrals_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,
   "AMBULATORYREFERRALS")), protect
 DECLARE temp_orders_val = vc
 DECLARE mdstafffftextord = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "MDTOSTAFFFREETEXTORDER")), protect
 DECLARE outsidelaborder = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"OUTSIDELABORDER")),
 protect
 RECORD reply(
   1 text = vc
   1 format = i4
 )
 FREE RECORD rdatalist
 RECORD rdatalist(
   1 data[*]
     2 value = f8
 )
 DECLARE formatspecialcharacters(iformattype=i2,sinputdata=vc) = vc
 DECLARE getmedian(param=i2) = f8
 DECLARE getaverage(param=i2) = f8
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
 SUBROUTINE formatspecialcharacters(iformattype,sinputdata)
   DECLARE sformatdata = vc WITH noconstant(sinputdata)
   CALL echo(build("Calling FormatSpecialCharacters with FormatType -> ",iformattype))
   IF (size(sinputdata,1) > 0)
    CASE (iformattype)
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
   CALL echo(build("The Input Data was : ",sinputdata,". This is now formatted to :",sformatdata))
   CALL echo("FormatSpecialCharacters complete")
   RETURN(sformatdata)
 END ;Subroutine
 SUBROUTINE getmedian(param)
   DECLARE ireccount = i4 WITH constant(size(rdatalist->data,5))
   CALL echo(build("Calling GetMedian with iRecCount -> ",ireccount))
   DECLARE dmedian = f8 WITH noconstant(0.0)
   IF (ireccount > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ireccount)
     ORDER BY rdatalist->data[d.seq].value
     FOOT REPORT
      dmedian = median(rdatalist->data[d.seq].value)
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("GetMedian complete with dMedian -> ",dmedian))
   RETURN(dmedian)
 END ;Subroutine
 SUBROUTINE getaverage(param)
   DECLARE ireccount = i4 WITH constant(size(rdatalist->data,5))
   CALL echo(build("Calling GetAverage with iRecCount -> ",ireccount))
   DECLARE daverage = f8 WITH noconstant(0.0)
   IF (ireccount > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ireccount)
     FOOT REPORT
      daverage = avg(rdatalist->data[d.seq].value)
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("GetAverage complete with dAverage -> ",daverage))
   RETURN(daverage)
 END ;Subroutine
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
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
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
 DECLARE active = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE anticipated = f8 WITH constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
 DECLARE not_done = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE completed_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE ordered_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE placeholder_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE em_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"EVALUATIONANDMANAGEMENT")),
 protect
 DECLARE beginspan = vc WITH constant("<span")
 DECLARE beginbodystyle = vc WITH constant("style='font-size:12.0pt;font-family:Arial;'>")
 DECLARE beginheadstyle = vc WITH constant("style='font-size:12.0pt;font-family:Arial;'>")
 DECLARE endstyle = vc WITH constant("</style>")
 DECLARE endspan = vc WITH constant("</span>")
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
 DECLARE htmlbold = vc WITH constant("<b>")
 DECLARE htmlboldend = vc WITH constant("</b>")
 DECLARE htmlspan = vc WITH constant("<span style='font-size:12.0pt;font-family:Arial'>")
 DECLARE htmlspanend = vc WITH constant("</span>")
 DECLARE htmlparagraph = vc WITH constant(
  "<p class=MsoNormal style='TEXT-ALIGN: center' align=center>")
 DECLARE htmlparagraphend = vc WITH constant("</p>")
 DECLARE htmlrow = vc WITH constant("<tr>")
 DECLARE htmlrowend = vc WITH constant("</tr>")
 DECLARE htmlbreak = vc WITH constant("<br>")
 DECLARE hdrbegin = vc WITH constant(concat(beginspan," ",beginheadstyle,bold))
 DECLARE hdrend = vc WITH constant(concat(ebold,endstyle,endspan))
 DECLARE subbegin = vc WITH constant(concat(beginspan," ",beginbodystyle,bold))
 DECLARE subend = vc WITH constant(concat(ebold,endstyle,endspan))
 DECLARE bodybegin = vc WITH constant(concat(beginspan," ",beginbodystyle))
 DECLARE bodyend = vc WITH constant(concat(endstyle,endspan))
 DECLARE i18n_thisvisithdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"this_visit_hdr",
   "Orders Completed this Visit"))
 DECLARE i18n_visithdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"visit_hdr",
   "Visit Information"))
 DECLARE i18n_ftrappthdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ftrappt_hdr",
   "Future Appointments"))
 DECLARE i18n_ftrorderhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ftrorder_hdr",
   "Future Orders"))
 DECLARE i18n_diaghdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"diag_hdr",
   "Diagnoses this Visit"))
 DECLARE i18n_probhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"prob_hdr",
   "Problems and Health Issues"))
 DECLARE i18n_medprobhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"medprob_hdr",
   "Medical Problems"))
 DECLARE i18n_refconshdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"refcons_hdr",
   "Referral and Consult Requests this Visit"))
 DECLARE i18n_patedhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"pated_hdr",
   "Patient Education Materials Provided this Visit"))
 DECLARE i18n_smokestatushdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"smoke_status_hdr",
   "Smoking Status"))
 DECLARE i18n_prochdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"proc_hdr","Procedures"))
 DECLARE i18n_immunhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"immun_hdr","Immunizations"))
 DECLARE i18n_allergyhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allergy_hdr","Allergies"))
 DECLARE i18n_ordershdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"orders_hdr",
   "Orders this Visit"))
 DECLARE i18n_vismedhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vismed_hdr",
   "Medications and Immunizations Administered During This Visit"))
 DECLARE i18n_allrxhx = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allrxhx_hdr",
   "All Known Current Prescriptions and Reported Medications"))
 DECLARE i18n_vismeashdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vs_meas_hdr",
   "Vitals and Measurements this Visit"))
 DECLARE i18n_labradhdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"lab_rad_hdr",
   "Laboratory and Radiology this Visit"))
 DECLARE i18n_lastchartedstr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"last_charted_str",
   "last charted value for your"))
 DECLARE i18n_visitstr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"visit_str","visit"))
 DECLARE i18nsummarytitlehdr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"summary_title_hdr",
   "Visit Summary for "))
 DECLARE i18ntitlethanks = vc WITH constant(uar_i18ngetmessage(i18nhandle,"title_thanks",
"We would like to thank you for allowing us to assist you with your healthcare needs. Our entire staff strives to provide a\
n   excellent experience for our patients and their families. The following includes information regarding your visit.\
"))
 DECLARE i18n_futureappt = vc WITH constant(uar_i18ngetmessage(i18nhandle,"future_appt",
   "No future appointments scheduled"))
 DECLARE i18n_futureorder = vc WITH constant(uar_i18ngetmessage(i18nhandle,"future_order",
   "No future orders"))
 DECLARE i18n_vsmeasure = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vs_meas",
   "No vitals and measurements documented"))
 DECLARE i18n_labrad = vc WITH constant(uar_i18ngetmessage(i18nhandle,"lab_rad",
   "No Laboratory and Radiology documented"))
 DECLARE i18n_allergy = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allergy",
   "No allergies documented"))
 DECLARE i18n_vismed = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vis_med",
   "No new prescriptions for this visit"))
 DECLARE i18n_vismedma = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vis_medma",
   "No medication administered during this visit"))
 DECLARE i18n_allrx = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allrx",
   "No previous prescriptions documented"))
 DECLARE i18n_allhx = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allhx",
   "No reported medications documented"))
 DECLARE i18n_orders = vc WITH constant(uar_i18ngetmessage(i18nhandle,"orders",
   "No visit orders documented"))
 DECLARE i18n_diag = vc WITH constant(uar_i18ngetmessage(i18nhandle,"diag",
   "No visit diagnoses documented"))
 DECLARE i18n_prob = vc WITH constant(uar_i18ngetmessage(i18nhandle,"prob",
   "No Problems/Health issues documented"))
 DECLARE i18n_medprob = vc WITH constant(uar_i18ngetmessage(i18nhandle,"prob",
   "No Medical Problems documented"))
 DECLARE i18n_refcons = vc WITH constant(uar_i18ngetmessage(i18nhandle,"refcons",
   "No Referral or Consults documented"))
 DECLARE i18n_pated = vc WITH constant(uar_i18ngetmessage(i18nhandle,"pated",
   "No patient education material documented"))
 DECLARE i18n_smokestatus = vc WITH constant(uar_i18ngetmessage(i18nhandle,"smoke_status",
   "No smoking status documented"))
 DECLARE i18n_proc = vc WITH constant(uar_i18ngetmessage(i18nhandle,"proc","No Procedures documented"
   ))
 DECLARE i18n_immun = vc WITH constant(uar_i18ngetmessage(i18nhandle,"immun",
   "No Immunizations documented this visit"))
 DECLARE i18n_schedprovtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"sched_prov_title",
   "Scheduled Provider"))
 DECLARE i18n_agetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"age_title","Age"))
 DECLARE i18n_gendertitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"gender_title","Sex"))
 DECLARE i18n_dobtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"dob_title","DOB"))
 DECLARE i18n_mrntitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mrn_title","MRN"))
 DECLARE i18n_addresstitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"address_title","Address"
   ))
 DECLARE i18n_homephtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"home_ph_title","Home"))
 DECLARE i18n_workphtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"work_ph_title","Work"))
 DECLARE i18n_mobilephtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"mobile_ph_title",
   "Mobile"))
 DECLARE i18n_pcptitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"pcp_title",
   "Primary Care Provider"))
 DECLARE i18n_racetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"race_title","Race"))
 DECLARE i18n_ethnicitytitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ethinicity_title",
   "Ethnicity"))
 DECLARE i18n_languagetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"language_title",
   "Language"))
 DECLARE i18n_healthplantitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"hp_title",
   "Health Plan"))
 DECLARE i18n_locphtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"loc_ph_title","Phone"))
 DECLARE i18n_locfaxtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"loc_fax_title","Fax"))
 DECLARE i18n_visdatetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vis_dt_title",
   "Visit Date"))
 DECLARE i18n_refprovtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ref_prov_title",
   "Referring Provider"))
 DECLARE i18n_chief_complttitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"chief_complt_title",
   "Reason For Visit"))
 DECLARE i18n_apptdttitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"appt_dt_title",
   "Appt. Date"))
 DECLARE i18n_apploctitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"appt_loc_title",
   "Location"))
 DECLARE i18n_apptypetitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"appt_type_title","Type")
  )
 DECLARE i18n_appdesctitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"appt_desc_title",
   "Description"))
 DECLARE i18n_vismednrxsubtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "vismed_nrx_subtitle","New Prescriptions this Visit"))
 DECLARE i18n_allrxsubtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allrx_subtitle",
   "Prescriptions"))
 DECLARE i18n_allhxsubtitle = vc WITH constant(uar_i18ngetmessage(i18nhandle,"allhx_subtitle",
   "Home Medications"))
 DECLARE i18n_requestdatestr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"request_dt_str",
   "Requested Date"))
 DECLARE i18n_orderbystr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"order_by_str","Ordered By"
   ))
 DECLARE i18n_refertostr = vc WITH constant(uar_i18ngetmessage(i18nhandle,"refer_to_str",
   "Referred To"))
 DECLARE i18n_referralreasonstr = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "referral_reason_str","Reason for Referral"))
 DECLARE i18n_reqstartdttm = vc WITH constant(uar_i18ngetmessage(i18nhandle,"req_start_dt_tm_str",
   "Requested Start Date\Time"))
 DECLARE i18n_fax = vc WITH constant(uar_i18ngetmessage(i18nhandle,"fax_str","Fax"))
 DECLARE i18n_normalrangebetween = vc WITH constant(uar_i18ngetmessage(i18nhandle,"normal_range_str",
   "Normal range between"))
 DECLARE i18n_and = vc WITH constant(uar_i18ngetmessage(i18nhandle,"and_str","and"))
 DECLARE i18n_for = vc WITH constant(uar_i18ngetmessage(i18nhandle,"for_str","for"))
 DECLARE i18n_instructions = vc WITH constant(uar_i18ngetmessage(i18nhandle,"intructions_str",
   "Instructions"))
 DECLARE i18n_authrefills = vc WITH constant(uar_i18ngetmessage(i18nhandle,"refills_auth_str",
   "refills authorized"))
 DECLARE i18n_sentto = vc WITH constant(uar_i18ngetmessage(i18nhandle,"sent_to_str","Sent to"))
 DECLARE i18n_take = vc WITH constant(uar_i18ngetmessage(i18nhandle,"take_str","Take"))
 DECLARE i18n_deceasedon = vc WITH constant(uar_i18ngetmessage(i18nhandle,"deceased_on_str",
   "Deceased on"))
 DECLARE i18n_deceased = vc WITH constant(uar_i18ngetmessage(i18nhandle,"deceased_str","Deceased"))
 DECLARE i18n_visitvitalsigns = vc WITH constant(uar_i18ngetmessage(i18nhandle,"vital_signs_str",
   "Vital Signs This Visit"))
 DECLARE i18n_visitmeasurements = vc WITH constant(uar_i18ngetmessage(i18nhandle,"measurements_str",
   "Measurements This Visit"))
 DECLARE i18n_bloodpressure = vc WITH constant(uar_i18ngetmessage(i18nhandle,"blood_pressure_str",
   "Blood Pressure"))
 DECLARE i18n_notgiven = vc WITH constant(uar_i18ngetmessage(i18nhandle,"not_given_str","Not Given"))
 DECLARE title_thanks = vc WITH constant(concat(bodybegin,i18ntitlethanks,bodyend))
 DECLARE future_appt_str = vc WITH noconstant(concat(bodybegin,tab,i18n_futureappt,bodyend))
 DECLARE future_order_str = vc WITH noconstant(concat(bodybegin,tab,i18n_futureorder,bodyend))
 DECLARE vs_meas_str = vc WITH noconstant(concat(bodybegin,tab,i18n_vsmeasure,bodyend))
 DECLARE lab_rad_str = vc WITH noconstant(concat(bodybegin,tab,i18n_labrad,bodyend))
 DECLARE allergy_str = vc WITH noconstant(concat(bodybegin,tab,i18n_allergy,bodyend))
 DECLARE vismed_val = vc WITH noconstant(concat(bodybegin,tab,i18n_vismed,bodyend))
 DECLARE vismedma_val = vc WITH noconstant(concat(bodybegin,tab,i18n_vismedma,bodyend))
 DECLARE allrx_val = vc WITH noconstant(concat(bodybegin,tab,i18n_allrx,bodyend))
 DECLARE allhx_val = vc WITH noconstant(concat(bodybegin,tab,i18n_allhx,bodyend))
 DECLARE orders_str = vc WITH noconstant(concat(bodybegin,tab,i18n_orders,bodyend))
 DECLARE diag_str = vc WITH noconstant(concat(bodybegin,tab,i18n_diag,bodyend))
 DECLARE prob_str = vc WITH noconstant(concat(bodybegin,tab,i18n_prob,bodyend))
 DECLARE medprob_str = vc WITH noconstant(concat(bodybegin,tab,i18n_medprob,bodyend))
 DECLARE refcons_str = vc WITH noconstant(concat(bodybegin,tab,i18n_refcons,bodyend))
 DECLARE smoke_status_str = vc WITH noconstant(concat(bodybegin,tab,i18n_smokestatus,bodyend))
 DECLARE proc_str = vc WITH noconstant(concat(bodybegin,tab,i18n_proc,bodyend))
 DECLARE immun_str = vc WITH noconstant(concat(bodybegin,tab,i18n_immun,bodyend))
 DECLARE dnurseloccd = i4 WITH noconstant(0)
 DECLARE encntr_date_val = vc
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_id=dencntrid
  DETAIL
   encntr_date_val = format(e.reg_dt_tm,"@SHORTDATE4YR"), dnurseloccd = e.loc_nurse_unit_cd
  WITH nocounter
 ;end select
 DECLARE this_visit_header = vc WITH constant(concat(hdrbegin,i18n_thisvisithdr,hdrend))
 DECLARE visit_header = vc WITH constant(concat(hdrbegin,i18n_visithdr,hdrend))
 DECLARE ftrappt_header = vc WITH constant(concat(hdrbegin,i18n_ftrappthdr,hdrend))
 DECLARE ftrorder_header = vc WITH constant(concat(hdrbegin,i18n_ftrorderhdr,hdrend))
 DECLARE diag_header = vc WITH constant(concat(hdrbegin,i18n_diaghdr,hdrend))
 DECLARE prob_header = vc WITH constant(concat(hdrbegin,i18n_probhdr,hdrend))
 DECLARE medprob_header = vc WITH constant(concat(hdrbegin,i18n_medprobhdr,hdrend))
 DECLARE refcons_header = vc WITH constant(concat(hdrbegin,i18n_refconshdr,hdrend))
 DECLARE smoke_status_header = vc WITH constant(concat(hdrbegin,i18n_smokestatushdr,hdrend))
 DECLARE proc_header = vc WITH constant(concat(hdrbegin,i18n_prochdr,hdrend))
 DECLARE immun_header = vc WITH constant(concat(hdrbegin,i18n_immunhdr,hdrend))
 DECLARE allergy_header = vc WITH constant(concat(hdrbegin,i18n_allergyhdr,hdrend))
 DECLARE orders_header = vc WITH constant(concat(hdrbegin,i18n_ordershdr,hdrend))
 DECLARE vismed_header = vc WITH constant(concat(hdrbegin,i18n_vismedhdr,hdrend))
 DECLARE allrxhx_header = vc WITH constant(concat(hdrbegin,i18n_allrxhx,hdrend))
 DECLARE visit_reason_header = vc WITH constant(concat(hdrbegin,i18nsummarytitlehdr,hdrend))
 DECLARE vs_meas_header = vc WITH constant(concat(hdrbegin,i18n_vismeashdr,hdrend,bodybegin,sspace,
   "(",i18n_lastchartedstr,sspace,encntr_date_val,sspace,
   i18n_visitstr,")",bodyend))
 DECLARE lab_rad_header = vc WITH constant(concat(hdrbegin,i18n_labradhdr,hdrend,bodybegin,sspace,
   "(",i18n_lastchartedstr,sspace,encntr_date_val,sspace,
   i18n_visitstr,")",bodyend))
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
 DECLARE ref_prov_title = vc WITH constant(concat(bold,i18n_refprovtitle,cspace,ebold))
 DECLARE chief_complt_title = vc WITH constant(concat(bold,i18n_chief_complttitle,cspace,ebold))
 DECLARE appt_dt_title = vc WITH constant(concat(bold,i18n_apptdttitle,cspace,ebold))
 DECLARE appt_loc_title = vc WITH constant(concat(bold,i18n_apploctitle,cspace,ebold))
 DECLARE appt_type_title = vc WITH constant(concat(bold,i18n_apptypetitle,cspace,ebold))
 DECLARE appt_desc_title = vc WITH constant(concat(bold,i18n_appdesctitle,cspace,ebold))
 DECLARE vismed_nrx_subtitle = vc WITH constant(concat(subbegin,i18n_vismednrxsubtitle,subend))
 DECLARE allrx_subtitle = vc WITH constant(concat(subbegin,i18n_allrxsubtitle,subend))
 DECLARE allhx_subtitle = vc WITH constant(concat(subbegin,i18n_allhxsubtitle,subend))
 DECLARE catalog_subtitle = vc
 DECLARE reqdttm_title = vc WITH constant(concat(bold,i18n_requestdatestr,cspace,ebold))
 DECLARE refdttm_title = vc WITH constant(concat(bold,i18n_requestdatestr,cspace,ebold))
 DECLARE refby_title = vc WITH constant(concat(bold,i18n_orderbystr,cspace,ebold))
 DECLARE refto_title = vc WITH constant(concat(bold,i18n_refertostr,cspace,ebold))
 DECLARE refreas_title = vc WITH constant(concat(bold,i18n_referralreasonstr,cspace,ebold))
 DECLARE nof_def = vc WITH constant("--")
 DECLARE loc_fax = vc WITH noconstant(concat(loc_fax_title,nof_def))
 DECLARE loc_phone = vc WITH noconstant(concat(loc_ph_title,nof_def))
 DECLARE orders_val = vc
 DECLARE result_val = vc
 DECLARE vs_meas_val = vc
 DECLARE loc_final_addr_str = vc
 DECLARE loc_final_phone_str = vc
 DECLARE loc_street_addr1 = vc
 DECLARE loc_city_state_zip = vc
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
 SET orders_val = orders_str
 SELECT INTO "nl:"
  order_sort = cnvtupper(o.order_mnemonic)
  FROM orders o
  PLAN (o
   WHERE ((o.encntr_id+ 0)=dencntrid)
    AND o.person_id=dpersonid
    AND o.order_status_cd IN (completed_status_cd, ordered_status_cd)
    AND  NOT (o.catalog_type_cd IN (pharm_cd, em_cd, ambulatoryreferrals_cd))
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(curdate,000000) AND cnvtdatetime(curdate,235959))
  ORDER BY order_sort
  HEAD REPORT
   ocnt = 0, orders_val = ""
  HEAD order_sort
   ocnt = (ocnt+ 1), temp_orders_val = ""
   IF (o.catalog_cd IN (mdstafffftextord, outsidelaborder))
    temp_orders_val = concat(trim(o.order_mnemonic,3),tab,"(",trim(o.clinical_display_line,3),")")
   ELSE
    temp_orders_val = trim(o.order_mnemonic,3)
   ENDIF
   IF (ocnt=1)
    orders_val = concat(htmlspan,tab,temp_orders_val,brk,endstyle,
     htmlspanend)
   ELSE
    orders_val = concat(orders_val,htmlspan,tab,temp_orders_val,brk,
     endstyle,htmlspanend)
   ENDIF
  WITH nocounter
 ;end select
 SET final_orders_html = concat(htmlbegin,this_visit_header,brk,orders_val,htmlend)
 SET reply->text = final_orders_html
 SET reply->format = 1
 CALL echo("002 08/28/13 			rm024902		CCPS-1397 update object name minor mods")
END GO
