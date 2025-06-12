CREATE PROGRAM clinical_rpt_witness_report1:dba
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
 SET c_omf_profile_save = "OMF_TIME_ZONE_HEADER.INC 000"
 DECLARE v_utc_on_ind = i2 WITH noconstant(0)
 FREE SET tz
 RECORD tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 )
 SET v_utc_on_ind = 0
 IF (validate(curutc,999)=999)
  SET v_utc_on_ind = 0
 ELSE
  IF (curutc)
   SET v_utc_on_ind = 1
   DECLARE v_time_zone = vc
   DECLARE c_tmzn_cd = f8
   DECLARE code_set = f8
   DECLARE code_value = f8
   DECLARE cdf_meaning = c12
   SET code_value = 0
   SET cdf_meaning = fillstring(12," ")
   SET code_set = 13003
   SET cdf_meaning = "TIME ZONE"
   EXECUTE cpm_get_cd_for_cdf
   SET c_tmzn_cd = code_value
   DECLARE uar_datesettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateSetTimeZone"
   DECLARE uar_dategettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateGetTimeZone"
   DECLARE uar_dategetsystemtimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
   "libdate.a(libdate.o)", uar = "DateGetSystemTimeZone"
  ENDIF
 ENDIF
 IF (v_utc_on_ind=1)
  CALL echo("... OMF_TIME_ZONE_HEADER: UTC is turned ON.")
 ELSE
  CALL echo("... OMF_TIME_ZONE_HEADER: UTC is turned OFF or not present.")
 ENDIF
 IF ( NOT (validate(patient,0)))
  RECORD patient(
    1 name = vc
    1 birth_dt_tm = dq8
    1 sex = vc
    1 attending_md_cnt = i4
    1 attending_md_list[*]
      2 attending_md = vc
    1 location = vc
    1 admit_dt_tm = dq8
    1 fin_nbr = vc
    1 mrn = vc
  )
 ENDIF
 RECORD req(
   1 output_device = vc
   1 script_name = vc
   1 scope_flag = i4
   1 person_id = f8
   1 encntr_list[*]
     2 encntr_id = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 param_list[4]
     2 param_name = vc
     2 param_value = vc
 )
 RECORD rep(
   1 qual[*]
     2 item_name = vc
     2 event_id = f8
     2 result_value = vc
     2 event_class_cd = f8
     2 result_status_cd = f8
     2 date_time = dq8
     2 perfomed_by = vc
     2 perfomed_date_time = dq8
     2 valid_from_dt_tm = dq8
     2 updt_cnt = i4
     2 witnesses[*]
       3 witnessed_by = vc
       3 witnessed_date_time = dq8
     2 witness_cnt = i4
     2 versions[*]
       3 result = vc
       3 event_class_cd = f8
       3 result_status_cd = f8
       3 date_time = dq8
       3 perfomed_by = vc
       3 perfomed_date_time = dq8
       3 valid_from_dt_tm = dq8
       3 updt_cnt = i4
       3 witnesses[*]
         4 witnessed_by = vc
         4 witnessed_date_time = dq8
       3 witness_cnt = i4
     2 dynamic_label_ind = i2
     2 version_cnt = i4
   1 cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(captions,0)))
  RECORD captions(
    1 report_head = vc
    1 date_range = vc
    1 pat_name = vc
    1 dob = vc
    1 sex = vc
    1 attend_md = vc
    1 loc = vc
    1 admit_dt = vc
    1 fin_nbr = vc
    1 mrn = vc
    1 no_data = vc
    1 page_num = vc
    1 end_of_rpt = vc
    1 item_name = vc
    1 results = vc
    1 end_dt = vc
    1 res_details = vc
    1 date = vc
    1 dynamic_labels = vc
    1 performed_by = vc
    1 witnessed_by = vc
    1 modified_by = vc
    1 at = vc
    1 encntr_rpt = vc
    1 person_rpt = vc
    1 tz_label = vc
  )
 ENDIF
 SET modify = predeclare
 DECLARE mrnperson = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE finnbr = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mrnencntr = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE attenddoc = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE business = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE inerror = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE med = f8 WITH public, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE date = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DATE"))
 DECLARE ivparent = f8 WITH public, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE witness = f8 WITH public, constant(uar_get_code_by("MEANING",21,"WITNESS"))
 DECLARE modify = f8 WITH public, constant(uar_get_code_by("MEANING",21,"MODIFY"))
 DECLARE dta_date = f8 WITH public, constant(uar_get_code_by("MEANING",289,"6"))
 DECLARE dta_time = f8 WITH public, constant(uar_get_code_by("MEANING",289,"10"))
 DECLARE dta_date_time = f8 WITH public, constant(uar_get_code_by("MEANING",289,"11"))
 DECLARE dta_date_time_timezone = f8 WITH public, constant(uar_get_code_by("MEANING",289,"19"))
 DECLARE powerchart = i2 WITH public, constant(1)
 DECLARE clinicalreporting = i2 WITH public, constant(2)
 DECLARE person = i2 WITH public, constant(1)
 DECLARE encounter = i2 WITH public, constant(2)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE cnt1 = i4 WITH protect, noconstant(0)
 DECLARE item_no = i4 WITH protect, noconstant(1)
 DECLARE version_index = i4 WITH protect, noconstant(0)
 DECLARE rpt_call_flag = i2 WITH protect, noconstant(powerchart)
 DECLARE rpt_type_flag = i2 WITH protect, noconstant(person)
 DECLARE max_item_width = i2 WITH protect, noconstant(35)
 DECLARE max_result_width = i2 WITH protect, noconstant(40)
 DECLARE half_line = i2 WITH protect, constant(6)
 DECLARE mid_line = i2 WITH protect, constant(9)
 DECLARE 1_line = i2 WITH protect, constant(12)
 DECLARE 1_5_line = i2 WITH protect, constant(18)
 DECLARE 2_line = i2 WITH protect, constant(24)
 DECLARE col_gap = i2 WITH protect, constant(20)
 DECLARE x_left = i2 WITH public, constant(40)
 DECLARE x_right = i2 WITH public, noconstant(0)
 DECLARE y_top = i2 WITH public, constant(15)
 DECLARE y_bottom = i2 WITH public, constant(700)
 DECLARE y_page = i2 WITH public, constant(750)
 DECLARE x_page = i2 WITH public, constant(250)
 DECLARE x_date = i2 WITH public, constant(310)
 DECLARE item_x_pos = i2 WITH public, noconstant(40)
 DECLARE item_width = i2 WITH public, constant(120)
 DECLARE result_x_pos = i2 WITH public, noconstant(0)
 DECLARE result_width = i2 WITH public, constant(130)
 DECLARE enddt_x_pos = i2 WITH public, noconstant(0)
 DECLARE enddt_width = i2 WITH public, constant(60)
 DECLARE details_x_pos = i2 WITH public, noconstant(0)
 DECLARE details_width = i2 WITH public, constant(130)
 DECLARE cur_row_y = i2 WITH public, noconstant(0)
 DECLARE cur_pos_y = i2 WITH public, noconstant(0)
 DECLARE cur_max_y = i2 WITH public, noconstant(0)
 DECLARE max_field_width = i2 WITH public, constant(38)
 DECLARE display_x = i2 WITH public, noconstant(0)
 DECLARE display_y = i2 WITH public, noconstant(0)
 SET result_x_pos = ((item_x_pos+ item_width)+ (2 * col_gap))
 SET enddt_x_pos = ((result_x_pos+ result_width)+ col_gap)
 SET details_x_pos = ((enddt_x_pos+ enddt_width)+ col_gap)
 SET x_right = (details_x_pos+ details_width)
 SET cur_row_y = y_top
 DECLARE item_name_box = vc WITH protect, noconstant(" ")
 DECLARE dynamic_label_data_exists = i2 WITH protect, noconstant(0)
 DECLARE event_set_data_exists = i2 WITH protect, noconstant(0)
 DECLARE printing_eventset_data = i2 WITH protect, noconstant(0)
 DECLARE printing_label_data = i2 WITH protect, noconstant(0)
 DECLARE label_heading_printed = i2 WITH protect, noconstant(0)
 DECLARE display_bold = i2 WITH protect, noconstant(0)
 DECLARE name = vc WITH noconstant(fillstring(50," "))
 DECLARE mrn = vc WITH noconstant(fillstring(50," "))
 DECLARE fnbr = vc WITH noconstant(fillstring(50,"*"))
 DECLARE dob = vc WITH noconstant(fillstring(50," "))
 DECLARE age = vc WITH noconstant(fillstring(50," "))
 DECLARE sex = vc WITH noconstant(fillstring(50," "))
 DECLARE admit_date = vc WITH noconstant(fillstring(50," "))
 DECLARE unit = vc WITH noconstant(fillstring(50," "))
 DECLARE room = vc WITH noconstant(fillstring(50," "))
 DECLARE bed = vc WITH noconstant(fillstring(50," "))
 DECLARE location = vc WITH noconstant(fillstring(50," "))
 DECLARE disp_str = vc WITH noconstant(fillstring(255," "))
 DECLARE disp_field = vc WITH noconstant(fillstring(40," "))
 DECLARE tz_string = vc WITH noconstant(fillstring(3," "))
 IF (v_utc_on_ind=1)
  SET tz_string = concat(" ",trim(datetimezoneformat(cnvtdatetime(curdate,curtime),curtimezoneapp,
     "ZZZ")))
 ELSE
  SET tz_string = ""
 ENDIF
 DECLARE org_head = vc WITH protect, noconstant(" ")
 DECLARE org_addr = vc WITH protect, noconstant(" ")
 DECLARE org_addr2 = vc WITH protect, noconstant(" ")
 DECLARE org_city = vc WITH protect, noconstant(" ")
 DECLARE item_name = vc WITH protect, noconstant(" ")
 DECLARE report_header = vc WITH protect, noconstant("WITNESS REPORT")
 DECLARE end_of_report = vc WITH protect, noconstant("** END OF REPORT **")
 DECLARE no_data = vc WITH protect, noconstant("No information available for selected date range.")
 IF (size(req->encntr_list)=0)
  SET rpt_type_flag = person
 ELSE
  SET rpt_type_flag = encounter
 ENDIF
 IF (validate(bglobaldebugflag)=0)
  DECLARE bglobaldebugflag = i2 WITH noconstant(0)
 ENDIF
 IF (validate(stat)=0)
  DECLARE stat = i2 WITH noconstant(0)
 ENDIF
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET bglobaldebugflag = 1
  ENDIF
 ENDIF
 DECLARE expand_id = i4 WITH public, noconstant(0)
 DECLARE no_of_encntrs = i4 WITH public, noconstant(0)
 DECLARE retrieve_witnessed_clinicalevents(null) = null WITH public
 DECLARE retrieve_organizationinformation(null) = null WITH public
 DECLARE retrieve_witnessed_labels(null) = null WITH public
 DECLARE retrieve_beginenddttm(null) = null WITH public
 DECLARE retrieve_personinformation(null) = null WITH public
 DECLARE build_witness_report(null) = null WITH public
 DECLARE retrieve_reportparams(null) = null WITH public
 DECLARE retrieve_date_values(null) = null WITH public
 DECLARE adjust_prsnl(null) = null WITH public
 DECLARE checkfororgsecurity(null) = null WITH public
 IF (bglobaldebugflag=1)
  CALL echo("Initializing i18n localization")
  CALL echo(build("curprog:",curprog))
  CALL echo(build("curcclrev:",curcclrev))
 ENDIF
 DECLARE lhandlei18n = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(lhandlei18n,curprog,"",curcclrev)
 SET captions->report_head = uar_i18ngetmessage(lhandlei18n,"report_head","WITNESS REPORT")
 SET captions->no_data = uar_i18ngetmessage(lhandlei18n,"no_data",
  "No information available for selected date range.")
 SET captions->pat_name = uar_i18ngetmessage(lhandlei18n,"pat_name","Patient Name:")
 SET captions->dob = uar_i18ngetmessage(lhandlei18n,"dob","Date of Birth:")
 SET captions->sex = uar_i18ngetmessage(lhandlei18n,"sex","Sex:")
 SET captions->attend_md = uar_i18ngetmessage(lhandlei18n,"attend_md","Attending MD:")
 SET captions->loc = uar_i18ngetmessage(lhandlei18n,"loc","Location:")
 SET captions->admit_dt = uar_i18ngetmessage(lhandlei18n,"admit_dt","Admit Date:")
 SET captions->fin_nbr = uar_i18ngetmessage(lhandlei18n,"fin_nbr","Financial Number:")
 SET captions->mrn = uar_i18ngetmessage(lhandlei18n,"mrn","Medical Record Number:")
 SET captions->page_num = uar_i18ngetmessage(lhandlei18n,"page_num","Page ")
 SET captions->end_of_rpt = uar_i18ngetmessage(lhandlei18n,"end_of_rpt","** END OF REPORT **")
 SET captions->dynamic_labels = uar_i18ngetmessage(lhandlei18n,"dynamic_labels","Dynamic Labels")
 SET captions->item_name = uar_i18ngetmessage(lhandlei18n,"item_name","Item")
 SET captions->results = uar_i18ngetmessage(lhandlei18n,"results","Result(s)")
 SET captions->end_dt = uar_i18ngetmessage(lhandlei18n,"end_dt","End Date/Time")
 SET captions->res_details = uar_i18ngetmessage(lhandlei18n,"res_details","Result Detail(s)")
 SET captions->date = uar_i18ngetmessage(lhandlei18n,"date","Date/Time")
 SET captions->performed_by = uar_i18ngetmessage(lhandlei18n,"performed_by","Performed By:")
 SET captions->witnessed_by = uar_i18ngetmessage(lhandlei18n,"witnessed_by","Witnessed By:")
 SET captions->modified_by = uar_i18ngetmessage(lhandlei18n,"modified_by","Modified By:")
 SET captions->at = uar_i18ngetmessage(lhandlei18n,"at","at")
 SET captions->encntr_rpt = uar_i18ngetmessage(lhandlei18n,"encntr_rpt",
  "This encounter specific report displays witness information for the selected encounter.")
 SET captions->person_rpt = uar_i18ngetmessage(lhandlei18n,"person_rpt",
  "This person specific report may display witness information across multiple, active encounters.")
 SET captions->tz_label = uar_i18nbuildmessage(lhandlei18n,"tz_label",
  "** All times are based on %1 time **","s",nullterm(trim(datetimezoneformat(cnvtdatetime(curdate,
      curtime),curtimezoneapp,"ZZZ"))))
 SET req->output_device = build("cer_print:WITNESS_CR",trim(cnvtstring(request->chart_request_id,40,0
    ),3),".ps")
 SET req->script_name = "clinical_rpt_witness_report1"
 SET req->scope_flag = request->scope_flag
 SET req->person_id = request->person_id
 SET req->encntr_id = request->encntr_id
 SET req->beg_dt_tm = cnvtdatetime(request->start_dt_tm)
 SET req->end_dt_tm = cnvtdatetime(request->end_dt_tm)
 IF (retrieve_reportparams(null)=false)
  GO TO exit_report_builder
 ENDIF
 CALL retrieve_beginenddttm(null)
 SUBROUTINE checkfororgsecurity(null)
   DECLARE chidx = i2 WITH noconstant(0)
   EXECUTE dcp_gen_valid_encounters_recs
   SET gve_request->prsnl_id = reqinfo->updt_id
   SET gve_request->force_encntrs_ind = 0
   SET stat = alterlist(gve_request->persons,1)
   SET gve_request->persons[1].person_id = req->person_id
   EXECUTE dcp_get_valid_encounters  WITH replace("REQUEST",gve_request), replace("REPLY",gve_reply)
   IF ((gve_reply->status_data.status="F"))
    CALL echo("*Failed - dcp_get_valid_encounters in DCP_GET_FORMS_ACTIVITY_PRT*")
    SET failure_ind = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieve_date_values(null)
   FOR (cnt = 1 TO rep->cnt)
     IF ((rep->qual[cnt].event_class_cd=date))
      SELECT INTO "nl:"
       ced.date_type_flag, ced.result_dt_tm, ced.updt_dt_tm,
       ced.valid_until_dt_tm, ce.updt_dt_tm, ce.valid_until_dt_tm,
       ce.event_id, ced.event_id
       FROM clinical_event ce,
        ce_date_result ced,
        discrete_task_assay dta
       PLAN (ce
        WHERE (ce.event_id=rep->qual[cnt].event_id))
        JOIN (ced
        WHERE ce.event_id=ced.event_id
         AND (ced.updt_cnt=rep->qual[cnt].updt_cnt))
        JOIN (dta
        WHERE dta.task_assay_cd=ce.task_assay_cd)
       ORDER BY ce.clinical_event_id DESC
       HEAD ce.clinical_event_id
        IF ((rep->qual[cnt].result_status_cd != inerror))
         IF (dta.default_result_type_cd=dta_date)
          rep->qual[cnt].result_value = format(ced.result_dt_tm,"MM/DD/YYYY;;D")
         ELSEIF (dta.default_result_type_cd=dta_time)
          rep->qual[cnt].result_value = format(ced.result_dt_tm,"HH:MM;;D")
         ELSEIF (dta.default_result_type_cd=dta_date_time)
          rep->qual[cnt].result_value = format(ced.result_dt_tm,"MM/DD/YYYY HH:MM;;D")
         ELSEIF (dta.default_result_type_cd=dta_date_time_timezone)
          IF (v_utc_on_ind)
           date_temp = cnvtdatetimeutc(ced.result_dt_tm,1), date_temp = cnvtdatetimeutc(cnvtdatetime(
             date_temp),2,abs(ced.result_tz)), date_str = format(cnvtdatetime(date_temp),
            "MM/DD/YYYY HH:MM;;D"),
           tz_str = trim(datetimezoneformat(cnvtdatetime(ced.result_dt_tm),abs(ced.result_tz),"ZZZ")),
           rep->qual[cnt].result_value = concat(date_str," ",tz_str)
          ELSE
           rep->qual[cnt].result_value = format(ced.result_dt_tm,"MM/DD/YYYY HH:MM;;D")
          ENDIF
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      IF ((rep->qual[cnt].version_cnt > 0))
       FOR (ver_no = 1 TO rep->qual[cnt].version_cnt)
         IF ((rep->qual[cnt].versions[ver_no].event_class_cd=date)
          AND (rep->qual[cnt].versions[ver_no].result_status_cd != inerror))
          SELECT INTO "nl:"
           ced.date_type_flag, ced.result_dt_tm, ced.updt_dt_tm,
           ced.valid_until_dt_tm, ce.updt_dt_tm, ce.valid_until_dt_tm,
           ce.event_id, ced.event_id
           FROM clinical_event ce,
            ce_date_result ced
           PLAN (ce
            WHERE (ce.event_id=rep->qual[cnt].event_id))
            JOIN (ced
            WHERE ce.event_id=ced.event_id
             AND (ced.updt_cnt=rep->qual[cnt].versions[ver_no].updt_cnt))
           ORDER BY ce.clinical_event_id DESC
           HEAD ce.clinical_event_id
            IF (dta.default_result_type_cd=dta_date)
             rep->qual[cnt].versions[ver_no].result = format(ced.result_dt_tm,"MM/DD/YYYY;;D")
            ELSEIF (dta.default_result_type_cd=dta_time)
             rep->qual[cnt].versions[ver_no].result = format(ced.result_dt_tm,"HH:MM;;D")
            ELSEIF (dta.default_result_type_cd=dta_date_time)
             rep->qual[cnt].versions[ver_no].result = format(ced.result_dt_tm,"MM/DD/YYYY HH:MM;;D")
            ELSEIF (dta.default_result_type_cd=dta_date_time_timezone)
             IF (v_utc_on_ind)
              date_temp = cnvtdatetimeutc(ced.result_dt_tm,1), date_temp = cnvtdatetimeutc(
               cnvtdatetime(date_temp),2,abs(ced.result_tz)), date_str = format(cnvtdatetime(
                date_temp),"MM/DD/YYYY HH:MM;;D"),
              tz_str = trim(datetimezoneformat(cnvtdatetime(ced.result_dt_tm),abs(ced.result_tz),
                "ZZZ")), rep->qual[cnt].versions[ver_no].result = concat(date_str," ",tz_str)
             ELSE
              rep->qual[cnt].versions[ver_no].result = format(ced.result_dt_tm,"MM/DD/YYYY HH:MM;;D")
             ENDIF
            ENDIF
           WITH nocounter
          ;end select
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE adjust_prsnl(null)
   FOR (cnt = 1 TO rep->cnt)
     IF ((rep->qual[cnt].version_cnt > 0))
      SELECT INTO "nl:"
       cep.event_id, p.person_id
       FROM ce_event_prsnl cep,
        person p
       PLAN (cep
        WHERE (cep.event_id=rep->qual[cnt].event_id)
         AND cep.action_type_cd=modify
         AND cep.valid_from_dt_tm=cnvtdatetime(rep->qual[cnt].valid_from_dt_tm))
        JOIN (p
        WHERE p.person_id=cep.action_prsnl_id)
       DETAIL
        rep->qual[cnt].perfomed_by = p.name_full_formatted
       WITH format
      ;end select
      FOR (ver_cnt = 1 TO rep->qual[cnt].version_cnt)
        SELECT INTO "nl:"
         cep.event_id, p.person_id
         FROM ce_event_prsnl cep,
          person p
         PLAN (cep
          WHERE (cep.event_id=rep->qual[cnt].event_id)
           AND cep.action_type_cd=modify
           AND cep.valid_from_dt_tm=cnvtdatetime(rep->qual[cnt].versions[ver_cnt].valid_from_dt_tm))
          JOIN (p
          WHERE p.person_id=cep.action_prsnl_id)
         DETAIL
          rep->qual[cnt].versions[ver_cnt].perfomed_by = p.name_full_formatted
         WITH format
        ;end select
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE retrieve_witnessed_clinicalevents(null)
  SELECT
   IF (rpt_type_flag=person
    AND (gve_reply->restrict_ind=1))
    PLAN (c
     WHERE expand(expand_id,1,size(gve_reply->persons[1].encntrs,5),c.encntr_id,gve_reply->persons[1]
      .encntrs[expand_id].encntr_id)
      AND c.event_end_dt_tm >= cnvtdatetime(req->beg_dt_tm)
      AND c.event_end_dt_tm <= cnvtdatetime(req->end_dt_tm)
      AND c.event_class_cd != med
      AND c.event_cd != ivparent
      AND c.view_level > 0
      AND c.publish_flag=1)
     JOIN (cep
     WHERE cep.event_id=c.event_id
      AND ((cep.action_type_cd=witness) OR (c.result_status_cd=inerror))
      AND cep.valid_from_dt_tm=c.valid_from_dt_tm)
     JOIN (vec
     WHERE vec.event_cd=c.event_cd)
     JOIN (dl
     WHERE dl.ce_dynamic_label_id=c.ce_dynamic_label_id)
     JOIN (p1
     WHERE p1.person_id=c.performed_prsnl_id)
     JOIN (p2
     WHERE p2.person_id=cep.action_prsnl_id)
   ELSEIF (rpt_type_flag=person)
    PLAN (c
     WHERE (c.person_id=req->person_id)
      AND c.event_end_dt_tm >= cnvtdatetime(req->beg_dt_tm)
      AND c.event_end_dt_tm <= cnvtdatetime(req->end_dt_tm)
      AND c.event_class_cd != med
      AND c.event_cd != ivparent
      AND c.view_level > 0
      AND c.publish_flag=1)
     JOIN (cep
     WHERE cep.event_id=c.event_id
      AND ((cep.action_type_cd=witness) OR (c.result_status_cd=inerror))
      AND cep.valid_from_dt_tm=c.valid_from_dt_tm)
     JOIN (vec
     WHERE vec.event_cd=c.event_cd)
     JOIN (dl
     WHERE dl.ce_dynamic_label_id=c.ce_dynamic_label_id)
     JOIN (p1
     WHERE p1.person_id=c.performed_prsnl_id)
     JOIN (p2
     WHERE p2.person_id=cep.action_prsnl_id)
   ELSE
    PLAN (c
     WHERE expand(expand_id,1,size(req->encntr_list,5),c.encntr_id,req->encntr_list[expand_id].
      encntr_id)
      AND c.event_end_dt_tm >= cnvtdatetime(req->beg_dt_tm)
      AND c.event_end_dt_tm <= cnvtdatetime(req->end_dt_tm)
      AND c.event_class_cd != med
      AND c.event_cd != ivparent
      AND c.view_level > 0
      AND c.publish_flag=1)
     JOIN (cep
     WHERE cep.event_id=c.event_id
      AND ((cep.action_type_cd=witness) OR (c.result_status_cd=inerror))
      AND cep.valid_from_dt_tm=c.valid_from_dt_tm)
     JOIN (vec
     WHERE vec.event_cd=c.event_cd)
     JOIN (dl
     WHERE dl.ce_dynamic_label_id=c.ce_dynamic_label_id)
     JOIN (p1
     WHERE p1.person_id=c.performed_prsnl_id)
     JOIN (p2
     WHERE p2.person_id=cep.action_prsnl_id)
   ENDIF
   INTO "nl:"
   c.clinical_event_id, c.event_id, c.event_cd,
   c.event_tag, c.person_id, c.event_end_dt_tm,
   c.valid_until_dt_tm, c.performed_prsnl_id, c.performed_dt_tm,
   c.ce_dynamic_label_id, c.event_class_cd, cep.event_prsnl_id,
   cep.person_id, ce_action_type_disp = uar_get_code_display(cep.action_type_cd), cep.action_type_cd,
   vec.event_cd_disp, vec.event_set_name
   FROM clinical_event c,
    ce_event_prsnl cep,
    v500_event_code vec,
    ce_dynamic_label dl,
    prsnl p1,
    prsnl p2
   ORDER BY c.event_id DESC, cnvtdatetime(c.valid_until_dt_tm) DESC, c.clinical_event_id DESC,
    cnvtdatetime(c.event_end_dt_tm) DESC, vec.event_cd_disp
   HEAD REPORT
    CALL echo("stat = alterlist inside events"), index = 0, cnt = 0,
    beventidfound = 0
   HEAD c.event_id
    current_ec_disp = trim(vec.event_cd_disp,3)
   DETAIL
    event_set_data_exists = 1
    IF (locateval(expand_id,1,rep->cnt,c.event_id,rep->qual[expand_id].event_id) > 0)
     beventidfound = 1
    ENDIF
    IF (((c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")) OR (beventidfound=0)) )
     add_new_item = 1, version_index = 0
    ELSE
     add_new_item = 0
    ENDIF
    beventidfound = 0, index = (index+ 1), rep->cnt = index
    IF (mod(index,10)=1)
     stat = alterlist(rep->qual,(index+ 9))
    ENDIF
    IF (index > 0
     AND add_new_item=1)
     IF (c.ce_dynamic_label_id=0)
      rep->qual[index].item_name = trim(current_ec_disp,3)
     ELSE
      rep->qual[index].item_name = concat(trim(current_ec_disp,3)," <",trim(dl.label_name,3),">")
     ENDIF
     rep->qual[index].event_id = c.event_id, rep->qual[index].updt_cnt = c.updt_cnt, rep->qual[index]
     .event_class_cd = c.event_class_cd,
     rep->qual[index].result_status_cd = c.result_status_cd
     IF (c.result_status_cd != inerror)
      rep->qual[index].result_value = c.result_val
     ELSE
      rep->qual[index].result_value = uar_get_code_display(c.result_status_cd)
     ENDIF
     rep->qual[index].date_time = c.event_end_dt_tm, rep->qual[index].valid_from_dt_tm = c
     .valid_from_dt_tm, rep->qual[index].perfomed_by = p1.name_full_formatted
     IF (c.updt_cnt=1)
      rep->qual[index].perfomed_date_time = c.performed_dt_tm
     ELSE
      rep->qual[index].perfomed_date_time = c.updt_dt_tm
     ENDIF
     IF (c.result_status_cd != inerror)
      stat = alterlist(rep->qual[index].witnesses,1), rep->qual[index].witnesses[1].witnessed_by = p2
      .name_full_formatted, rep->qual[index].witnesses[1].witnessed_date_time = cep.action_dt_tm,
      rep->qual[index].witness_cnt = 1
     ENDIF
     rep->qual[index].dynamic_label_ind = 0
    ENDIF
    IF (index > 0
     AND add_new_item=0)
     index = (index - 1), rep->cnt = index, rep->qual[index].version_cnt = (rep->qual[index].
     version_cnt+ 1),
     version_index = rep->qual[index].version_cnt, stat = alterlist(rep->qual[index].versions,
      version_index)
     IF (c.result_status_cd != inerror)
      rep->qual[index].versions[version_index].result = c.result_val
     ELSE
      rep->qual[index].result_value = uar_get_code_display(c.result_status_cd)
     ENDIF
     rep->qual[index].versions[version_index].event_class_cd = c.event_class_cd, rep->qual[index].
     versions[version_index].valid_from_dt_tm = c.valid_from_dt_tm, rep->qual[index].versions[
     version_index].result_status_cd = c.result_status_cd,
     rep->qual[index].versions[version_index].date_time = c.event_end_dt_tm, rep->qual[index].
     versions[version_index].perfomed_by = p1.name_full_formatted, rep->qual[index].versions[
     version_index].updt_cnt = c.updt_cnt
     IF (c.updt_cnt=1)
      rep->qual[index].versions[version_index].perfomed_date_time = c.performed_dt_tm
     ELSE
      rep->qual[index].versions[version_index].perfomed_date_time = c.updt_dt_tm
     ENDIF
     IF (c.result_status_cd != inerror)
      stat = alterlist(rep->qual[index].versions[version_index].witnesses,1), rep->qual[index].
      versions[version_index].witnesses[1].witnessed_by = p2.name_full_formatted, rep->qual[index].
      versions[version_index].witnesses[1].witnessed_date_time = cep.action_dt_tm,
      rep->qual[index].versions[version_index].witness_cnt = 1
     ENDIF
    ENDIF
   FOOT REPORT
    CALL echo("Foot Report - Retrieve Witnessed Clinical Evens")
   WITH nocounter
  ;end select
  CALL adjust_prsnl(null)
 END ;Subroutine
 SUBROUTINE retrieve_witnessed_labels(null)
  IF (rpt_type_flag=encounter)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.encntr_id=req->encntr_list[1].encntr_id)
    HEAD e.encntr_id
     req->person_id = e.person_id
    WITH nocounter
   ;end select
  ENDIF
  SELECT
   IF ((gve_reply->restrict_ind=1))
    PLAN (dl
     WHERE (dl.person_id=req->person_id)
      AND dl.create_dt_tm >= cnvtdatetime(req->beg_dt_tm)
      AND dl.create_dt_tm <= cnvtdatetime(req->end_dt_tm)
      AND dl.label_status_cd != inerror
      AND dl.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (dlt
     WHERE dlt.label_template_id=dl.label_template_id)
     JOIN (dsr
     WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
     JOIN (rsl
     WHERE rsl.result_set_id=dl.result_set_id)
     JOIN (ce
     WHERE ce.event_id=rsl.event_id
      AND expand(expand_id,1,size(gve_reply->persons[1].encntrs,5),ce.encntr_id,gve_reply->persons[1]
      .encntrs[expand_id].encntr_id))
     JOIN (cep
     WHERE cep.event_id=ce.event_id
      AND cep.action_type_cd=witness)
     JOIN (p1
     WHERE p1.person_id=dl.label_prsnl_id)
     JOIN (p2
     WHERE p2.person_id=cep.action_prsnl_id)
   ELSE
    PLAN (dl
     WHERE (dl.person_id=req->person_id)
      AND dl.create_dt_tm >= cnvtdatetime(req->beg_dt_tm)
      AND dl.create_dt_tm <= cnvtdatetime(req->end_dt_tm)
      AND dl.label_status_cd != inerror
      AND dl.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (dlt
     WHERE dlt.label_template_id=dl.label_template_id)
     JOIN (dsr
     WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
     JOIN (rsl
     WHERE rsl.result_set_id=dl.result_set_id)
     JOIN (ce
     WHERE ce.event_id=rsl.event_id)
     JOIN (cep
     WHERE cep.event_id=ce.event_id
      AND cep.action_type_cd=witness)
     JOIN (p1
     WHERE p1.person_id=dl.label_prsnl_id)
     JOIN (p2
     WHERE p2.person_id=cep.action_prsnl_id)
   ENDIF
   INTO "nl:"
   dl.dynamic_label_id
   FROM ce_dynamic_label dl,
    ce_result_set_link rsl,
    dynamic_label_template dlt,
    doc_set_ref dsr,
    clinical_event ce,
    ce_event_prsnl cep,
    prsnl p1,
    prsnl p2
   ORDER BY cnvtdatetime(dl.create_dt_tm) DESC, dsr.doc_set_name, dl.ce_dynamic_label_id
   HEAD REPORT
    cnt1 = 0, cnt2 = 0, data_exists = false,
    prev_label_id = 0.0, new_label = 1
   HEAD dsr.doc_set_name
    current_ec_disp = trim(dsr.doc_set_name,3)
   HEAD dl.ce_dynamic_label_id
    cur_label_id = dl.ce_dynamic_label_id
    IF (prev_label_id=cur_label_id)
     new_label = 0
    ELSE
     new_label = 1
    ENDIF
    IF (new_label=1)
     rep->cnt = (rep->cnt+ 1), index = rep->cnt
     IF (mod(index,10)=1)
      stat = alterlist(rep->qual,(index+ 9))
     ENDIF
    ENDIF
   DETAIL
    dynamic_label_data_exists = 1
    IF (new_label=1)
     rep->qual[index].item_name = current_ec_disp, rep->qual[index].result_value = dl.label_name, rep
     ->qual[index].date_time = dl.create_dt_tm,
     rep->qual[index].perfomed_by = p1.name_full_formatted, rep->qual[index].perfomed_date_time = cep
     .action_dt_tm, rep->qual[index].dynamic_label_ind = 1,
     stat = alterlist(rep->qual[index].witnesses,1), rep->qual[index].witnesses[1].witnessed_by = p2
     .name_full_formatted, rep->qual[index].witnesses[1].witnessed_date_time = cep.action_dt_tm,
     rep->qual[index].witness_cnt = 1
    ELSE
     bwitnessfound = 0, winesscnt = 0
     FOR (winesscnt = 1 TO rep->qual[index].witness_cnt)
       IF ((rep->qual[index].witnesses[winesscnt].witnessed_by=p2.name_full_formatted))
        bwitnessfound = 1
       ENDIF
     ENDFOR
     IF (bwitnessfound=0)
      rep->qual[index].witness_cnt = (rep->qual[index].witness_cnt+ 1), index_ver = rep->qual[index].
      witness_cnt, stat = alterlist(rep->qual[index].witnesses,index_ver),
      rep->qual[index].witnesses[index_ver].witnessed_by = p2.name_full_formatted, rep->qual[index].
      witnesses[index_ver].witnessed_date_time = cep.action_dt_tm
     ENDIF
    ENDIF
    prev_label_id = dl.ce_dynamic_label_id, new_label = 0
   FOOT REPORT
    stat = alterlist(rep->qual,rep->cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE retrieve_reportparams(null)
   IF ((req->scope_flag > 0))
    SET rpt_call_flag = clinicalreporting
   ENDIF
   IF (rpt_call_flag=powerchart)
    IF ((req->person_id > 0.0))
     SET rpt_type_flag = person
    ELSEIF (size(req->encntr_list,5) > 0)
     SET rpt_type_flag = encounter
    ELSE
     IF (bglobaldebugflag)
      CALL echo("POWERCHART - NO VALID PERSON ID OR ENCOUNTER ID")
     ENDIF
     SET rep->status_data.subeventstatus[1].operationname = req->script_name
     SET rep->status_data.subeventstatus[1].operationstatus = "F"
     SET rep->status_data.subeventstatus[1].targetobjectvalue = "THE ENCOUNTER ID IS NOT VALID"
     RETURN(false)
    ENDIF
   ELSE
    IF ((((req->scope_flag=1)) OR ((((req->scope_flag=2)) OR ((req->scope_flag=16))) )) )
     IF (size(req->encntr_list,5) > 0)
      SET rpt_type_flag = encounter
     ELSE
      SET rpt_type_flag = person
     ENDIF
    ELSE
     IF (bglobaldebugflag)
      CALL echo("THE SCOPE FLAG IS NOT VALID")
     ENDIF
     SET rep->status_data.subeventstatus[1].operationname = req->script_name
     SET rep->status_data.subeventstatus[1].operationstatus = "F"
     SET rep->status_data.subeventstatus[1].targetobjectvalue = "THE SCOPE FLAG IS NOT VALID"
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE retrieve_beginenddttm(null)
   DECLARE cnt1 = i2 WITH protect, noconstant(0)
   DECLARE beg_ind = i2 WITH protect, noconstant(false)
   DECLARE end_ind = i2 WITH protect, noconstant(false)
   DECLARE str1 = vc WITH protect, noconstant(fillstring(25," "))
   DECLARE str2 = vc WITH protect, noconstant("  ")
   DECLARE str3 = vc WITH protect, noconstant("   ")
   DECLARE str4 = c20 WITH protect, noconstant("  -   -       :  :  ")
   SET req->beg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET req->end_dt_tm = cnvtdatetime(curdate,curtime3)
   IF (rpt_call_flag=powerchart)
    FOR (cnt1 = 1 TO size(req->param_list,5))
      IF ((req->param_list[cnt1].param_name="BEG_DT_TM")
       AND beg_ind=false)
       SET beg_ind = true
       SET str1 = trim(req->param_list[cnt1].param_value)
       SET stat = movestring(str1,7,str4,1,2)
       SET str2 = substring(5,2,str1)
       CASE (str2)
        OF "01":
         SET str3 = "JAN"
        OF "02":
         SET str3 = "FEB"
        OF "03":
         SET str3 = "MAR"
        OF "04":
         SET str3 = "APR"
        OF "05":
         SET str3 = "MAY"
        OF "06":
         SET str3 = "JUN"
        OF "07":
         SET str3 = "JUL"
        OF "08":
         SET str3 = "AUG"
        OF "09":
         SET str3 = "SEP"
        OF "10":
         SET str3 = "OCT"
        OF "11":
         SET str3 = "NOV"
        OF "12":
         SET str3 = "DEC"
       ENDCASE
       SET stat = movestring(str3,1,str4,4,3)
       SET stat = movestring(str1,1,str4,8,4)
       SET stat = movestring(str1,9,str4,13,2)
       SET stat = movestring(str1,11,str4,16,2)
       SET stat = movestring(str1,13,str4,19,2)
       SET req->beg_dt_tm = cnvtdatetime(str4)
      ELSEIF ((req->param_list[cnt1].param_name="END_DT_TM")
       AND end_ind=false)
       SET end_ind = true
       SET str1 = trim(req->param_list[cnt1].param_value)
       SET stat = movestring(str1,7,str4,1,2)
       SET str2 = substring(5,2,str1)
       CASE (str2)
        OF "01":
         SET str3 = "JAN"
        OF "02":
         SET str3 = "FEB"
        OF "03":
         SET str3 = "MAR"
        OF "04":
         SET str3 = "APR"
        OF "05":
         SET str3 = "MAY"
        OF "06":
         SET str3 = "JUN"
        OF "07":
         SET str3 = "JUL"
        OF "08":
         SET str3 = "AUG"
        OF "09":
         SET str3 = "SEP"
        OF "10":
         SET str3 = "OCT"
        OF "11":
         SET str3 = "NOV"
        OF "12":
         SET str3 = "DEC"
       ENDCASE
       SET stat = movestring(str3,1,str4,4,3)
       SET stat = movestring(str1,1,str4,8,4)
       SET stat = movestring(str1,9,str4,13,2)
       SET stat = movestring(str1,11,str4,16,2)
       SET stat = movestring(str1,13,str4,19,2)
       SET req->end_dt_tm = cnvtdatetime(str4)
      ENDIF
    ENDFOR
   ELSE
    SET req->beg_dt_tm = cnvtdatetime(request->start_dt_tm)
    SET req->end_dt_tm = cnvtdatetime(request->end_dt_tm)
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieve_personinformation(null)
   DECLARE unit = vc WITH protect, noconstant(" ")
   DECLARE room = vc WITH protect, noconstant(" ")
   DECLARE bed = vc WITH protect, noconstant(" ")
   IF (rpt_type_flag=person)
    SELECT INTO "nl:"
     p.name_full_formatted, p.birth_dt_tm, p.sex_cd,
     pa_check = decode(pa.seq,"EXISTS","DOES NOT EXIST")
     FROM person p,
      person_alias pa
     PLAN (p
      WHERE (p.person_id=req->person_id))
      JOIN (pa
      WHERE pa.person_id=p.person_id
       AND pa.person_alias_type_cd=mrnperson
       AND pa.active_ind=1)
     DETAIL
      patient->name = substring(1,22,p.name_full_formatted), patient->birth_dt_tm = p.birth_dt_tm,
      patient->sex = substring(1,10,uar_get_code_display(p.sex_cd))
      IF (pa_check="EXISTS")
       IF ((patient->mrn <= " "))
        patient->mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     p.name_full_formatted, p.birth_dt_tm, p.sex_cd,
     pl.name_full_formatted, e.reg_dt_tm, e.loc_bed_cd,
     e.loc_room_cd, pa_check = decode(pa.seq,"EXISTS","DOES NOT EXIST"), epr_check = decode(epr.seq,
      "EXISTS","DOES NOT EXIST"),
     ea_check = decode(ea.seq,"EXISTS","DOES NOT EXIST")
     FROM person p,
      encounter e,
      person_alias pa,
      encntr_prsnl_reltn epr,
      prsnl pl,
      encntr_alias ea,
      (dummyt d1  WITH seq = 1),
      (dummyt d2  WITH seq = 1),
      (dummyt d3  WITH seq = 1)
     PLAN (e
      WHERE (e.encntr_id=req->encntr_list[1].encntr_id))
      JOIN (p
      WHERE p.person_id=e.person_id)
      JOIN (d1)
      JOIN (((pa
      WHERE pa.person_id=p.person_id
       AND pa.person_alias_type_cd=mrnperson
       AND pa.active_ind=1)
      ) ORJOIN ((d2)
      JOIN (((epr
      WHERE epr.encntr_id=e.encntr_id
       AND epr.encntr_prsnl_r_cd=attenddoc
       AND epr.active_ind=1
       AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
      JOIN (pl
      WHERE pl.person_id=epr.prsnl_person_id)
      ) ORJOIN ((d3)
      JOIN (ea
      WHERE ea.encntr_id=e.encntr_id
       AND ea.encntr_alias_type_cd IN (finnbr, mrnencntr)
       AND ea.active_ind=1
       AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      )) ))
     DETAIL
      patient->name = substring(1,22,p.name_full_formatted), patient->birth_dt_tm = p.birth_dt_tm,
      patient->sex = substring(1,10,uar_get_code_display(p.sex_cd)),
      patient->admit_dt_tm = e.reg_dt_tm, unit = substring(1,10,uar_get_code_display(e
        .loc_nurse_unit_cd)), room = substring(1,10,uar_get_code_display(e.loc_room_cd)),
      bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), patient->location = trim(concat(trim(
         unit,3)," ",trim(room,3)),3), patient->location = trim(concat(patient->location," ",bed),3)
      IF (pa_check="EXISTS")
       IF ((patient->mrn <= " "))
        patient->mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
       ENDIF
      ENDIF
      IF (ea_check="EXISTS")
       IF (ea.encntr_alias_type_cd=finnbr)
        patient->fin_nbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd)), fnbr = cnvtalias(ea
         .alias,ea.alias_pool_cd)
       ENDIF
       IF (ea.encntr_alias_type_cd=mrnencntr)
        patient->mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
       ENDIF
      ENDIF
     WITH outerjoin = d1, nocounter
    ;end select
   ENDIF
   IF (rpt_type_flag=encounter)
    SELECT INTO "nl:"
     FROM encntr_prsnl_reltn epr,
      prsnl pl
     PLAN (epr
      WHERE expand(expand_id,1,size(req->encntr_list,5),epr.encntr_id,req->encntr_list[expand_id].
       encntr_id)
       AND epr.encntr_prsnl_r_cd=attenddoc
       AND epr.active_ind=1
       AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
      JOIN (pl
      WHERE pl.person_id=epr.prsnl_person_id)
     HEAD REPORT
      patient->attending_md_cnt = 0
     DETAIL
      patient->attending_md_cnt = (patient->attending_md_cnt+ 1), stat = alterlist(patient->
       attending_md_list,patient->attending_md_cnt), patient->attending_md_list[patient->
      attending_md_cnt].attending_md = pl.name_full_formatted
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("THE PATIENT'S INFORMATION")
   CALL echorecord(patient)
   CALL echo("THE PATIENT'S INFORMATION ENDS")
 END ;Subroutine
 SUBROUTINE retrieve_organizationinformation(null)
   DECLARE add_line = vc WITH protect, noconstant(" ")
   SELECT INTO req->output_device
    o.org_name, a.street_addr, a.street_addr2,
    a.city, a.state, state = uar_get_code_display(a.state_cd),
    a.zipcode, type = uar_get_code_display(a.address_type_cd)
    FROM encounter e,
     organization o,
     address a
    PLAN (e
     WHERE (e.encntr_id=req->encntr_list[1].encntr_id))
     JOIN (o
     WHERE o.organization_id=e.organization_id)
     JOIN (a
     WHERE a.parent_entity_id=outerjoin(o.organization_id)
      AND a.active_ind=outerjoin(1)
      AND a.parent_entity_name=outerjoin("ORGANIZATION")
      AND a.address_type_cd=outerjoin(business))
    DETAIL
     org_head = trim(o.org_name), org_addr = trim(a.street_addr), org_addr2 = trim(a.street_addr2)
     IF (a.city > " ")
      add_line = trim(a.city)
     ENDIF
     IF (((a.state > " ") OR (a.state_cd > 0)) )
      IF (add_line > " ")
       IF (a.state_cd > 0)
        add_line = concat(trim(add_line),", ",trim(uar_get_code_display(a.state_cd)))
       ELSE
        add_line = concat(trim(add_line),", ",trim(a.state))
       ENDIF
      ELSE
       IF (a.state_cd > 0)
        add_line = trim(uar_get_code_display(a.state_cd))
       ELSE
        add_line = trim(a.state)
       ENDIF
      ENDIF
     ENDIF
     IF (a.zipcode > " ")
      IF (add_line > " ")
       add_line = concat(trim(add_line)," ",trim(a.zipcode))
      ELSE
       add_line = trim(a.zipcode)
      ENDIF
     ENDIF
     org_city = trim(add_line)
    WITH nocounter
   ;end select
   CALL echo("THE ORGANIZATIONS INFORMATION")
   CALL echo(build("org_head=",org_head))
   CALL echo(build("org_addr=",org_addr))
   CALL echo(build("org_addr2=",org_addr2))
   CALL echo(build("org_city=",org_city))
 END ;Subroutine
 SUBROUTINE build_witness_report(null)
   IF (locateval(expand_id,1,rep->cnt,1,rep->qual[expand_id].dynamic_label_ind) > 0)
    SET dynamic_label_data_exists = 1
   ENDIF
   IF (locateval(expand_id,1,rep->cnt,0,rep->qual[expand_id].dynamic_label_ind) > 0)
    SET event_set_data_exists = 1
   ENDIF
   IF (event_set_data_exists=0
    AND dynamic_label_data_exists=1)
    SET printing_label_data = 1
   ENDIF
   SELECT INTO req->output_device
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     MACRO (size_string)
      len = textlen(disp_str)
      IF (len > 255)
       disp_str = concat(substring(1,252,disp_str),"...")
      ENDIF
     ENDMACRO
     ,
     MACRO (print_field)
      size_string, len = textlen(disp_str), pos = 0
      IF (len > max_field_width)
       WHILE (len > max_field_width)
         pos1 = - (2), pos2 = - (1), start_search_pos = 1
         WHILE (pos1 < pos2
          AND pos1 <= max_field_width
          AND pos2 <= max_field_width)
           pos1 = findstring(" ",disp_str,start_search_pos,0), pos2 = findstring(" ",disp_str,(pos1+
            1),0), start_search_pos = (pos1+ 1)
         ENDWHILE
         disp_field = substring(1,pos1,disp_str), disp_str = substring((pos1+ 1),(len - pos1),
          disp_str), len = textlen(disp_str)
         IF (display_bold=1)
          CALL print(calcpos(display_x,display_y)), "{b}", disp_field,
          row + 1
         ELSE
          CALL print(calcpos(display_x,display_y)), disp_field, row + 1
         ENDIF
         display_y = (display_y+ 1_line), cur_pos_y = display_y
         IF (display_y > y_bottom)
          BREAK
         ENDIF
       ENDWHILE
       IF (display_y > y_bottom)
        BREAK
       ENDIF
      ENDIF
      IF (display_bold=1)
       CALL print(calcpos(display_x,display_y)), "{b}", disp_str,
       row + 1
      ELSE
       CALL print(calcpos(display_x,display_y)), disp_str, row + 1
      ENDIF
      IF (cur_max_y < display_y)
       cur_max_y = display_y
      ENDIF
      display_bold = 0
     ENDMACRO
     , "{f/4}{cpi/8}",
     CALL print(calcpos(200,y_top)), "{b}", captions->report_head,
     row + 1, line = fillstring(120,"_")
    HEAD PAGE
     cur_row_y = (y_top+ 40)
     IF (curpage != 1)
      cur_row_y = y_top
     ENDIF
     "{f/8}{cpi/12}", row + 1
     IF (((rpt_type_flag=person) OR (size(req->encntr_list,5) > 1)) )
      disp_str = concat("{b}",captions->pat_name,"{endb}"," ",patient->name),
      CALL print(calcpos((item_x_pos+ 180),cur_row_y)), disp_str,
      row + 1, cur_row_y = (cur_row_y+ 15), disp_str = concat("{b}",captions->dob,"{endb} "," ",
       format(patient->birth_dt_tm,"MM/DD/YY HH:MM;;D")),
      CALL print(calcpos((item_x_pos+ 180),cur_row_y)), disp_str, row + 1,
      cur_row_y = (cur_row_y+ 15), disp_str = concat("{b}",captions->sex,"{endb}"," ",patient->sex),
      CALL print(calcpos((item_x_pos+ 180),cur_row_y)),
      disp_str, row + 1, cur_row_y = (cur_row_y+ 15),
      disp_str = concat("{b}",captions->mrn,"{endb} "," ",patient->mrn),
      CALL print(calcpos((item_x_pos+ 180),cur_row_y)), disp_str,
      row + 1
     ELSE
      disp_str = concat("{b}",captions->pat_name,"{endb}"," ",patient->name),
      CALL print(calcpos(item_x_pos,cur_row_y)), disp_str,
      row + 1, disp_str = concat("{b}",captions->dob,"{endb}"," ",format(patient->birth_dt_tm,
        "MM/DD/YY HH:MM;;D")),
      CALL print(calcpos(enddt_x_pos,cur_row_y)),
      disp_str, row + 1, cur_row_y = (cur_row_y+ 15),
      disp_str = concat("{b}",captions->mrn,"{endb}"," ",patient->mrn),
      CALL print(calcpos(item_x_pos,cur_row_y)), disp_str,
      row + 1, disp_str = concat("{b}",captions->sex,"{endb}"," ",patient->sex),
      CALL print(calcpos(enddt_x_pos,cur_row_y)),
      disp_str, row + 1, cur_row_y = (cur_row_y+ 15),
      disp_str = concat("{b}",captions->fin_nbr,"{endb}"," ",patient->fin_nbr),
      CALL print(calcpos(item_x_pos,cur_row_y)), disp_str,
      row + 1, disp_str = concat("{b}",captions->admit_dt,"{endb}"," ",format(patient->admit_dt_tm,
        "MM/DD/YY HH:MM;;D")),
      CALL print(calcpos(enddt_x_pos,cur_row_y)),
      disp_str, row + 1, cur_row_y = (cur_row_y+ 15),
      disp_str = concat("{b}",captions->loc,"{endb}"," ",patient->location),
      CALL print(calcpos(enddt_x_pos,cur_row_y)), disp_str,
      row + 1, md_cnt = 1
      IF ((patient->attending_md_cnt=0))
       disp_str = concat("{b}",captions->attend_md,"{endb}"),
       CALL print(calcpos(item_x_pos,cur_row_y)), disp_str,
       row + 1
      ELSE
       WHILE ((md_cnt <= patient->attending_md_cnt))
        IF (md_cnt=1)
         disp_str = concat("{b}",captions->attend_md,"{endb}"," ",patient->attending_md_list[md_cnt].
          attending_md),
         CALL print(calcpos(item_x_pos,cur_row_y)), disp_str,
         row + 1
        ELSE
         cur_row_y = (cur_row_y+ 15), disp_str = patient->attending_md_list[md_cnt].attending_md,
         CALL print(calcpos((item_x_pos+ 70),cur_row_y)),
         disp_str, row + 1
        ENDIF
        ,md_cnt = (md_cnt+ 1)
       ENDWHILE
      ENDIF
     ENDIF
     cur_row_y = ((cur_row_y+ 1_line)+ half_line), "{f/4}{cpi/14}", disp_str = "",
     CALL print(calcpos(item_x_pos,cur_row_y)), "{b}", captions->date_range,
     "{endb}", row + 1
     IF (v_utc_on_ind=1)
      cur_row_y = (cur_row_y+ 1_line),
      CALL print(calcpos(item_x_pos,cur_row_y)), "{b}",
      captions->tz_label, "{endb}", row + 1
     ENDIF
     cur_row_y = (cur_row_y+ (2 * 1_line))
     IF ((rep->cnt=0))
      "{f/4}{cpi/10}",
      CALL print(calcpos(item_x_pos,cur_row_y)), line,
      row + 1, cur_row_y = (cur_row_y+ (2 * 1_line)),
      CALL print(calcpos((item_x_pos+ (7 * col_gap)),cur_row_y)),
      captions->no_data, row + 1
     ELSE
      IF (printing_label_data=1)
       IF (label_heading_printed=0)
        "{f/4}{cpi/10}",
        CALL print(calcpos(item_x_pos,cur_row_y)), "{b}",
        captions->dynamic_labels, row + 1, cur_row_y = (cur_row_y+ (2 * 1_line)),
        label_heading_printed = 1, "{f/4}{cpi/14}", row + 1
       ENDIF
       CALL print(calcpos(item_x_pos,cur_row_y)), "{b}", captions->item_name,
       "{endb}", row + 1,
       CALL print(calcpos(result_x_pos,cur_row_y)),
       "{b}", captions->results, "{endb}",
       row + 1,
       CALL print(calcpos(enddt_x_pos,cur_row_y)), "{b}",
       captions->date, "{endb}", row + 1,
       CALL print(calcpos(details_x_pos,cur_row_y)), "{b}", captions->res_details,
       "{endb}", row + 1,
       CALL print(calcpos(item_x_pos,(cur_row_y+ half_line))),
       line, row + 1
      ELSEIF (event_set_data_exists=1)
       "{f/4}{cpi/14}", row + 1,
       CALL print(calcpos(item_x_pos,cur_row_y)),
       "{b}", captions->item_name, "{endb}",
       row + 1,
       CALL print(calcpos(result_x_pos,cur_row_y)), "{b}",
       captions->results, "{endb}", row + 1,
       CALL print(calcpos(enddt_x_pos,cur_row_y)), "{b}", captions->end_dt,
       "{endb}", row + 1,
       CALL print(calcpos(details_x_pos,cur_row_y)),
       "{b}", captions->res_details, "{endb}",
       row + 1,
       CALL print(calcpos(item_x_pos,(cur_row_y+ half_line))), line,
       row + 1
      ENDIF
      cur_row_y = (cur_row_y+ half_line), cur_pos_y = cur_row_y, display_y = cur_row_y,
      cur_max_y = display_y, "{f/4}{cpi/14}", row + 1
     ENDIF
    DETAIL
     IF (((event_set_data_exists=1) OR (dynamic_label_data_exists=1)) )
      FOR (xx = 1 TO rep->cnt)
        IF ((rep->qual[xx].dynamic_label_ind=0)
         AND (rep->qual[xx].result_status_cd != inerror))
         cur_row_y = (cur_max_y+ 1_5_line), "{f/4}{cpi/14}", row + 1,
         display_bold = 1, disp_str = rep->qual[xx].item_name, display_x = item_x_pos,
         display_y = cur_row_y, print_field, disp_str = rep->qual[xx].result_value,
         display_x = result_x_pos, display_y = cur_row_y, print_field,
         disp_str = format(rep->qual[xx].date_time,"MM/DD/YY HH:MM;;D"),
         CALL print(calcpos(enddt_x_pos,cur_row_y)), disp_str,
         row + 1, cur_pos_y = cur_row_y
         IF ((rep->qual[xx].updt_cnt=1))
          disp_str = captions->performed_by
         ELSE
          disp_str = captions->modified_by
         ENDIF
         disp_str = concat(disp_str,"  ",rep->qual[xx].perfomed_by), display_x = details_x_pos,
         display_y = cur_pos_y,
         print_field, cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->at," ",format(rep
           ->qual[xx].perfomed_date_time,"MM/DD/YY HH:MM;;D")),
         display_x = details_x_pos, display_y = cur_pos_y, print_field
         IF ((rep->qual[xx].witnesses[1].witnessed_by != ""))
          cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->witnessed_by," ",rep->qual[xx]
           .witnesses[1].witnessed_by), display_x = details_x_pos,
          display_y = cur_pos_y, print_field, cur_pos_y = (cur_pos_y+ 1_line),
          disp_str = concat(captions->at," ",format(rep->qual[xx].witnesses[1].witnessed_date_time,
            "MM/DD/YY HH:MM;;D")), display_x = details_x_pos, display_y = cur_pos_y,
          print_field
         ENDIF
         cur_row_y = (cur_pos_y+ 2_line), item_no = (item_no+ 1)
         IF (((cur_row_y+ (3 * 1_line)) > y_bottom))
          BREAK, row + 1, "{cpi/15}"
         ENDIF
         IF ((rep->qual[xx].version_cnt > 0))
          FOR (ver_no = 1 TO rep->qual[xx].version_cnt)
            cur_row_y = (cur_max_y+ 15), disp_str = rep->qual[xx].versions[ver_no].result, display_x
             = result_x_pos,
            display_y = cur_row_y, print_field, disp_str = format(rep->qual[xx].versions[ver_no].
             date_time,"MM/DD/YY HH:MM;;D"),
            CALL print(calcpos(enddt_x_pos,cur_row_y)), disp_str, row + 1,
            cur_pos_y = cur_row_y
            IF ((rep->qual[xx].versions[ver_no].updt_cnt=1))
             disp_str = captions->performed_by
            ELSE
             disp_str = captions->modified_by
            ENDIF
            disp_str = concat(disp_str," ",rep->qual[xx].versions[ver_no].perfomed_by), display_x =
            details_x_pos, display_y = cur_pos_y,
            print_field, cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->at," ",format(
              rep->qual[xx].versions[ver_no].perfomed_date_time,"MM/DD/YY HH:MM;;D")),
            display_x = details_x_pos, display_y = cur_pos_y, print_field
            IF ((rep->qual[xx].versions[ver_no].witnesses[1].witnessed_by != ""))
             cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->witnessed_by," ",rep->qual[
              xx].versions[ver_no].witnesses[1].witnessed_by), display_x = details_x_pos,
             display_y = cur_pos_y, print_field, cur_pos_y = (cur_pos_y+ 1_line),
             disp_str = concat(captions->at," ",format(rep->qual[xx].versions[ver_no].witnesses[1].
               witnessed_date_time,"MM/DD/YY HH:MM;;D")), display_x = details_x_pos, display_y =
             cur_pos_y,
             print_field
            ENDIF
            cur_row_y = (cur_pos_y+ 2_line), item_no = (item_no+ 1)
            IF (((cur_row_y+ (3 * 1_line)) > y_bottom))
             BREAK, row + 1, "{cpi/15}"
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
      IF (dynamic_label_data_exists=1)
       printing_label_data = 1
      ENDIF
      IF (printing_label_data=1
       AND event_set_data_exists > 0)
       IF (((cur_row_y+ (8 * 1_line)) < y_bottom))
        cur_row_y = (cur_row_y+ (3 * 1_line)), "{f/4}{cpi/10}",
        CALL print(calcpos(item_x_pos,cur_row_y)),
        "{b}", captions->dynamic_labels, row + 1,
        "{f/4}{cpi/14}", row + 1, cur_row_y = (cur_row_y+ 2_line),
        CALL print(calcpos(item_x_pos,cur_row_y)), "{b}", captions->item_name,
        "{endb}", row + 1,
        CALL print(calcpos(result_x_pos,cur_row_y)),
        "{b}", captions->results, "{endb}",
        row + 1,
        CALL print(calcpos(enddt_x_pos,cur_row_y)), "{b}",
        captions->date, "{endb}", row + 1,
        CALL print(calcpos(details_x_pos,cur_row_y)), "{b}", captions->res_details,
        "{endb}", row + 1,
        CALL print(calcpos(item_x_pos,(cur_row_y+ half_line))),
        line, row + 1, cur_row_y = (cur_row_y+ half_line),
        cur_max_y = cur_row_y, label_heading_printed = 1
       ELSE
        BREAK
       ENDIF
      ENDIF
      FOR (xx = 1 TO rep->cnt)
        IF ((rep->qual[xx].dynamic_label_ind=1))
         "{f/4}{cpi/14}", row + 1, cur_row_y = (cur_max_y+ 1_5_line),
         display_bold = 1, disp_str = rep->qual[xx].item_name, display_x = item_x_pos,
         display_y = cur_row_y, print_field, disp_str = rep->qual[xx].result_value,
         display_x = result_x_pos, display_y = cur_row_y, print_field,
         dt_str = format(rep->qual[xx].date_time,"@SHORTDATETIME;C;Q"),
         CALL print(calcpos(enddt_x_pos,cur_row_y)), dt_str,
         row + 1, cur_pos_y = cur_row_y, disp_str = concat(captions->performed_by," ",rep->qual[xx].
          perfomed_by),
         display_x = details_x_pos, display_y = cur_pos_y, print_field,
         cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->at," ",format(rep->qual[xx].
           perfomed_date_time,"@SHORTDATETIME;C;Q")), display_x = details_x_pos,
         display_y = cur_pos_y, print_field, witness_count = 1,
         cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(""," ")
         WHILE ((witness_count <= rep->qual[xx].witness_cnt))
          IF (witness_count=1)
           disp_str = concat(captions->witnessed_by," ",rep->qual[xx].witnesses[witness_count].
            witnessed_by)
          ELSE
           disp_str = concat(disp_str,"; ",rep->qual[xx].witnesses[witness_count].witnessed_by)
          ENDIF
          ,witness_count = (witness_count+ 1)
         ENDWHILE
         display_x = details_x_pos, display_y = cur_pos_y, print_field,
         cur_pos_y = (cur_pos_y+ 1_line), disp_str = concat(captions->at," ",format(rep->qual[xx].
           witnesses[1].witnessed_date_time,"@SHORTDATETIME;C;Q")), display_x = details_x_pos,
         display_y = cur_pos_y, print_field
         IF (cur_max_y > cur_pos_y)
          cur_pos_y = cur_max_y
         ENDIF
         cur_row_y = (cur_pos_y+ 2_line)
         IF (((cur_row_y+ (3 * 1_line)) > y_bottom))
          BREAK, row + 1, "{cpi/15}"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    FOOT PAGE
     IF (rpt_call_flag=powerchart)
      CALL print(calcpos(x_page,y_page)), captions->page_num, curpage"##",
      row + 1,
      CALL print(calcpos(x_date,y_page)), curdate,
      " ", curtime, row + 1
     ENDIF
    FOOT REPORT
     cur_row_y = (cur_row_y+ (3 * 1_line)), "{f/12}{cpi/10}",
     CALL print(calcpos((item_x_pos+ (10 * col_gap)),cur_row_y)),
     "{b}", captions->end_of_rpt, row + 1
    WITH nocounter, dio = postscript, maxcol = 800,
     maxrow = 800, nullreport
   ;end select
   SET modify = nopredeclare
 END ;Subroutine
 SET captions->date_range = uar_i18nbuildmessage(lhandlei18n,"date_range",
  "Witness Report generated for range - %1 to %2","ss",format(cnvtdatetime(req->beg_dt_tm),
   "MM/DD/YYYY HH:MM;;D"),
  format(cnvtdatetime(req->end_dt_tm),"MM/DD/YYYY HH:MM;;D"))
 CALL retrieve_personinformation(null)
 IF (rpt_type_flag=encounter)
  CALL retrieve_organizationinformation(null)
 ENDIF
 CALL echo("stat = beginning ret data")
 CALL retrieve_witnessed_clinicalevents(null)
 CALL retrieve_witnessed_labels(null)
 IF (dynamic_label_data_exists=false
  AND event_set_data_exists=false)
  IF (bglobaldebugflag=1)
   CALL echo("No results found")
  ENDIF
  SET stat = alterlist(rep->qual,0)
  SET rep->status_data.status = "Z"
 ELSE
  SET rep->status_data.status = "S"
 ENDIF
 CALL build_witness_report(null)
 IF (bglobaldebugflag=1)
  CALL echorecord(request)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
#exit_report_builder
END GO
