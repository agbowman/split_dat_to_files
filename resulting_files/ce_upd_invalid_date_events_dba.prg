CREATE PROGRAM ce_upd_invalid_date_events:dba
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 person_list[*]
     2 person_id = f8
     2 person_name = vc
     2 ce_list[*]
       3 clinical_event_id = f8
       3 event_id = f8
       3 event_seq = i4
       3 encntr_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 clinsig_updt_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 subtable_bitmap = i4
       3 new_valid_from_dt_tm = dq8
       3 new_valid_until_dt_tm = dq8
       3 new_clinsig_updt_dt_tm = dq8
       3 found_proposed_ind = i2
       3 fix_date_ind = i2
     2 cr_rpt_req_list[*]
       3 report_request_id = f8
       3 end_dt_tm = dq8
       3 new_end_dt_tm = dq8
     2 chart_req_list[*]
       3 chart_request_id = f8
       3 end_dt_tm = dq8
       3 new_end_dt_tm = dq8
 )
 FREE RECORD temp_captions
 RECORD temp_captions(
   1 rpttitle = vc
   1 patientname = vc
   1 patientid = vc
   1 clinical = vc
   1 oldvalid = vc
   1 newvalid = vc
   1 oldclinsig = vc
   1 newclinsig = vc
   1 oldupdt = vc
   1 newupdt = vc
   1 oldvalid = vc
   1 newvalid = vc
   1 eventid = vc
   1 fromdate = vc
   1 date = vc
   1 untildate = vc
 )
 FREE RECORD unique_encntrs
 RECORD unique_encntrs(
   1 encntrs[*]
     2 encntr_id = f8
   1 found_person_level = i2
 )
 DECLARE validateinputs() = i2 WITH protect
 DECLARE getpersonlistfromfile() = i2 WITH protect
 DECLARE getoutputfilename() = vc WITH protect
 DECLARE writereportheader() = i2 WITH protect
 DECLARE writechangesreport() = i2 WITH protect
 DECLARE lockperson() = i2 WITH protect
 DECLARE getinvaliddateevents() = i2 WITH protect
 DECLARE getproposeddatefromeventprsnl() = i2 WITH protect
 DECLARE getproposeddatefromeventaction() = i2 WITH protect
 DECLARE syncupeventhistory() = i2 WITH protect
 DECLARE fixinvaliddateevents() = i2 WITH protect
 DECLARE fixclinicalevent() = i2 WITH protect
 DECLARE fixeventaction() = i2 WITH protect
 DECLARE fixeventprsnl() = i2 WITH protect
 DECLARE fixsubscriptionnewresults() = i2 WITH protect
 DECLARE fixchartrequest() = i2 WITH protect
 DECLARE fixcrreportrequest() = i2 WITH protect
 DECLARE fixcytoscreeningevent() = i2 WITH protect
 DECLARE fixeventnote() = i2 WITH protect
 DECLARE fixmedresult() = i2 WITH protect
 DECLARE fixintakeoutputresult() = i2 WITH protect
 DECLARE fixspecimencoll() = i2 WITH protect
 DECLARE fixiototalresult() = i2 WITH protect
 DECLARE fixcontributorlink() = i2 WITH protect
 DECLARE fixcalculationresult() = i2 WITH protect
 DECLARE fixblobresult() = i2 WITH protect
 DECLARE fixblob() = i2 WITH protect
 DECLARE fixlinkedresult() = i2 WITH protect
 DECLARE fixblobsummary() = i2 WITH protect
 DECLARE fixeventmodifier() = i2 WITH protect
 DECLARE fixstringresult() = i2 WITH protect
 DECLARE fixinterpcomp() = i2 WITH protect
 DECLARE fixcodedresult() = i2 WITH protect
 DECLARE fixmicrobiology() = i2 WITH protect
 DECLARE fixsusceptibility() = i2 WITH protect
 DECLARE fixmedadminidentifier() = i2 WITH protect
 DECLARE fixeventorderlink() = i2 WITH protect
 DECLARE fixproduct() = i2 WITH protect
 DECLARE fixproductantigen() = i2 WITH protect
 DECLARE fixdateresult() = i2 WITH protect
 DECLARE fixsuscepfootnoter() = i2 WITH protect
 DECLARE fixsuscepfootnote() = i2 WITH protect
 DECLARE fixinventoryresult() = i2 WITH protect
 DECLARE fiximplantresult() = i2 WITH protect
 DECLARE fixinvtimeresult() = i2 WITH protect
 DECLARE fixeventactionmodifier() = i2 WITH protect
 DECLARE fixresultsetlink() = i2 WITH protect
 DECLARE event_seq = i4 WITH protect, noconstant(0)
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE ce_cnt = i4 WITH protect, noconstant(0)
 DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE cr_rpt_req_cnt = i4 WITH protect, noconstant(0)
 DECLARE chart_req_cnt = i4 WITH protect, noconstant(0)
 DECLARE person_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ce_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE encntr_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE person_idx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE lvindex = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE today_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE tomorrow_dt_tm = dq8 WITH protect, constant(cnvtdatetime((curdate+ 1),cnvttime2("235959",
    "HHMMSS")))
 DECLARE end_of_time = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE perform_action_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modify_action_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verify_action_cd = f8 WITH protect, noconstant(0.0)
 DECLARE temp_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE input_file_name = vc WITH protect, noconstant(" ")
 DECLARE output_file_name = vc WITH protect, noconstant(" ")
 DECLARE line1 = vc WITH protect, noconstant(" ")
 DECLARE status_success = i2 WITH protect, noconstant(0)
 DECLARE status_no_data = i2 WITH protect, noconstant(1)
 DECLARE status_ccl_error = i2 WITH protect, noconstant(2)
 DECLARE status_input_error = i2 WITH protect, noconstant(3)
 DECLARE estatus = i2 WITH protect, noconstant(status_success)
 DECLARE distribution_request_type = i2 WITH protect, constant(4)
 DECLARE bit_ce_event_prsnl = i4 WITH protect, constant(0)
 DECLARE bit_ce_event_note = i4 WITH protect, constant(1)
 DECLARE bit_ce_med_result = i4 WITH protect, constant(2)
 DECLARE bit_ce_intake_output_result = i4 WITH protect, constant(3)
 DECLARE bit_ce_specimen_coll = i4 WITH protect, constant(4)
 DECLARE bit_ce_io_total_result = i4 WITH protect, constant(5)
 DECLARE bit_ce_contributor_link = i4 WITH protect, constant(6)
 DECLARE bit_ce_calculation_result = i4 WITH protect, constant(7)
 DECLARE bit_ce_blob_result = i4 WITH protect, constant(8)
 DECLARE bit_ce_blob = i4 WITH protect, constant(9)
 DECLARE bit_ce_linked_result = i4 WITH protect, constant(10)
 DECLARE bit_ce_blob_summary = i4 WITH protect, constant(11)
 DECLARE bit_ce_event_modifier = i4 WITH protect, constant(12)
 DECLARE bit_ce_string_result = i4 WITH protect, constant(13)
 DECLARE bit_ce_interp_comp = i4 WITH protect, constant(14)
 DECLARE bit_ce_coded_result = i4 WITH protect, constant(15)
 DECLARE bit_ce_microbiology = i4 WITH protect, constant(16)
 DECLARE bit_ce_susceptibility = i4 WITH protect, constant(17)
 DECLARE bit_ce_med_admin_identifier = i4 WITH protect, constant(18)
 DECLARE bit_ce_event_order_link = i4 WITH protect, constant(19)
 DECLARE bit_ce_product = i4 WITH protect, constant(20)
 DECLARE bit_ce_product_antigen = i4 WITH protect, constant(21)
 DECLARE bit_ce_date_result = i4 WITH protect, constant(22)
 DECLARE bit_ce_suscep_footnote_r = i4 WITH protect, constant(23)
 DECLARE bit_ce_suscep_footnote = i4 WITH protect, constant(24)
 DECLARE bit_ce_inventory_result = i4 WITH protect, constant(25)
 DECLARE bit_ce_implant_result = i4 WITH protect, constant(26)
 DECLARE bit_ce_inv_time_result = i4 WITH protect, constant(27)
 DECLARE bit_ce_event_action_modifier = i4 WITH protect, constant(29)
 DECLARE bit_ce_result_set_link = i4 WITH protect, constant(30)
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
 SET temp_captions->rpttitle = uar_i18ngetmessage(i18nhandle,"h1",
  "INVALID FUTURE DATE CHANGES REPORT")
 SET temp_captions->patientname = uar_i18ngetmessage(i18nhandle,"h2","PATIENT NAME:")
 SET temp_captions->patientid = uar_i18ngetmessage(i18nhandle,"h3","ID:")
 SET temp_captions->clinical = uar_i18ngetmessage(i18nhandle,"h4","CLINICAL")
 SET temp_captions->oldvalid = uar_i18ngetmessage(i18nhandle,"h5","OLD VALID")
 SET temp_captions->newvalid = uar_i18ngetmessage(i18nhandle,"h6","NEW VALID")
 SET temp_captions->oldclinsig = uar_i18ngetmessage(i18nhandle,"h7","OLD CLINSIG")
 SET temp_captions->newclinsig = uar_i18ngetmessage(i18nhandle,"h8","NEW CLINSIG")
 SET temp_captions->oldupdt = uar_i18ngetmessage(i18nhandle,"h9","OLD UPDT")
 SET temp_captions->newupdt = uar_i18ngetmessage(i18nhandle,"h10","NEW UPDT")
 SET temp_captions->oldvalid = uar_i18ngetmessage(i18nhandle,"h11","OLD VALID")
 SET temp_captions->newvalid = uar_i18ngetmessage(i18nhandle,"h12","NEW VALID")
 SET temp_captions->eventid = uar_i18ngetmessage(i18nhandle,"h13","EVENT ID")
 SET temp_captions->fromdate = uar_i18ngetmessage(i18nhandle,"h14","FROM DATE")
 SET temp_captions->date = uar_i18ngetmessage(i18nhandle,"h15","DATE")
 SET temp_captions->untildate = uar_i18ngetmessage(i18nhandle,"h16","UNTIL DATE")
 SET errcode = error(errmsg,1)
 SET perform_action_cd = uar_get_code_by("MEANING",21,"PERFORM")
 SET modify_action_cd = uar_get_code_by("MEANING",21,"MODIFY")
 SET verify_action_cd = uar_get_code_by("MEANING",21,"VERIFY")
 SET estatus = validateinputs(null)
 IF (estatus != status_success)
  GO TO exit_script
 ENDIF
 SET estatus = getpersonlistfromfile(null)
 IF (estatus != status_success)
  GO TO exit_script
 ENDIF
 SET output_file_name = getoutputfilename(null)
 SET estatus = writereportheader(null)
 IF (estatus != status_success)
  GO TO exit_script
 ENDIF
 SET curalias clin_event_list temp_rec->person_list[person_idx].ce_list[((ce_cnt - d.seq)+ 1)]
 FOR (person_idx = 1 TO person_cnt)
   SET estatus = fixinvaliddateevents(null)
   IF (estatus=status_success)
    SET estatus = writechangesreport(null)
    IF (estatus=status_success)
     COMMIT
    ENDIF
   ENDIF
   IF (estatus != status_success)
    IF (estatus=status_ccl_error)
     CALL echo(build("An error occured while fixing invalid date events for patient = ",trim(temp_rec
        ->person_list[person_idx].person_name,3),"(",cnvtstring(temp_rec->person_list[person_idx].
        person_id),")"))
    ENDIF
    ROLLBACK
   ENDIF
 ENDFOR
 SET curalias clin_event_list off
 SUBROUTINE validateinputs(null)
   SET input_file_name = trim( $1,3)
   IF (textlen(input_file_name)=0)
    CALL echo("Invalid file name entered to retrieve patient list from.")
    RETURN(status_input_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE getpersonlistfromfile(null)
   IF (findfile(input_file_name)=1)
    FREE DEFINE rtl2
    SET logical cclfilein value(input_file_name)
    DEFINE rtl2 "CCLFILEIN"
    SELECT INTO "nl:"
     r2.line, p.name_full_formatted
     FROM rtl2t r2,
      person p
     PLAN (r2
      WHERE assign(temp_person_id,cnvtreal(r2.line)) > 0)
      JOIN (p
      WHERE p.person_id=temp_person_id)
     ORDER BY cnvtupper(p.name_full_formatted), p.person_id
     HEAD REPORT
      person_cnt = 0
     HEAD p.person_id
      person_cnt = (person_cnt+ 1)
      IF (person_cnt > size(temp_rec->person_list,5))
       stat = alterlist(temp_rec->person_list,(person_cnt+ 19))
      ENDIF
      temp_rec->person_list[person_cnt].person_id = p.person_id, temp_rec->person_list[person_cnt].
      person_name = p.name_full_formatted
     FOOT REPORT
      stat = alterlist(temp_rec->person_list,person_cnt)
     WITH nocounter
    ;end select
    FREE DEFINE rtl2
    IF (error(errmsg,1))
     CALL echo(build("An error occured while retrieving patient list from file -",errmsg))
     RETURN(status_ccl_error)
    ELSEIF (person_cnt=0)
     CALL echo("No valid patients found in file.")
     RETURN(status_no_data)
    ENDIF
   ELSE
    CALL echo("Invalid file name entered to retrieve patient list from.")
    RETURN(status_input_error)
   ENDIF
   SET person_loop_cnt = ceil((cnvtreal(person_cnt)/ batch_size))
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE getoutputfilename(null)
   DECLARE outfilename = vc WITH protect, noconstant(" ")
   SET outfilename = concat("ce_inv_date_rpt_",format(curdate,"YYMMDD;;D"),format(curtime3,
     "HHMMSSCC;;M"),".dat")
   CALL echo(concat("Output file name = '",outfilename,"'"))
   RETURN(outfilename)
 END ;Subroutine
 SUBROUTINE fixinvaliddateevents(null)
   DECLARE tempstatus = i2 WITH protect, noconstant(status_success)
   SET stat = initrec(unique_encntrs)
   SET encntr_cnt = 0
   SET ce_cnt = 0
   SET tempstatus = lockperson(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = getinvaliddateevents(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET ce_cnt = size(temp_rec->person_list[person_idx].ce_list,5)
   SET ce_loop_cnt = ceil((cnvtreal(ce_cnt)/ batch_size))
   SET encntr_cnt = size(unique_encntrs->encntrs,5)
   SET encntr_loop_cnt = ceil((cnvtreal(encntr_cnt)/ batch_size))
   SET tempstatus = getproposeddatefromeventprsnl(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = getproposeddatefromeventaction(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = syncupeventhistory(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixclinicalevent(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventaction(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventprsnl(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventnote(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixmedresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixintakeoutputresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixspecimencoll(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixiototalresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixcontributorlink(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixcalculationresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixblobresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixblob(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixlinkedresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixblobsummary(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventmodifier(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixstringresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixinterpcomp(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixcodedresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixmicrobiology(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixsusceptibility(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixmedadminidentifier(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventorderlink(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixproduct(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixproductantigen(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixdateresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixsuscepfootnoter(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixsuscepfootnote(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixinventoryresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fiximplantresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixinvtimeresult(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixeventactionmodifier(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixresultsetlink(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixsubscriptionnewresults(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixchartrequest(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixcrreportrequest(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   SET tempstatus = fixcytoscreeningevent(null)
   IF (tempstatus != status_success)
    RETURN(tempstatus)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE lockperson(null)
   SELECT INTO "nl:"
    p.person_id
    FROM person p
    PLAN (p
     WHERE (p.person_id=temp_rec->person_list[person_idx].person_id))
    WITH nocounter, forupdatewait(p)
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while locking person (id =",cnvtstring(temp_rec->person_list[
       person_idx].person_id),") -",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE getinvaliddateevents(null)
   SELECT INTO "nl:"
    ce.person_id, ce.clinical_event_id, ce.event_id,
    ce.event_end_dt_tm, ce.valid_from_dt_tm, ce.clinsig_updt_dt_tm,
    ce.updt_dt_tm, ce.valid_until_dt_tm, ce.subtable_bit_map,
    eff_event_ind = evaluate(ce.valid_until_dt_tm,end_of_time,1,0)
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.event_id IN (
     (SELECT DISTINCT INTO "nl:"
      ce2.event_id
      FROM clinical_event ce2
      WHERE (ce2.person_id=temp_rec->person_list[person_idx].person_id)
       AND ((((ce2.valid_from_dt_tm+ 0) > cnvtdatetime(tomorrow_dt_tm))) OR (((((ce2
      .clinsig_updt_dt_tm+ 0) > cnvtdatetime(tomorrow_dt_tm))) OR (((ce2.updt_dt_tm+ 0) >
      cnvtdatetime(tomorrow_dt_tm)))) ))
      WITH nocounter)))
    ORDER BY ce.event_id, eff_event_ind DESC, ce.valid_until_dt_tm DESC
    HEAD REPORT
     ce_cnt = 0
    HEAD ce.event_id
     event_seq = 0
    DETAIL
     event_seq = (event_seq+ 1), ce_cnt = (ce_cnt+ 1)
     IF (ce_cnt > size(temp_rec->person_list[person_idx].ce_list,5))
      stat = alterlist(temp_rec->person_list[person_idx].ce_list,(ce_cnt+ 49))
     ENDIF
     IF (ce.encntr_id > 0.0)
      IF (locateval(num,1,size(unique_encntrs->encntrs,5),ce.encntr_id,unique_encntrs->encntrs[num].
       encntr_id)=0)
       encntr_cnt = (encntr_cnt+ 1)
       IF (encntr_cnt > size(unique_encntrs->encntrs,5))
        stat = alterlist(unique_encntrs->encntrs,(encntr_cnt+ 5))
       ENDIF
       unique_encntrs->encntrs[encntr_cnt].encntr_id = ce.encntr_id
      ENDIF
     ELSEIF (ce.encntr_id=0.0)
      unique_encntrs->found_person_level = 1
     ENDIF
     temp_rec->person_list[person_idx].ce_list[ce_cnt].clinical_event_id = ce.clinical_event_id,
     temp_rec->person_list[person_idx].ce_list[ce_cnt].event_id = ce.event_id, temp_rec->person_list[
     person_idx].ce_list[ce_cnt].event_seq = event_seq,
     temp_rec->person_list[person_idx].ce_list[ce_cnt].encntr_id = ce.encntr_id, temp_rec->
     person_list[person_idx].ce_list[ce_cnt].valid_from_dt_tm = cnvtdatetime(ce.valid_from_dt_tm),
     temp_rec->person_list[person_idx].ce_list[ce_cnt].valid_until_dt_tm = cnvtdatetime(ce
      .valid_until_dt_tm),
     temp_rec->person_list[person_idx].ce_list[ce_cnt].clinsig_updt_dt_tm = cnvtdatetime(ce
      .clinsig_updt_dt_tm), temp_rec->person_list[person_idx].ce_list[ce_cnt].updt_dt_tm =
     cnvtdatetime(ce.updt_dt_tm), temp_rec->person_list[person_idx].ce_list[ce_cnt].subtable_bitmap
      = ce.subtable_bit_map,
     temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind = 0, temp_rec->person_list[
     person_idx].ce_list[ce_cnt].fix_date_ind = 0, temp_rec->person_list[person_idx].ce_list[ce_cnt].
     new_valid_until_dt_tm = cnvtdatetime(ce.valid_until_dt_tm),
     temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(ce
      .valid_from_dt_tm), temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm =
     cnvtdatetime(ce.clinsig_updt_dt_tm)
     IF (ce.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm))
      temp_rec->person_list[person_idx].ce_list[ce_cnt].fix_date_ind = 1
     ELSEIF ((temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind=0))
      temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(ce
       .valid_from_dt_tm)
      IF (ce.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
       temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm = cnvtdatetime(ce
        .valid_from_dt_tm)
      ENDIF
      temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind = 1
     ENDIF
     IF (ce.updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
      temp_rec->person_list[person_idx].ce_list[ce_cnt].fix_date_ind = 1
     ELSEIF ((temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind=0))
      IF (ce.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm))
       temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(ce
        .updt_dt_tm)
      ENDIF
      IF (ce.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
       temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm = cnvtdatetime(ce
        .updt_dt_tm)
      ENDIF
      temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind = 1
     ENDIF
     IF (ce.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
      temp_rec->person_list[person_idx].ce_list[ce_cnt].fix_date_ind = 1
     ELSEIF ((temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind=0))
      IF (ce.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm))
       temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(ce
        .clinsig_updt_dt_tm)
      ENDIF
      temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm = cnvtdatetime(ce
       .clinsig_updt_dt_tm), temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind = 1
     ENDIF
     IF ((temp_rec->person_list[person_idx].ce_list[ce_cnt].fix_date_ind=1)
      AND (temp_rec->person_list[person_idx].ce_list[ce_cnt].found_proposed_ind=0))
      IF (ce.event_end_dt_tm > cnvtdatetime(tomorrow_dt_tm))
       IF (ce.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm))
        temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(
         today_dt_tm)
       ENDIF
       IF (ce.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
        temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm = cnvtdatetime(
         today_dt_tm)
       ENDIF
      ELSE
       IF (ce.valid_from_dt_tm > cnvtdatetime(tomorrow_dt_tm))
        temp_rec->person_list[person_idx].ce_list[ce_cnt].new_valid_from_dt_tm = cnvtdatetime(ce
         .event_end_dt_tm)
       ENDIF
       IF (ce.clinsig_updt_dt_tm > cnvtdatetime(tomorrow_dt_tm))
        temp_rec->person_list[person_idx].ce_list[ce_cnt].new_clinsig_updt_dt_tm = cnvtdatetime(ce
         .event_end_dt_tm)
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(temp_rec->person_list[person_idx].ce_list,ce_cnt), stat = alterlist(
      unique_encntrs->encntrs,encntr_cnt)
    WITH nocounter
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while selecting from clinical_event -",errmsg))
    RETURN(status_ccl_error)
   ELSEIF (ce_cnt=0)
    CALL echo(build("No invalid future date events found for patient = ",trim(temp_rec->person_list[
       person_idx].person_name,3),"(",cnvtstring(temp_rec->person_list[person_idx].person_id),")"))
    RETURN(status_no_data)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE getproposeddatefromeventprsnl(null)
   IF (((perform_action_cd=0) OR (((perform_action_cd=0) OR (perform_action_cd=0)) )) )
    CALL echo("Unable to retrieve code by meaning. Skipping ce_event_prsnl table..")
    RETURN(status_success)
   ENDIF
   SELECT INTO "nl:"
    cep.event_id, cep.action_type_cd, cep.action_dt_tm,
    cep.valid_from_dt_tm
    FROM ce_event_prsnl cep,
     (dummyt d  WITH seq = value(ce_loop_cnt))
    PLAN (d)
     JOIN (cep
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),minval((d.seq * batch_size),ce_cnt),cep
      .event_id,temp_rec->person_list[person_idx].ce_list[idx].event_id,
      cep.valid_from_dt_tm,temp_rec->person_list[person_idx].ce_list[idx].valid_from_dt_tm,0,temp_rec
      ->person_list[person_idx].ce_list[idx].found_proposed_ind,1,
      temp_rec->person_list[person_idx].ce_list[idx].fix_date_ind)
      AND cep.action_type_cd IN (perform_action_cd, modify_action_cd, verify_action_cd)
      AND cep.action_dt_tm <= cnvtdatetime(tomorrow_dt_tm))
    ORDER BY cep.event_id, cep.action_dt_tm DESC
    DETAIL
     lvindex = locateval(idx,1,ce_cnt,cep.event_id,temp_rec->person_list[person_idx].ce_list[idx].
      event_id,
      cep.valid_from_dt_tm,temp_rec->person_list[person_idx].ce_list[idx].valid_from_dt_tm)
     IF (lvindex > 0)
      IF ((temp_rec->person_list[person_idx].ce_list[lvindex].found_proposed_ind=0))
       temp_rec->person_list[person_idx].ce_list[lvindex].new_valid_from_dt_tm = cnvtdatetime(cep
        .action_dt_tm), temp_rec->person_list[person_idx].ce_list[lvindex].new_clinsig_updt_dt_tm =
       cnvtdatetime(cep.action_dt_tm), temp_rec->person_list[person_idx].ce_list[lvindex].
       found_proposed_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while selecting from ce_event_prsnl -",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE getproposeddatefromeventaction(null)
   SELECT INTO "nl:"
    cea.event_id, cea.updt_dt_tm
    FROM ce_event_action cea,
     (dummyt d  WITH seq = value(ce_loop_cnt))
    PLAN (d)
     JOIN (cea
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),minval((d.seq * batch_size),ce_cnt),cea
      .event_id,temp_rec->person_list[person_idx].ce_list[idx].event_id,
      1,temp_rec->person_list[person_idx].ce_list[idx].event_seq,0,temp_rec->person_list[person_idx].
      ce_list[idx].found_proposed_ind,1,
      temp_rec->person_list[person_idx].ce_list[idx].fix_date_ind)
      AND cea.updt_dt_tm <= cnvtdatetime(tomorrow_dt_tm))
    ORDER BY cea.event_id, cea.updt_dt_tm DESC
    HEAD cea.event_id
     lvindex = locateval(idx,1,ce_cnt,cea.event_id,temp_rec->person_list[person_idx].ce_list[idx].
      event_id,
      1,temp_rec->person_list[person_idx].ce_list[idx].event_seq)
     IF (lvindex > 0)
      temp_rec->person_list[person_idx].ce_list[lvindex].new_valid_from_dt_tm = cnvtdatetime(cea
       .updt_dt_tm), temp_rec->person_list[person_idx].ce_list[lvindex].new_clinsig_updt_dt_tm =
      cnvtdatetime(cea.updt_dt_tm), temp_rec->person_list[person_idx].ce_list[lvindex].
      found_proposed_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while selecting from ce_event_action -",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE syncupeventhistory(null)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(ce_cnt))
    PLAN (d
     WHERE (temp_rec->person_list[person_idx].ce_list[d.seq].event_seq > 1))
    ORDER BY d.seq
    DETAIL
     IF ((temp_rec->person_list[person_idx].ce_list[d.seq].new_valid_until_dt_tm > temp_rec->
     person_list[person_idx].ce_list[(d.seq - 1)].new_valid_from_dt_tm))
      temp_rec->person_list[person_idx].ce_list[d.seq].new_valid_until_dt_tm = datetimeadd(temp_rec->
       person_list[person_idx].ce_list[(d.seq - 1)].new_valid_from_dt_tm,- ((1.0/ ((24 * 60) * 60)))),
      temp_rec->person_list[person_idx].ce_list[d.seq].fix_date_ind = 1
     ENDIF
     IF ((temp_rec->person_list[person_idx].ce_list[d.seq].new_valid_from_dt_tm > temp_rec->
     person_list[person_idx].ce_list[d.seq].new_valid_until_dt_tm))
      temp_rec->person_list[person_idx].ce_list[d.seq].new_valid_from_dt_tm = datetimeadd(temp_rec->
       person_list[person_idx].ce_list[d.seq].new_valid_until_dt_tm,- ((1.0/ ((24 * 60) * 60)))),
      temp_rec->person_list[person_idx].ce_list[d.seq].fix_date_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured processing valid from and valid until dates -",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixclinicalevent(null)
   UPDATE  FROM clinical_event ce,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ce.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), ce
     .valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), ce.clinsig_updt_dt_tm
      = cnvtdatetime(clin_event_list->new_clinsig_updt_dt_tm),
     ce.updt_dt_tm = cnvtdatetime(today_dt_tm), ce.updt_cnt = (ce.updt_cnt+ 1)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1))
     JOIN (ce
     WHERE (ce.clinical_event_id=clin_event_list->clinical_event_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating clinical_event - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventaction(null)
   UPDATE  FROM ce_event_action cea,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cea.clinsig_updt_dt_tm = cnvtdatetime(clin_event_list->new_clinsig_updt_dt_tm), cea
     .updt_dt_tm = cea.updt_dt_tm
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND (clin_event_list->event_seq=1))
     JOIN (cea
     WHERE (cea.event_id=clin_event_list->event_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating ce_event_action - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventprsnl(null)
   UPDATE  FROM ce_event_prsnl cep,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cep.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cep.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_prsnl)=1)
     JOIN (cep
     WHERE (cep.event_id=clin_event_list->event_id)
      AND cep.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_event_prsnl - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_event_prsnl cep,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cep.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cep.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_prsnl)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cep
     WHERE (cep.event_id=clin_event_list->event_id)
      AND cep.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_event_prsnl - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventnote(null)
   UPDATE  FROM ce_event_note cen,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cen.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cen.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_note)=1)
     JOIN (cen
     WHERE (cen.event_id=clin_event_list->event_id)
      AND cen.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_event_note - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_event_note cen,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cen.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cen.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_note)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cen
     WHERE (cen.event_id=clin_event_list->event_id)
      AND cen.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_event_note - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixmedresult(null)
   UPDATE  FROM ce_med_result cmr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cmr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_result)=1)
     JOIN (cmr
     WHERE (cmr.event_id=clin_event_list->event_id)
      AND cmr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_med_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_med_result cmr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cmr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cmr
     WHERE (cmr.event_id=clin_event_list->event_id)
      AND cmr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_med_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixintakeoutputresult(null)
   UPDATE  FROM ce_intake_output_result cior,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cior.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cior.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_intake_output_result)=1)
     JOIN (cior
     WHERE (cior.event_id=clin_event_list->event_id)
      AND cior.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_intake_output_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_intake_output_result cior,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cior.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cior
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_intake_output_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cior
     WHERE (cior.event_id=clin_event_list->event_id)
      AND cior.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_intake_output_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixspecimencoll(null)
   UPDATE  FROM ce_specimen_coll csc,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csc.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), csc.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_specimen_coll)=1)
     JOIN (csc
     WHERE (csc.event_id=clin_event_list->event_id)
      AND csc.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_specimen_coll - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_specimen_coll csc,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csc.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), csc.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_specimen_coll)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (csc
     WHERE (csc.event_id=clin_event_list->event_id)
      AND csc.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_specimen_coll - ",errmsg
      ))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixiototalresult(null)
   UPDATE  FROM ce_io_total_result citr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET citr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), citr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_io_total_result)=1)
     JOIN (citr
     WHERE (citr.event_id=clin_event_list->event_id)
      AND citr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_io_total_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_io_total_result citr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET citr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), citr
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_io_total_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (citr
     WHERE (citr.event_id=clin_event_list->event_id)
      AND citr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_io_total_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixcontributorlink(null)
   UPDATE  FROM ce_contributor_link cclk,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cclk.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cclk.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_contributor_link)=1)
     JOIN (cclk
     WHERE (cclk.event_id=clin_event_list->event_id)
      AND cclk.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_contributor_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_contributor_link cclk,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cclk.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cclk
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_contributor_link)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cclk
     WHERE (cclk.event_id=clin_event_list->event_id)
      AND cclk.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_contributor_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixcalculationresult(null)
   UPDATE  FROM ce_calculation_result ccr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ccr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), ccr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_calculation_result)=1)
     JOIN (ccr
     WHERE (ccr.event_id=clin_event_list->event_id)
      AND ccr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_calculation_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_calculation_result ccr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ccr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), ccr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_calculation_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (ccr
     WHERE (ccr.event_id=clin_event_list->event_id)
      AND ccr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_calculation_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixblobresult(null)
   UPDATE  FROM ce_blob_result cbr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cbr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cbr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob_result)=1)
     JOIN (cbr
     WHERE (cbr.event_id=clin_event_list->event_id)
      AND cbr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_blob_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_blob_result cbr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cbr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cbr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cbr
     WHERE (cbr.event_id=clin_event_list->event_id)
      AND cbr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_blob_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixblob(null)
   UPDATE  FROM ce_blob cb,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cb.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cb.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob)=1)
     JOIN (cb
     WHERE (cb.event_id=clin_event_list->event_id)
      AND cb.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_blob - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_blob cb,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cb.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cb.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cb
     WHERE (cb.event_id=clin_event_list->event_id)
      AND cb.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_blob - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixlinkedresult(null)
   UPDATE  FROM ce_linked_result clr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET clr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), clr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_linked_result)=1)
     JOIN (clr
     WHERE (clr.event_id=clin_event_list->event_id)
      AND clr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_linked_result - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_linked_result clr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET clr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), clr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_linked_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (clr
     WHERE (clr.event_id=clin_event_list->event_id)
      AND clr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_linked_result - ",errmsg
      ))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixblobsummary(null)
   UPDATE  FROM ce_blob_summary cbs,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cbs.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cbs.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob_summary)=1)
     JOIN (cbs
     WHERE (cbs.event_id=clin_event_list->event_id)
      AND cbs.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_blob_summary - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_blob_summary cbs,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cbs.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cbs.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_blob_summary)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cbs
     WHERE (cbs.event_id=clin_event_list->event_id)
      AND cbs.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_blob_summary - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventmodifier(null)
   UPDATE  FROM ce_event_modifier cem,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cem.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cem.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_modifier)=1)
     JOIN (cem
     WHERE (cem.event_id=clin_event_list->event_id)
      AND cem.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_event_modifier - ",errmsg
      ))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_event_modifier cem,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cem.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cem.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_modifier)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cem
     WHERE (cem.event_id=clin_event_list->event_id)
      AND cem.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_event_modifier - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixstringresult(null)
   UPDATE  FROM ce_string_result csr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), csr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_string_result)=1)
     JOIN (csr
     WHERE (csr.event_id=clin_event_list->event_id)
      AND csr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_string_result - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_string_result csr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), csr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_string_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (csr
     WHERE (csr.event_id=clin_event_list->event_id)
      AND csr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_string_result - ",errmsg
      ))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixinterpcomp(null)
   UPDATE  FROM ce_interp_comp cic,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cic.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cic.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_interp_comp)=1)
     JOIN (cic
     WHERE (cic.event_id=clin_event_list->event_id)
      AND cic.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_interp_comp - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_interp_comp cic,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cic.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cic.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_interp_comp)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cic
     WHERE (cic.event_id=clin_event_list->event_id)
      AND cic.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_interp_comp - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixcodedresult(null)
   UPDATE  FROM ce_coded_result ccr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ccr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), ccr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_coded_result)=1)
     JOIN (ccr
     WHERE (ccr.event_id=clin_event_list->event_id)
      AND ccr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_coded_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_coded_result ccr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ccr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), ccr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_coded_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (ccr
     WHERE (ccr.event_id=clin_event_list->event_id)
      AND ccr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_coded_result - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixmicrobiology(null)
   UPDATE  FROM ce_microbiology cm,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cm.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cm.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_microbiology)=1)
     JOIN (cm
     WHERE (cm.event_id=clin_event_list->event_id)
      AND cm.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_microbiology - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_microbiology cm,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cm.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cm.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_microbiology)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cm
     WHERE (cm.event_id=clin_event_list->event_id)
      AND cm.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_microbiology - ",errmsg)
     )
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixsusceptibility(null)
   UPDATE  FROM ce_susceptibility cs,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cs.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cs.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_susceptibility)=1)
     JOIN (cs
     WHERE (cs.event_id=clin_event_list->event_id)
      AND cs.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_susceptibility - ",errmsg
      ))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_susceptibility cs,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cs.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cs.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_susceptibility)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cs
     WHERE (cs.event_id=clin_event_list->event_id)
      AND cs.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_susceptibility - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixmedadminidentifier(null)
   UPDATE  FROM ce_med_admin_ident cmai,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmai.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cmai.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_admin_identifier)=1)
     JOIN (cmai
     WHERE cmai.ce_med_admin_ident_id IN (
     (SELECT INTO "nl:"
      cmair.ce_med_admin_ident_id
      FROM ce_med_admin_ident_reltn cmair
      WHERE (cmair.event_id=clin_event_list->event_id)
       AND cmair.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_med_admin_ident - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_med_admin_ident cmai,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmai.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cmai
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_admin_identifier)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cmai
     WHERE cmai.ce_med_admin_ident_id IN (
     (SELECT INTO "nl:"
      cmair.ce_med_admin_ident_id
      FROM ce_med_admin_ident_reltn cmair
      WHERE (cmair.event_id=clin_event_list->event_id)
       AND cmair.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_med_admin_ident - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_med_admin_ident_reltn cmair,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmair.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cmair
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_admin_identifier)=1)
     JOIN (cmair
     WHERE (cmair.event_id=clin_event_list->event_id)
      AND cmair.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_med_admin_ident_reltn - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_med_admin_ident_reltn cmair,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cmair.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cmair
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_med_admin_identifier)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cmair
     WHERE (cmair.event_id=clin_event_list->event_id)
      AND cmair.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build(
      "An error occured while updating valid_until_dt_tm in ce_med_admin_ident_reltn - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventorderlink(null)
   UPDATE  FROM ce_event_order_link ceol,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ceol.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), ceol.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_order_link)=1)
     JOIN (ceol
     WHERE (ceol.event_id=clin_event_list->event_id)
      AND ceol.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_event_order_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_event_order_link ceol,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ceol.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), ceol
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_order_link)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (ceol
     WHERE (ceol.event_id=clin_event_list->event_id)
      AND ceol.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_event_order_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixproduct(null)
   UPDATE  FROM ce_product cp,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cp.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cp.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_product)=1)
     JOIN (cp
     WHERE (cp.event_id=clin_event_list->event_id)
      AND cp.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_product - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_product cp,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cp.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cp.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_product)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cp
     WHERE (cp.event_id=clin_event_list->event_id)
      AND cp.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_product - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixproductantigen(null)
   UPDATE  FROM ce_product_antigen cpa,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cpa.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cpa.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_product_antigen)=1)
     JOIN (cpa
     WHERE (cpa.event_id=clin_event_list->event_id)
      AND cpa.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_product_antigen - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_product_antigen cpa,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cpa.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cpa.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_product_antigen)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cpa
     WHERE (cpa.event_id=clin_event_list->event_id)
      AND cpa.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_product_antigen - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixdateresult(null)
   UPDATE  FROM ce_date_result cdr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cdr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cdr.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_date_result)=1)
     JOIN (cdr
     WHERE (cdr.event_id=clin_event_list->event_id)
      AND cdr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_date_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_date_result cdr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cdr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cdr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_date_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cdr
     WHERE (cdr.event_id=clin_event_list->event_id)
      AND cdr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_date_result - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixsuscepfootnoter(null)
   UPDATE  FROM ce_suscep_footnote_r csfr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csfr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), csfr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_suscep_footnote_r)=1)
     JOIN (csfr
     WHERE (csfr.event_id=clin_event_list->event_id)
      AND csfr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_suscep_footnote_r - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_suscep_footnote_r csfr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csfr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), csfr
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_suscep_footnote_r)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (csfr
     WHERE (csfr.event_id=clin_event_list->event_id)
      AND csfr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_suscep_footnote_r - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixsuscepfootnote(null)
   UPDATE  FROM ce_suscep_footnote csf,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csf.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), csf.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_suscep_footnote)=1)
     JOIN (csf
     WHERE (csf.event_id=clin_event_list->event_id)
      AND csf.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_suscep_footnote - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_suscep_footnote csf,
     (dummyt d  WITH seq = value(ce_cnt))
    SET csf.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), csf.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_suscep_footnote)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (csf
     WHERE (csf.event_id=clin_event_list->event_id)
      AND csf.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_suscep_footnote - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixinventoryresult(null)
   UPDATE  FROM ce_inventory_result cir,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cir.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cir.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_inventory_result)=1)
     JOIN (cir
     WHERE (cir.event_id=clin_event_list->event_id)
      AND cir.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_inventory_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_inventory_result cir,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cir.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cir.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_inventory_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cir
     WHERE (cir.event_id=clin_event_list->event_id)
      AND cir.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_inventory_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fiximplantresult(null)
   UPDATE  FROM ce_implant_result cir,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cir.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cir.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_implant_result)=1)
     JOIN (cir
     WHERE (cir.event_id=clin_event_list->event_id)
      AND cir.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_implant_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_implant_result cir,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cir.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), cir.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_implant_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (cir
     WHERE (cir.event_id=clin_event_list->event_id)
      AND cir.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_implant_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixinvtimeresult(null)
   UPDATE  FROM ce_inv_time_result citr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET citr.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), citr.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_inv_time_result)=1)
     JOIN (citr
     WHERE (citr.event_id=clin_event_list->event_id)
      AND citr.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_inv_time_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_inv_time_result citr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET citr.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), citr
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_inv_time_result)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (citr
     WHERE (citr.event_id=clin_event_list->event_id)
      AND citr.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_inv_time_result - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixeventactionmodifier(null)
   UPDATE  FROM ce_event_action_modifier ceam,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ceam.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), ceam.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_action_modifier)=1)
     JOIN (ceam
     WHERE (ceam.event_id=clin_event_list->event_id)
      AND ceam.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_event_action_modifier - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_event_action_modifier ceam,
     (dummyt d  WITH seq = value(ce_cnt))
    SET ceam.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), ceam
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_event_action_modifier)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (ceam
     WHERE (ceam.event_id=clin_event_list->event_id)
      AND ceam.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build(
      "An error occured while updating valid_until_dt_tm in ce_event_action_modifier - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixresultsetlink(null)
   UPDATE  FROM ce_result_set_link crsl,
     (dummyt d  WITH seq = value(ce_cnt))
    SET crsl.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), crsl.updt_dt_tm
      = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_result_set_link)=1)
     JOIN (crsl
     WHERE (crsl.event_id=clin_event_list->event_id)
      AND crsl.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_from_dt_tm in ce_result_set_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   UPDATE  FROM ce_result_set_link crsl,
     (dummyt d  WITH seq = value(ce_cnt))
    SET crsl.valid_until_dt_tm = cnvtdatetime(clin_event_list->new_valid_until_dt_tm), crsl
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND btest(clin_event_list->subtable_bitmap,bit_ce_result_set_link)=1
      AND (clin_event_list->valid_until_dt_tm != cnvtdatetime(end_of_time)))
     JOIN (crsl
     WHERE (crsl.event_id=clin_event_list->event_id)
      AND crsl.valid_until_dt_tm=cnvtdatetime(clin_event_list->valid_until_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating valid_until_dt_tm in ce_result_set_link - ",
      errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixsubscriptionnewresults(null)
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_tables_doc dtd
    PLAN (dtd
     WHERE dtd.table_name="SUBSCRIPTION_NEW_RESULTS")
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(status_success)
   ENDIF
   UPDATE  FROM subscription_new_results snr,
     (dummyt d  WITH seq = value(ce_cnt))
    SET snr.clinsig_updt_dt_tm = cnvtdatetime(clin_event_list->new_clinsig_updt_dt_tm), snr
     .updt_dt_tm = cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1)
      AND (clin_event_list->event_seq=1))
     JOIN (snr
     WHERE (snr.event_id=clin_event_list->event_id))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating ce_event_prsnl - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixchartrequest(null)
   SET chart_req_cnt = 0
   SELECT INTO "nl:"
    cr.chart_request_id, cr.end_dt_tm, maxclinsig = max(ce.clinsig_updt_dt_tm)
    FROM chart_request cr,
     clinical_event ce,
     (dummyt d  WITH seq = value(encntr_loop_cnt))
    PLAN (d)
     JOIN (cr
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),minval((d.seq * batch_size),encntr_cnt),cr
      .encntr_id,unique_encntrs->encntrs[idx].encntr_id)
      AND cr.end_dt_tm > cnvtdatetime(tomorrow_dt_tm)
      AND cr.request_type=distribution_request_type)
     JOIN (ce
     WHERE ce.encntr_id=cr.encntr_id
      AND ce.clinsig_updt_dt_tm <= cr.request_dt_tm)
    GROUP BY cr.chart_request_id, cr.end_dt_tm
    HEAD REPORT
     chart_req_cnt = 0
    HEAD cr.chart_request_id
     chart_req_cnt = (chart_req_cnt+ 1)
     IF (chart_req_cnt > size(temp_rec->person_list[person_idx].chart_req_list,5))
      stat = alterlist(temp_rec->person_list[person_idx].chart_req_list,(chart_req_cnt+ 49))
     ENDIF
     temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].chart_request_id = cr
     .chart_request_id, temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].end_dt_tm =
     cnvtdatetime(cr.end_dt_tm), temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].
     new_end_dt_tm = cnvtdatetime(maxclinsig)
    FOOT REPORT
     stat = alterlist(temp_rec->person_list[person_idx].chart_req_list,chart_req_cnt)
    WITH nocounter, orahintcbo("USE_NL(CR CE) LEADING(CR CE)")
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while selecting from chart_request by encntr_id- ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   IF ((unique_encntrs->found_person_level=1))
    SELECT INTO "nl:"
     cr.chart_request_id, cr.end_dt_tm, cr.dist_run_dt_tm
     FROM chart_request cr
     WHERE (cr.person_id=temp_rec->person_list[person_idx].person_id)
      AND cr.end_dt_tm > cnvtdatetime(tomorrow_dt_tm)
      AND cr.encntr_id=0.0
      AND cr.request_type=distribution_request_type
     HEAD REPORT
      fake = 0
     HEAD cr.chart_request_id
      chart_req_cnt = (chart_req_cnt+ 1)
      IF (chart_req_cnt > size(temp_rec->person_list[person_idx].chart_req_list,5))
       stat = alterlist(temp_rec->person_list[person_idx].chart_req_list,(chart_req_cnt+ 49))
      ENDIF
      temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].chart_request_id = cr
      .chart_request_id, temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].end_dt_tm =
      cnvtdatetime(cr.end_dt_tm), temp_rec->person_list[person_idx].chart_req_list[chart_req_cnt].
      new_end_dt_tm = cnvtdatetime(cr.dist_run_dt_tm)
     FOOT REPORT
      stat = alterlist(temp_rec->person_list[person_idx].chart_req_list,chart_req_cnt)
     WITH nocounter, orahintcbo("INDEX(CR XIE2CHART_REQUEST)")
    ;end select
    IF (error(errmsg,1))
     CALL echo(build("An error occured while selecting from chart_request by person_id - ",errmsg))
     RETURN(status_ccl_error)
    ENDIF
   ENDIF
   IF (chart_req_cnt > 0)
    UPDATE  FROM chart_request cr,
      (dummyt d  WITH seq = value(chart_req_cnt))
     SET cr.end_dt_tm = cnvtdatetime(temp_rec->person_list[person_idx].chart_req_list[d.seq].
       new_end_dt_tm)
     PLAN (d)
      JOIN (cr
      WHERE (cr.chart_request_id=temp_rec->person_list[person_idx].chart_req_list[d.seq].
      chart_request_id))
     WITH nocounter
    ;end update
    IF (error(errmsg,1))
     CALL echo(build("An error occured while updating chart_request - ",errmsg))
     RETURN(status_ccl_error)
    ENDIF
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixcrreportrequest(null)
   SET cr_rpt_req_cnt = 0
   SELECT INTO "nl:"
    crr.report_request_id, crr.end_dt_tm, maxclinsig = max(ce.clinsig_updt_dt_tm)
    FROM cr_report_request crr,
     clinical_event ce,
     (dummyt d  WITH seq = value(encntr_loop_cnt))
    PLAN (d)
     JOIN (crr
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),minval((d.seq * batch_size),encntr_cnt),crr
      .encntr_id,unique_encntrs->encntrs[idx].encntr_id)
      AND crr.end_dt_tm > cnvtdatetime(tomorrow_dt_tm)
      AND crr.request_type_flag=distribution_request_type)
     JOIN (ce
     WHERE ce.encntr_id=crr.encntr_id
      AND ce.clinsig_updt_dt_tm <= crr.request_dt_tm)
    GROUP BY crr.report_request_id, crr.end_dt_tm
    HEAD REPORT
     cr_rpt_req_cnt = 0
    HEAD crr.report_request_id
     cr_rpt_req_cnt = (cr_rpt_req_cnt+ 1)
     IF (cr_rpt_req_cnt > size(temp_rec->person_list[person_idx].cr_rpt_req_list,5))
      stat = alterlist(temp_rec->person_list[person_idx].cr_rpt_req_list,(cr_rpt_req_cnt+ 49))
     ENDIF
     temp_rec->person_list[person_idx].cr_rpt_req_list[cr_rpt_req_cnt].report_request_id = crr
     .report_request_id, temp_rec->person_list[person_idx].cr_rpt_req_list[cr_rpt_req_cnt].end_dt_tm
      = cnvtdatetime(crr.end_dt_tm), temp_rec->person_list[person_idx].cr_rpt_req_list[cr_rpt_req_cnt
     ].new_end_dt_tm = cnvtdatetime(maxclinsig)
    FOOT REPORT
     stat = alterlist(temp_rec->person_list[person_idx].cr_rpt_req_list,cr_rpt_req_cnt)
    WITH nocounter, orahintcbo("USE_NL(CRR CE) LEADING(CRR CE)")
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while  selecting from cr_report_request - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   IF ((unique_encntrs->found_person_level=1))
    SELECT INTO "nl:"
     crr.report_request_id, crr.end_dt_tm, crr.dist_run_dt_tm
     FROM cr_report_request crr
     WHERE (crr.person_id=temp_rec->person_list[person_idx].person_id)
      AND crr.end_dt_tm > cnvtdatetime(tomorrow_dt_tm)
      AND crr.encntr_id=0.0
      AND crr.request_type_flag=distribution_request_type
     HEAD REPORT
      fake = 0
     HEAD crr.report_request_id
      cr_rpt_req_cnt = (cr_rpt_req_cnt+ 1)
      IF (cr_rpt_req_cnt > size(temp_rec->person_list[person_idx].cr_rpt_req_list,5))
       stat = alterlist(temp_rec->person_list[person_idx].cr_rpt_req_list,(cr_rpt_req_cnt+ 49))
      ENDIF
      temp_rec->person_list[person_idx].cr_rpt_req_list[cr_rpt_req_cnt].report_request_id = crr
      .report_request_id, temp_rec->person_list[person_idx].cr_rpt_req_list[cr_rpt_req_cnt].end_dt_tm
       = cnvtdatetime(crr.end_dt_tm), temp_rec->person_list[person_idx].cr_rpt_req_list[
      cr_rpt_req_cnt].new_end_dt_tm = crr.dist_run_dt_tm
     FOOT REPORT
      stat = alterlist(temp_rec->person_list[person_idx].cr_rpt_req_list,cr_rpt_req_cnt)
     WITH nocounter, orahintcbo("INDEX(CRR XIE3CR_REPORT_REQUEST")
    ;end select
    IF (error(errmsg,1))
     CALL echo(build("An error occured while  selecting from cr_report_request - ",errmsg))
     RETURN(status_ccl_error)
    ENDIF
   ENDIF
   IF (cr_rpt_req_cnt > 0)
    UPDATE  FROM cr_report_request crr,
      (dummyt d  WITH seq = value(cr_rpt_req_cnt))
     SET crr.end_dt_tm = cnvtdatetime(temp_rec->person_list[person_idx].cr_rpt_req_list[d.seq].
       new_end_dt_tm)
     PLAN (d)
      JOIN (crr
      WHERE (crr.report_request_id=temp_rec->person_list[person_idx].cr_rpt_req_list[d.seq].
      report_request_id))
     WITH nocounter
    ;end update
    IF (error(errmsg,1))
     CALL echo(build("An error occured while updating cr_report_request - ",errmsg))
     RETURN(status_ccl_error)
    ENDIF
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE fixcytoscreeningevent(null)
   UPDATE  FROM cyto_screening_event cse,
     (dummyt d  WITH seq = value(ce_cnt))
    SET cse.valid_from_dt_tm = cnvtdatetime(clin_event_list->new_valid_from_dt_tm), cse.updt_dt_tm =
     cnvtdatetime(today_dt_tm)
    PLAN (d
     WHERE (clin_event_list->fix_date_ind=1))
     JOIN (cse
     WHERE (cse.event_id=clin_event_list->event_id)
      AND cse.valid_from_dt_tm=cnvtdatetime(clin_event_list->valid_from_dt_tm))
    WITH nocounter
   ;end update
   IF (error(errmsg,1))
    CALL echo(build("An error occured while updating cyto_screening_event - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE writereportheader(null)
   SELECT INTO value(output_file_name)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     row + 1, col 109, curdate"MM/DD/YYYY;;D",
     col 120, curtime2"HH:MM:SS;;M", row + 2,
     CALL center(temp_captions->rpttitle,1,maxcol)
    WITH nocounter, maxcol = 132, compress
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while creating or writing to output file - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
 SUBROUTINE writechangesreport(null)
   SELECT INTO value(output_file_name)
    patient_name = notrim(substring(1,60,temp_rec->person_list[person_idx].person_name)), patient_id
     = temp_rec->person_list[person_idx].person_id, event_id = temp_rec->person_list[person_idx].
    ce_list[d.seq].event_id,
    clinical_event_id = temp_rec->person_list[person_idx].ce_list[d.seq].clinical_event_id,
    old_valid_from_dt_tm = format(temp_rec->person_list[person_idx].ce_list[d.seq].valid_from_dt_tm,
     "MM/DD/YYYY;;D"), old_valid_until_dt_tm = format(temp_rec->person_list[person_idx].ce_list[d.seq
     ].valid_until_dt_tm,"MM/DD/YYYY;;D"),
    old_clinsig_dt_tm = format(temp_rec->person_list[person_idx].ce_list[d.seq].clinsig_updt_dt_tm,
     "MM/DD/YYYY;;D"), old_updt_dt_tm = format(temp_rec->person_list[person_idx].ce_list[d.seq].
     updt_dt_tm,"MM/DD/YYYY;;D"), new_valid_from_dt_tm = format(temp_rec->person_list[person_idx].
     ce_list[d.seq].new_valid_from_dt_tm,"MM/DD/YYYY;;D"),
    new_valid_until_dt_tm = format(temp_rec->person_list[person_idx].ce_list[d.seq].
     new_valid_until_dt_tm,"MM/DD/YYYY;;D"), new_clinsig_dt_tm = format(temp_rec->person_list[
     person_idx].ce_list[d.seq].new_clinsig_updt_dt_tm,"MM/DD/YYYY;;D"), new_updt_dt_tm = format(
     cnvtdatetime(today_dt_tm),"MM/DD/YYYY;;D")
    FROM (dummyt d  WITH seq = value(ce_cnt))
    PLAN (d
     WHERE (temp_rec->person_list[person_idx].ce_list[d.seq].fix_date_ind=1))
    ORDER BY event_id, temp_rec->person_list[person_idx].ce_list[d.seq].event_seq DESC
    HEAD REPORT
     line1 = fillstring(127,"-"), row + 2, col 2,
     line1, row + 1, col 5,
     temp_captions->patientname, col 23, patient_name,
     col 85, temp_captions->patientid, col 92,
     patient_id"##########################;L", row + 1, col 2,
     line1, row + 1, col 17,
     temp_captions->clinical, col 32, temp_captions->oldvalid,
     col 44, temp_captions->newvalid, col 56,
     temp_captions->oldclinsig, col 69, temp_captions->newclinsig,
     col 82, temp_captions->oldupdt, col 94,
     temp_captions->newupdt, col 106, temp_captions->oldvalid,
     col 118, temp_captions->newvalid, row + 1,
     col 2, temp_captions->eventid, col 17,
     temp_captions->eventid, col 32, temp_captions->fromdate,
     col 44, temp_captions->fromdate, col 56,
     temp_captions->date, col 69, temp_captions->date,
     col 82, temp_captions->date, col 94,
     temp_captions->date, col 106, temp_captions->untildate,
     col 118, temp_captions->untildate, row + 1,
     col 2, "---------------", col 17,
     "---------------", col 32, "-----------",
     col 44, "-----------", col 56,
     "------------", col 69, "------------",
     col 82, "-----------", col 94,
     "-----------", col 106, "-----------",
     col 118, "-----------"
    HEAD event_id
     row + 1, col 2, event_id"##############;L"
    DETAIL
     row + 0, col 17, clinical_event_id"##############;L",
     col 32, old_valid_from_dt_tm, col 44,
     new_valid_from_dt_tm, col 56, old_clinsig_dt_tm,
     col 69, new_clinsig_dt_tm, col 82,
     old_updt_dt_tm, col 94, new_updt_dt_tm,
     col 106, old_valid_until_dt_tm, col 118,
     new_valid_until_dt_tm, row + 1
    FOOT REPORT
     row + 0, col 2, line1
    WITH nocounter, maxcol = 132, append,
     compress
   ;end select
   IF (error(errmsg,1))
    CALL echo(build("An error occured while writing to output file - ",errmsg))
    RETURN(status_ccl_error)
   ENDIF
   RETURN(status_success)
 END ;Subroutine
#exit_script
 FREE RECORD temp_rec
 FREE RECORD temp_captions
END GO
