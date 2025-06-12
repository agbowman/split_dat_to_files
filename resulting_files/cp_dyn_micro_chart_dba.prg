CREATE PROGRAM cp_dyn_micro_chart:dba
 FREE DEFINE rtl
 DECLARE person_level = i2 WITH constant(1), protect
 DECLARE encntr_level = i2 WITH constant(2), protect
 DECLARE order_level = i2 WITH constant(3), protect
 DECLARE accession_level = i2 WITH constant(4), protect
 DECLARE xencntr_level = i2 WITH constant(5), protect
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 SET numlines = 0
 IF ( NOT ((request->scope_flag IN (person_level, encntr_level, order_level, accession_level,
 xencntr_level))))
  CALL echo(build("Invalid Scope of",request->scope_flag))
  GO TO exit_script
 ENDIF
 FREE RECORD table_rec
 RECORD table_rec(
   1 qual[*]
     2 noofinterps = i2
     2 bugnames1 = i2
     2 sm[*]
       3 col = i2
       3 sus_test_cd = f8
       3 display_order = i4
 )
 FREE RECORD interp_data
 RECORD interp_data(
   1 qual[*]
     2 text_id = f8
     2 catalog_cd = f8
     2 report_text = vc
     2 event_id = f8
     2 valid_from_dt_tm = dq8
 )
 FREE RECORD report_data2
 RECORD report_data2(
   1 stain[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = vc
     2 rep_type = vc
   1 prelim[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = vc
     2 rep_type = vc
   1 final[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = vc
     2 rep_type = vc
   1 amend[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = vc
     2 rep_type = vc
   1 other[*]
     2 stain_name = vc
     2 report_text = vc
     2 report_type = i2
     2 report_seq = i2
     2 ver_name = vc
     2 ver_dt_time = vc
     2 rep_type = vc
 )
 FREE RECORD cor_data
 RECORD cor_data(
   1 qual[*]
     2 drug = c60
     2 data_type = c1
     2 old_interp_type = c30
     2 old_result = vc
     2 old_interp = vc
     2 old_v_dt_tm = dq8
     2 new_v_dt_tm = dq8
     2 corrected_date = dq8
     2 res_type = c12
     2 column = i4
     2 suscep_seq_nbr = i4
 )
 FREE RECORD foot_data
 RECORD foot_data(
   1 qual[*]
     2 qualx[*]
       3 drug = c60
       3 antibiotic_cd = f8
       3 ord2 = c8
     2 text = vc
     2 text_id = f8
     2 long_blob_id = f8
     2 index_num = i4
     2 printable_ind = i4
     2 drug_id = f8
 )
 FREE RECORD out_rec
 RECORD out_rec(
   1 outval = vc
 )
 FREE RECORD order_comment
 RECORD order_comment(
   1 qual[*]
     2 text_id = f8
     2 report_text = vc
     2 order_id = f8
     2 action_sequence = f8
 )
 FREE RECORD org_rec
 RECORD org_rec(
   1 qual[*]
     2 accession_nbr = c20
     2 bug_id = f8
     2 ord2 = c8
     2 bug_occur_num = i2
     2 bug_name = c60
     2 column = i2
     2 output_row = i2
     2 isdosagepres = i2
     2 istradenpres = i2
     2 iscostperdosepres = i2
     2 d_start = i2
     2 tn_start = i2
     2 cpd_start = i2
     2 det_sus_method[*]
       3 det_sus_cd = f8
       3 sus_test_cd = f8
       3 mdt_ttf = i4
       3 mt_ttf = i4
       3 display_order = i4
       3 col_start = i4
       3 col_end = i4
       3 col_underline = c60
       3 display = c60
 )
 FREE RECORD suscep_rec
 RECORD suscep_rec(
   1 drugresult[*]
     2 drug_name = c60
     2 drug_id = f8
     2 rel_cost_po = c15
     2 rel_cost_iv = c15
     2 cost_index = c10
     2 orgresult[*]
       3 bug_id = f8
       3 res_type = c10
       3 ord2 = c8
       3 bug_occur_num = i2
       3 column = i2
       3 notes[*]
         4 note_num = i4
       3 note_ind = i4
       3 suscep_result[*]
         4 det_suscep_cd = f8
         4 suscep_test_cd = f8
         4 result = vc
         4 suscep_seq_nbr = i4
         4 sus_type = vc
         4 mdt_ttf = i4
         4 mt_ttf = i4
         4 display_order = i4
         4 column = i4
         4 trade_name = vc
         4 cost_per_dose = c10
         4 dosage = c30
         4 cor_data[*]
           5 cor_dt_tm = vc
           5 ver_dt_tm = vc
           5 cor_result = c12
 )
 FREE RECORD pathogen_rec
 RECORD pathogen_rec(
   1 accession_list[*]
     2 accession_nbr = c20
     2 orders[*]
       3 order_id = f8
       3 pathogen_descr = vc
 )
 FREE RECORD reflab_rec
 RECORD reflab_rec(
   1 encntr_list[*]
     2 encntr_id = f8
     2 orders[*]
       3 catalog_cd_descr = vc
       3 verified_dt_tm = vc
       3 order_id = f8
       3 resource_cd_list[*]
         4 service_resource_cd = f8
       3 footnotes[*]
         4 ref_lab_description = vc
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
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE tempstr = vc
 DECLARE nordcommentflag = i2 WITH noconstant(0)
 DECLARE zone = c64
 DECLARE utcoffset = i4
 DECLARE daylight = i4
 DECLARE utc_on = i2
 SET utc_on = curutc
 DECLARE temp_v_date = vc
 DECLARE stnrpt = i2 WITH constant(1)
 DECLARE prelim = i2 WITH constant(2)
 DECLARE final = i2 WITH constant(3)
 DECLARE amend = i2 WITH constant(4)
 DECLARE otherrpt = i2 WITH constant(5)
 DECLARE ndosage_flag = i2 WITH constant(1)
 DECLARE ncost_flag = i2 WITH constant(2)
 DECLARE ntrade_flag = i2 WITH constant(3)
 DECLARE chart_ind = i2 WITH constant(1)
 DECLARE nochart_ind = i4 WITH noconstant(0)
 DECLARE nresultsize = i4 WITH noconstant(0)
 DECLARE nstainreports = i4 WITH noconstant(0)
 DECLARE nprelimreports = i4 WITH noconstant(0)
 DECLARE nfinalreports = i4 WITH noconstant(0)
 DECLARE namendedreports = i4 WITH noconstant(0)
 DECLARE notherreports = i4 WITH noconstant(0)
 DECLARE formatnumericvalue(p1=f8,p2=i2) = vc
 DECLARE resizewidthcolumn(p1=f8) = i4
 DECLARE validatecolumnwidth(p1=vc,p2=i2) = i4
 DECLARE settypeflag(p1=i4) = i4
 DECLARE ntypeflag = i4 WITH noconstant(0)
 DECLARE idx1 = i4
 DECLARE idx2 = i4 WITH noconstant(1)
 DECLARE temp_drug_id = f8 WITH noconstant(0.0), protect
 DECLARE wraptextforline(p1=vc,p2=i4) = i4
 SET x10 = char(10)
 SET x13 = char(13)
 SET x13_10 = concat(char(13),char(10))
 SET skips_to_make = 0
 SET ival = 0
 FREE RECORD wrapped_text
 RECORD wrapped_text(
   1 qual[*]
     2 line = vc
 )
 SUBROUTINE findearliesthardreturn(text_string)
   SET found_at_pos = 0
   FOR (c = 1 TO size(text_string))
     IF (substring(c,1,text_string)=x13)
      SET found_at_pos = c
      SET skips_to_make = 1
      IF (substring((c+ 1),1,text_string)=x10)
       SET skips_to_make = 2
      ENDIF
      SET c = (size(text_string)+ 1)
     ELSEIF (substring(c,1,text_string)=x10)
      SET found_at_pos = c
      SET skips_to_make = 1
      SET c = (size(text_string)+ 1)
     ENDIF
   ENDFOR
   RETURN(found_at_pos)
 END ;Subroutine
 SUBROUTINE wraptextforline(text_string,maxchars)
   SET stat = alterlist(wrapped_text->qual,0)
   SET line_cnt = 0
   SET string_size = size(trim(text_string,5))
   SET currentpos = 1
   SET complete = "F"
   SET temp_string = trim(text_string,5)
   SET hard_return = findearliesthardreturn(temp_string)
   IF (string_size <= maxchars
    AND hard_return=0)
    SET line_cnt = (line_cnt+ 1)
    SET stat = alterlist(wrapped_text->qual,line_cnt)
    SET wrapped_text->qual[line_cnt].line = temp_string
   ELSE
    SET exec_times = 0
    WHILE (complete="F")
     SET hard_return = findearliesthardreturn(temp_string)
     IF (hard_return <= maxchars
      AND hard_return > 0)
      SET line_cnt = (line_cnt+ 1)
      SET stat = alterlist(wrapped_text->qual,line_cnt)
      SET wrapped_text->qual[line_cnt].line = substring(currentpos,(hard_return - currentpos),
       temp_string)
      SET currentpos = (((hard_return - currentpos)+ skips_to_make)+ 1)
      SET temp_string = trim(substring(currentpos,((size(trim(temp_string,5)) - currentpos)+ 1),
        temp_string),5)
      SET currentpos = 1
     ELSE
      SET foundbreakchar = "F"
      SET mypos = minval(((currentpos+ maxchars) - 1),size(trim(temp_string,5)))
      IF (size(trim(temp_string,5)) <= maxchars
       AND hard_return=0)
       SET line_cnt = (line_cnt+ 1)
       SET stat = alterlist(wrapped_text->qual,line_cnt)
       SET wrapped_text->qual[line_cnt].line = temp_string
       SET complete = "T"
      ELSE
       WHILE (foundbreakchar="F"
        AND size(trim(temp_string,5)) > 0)
         IF (substring(mypos,1,temp_string) IN (" ", ",", ".", ":", ";"))
          SET foundbreakchar = "T"
          SET breakpos = mypos
          SET line_cnt = (line_cnt+ 1)
          SET stat = alterlist(wrapped_text->qual,line_cnt)
          SET wrapped_text->qual[line_cnt].line = substring(currentpos,((breakpos - currentpos)+ 1),
           temp_string)
          SET currentpos = (breakpos+ 1)
          SET temp_string = trim(substring(currentpos,((size(trim(temp_string,5)) - currentpos)+ 1),
            temp_string),5)
          SET currentpos = 1
         ELSE
          SET mypos = (mypos - 1)
         ENDIF
         IF (mypos < 1)
          SET line_cnt = (line_cnt+ 1)
          SET stat = alterlist(wrapped_text->qual,line_cnt)
          SET wrapped_text->qual[line_cnt].line = substring(currentpos,minval(((currentpos+ maxchars)
             - 1),size(trim(temp_string,5))),temp_string)
          SET currentpos = (minval(((currentpos+ maxchars) - 1),size(trim(temp_string,5)))+ 1)
          SET temp_string = trim(substring(currentpos,((size(trim(temp_string,5)) - currentpos)+ 1),
            temp_string),5)
          SET currentpos = 1
         ENDIF
         IF (size(trim(temp_string,5))=0)
          SET complete = "T"
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDWHILE
   ENDIF
   RETURN(size(wrapped_text->qual,5))
 END ;Subroutine
 SET noofopts = size(request->option_list,5)
 SET xkount = 0
 SET forceout = 0
 SET maxdrugsize = 10
 SET legendcharline1 = fillstring(100," ")
 SET legendcharline2 = fillstring(100," ")
 SET tmplegchar1 = fillstring(50," ")
 SET tmplegchar2 = fillstring(50," ")
 SET tmplegchar3 = fillstring(50," ")
 SET tmplegchar4 = fillstring(50," ")
 SET fontlbl = 48
 SET fontwidth = 73
 SET isfontsize8 = 0
 SET isdosagechartable = 0
 SET istradenchartable = 0
 SET max_no_of_orgs_horiz = 1
 SET corrected_char = "^"
 SET isisolateleft = 0
 SET iscostperdosechartable = 0
 SET iscorrectedresultsdisplayend = 1
 SET isbold = 0
 SET isisolateoneline = 0
 SET isa4 = 0
 SET suscmethoddisplay = 1
 SET verified_justification = 0
 SET legend_justification = 0
 SET underline_sus_headings = 0
 SET use_smart_captions = 0
 SET showprocedure = 1
 SET labelprocedure = fillstring(50," ")
 SET labelprocedure = uar_i18ngetmessage(i18nhandle,"RPTPPROC","PROCEDURE: ")
 SET showsource = 1
 SET labelsource = fillstring(50," ")
 SET labelsource = uar_i18ngetmessage(i18nhandle,"RPTSRC","SOURCE: ")
 SET showbodysite = 1
 SET labelbodysite = fillstring(50," ")
 SET labelbodysite = uar_i18ngetmessage(i18nhandle,"RPTBDTST","BODY SITE: ")
 SET showfreetext = 1
 SET labelfreetext = fillstring(50," ")
 SET labelfreetext = uar_i18ngetmessage(i18nhandle,"RPTFTSRC","FREE TEXT SOURCE: ")
 SET showsuspath = 0
 SET labelsuspath = fillstring(50," ")
 SET labelsuspath = ""
 SET showcollected = 1
 SET labelcollected = fillstring(50," ")
 SET labelcollected = uar_i18ngetmessage(i18nhandle,"RPTCOLL","COLLECTED: ")
 SET showstarted = 1
 SET labelstarted = fillstring(50," ")
 SET labelstarted = uar_i18ngetmessage(i18nhandle,"RPTSTRT","STARTED: ")
 SET showaccession = 1
 SET labelaccession = fillstring(50," ")
 SET labelaccession = uar_i18ngetmessage(i18nhandle,"RPTACC","ACCESSION: ")
 SET labelprelim = fillstring(50," ")
 SET labelprelim = uar_i18ngetmessage(i18nhandle,"RPTPRELIM","*** PRELIMINARY REPORT ***")
 SET labelfinal = fillstring(50," ")
 SET labelfinal = uar_i18ngetmessage(i18nhandle,"RPTFINAL","*** FINAL REPORT ***")
 SET labelamended = fillstring(50," ")
 SET labelamended = uar_i18ngetmessage(i18nhandle,"RPTAMND","*** AMENDED REPORT ***")
 SET labelstain = fillstring(50," ")
 SET labelstain = uar_i18ngetmessage(i18nhandle,"RPTSTAIN","*** STAINS / PREPARATIONS ***")
 SET labelglobal = fillstring(50," ")
 SET labelglobal = ""
 SET labelfootnotes = fillstring(50," ")
 SET labelfootnotes = uar_i18ngetmessage(i18nhandle,"RPTFOOTNT","*** FOOTNOTES ***")
 SET labelinterpresults = fillstring(50," ")
 SET labelinterpresults = uar_i18ngetmessage(i18nhandle,"RPTINTRP","Interpretive Results")
 SET labelordercomments = fillstring(50," ")
 SET labelordercomments = uar_i18ngetmessage(i18nhandle,"RPTORDCOM","*** ORDER COMMENTS ***")
 SET labelsuscresults = fillstring(50," ")
 SET labelsuscresults = uar_i18ngetmessage(i18nhandle,"RPTSUSCCOM","*** SUSCEPTIBILITY RESULTS ***")
 SET labeldosage = fillstring(50," ")
 SET labeldosage = uar_i18ngetmessage(i18nhandle,"RPTDOSAGE","DOSAGE")
 SET labelcost = fillstring(50," ")
 SET labelcost = uar_i18ngetmessage(i18nhandle,"RPTCOSTDOSAGE","COST/DOSE")
 SET labeltradename = fillstring(50," ")
 SET labeltradename = uar_i18ngetmessage(i18nhandle,"RPTTRDNAME","TRADE NAME")
 DECLARE formatted_date = vc WITH noconstant(" ")
 DECLARE date_format_cdf = vc
 DECLARE date_mask = vc WITH noconstant("MM/DD/YYYY;;D")
 DECLARE sdatemask_tz = vc WITH noconstant("MM/DD/YYYY;4;d")
 DECLARE time_mask = vc WITH noconstant("HH:MM;;M")
 DECLARE stimemask_tz = vc WITH noconstant("HH:MM;4;M")
 DECLARE interp_width = i4 WITH noconstant(11)
 DECLARE dilution_width = i4 WITH noconstant(14)
 DECLARE dosage_width = i4 WITH noconstant(20)
 DECLARE cost_per_dos_width = i4 WITH noconstant(10)
 DECLARE trade_name_width = i4 WITH noconstant(20)
 DECLARE long_legend = vc WITH noconstant(" ")
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE start_pos = i4 WITH noconstant(0)
 DECLARE font10labela4 = i4 WITH constant(40)
 DECLARE font10widtha4 = i4 WITH constant(75)
 DECLARE font8lablela4 = i4 WITH constant(70)
 DECLARE font8widtha4 = i4 WITH constant(100)
 DECLARE font10label = i4 WITH constant(48)
 DECLARE font10width = i4 WITH constant(73)
 DECLARE font8label = i4 WITH constant(70)
 DECLARE font8width = i4 WITH constant(105)
 DECLARE sort_accession_flag = i2 WITH noconstant(0)
 DECLARE report_option = i2 WITH noconstant(0)
 DECLARE curresult = i2 WITH constant(0)
 DECLARE curprefinadd = i2 WITH constant(1)
 DECLARE allresults = i2 WITH constant(2)
 DECLARE allfinadd = i2 WITH constant(3)
 SET showreceived = 0
 SET labelreceived = fillstring(50," ")
 SET labelreceived = uar_i18ngetmessage(i18nhandle,"RPTRECV","RECEIVED: ")
 WHILE (xkount < noofopts)
  SET xkount = (xkount+ 1)
  CASE (request->option_list[xkount].option_flag)
   OF 2:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET isfontsize8 = 0
    ELSE
     SET isfontsize8 = 1
    ENDIF
   OF 3:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET isdosagechartable = 1
    ELSE
     SET isdosagechartable = 0
    ENDIF
   OF 4:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET istradenchartable = 1
    ELSE
     SET istradenchartable = 0
    ENDIF
   OF 5:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET max_no_of_orgs_horiz = 1
    ELSEIF (optv=2)
     SET max_no_of_orgs_horiz = 2
    ELSE
     SET max_no_of_orgs_horiz = 3
    ENDIF
   OF 6:
    SET corrected_char = concat(request->option_list[xkount].option_value)
   OF 7:
    SET tmplegchar1 = concat(request->option_list[xkount].option_value)
   OF 8:
    SET tmplegchar2 = concat(request->option_list[xkount].option_value)
   OF 9:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET isisolatecenter = 0
     SET isisolateleft = 1
     SET max_no_of_orgs_horiz = 1
    ELSE
     SET isisolateleft = 0
     SET isisolatecenter = 1
    ENDIF
   OF 10:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET iscostperdosechartable = 1
    ELSE
     SET iscostperdosechartable = 0
    ENDIF
   OF 11:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET iscorrectedresultsdisplayend = 1
    ELSE
     SET iscorrectedresultsdisplayend = 0
    ENDIF
   OF 12:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET isbold = 1
    ELSE
     SET isbold = 0
    ENDIF
   OF 13:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=0)
     SET isisolateoneline = 1
    ELSE
     SET isisolateoneline = 0
    ENDIF
   OF 14:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=1)
     SET isa4 = 1
    ELSE
     SET isa4 = 0
    ENDIF
   OF 15:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    SET suscmethoddisplay = optv
   OF 16:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    SET verified_justification = optv
   OF 17:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    SET legend_justification = optv
   OF 18:
    SET tmplegchar3 = concat(request->option_list[xkount].option_value)
   OF 19:
    SET tmplegchar4 = concat(request->option_list[xkount].option_value)
   OF 20:
    SET underline_sus_headings = cnvtint(request->option_list[xkount].option_value)
   OF 21:
    SET use_smart_captions = cnvtint(request->option_list[xkount].option_value)
   OF 22:
    SET showprocedure = cnvtint(request->option_list[xkount].option_value)
   OF 23:
    SET labelprocedure = concat(request->option_list[xkount].option_value)
   OF 24:
    SET showsource = cnvtint(request->option_list[xkount].option_value)
   OF 25:
    SET labelsource = concat(request->option_list[xkount].option_value)
   OF 26:
    SET showbodysite = cnvtint(request->option_list[xkount].option_value)
   OF 27:
    SET labelbodysite = concat(request->option_list[xkount].option_value)
   OF 28:
    SET showfreetext = cnvtint(request->option_list[xkount].option_value)
   OF 29:
    SET labelfreetext = concat(request->option_list[xkount].option_value)
   OF 30:
    SET showsuspath = cnvtint(request->option_list[xkount].option_value)
   OF 31:
    SET labelsuspath = concat(request->option_list[xkount].option_value)
   OF 32:
    SET showcollected = cnvtint(request->option_list[xkount].option_value)
   OF 33:
    SET labelcollected = concat(request->option_list[xkount].option_value)
   OF 34:
    SET showstarted = cnvtint(request->option_list[xkount].option_value)
   OF 35:
    SET labelstarted = concat(request->option_list[xkount].option_value)
   OF 36:
    SET showaccession = cnvtint(request->option_list[xkount].option_value)
   OF 37:
    SET labelaccession = concat(request->option_list[xkount].option_value)
   OF 38:
    SET labelprelim = concat(request->option_list[xkount].option_value)
   OF 39:
    SET labelfinal = concat(request->option_list[xkount].option_value)
   OF 40:
    SET labelamended = concat(request->option_list[xkount].option_value)
   OF 41:
    SET labelstain = concat(request->option_list[xkount].option_value)
   OF 42:
    SET labelglobal = concat(request->option_list[xkount].option_value)
   OF 43:
    SET labelfootnotes = concat(request->option_list[xkount].option_value)
   OF 44:
    SET labelinterpresults = concat(request->option_list[xkount].option_value)
   OF 45:
    SET labelordercomments = concat(request->option_list[xkount].option_value)
   OF 46:
    SET labelsuscresults = concat(request->option_list[xkount].option_value)
   OF 47:
    SET labeldosage = concat(request->option_list[xkount].option_value)
   OF 48:
    SET labelcost = concat(request->option_list[xkount].option_value)
   OF 49:
    SET labeltradename = concat(request->option_list[xkount].option_value)
   OF 50:
    SET date_format_cdf = request->option_list[xkount].option_value
    CASE (date_format_cdf)
     OF "MMDDYYYY":
      SET date_mask = "mm/dd/yyyy;;d"
      SET sdatemask_tz = "mm/dd/yyyy;4;d"
     OF "MMDDYY":
      SET date_mask = "mm/dd/yy;;d"
      SET sdatemask_tz = "mm/dd/yy;4;d"
     OF "YYYYMMDD":
      SET date_mask = "yyyy/mm/dd;;d"
      SET sdatemask_tz = "yyyy/mm/dd;4;d"
     OF "YYMMDD":
      SET date_mask = "yy/mm/dd;;d"
      SET sdatemask_tz = "yy/mm/dd;4;d"
     OF "LONGDATE":
      SET date_mask = "@LONGDATE"
      SET sdatemask_tz = "@LONGDATE;4;q"
     OF "SHORTDATE":
      SET date_mask = "@SHORTDATE"
      SET sdatemask_tz = "@SHORTDATE;4;q"
    ENDCASE
   OF 51:
    SET optv = cnvtint(request->option_list[xkount].option_value)
    IF (optv=0)
     SET time_mask = "hh:mm;;M"
     SET stimemask_tz = "hh:mm;4;M"
    ELSE
     SET time_mask = "hh:mm;;S"
     SET stimemask_tz = "hh:mm;4;S"
    ENDIF
   OF 52:
    SET interp_width = cnvtint(request->option_list[xkount].option_value)
   OF 53:
    SET dilution_width = cnvtint(request->option_list[xkount].option_value)
   OF 54:
    SET dosage_width = cnvtint(request->option_list[xkount].option_value)
   OF 55:
    SET cost_per_dos_width = cnvtint(request->option_list[xkount].option_value)
   OF 56:
    SET trade_name_width = cnvtint(request->option_list[xkount].option_value)
   OF 57:
    SET long_legend = request->option_list[xkount].option_value
   OF 58:
    SET sort_accession_flag = cnvtint(request->option_list[xkount].option_value)
   OF 59:
    SET report_option = cnvtint(request->option_list[xkount].option_value)
   OF 60:
    SET showreceived = cnvtint(request->option_list[xkount].option_value)
   OF 61:
    SET labelreceived = concat(request->option_list[xkount].option_value)
  ENDCASE
 ENDWHILE
 IF (isbold=1)
  SET boldchars = "{B}"
 ELSE
  SET boldchars = ""
 ENDIF
 IF (isisolateleft=1)
  IF (max_no_of_orgs_horiz > 1)
   SET isisolateleft = 0
  ENDIF
 ENDIF
 IF (isa4=1)
  IF (isfontsize8=0)
   SET fontlbl = font10labela4
   SET fontwidth = font10widtha4
  ELSE
   SET fontlbl = font8lablela4
   SET fontwidth = font8widtha4
  ENDIF
 ELSE
  IF (isfontsize8=0)
   SET fontlbl = font10label
   SET fontwidth = font10width
  ELSE
   SET fontlbl = font8label
   SET fontwidth = font8width
  ENDIF
 ENDIF
 CALL echo(build("FONTLBL is = ",fontlbl))
 CALL echo(build("max_no_of_orgs_horiz = ",max_no_of_orgs_horiz))
 SET legendcharline1 = concat(trim(tmplegchar1),trim(tmplegchar2))
 SET legendcharline2 = concat(trim(tmplegchar3),trim(tmplegchar4))
 DECLARE comment_type_cd = f8
 DECLARE n_type = f8
 DECLARE vernum = f8
 DECLARE cornum = f8
 DECLARE auth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE unauth_cd = f8
 DECLARE deleted_cd = f8
 DECLARE dmbocd = f8
 DECLARE ddoccd = f8
 DECLARE dpowerchartcd = f8
 DECLARE interp_cd = f8
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,comment_type_cd)
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,n_type)
 SET stat = uar_get_meaning_by_codeset(1901,"VERIFIED",1,vernum)
 SET stat = uar_get_meaning_by_codeset(1901,"CORRECTED",1,cornum)
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,deleted_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MBO",1,dmbocd)
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,ddoccd)
 SET stat = uar_get_meaning_by_codeset(89,"POWERCHART",1,dpowerchartcd)
 SET stat = uar_get_meaning_by_codeset(14,"INTERPDATA",1,interp_cd)
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 SET numevents = size(request->code_list,5)
 SET xkount = 0
 SET ykount = 0
 SET zkount = 0
 SET colum_start = 0
 DECLARE locres = vc
 DECLARE locres_dosage = vc
 DECLARE locres_cpd = vc
 DECLARE locres_tn = vc
 SET printed_global_report_header = "f"
 IF ((request->start_dt_tm > 0))
  SET s_date = cnvtdatetime(request->start_dt_tm)
 ELSE
  SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
 ENDIF
 IF ((request->end_dt_tm > 0))
  SET e_date = cnvtdatetime(request->end_dt_tm)
 ELSE
  SET e_date = cnvtdatetime("31-dec-2100 00:00:00.00")
 ENDIF
 SET v_until_dt_tm = cnvtdatetime("31-dec-2100")
 DECLARE ce_date_clause = vc
 IF ((request->request_type=2)
  AND (request->mcis_ind=0))
  SET ce_date_clause = " (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
  IF ((request->pending_flag=1))
   SET ce_date_clause = concat(ce_date_clause,
    " or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)")
  ELSEIF ((request->pending_flag=2))
   SET ce_date_clause = concat(ce_date_clause,
    " or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)")
   SET ce_date_clause = concat(ce_date_clause,
    " or ce.event_end_dt_tm between cnvtdatetime(s_date) and  cnvtdatetime(e_date)")
  ENDIF
 ELSE
  IF ((request->result_lookup_ind=1))
   SET ce_date_clause = " (ce.event_end_dt_tm+0"
  ELSE
   SET ce_date_clause = " (ce.clinsig_updt_dt_tm+0"
  ENDIF
  SET ce_date_clause = concat(ce_date_clause,
   " between cnvtdatetime(s_date) and cnvtdatetime(e_date))")
 ENDIF
 CALL echo(build("ce_date_clause = ",ce_date_clause))
 DECLARE ce_status_clause = vc
 DECLARE ce_verified_status_clause = vc
 IF ((request->pending_flag=0))
  SET ce_status_clause = " (ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd)"
 ELSEIF ((request->pending_flag=1))
  SET ce_status_clause =
  " (ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
 ELSE
  SET ce_status_clause = concat(
   " (ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd,",
   " inprog_cd, trans_cd, unauth_cd)")
 ENDIF
 SET ce_status_clause = concat(ce_status_clause," and ce.contributor_system_cd != dPowerchartCd",
  " and ce.record_status_cd != deleted_cd)")
 SET ce_verified_status_clause = "(ce.contributor_system_cd = dPowerchartCd"
 SET ce_verified_status_clause = concat(ce_verified_status_clause,
  " and ce.result_status_cd in (auth_cd, mod_cd,",
  "super_cd, alt_cd, inlab_cd,inprog_cd, trans_cd, unauth_cd)")
 SET ce_verified_status_clause = concat(ce_verified_status_clause,
  " and ce.record_status_cd != deleted_cd)")
 SET ce_status_clause = concat(ce_status_clause," OR ",ce_verified_status_clause)
 CALL echo(build("ce_status_clause = ",ce_status_clause))
 SET numqual = 0
 SET with_add = " counter"
 FREE SELECT cp_mic_1
 FREE SELECT cp_mic_2
 SELECT
  IF ((request->scope_flag=person_level))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    clinical_event ce2,
    code_value_event_r cva,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd=e.event_cd
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cva
    WHERE cva.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cva.parent_cd)
  ELSEIF ((request->scope_flag=encntr_level))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    clinical_event ce2,
    code_value_event_r cva,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (e.event_set_cd=request->code_list[d.seq].code))
    JOIN (ce
    WHERE ((ce.encntr_id+ 0)=request->encntr_id)
     AND (ce.person_id=request->person_id)
     AND ce.event_cd=e.event_cd
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cva
    WHERE cva.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cva.parent_cd)
  ELSEIF ((request->scope_flag=order_level))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    clinical_event ce2,
    code_value_event_r cva,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (e.event_set_cd=request->code_list[d.seq].code))
    JOIN (ce
    WHERE ce.order_id IN (
    (SELECT
     order_id
     FROM chart_request_order
     WHERE (chart_request_id=request->chart_request_id)))
     AND ((ce.person_id+ 0)=request->person_id)
     AND ((ce.encntr_id+ 0)=request->encntr_id)
     AND ce.event_cd=e.event_cd
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cva
    WHERE cva.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cva.parent_cd)
  ELSEIF ((request->scope_flag=accession_level))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce2,
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cva,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (request->code_list[d.seq].code=e.event_set_cd))
    JOIN (ce
    WHERE (ce.accession_nbr=request->accession_nbr)
     AND ce.event_cd=e.event_cd
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cva
    WHERE cva.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cva.parent_cd)
  ELSEIF ((request->scope_flag=xencntr_level))
   FROM v500_event_set_explode e,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    clinical_event ce2,
    code_value_event_r cva,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=0))
    JOIN (e
    WHERE (e.event_set_cd=request->code_list[d.seq].code))
    JOIN (ce
    WHERE ((ce.encntr_id+ 0) IN (
    (SELECT
     encntr_id
     FROM chart_request_encntr
     WHERE (chart_request_id=request->chart_request_id))))
     AND (ce.person_id=request->person_id)
     AND ce.event_cd=e.event_cd
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cva
    WHERE cva.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cva.parent_cd)
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_mic_1
  ce2.clinical_event_id, display = decode(mt.seq,uar_get_code_display(mt.task_assay_cd)," "),
  catalog_cd =
  IF (ce2.catalog_cd > 0) ce2.catalog_cd
  ELSE ce.event_cd
  ENDIF
  ,
  ce2.order_id, ce2.verified_dt_tm, verified_tz = validate(ce2.verified_tz,0),
  ce.event_start_dt_tm, event_start_tz = validate(ce.event_start_tz,0), ce2.valid_from_dt_tm,
  ce2.verified_prsnl_id, stain_type = uar_get_code_description(mt.task_assay_cd), has_interp = btest(
   ce2.subtable_bit_map,1),
  text_order =
  IF (btest(ce2.subtable_bit_map,1)=1) otherrpt
  ELSEIF ( NOT (mt.task_type_flag IN (8, 9, 10))) stnrpt
  ELSEIF (mt.task_type_flag=8) prelim
  ELSEIF (mt.task_type_flag=9) final
  ELSEIF (mt.task_type_flag=10) amend
  ELSE 0
  ENDIF
  , ce2.event_cd, ce2.event_class_cd,
  accession_nbr =
  IF (size(trim(ce2.accession_nbr)) > 0) ce2.accession_nbr
  ELSE concat("##",format(ce2.parent_event_id,"##################;rp0"))
  ENDIF
  , ce2.event_id, ce2.parent_event_id,
  side =
  IF (btest(ce2.subtable_bit_map,9)=1) 0
  ELSEIF (btest(ce2.subtable_bit_map,17)=1) 1
  ELSE 2
  ENDIF
  , blob_entry = decode(ce2.seq,btest(ce2.subtable_bit_map,9),0), sus_entry = btest(ce2
   .subtable_bit_map,17),
  ce2.person_id, ce2.encntr_id, child_resource_cd = ce2.resource_cd,
  parent_resource_cd = ce.resource_cd, ce.contributor_system_cd
  ORDER BY accession_nbr, ce2.parent_event_id, side,
   text_order, ce2.clinical_event_id, ce2.verified_dt_tm
  WITH organization = work, outerjoin = d2, parser(with_add)
 ;end select
 SET numqual = (numqual+ curqual)
 IF (numqual > 0)
  SET with_add = " append"
 ELSE
  SET with_add = " counter"
 ENDIF
 SELECT
  IF ((request->scope_flag=person_level))
   FROM clinical_event ce,
    clinical_event ce2,
    (dummyt d  WITH seq = value(numevents)),
    (dummyt d2  WITH seq = 1),
    code_value_event_r cve_r,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (ce.person_id=request->person_id)
     AND (ce.catalog_cd=request->code_list[d.seq].code)
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cve_r
    WHERE cve_r.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cve_r.parent_cd)
  ELSEIF ((request->scope_flag=encntr_level))
   FROM clinical_event ce,
    clinical_event ce2,
    (dummyt d  WITH seq = value(numevents)),
    (dummyt d2  WITH seq = 1),
    code_value_event_r cve_r,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE ((ce.encntr_id+ 0)=request->encntr_id)
     AND (ce.person_id=request->person_id)
     AND (ce.catalog_cd=request->code_list[d.seq].code)
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cve_r
    WHERE cve_r.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cve_r.parent_cd)
  ELSEIF ((request->scope_flag=order_level))
   FROM clinical_event ce,
    clinical_event ce2,
    (dummyt d  WITH seq = value(numevents)),
    (dummyt d2  WITH seq = 1),
    code_value_event_r cve_r,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE ce.order_id IN (
    (SELECT
     order_id
     FROM chart_request_order
     WHERE (chart_request_id=request->chart_request_id)))
     AND ((ce.person_id+ 0)=request->person_id)
     AND ((ce.encntr_id+ 0)=request->encntr_id)
     AND (ce.catalog_cd=request->code_list[d.seq].code)
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cve_r
    WHERE cve_r.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cve_r.parent_cd)
  ELSEIF ((request->scope_flag=accession_level))
   FROM clinical_event ce2,
    (dummyt d  WITH seq = value(numevents)),
    clinical_event ce,
    (dummyt d2  WITH seq = 1),
    code_value_event_r cve_r,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE (ce.accession_nbr=request->accession_nbr)
     AND (ce.catalog_cd=request->code_list[d.seq].code)
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cve_r
    WHERE cve_r.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cve_r.parent_cd)
  ELSEIF ((request->scope_flag=xencntr_level))
   FROM clinical_event ce,
    clinical_event ce2,
    (dummyt d  WITH seq = value(numevents)),
    (dummyt d2  WITH seq = 1),
    code_value_event_r cve_r,
    mic_task mt
   PLAN (d
    WHERE (request->code_list[d.seq].procedure_type_flag=1))
    JOIN (ce
    WHERE ((ce.encntr_id+ 0) IN (
    (SELECT
     encntr_id
     FROM chart_request_encntr
     WHERE (chart_request_id=request->chart_request_id))))
     AND (ce.person_id=request->person_id)
     AND (ce.catalog_cd=request->code_list[d.seq].code)
     AND ce.event_class_cd=dmbocd
     AND parser(ce_date_clause)
     AND parser(ce_status_clause))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce.event_id
     AND ce2.publish_flag > 0
     AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce2.event_class_cd != placehold_class_cd)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (cve_r
    WHERE cve_r.event_cd=ce2.event_cd)
    JOIN (mt
    WHERE mt.task_assay_cd=cve_r.parent_cd)
  ELSE
  ENDIF
  DISTINCT INTO TABLE cp_mic_1
  ce2.clinical_event_id, display = decode(mt.seq,uar_get_code_display(mt.task_assay_cd)," "),
  catalog_cd =
  IF (ce2.catalog_cd > 0) ce2.catalog_cd
  ELSE ce.event_cd
  ENDIF
  ,
  ce2.order_id, ce2.verified_dt_tm, verified_tz = validate(ce2.verified_tz,0),
  ce.event_start_dt_tm, event_start_tz = validate(ce.event_start_tz,0), ce2.valid_from_dt_tm,
  ce2.verified_prsnl_id, stain_type = uar_get_code_description(mt.task_assay_cd), has_interp = btest(
   ce2.subtable_bit_map,1),
  text_order =
  IF (btest(ce2.subtable_bit_map,1)=1) otherrpt
  ELSEIF ( NOT (mt.task_type_flag IN (8, 9, 10))) stnrpt
  ELSEIF (mt.task_type_flag=8) prelim
  ELSEIF (mt.task_type_flag=9) final
  ELSEIF (mt.task_type_flag IN (10)) amend
  ELSE 0
  ENDIF
  , ce2.event_cd, ce2.event_class_cd,
  accession_nbr =
  IF (size(trim(ce2.accession_nbr)) > 0) ce2.accession_nbr
  ELSE concat("##",format(ce2.parent_event_id,"##################;rp0"))
  ENDIF
  , ce2.event_id, ce2.parent_event_id,
  side =
  IF (btest(ce2.subtable_bit_map,9)=1) 0
  ELSEIF (btest(ce2.subtable_bit_map,17)=1) 1
  ELSE 2
  ENDIF
  , blob_entry = decode(ce2.seq,btest(ce2.subtable_bit_map,9),0), sus_entry = btest(ce2
   .subtable_bit_map,17),
  ce2.person_id, ce2.encntr_id, child_resource_cd = ce2.resource_cd,
  parent_resource_cd = ce.resource_cd, ce.contributor_system_cd
  ORDER BY accession_nbr, ce2.parent_event_id, side,
   text_order, ce2.clinical_event_id, ce2.verified_dt_tm
  WITH organization = work, outerjoin = d2, parser(with_add)
 ;end select
 SET numqual = (numqual+ curqual)
 IF (numqual > 0)
  SELECT
   *
   FROM cp_mic_1
   WITH nocounter
  ;end select
  SET with_add = " counter"
  SELECT
   IF (sort_accession_flag=0)
    ORDER BY longacc, e.parent_event_id, sort_accession_nbr,
     ce_mic1.micro_seq_nbr, ce_mic1.organism_occurrence_nbr, sort_drug,
     sort_drugtest, result_dt_tm DESC, status,
     corrected_date DESC
   ELSE
    ORDER BY longacc DESC, e.parent_event_id, sort_accession_nbr,
     ce_mic1.micro_seq_nbr, ce_mic1.organism_occurrence_nbr, sort_drug,
     sort_drugtest, result_dt_tm DESC, status,
     corrected_date DESC
   ENDIF
   DISTINCT INTO TABLE cp_mic_2
   e.encntr_id, ce_sus1.chartable_flag, e.has_interp,
   old_chartable_flag = decode(ce_sus2.seq,ce_sus2.chartable_flag,ce_sus3.seq,ce_sus3.chartable_flag,
    ce_sus4.seq,
    ce_sus4.chartable_flag,ce_sus1.chartable_flag), ce_sus1.susceptibility_status_cd, ce_mic1
   .micro_seq_nbr,
   ce_sus1.suscep_seq_nbr, ce_sus2.suscep_seq_nbr, ce_sus3.suscep_seq_nbr,
   ce_sus4.suscep_seq_nbr, b.compression_cd, blob_id = decode(b.seq,cnvtreal(b.event_id),0.0),
   b.valid_until_dt_tm, b.blob_seq_num, e.event_cd,
   e.event_class_cd, e.event_id, e.parent_event_id,
   e.blob_entry, e.verified_dt_tm, verified_tz = validate(e.verified_tz,0),
   stain = e.display, e.order_id, text_order =
   IF (e.has_interp=1) otherrpt
   ELSE e.text_order
   ENDIF
   ,
   longacc = e.accession_nbr, sort_accession_nbr =
   IF (e.has_interp=1) concat(format(e.catalog_cd,"###########;rp0"),format(e.side,"#####;rp0"),
     format(5,"#####;rp0"),
     IF (e.text_order=0
      AND e.blob_entry=1) substring(1,30,uar_get_code_display(e.event_cd))
     ELSE e.stain_type
     ENDIF
     )
   ELSE concat(format(e.catalog_cd,"###########;rp0"),format(e.side,"#####;rp0"),format(e.text_order,
      "#####;rp0"),
     IF (e.text_order=0
      AND e.blob_entry=1) substring(1,30,uar_get_code_display(e.event_cd))
     ELSE e.stain_type
     ENDIF
     )
   ENDIF
   , ord0 =
   IF (e.has_interp=1) concat(format(e.side,"#####;rp0"),format(5,"#####;rp0"),e.stain_type)
   ELSE concat(format(e.side,"#####;rp0"),format(e.text_order,"#####;rp0"),e.stain_type)
   ENDIF
   ,
   e.side, e.sus_entry, e.valid_from_dt_tm,
   e.clinical_event_id, e.verified_prsnl_id, e.catalog_cd,
   text_type = e.stain_type, o1 = decode(dt3.seq,cnvtreal(e.event_cd)), display = trim(
    uar_get_code_display(ce_sus1.detail_susceptibility_cd)),
   susc_method_desc = trim(uar_get_code_description(ce_sus1.detail_susceptibility_cd)), body_site_cd
    = decode(ce_spc.seq,ce_spc.body_site_cd,0.0), ce_sus1.suscep_seq_nbr,
   status = decode(ce_sus2.seq,"C",ce_sus3.seq,"C",ce_sus4.seq,
    "C","V"), sort_status = decode(ce_sus2.seq,ichar("C"),ce_sus3.seq,ichar("C"),ce_sus4.seq,
    ichar("C"),ichar("V")), res_type =
   IF (mdt.task_type_flag=14) "RESULT"
   ELSEIF (mdt.task_type_flag=7) "INTERP"
   ELSE "ZZZZZZ"
   ENDIF
   ,
   source_cd = decode(ce_spc.seq,ce_spc.source_type_cd,0.0), cpd = decode(trade.seq,cnvtreal(trim(
      trade.cost_per_dose,3)),0.0), cor_type = decode(ce_sus2.seq,"I",ce_sus3.seq,"R",ce_sus4.seq,
    "K","X"),
   old_result = decode(cv2.seq,cv2.display," "), old_interp = decode(cv1.seq,cv1.display," "),
   old_zone =
   IF (ce_sus4.result_numeric_value > 0) ce_sus4.result_numeric_value
   ELSE cnvtreal(ce_sus4.result_text_value)
   ENDIF
   ,
   interp = substring(1,9,uar_get_code_display(ce_sus1.result_cd)), ce_sus1.antibiotic_cd,
   result_dt_tm = decode(ce_sus1.seq,ce_sus1.result_dt_tm,e.verified_dt_tm),
   result_tz = decode(ce_sus1.seq,validate(ce_sus1.result_tz,0),e.verified_tz), corrected_date =
   decode(ce_sus2.seq,cnvtdatetime(ce_sus2.result_dt_tm),ce_sus3.seq,cnvtdatetime(ce_sus3
     .result_dt_tm),ce_sus4.seq,
    cnvtdatetime(ce_sus4.result_dt_tm),cnvtdatetime("01-jan-1800 00:00:00.00")), corrected_tz =
   decode(ce_sus2.seq,validate(ce_sus2.result_tz,0),ce_sus3.seq,validate(ce_sus3.result_tz,0),ce_sus4
    .seq,
    validate(ce_sus4.result_tz,0)),
   ce_mic1.organism_occurrence_nbr, ce_sus1.result_numeric_value, typeflag = settypeflag(mdt
    .task_type_flag),
   columnwidth =
   IF (ce_sus1.result_cd > 0
    AND ce_sus1.chartable_flag=chart_ind) resizewidthcolumn(ce_sus1.result_cd)
   ELSE nochart_ind
   ENDIF
   , result =
   IF (ce_sus1.result_cd > 0) substring(1,20,uar_get_code_display(ce_sus1.result_cd))
   ELSEIF (ce_sus1.result_numeric_value > 0) formatnumericvalue(ce_sus1.result_numeric_value,ce_sus1
     .chartable_flag)
   ELSE trim(substring(1,20,ce_sus1.result_text_value),3)
   ENDIF
   , ord2 = concat(format(ce_mic1.micro_seq_nbr,"####;rp0"),format(ce_mic1.organism_occurrence_nbr,
     "####;rp0")),
   bug = substring(1,60,trim(uar_get_code_description(ce_mic1.organism_cd))), drug = substring(1,60,
    uar_get_code_description(ce_sus1.antibiotic_cd)), sort_drug = trim(cnvtupper(uar_get_code_display
     (ce_sus1.antibiotic_cd)),4),
   drugtest = concat(trim(cnvtupper(uar_get_code_display(ce_sus1.antibiotic_cd)),4),
    uar_get_code_display(ce_sus1.detail_susceptibility_cd)), sort_drugtest = concat(trim(cnvtupper(
      uar_get_code_display(ce_sus1.antibiotic_cd)),4),uar_get_code_display(ce_sus1
     .detail_susceptibility_cd)), ce_mic1.organism_cd,
   e.event_start_dt_tm, culture_start_tz = e.event_start_tz, specimen_src_text = substring(1,255,
    ce_spc.source_text),
   ce_spc.collect_dt_tm, drawn_tz = validate(ce_spc.collect_tz,0), has_trade = decode(trade.seq,1,0),
   task_assay_cd = ce_sus1.susceptibility_test_cd, mt_ttf = mt.task_type_flag, task_component_cd =
   ce_sus1.detail_susceptibility_cd,
   mdt_ttf = mdt.task_type_flag, display_order = decode(mtd_r.seq,mtd_r.display_order,ce_sus1
    .suscep_seq_nbr), trade_width =
   IF (ce_sus1.chartable_flag=chart_ind) validatecolumnwidth(trade.trade_name,ntrade_flag)
   ELSE nochart_ind
   ENDIF
   ,
   trade.trade_name, cost_width =
   IF (ce_sus1.chartable_flag=chart_ind) validatecolumnwidth(trade.cost_per_dose,ncost_flag)
   ELSE nochart_ind
   ENDIF
   , trade.cost_per_dose,
   dosage2_width =
   IF (ce_sus1.chartable_flag=chart_ind) validatecolumnwidth(trade.dosage,ndosage_flag)
   ELSE nochart_ind
   ENDIF
   , trade.dosage, trade.chart_ind,
   service_resource_cd_child =
   IF (e.child_resource_cd != 0) e.child_resource_cd
   ELSE osrc.service_resource_cd
   ENDIF
   , service_resource_cd_parent =
   IF (e.parent_resource_cd != 0) e.parent_resource_cd
   ELSE osrc.service_resource_cd
   ENDIF
   , e.contributor_system_cd,
   ce_spc.recvd_dt_tm, ce_spc.recvd_tz
   FROM cp_mic_1 e,
    ce_specimen_coll ce_spc,
    (dummyt dt1  WITH seq = 1),
    (dummyt dt2  WITH seq = 1),
    ce_blob_result br,
    ce_blob b,
    (dummyt dt3  WITH seq = 1),
    ce_microbiology ce_mic1,
    ce_susceptibility ce_sus1,
    (dummyt dt7  WITH seq = 1),
    mic_med_trade_name trade,
    (dummyt dt8  WITH seq = 1),
    (dummyt dt9  WITH seq = 1),
    ce_susceptibility ce_sus2,
    code_value cv1,
    (dummyt dt10  WITH seq = 1),
    ce_susceptibility ce_sus3,
    ce_susceptibility ce_sus4,
    code_value cv2,
    (dummyt dt4  WITH seq = 1),
    mic_task mt,
    (dummyt dt5  WITH seq = 1),
    mic_detail_task mdt,
    (dummyt dt6  WITH seq = 1),
    mic_task_detail_r mtd_r,
    order_serv_res_container osrc
   PLAN (e
    WHERE ((e.sus_entry > 0) OR (((e.blob_entry > 0) OR (e.has_interp > 0)) )) )
    JOIN (dt1
    WHERE dt1.seq=1)
    JOIN (ce_spc
    WHERE ce_spc.event_id=e.parent_event_id
     AND ce_spc.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100"))
    JOIN (osrc
    WHERE osrc.order_id=outerjoin(e.order_id)
     AND osrc.container_id=outerjoin(ce_spc.container_id))
    JOIN (((dt2)
    JOIN (br
    WHERE br.event_id=e.event_id
     AND e.blob_entry=1
     AND br.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE b.event_id=br.event_id
     AND b.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
    ) ORJOIN ((dt3)
    JOIN (ce_mic1
    WHERE ce_mic1.event_id=e.event_id
     AND ce_mic1.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
     AND e.sus_entry=1)
    JOIN (ce_sus1
    WHERE ce_sus1.event_id=ce_mic1.event_id
     AND ce_sus1.valid_until_dt_tm=ce_mic1.valid_until_dt_tm
     AND ce_sus1.micro_seq_nbr=ce_mic1.micro_seq_nbr
     AND ce_sus1.chartable_flag=1)
    JOIN (dt4
    WHERE dt4.seq=1)
    JOIN (mt
    WHERE mt.task_assay_cd=ce_sus1.susceptibility_test_cd)
    JOIN (dt5
    WHERE dt5.seq=1)
    JOIN (mdt
    WHERE mdt.task_component_cd=ce_sus1.detail_susceptibility_cd)
    JOIN (dt6
    WHERE dt6.seq=1)
    JOIN (mtd_r
    WHERE mtd_r.task_component_cd=mdt.task_component_cd
     AND mtd_r.task_assay_cd=mt.task_assay_cd)
    JOIN (dt7
    WHERE dt7.seq=1)
    JOIN (trade
    WHERE trade.task_component_cd=ce_sus1.antibiotic_cd)
    JOIN (dt8
    WHERE dt8.seq=1)
    JOIN (((ce_sus2
    WHERE ce_sus2.event_id=ce_sus1.event_id
     AND ce_sus2.micro_seq_nbr=ce_sus1.micro_seq_nbr
     AND ce_sus2.suscep_seq_nbr=ce_sus1.suscep_seq_nbr
     AND ce_sus2.antibiotic_cd=ce_sus1.antibiotic_cd
     AND ce_sus2.susceptibility_test_cd=ce_sus1.susceptibility_test_cd
     AND cnvtdatetime(ce_sus1.result_dt_tm) > ce_sus2.result_dt_tm
     AND ce_sus1.susceptibility_status_cd=cornum)
    JOIN (cv1
    WHERE cv1.code_value=ce_sus2.result_cd
     AND cv1.code_set=64)
    ) ORJOIN ((((dt9
    WHERE dt9.seq=1)
    JOIN (ce_sus4
    WHERE ce_sus1.event_id=ce_sus4.event_id
     AND ce_sus1.result_cd=0.0
     AND ce_sus1.micro_seq_nbr=ce_sus4.micro_seq_nbr
     AND ce_sus1.antibiotic_cd=ce_sus4.antibiotic_cd
     AND ce_sus1.susceptibility_test_cd=ce_sus4.susceptibility_test_cd
     AND cnvtdatetime(ce_sus1.result_dt_tm) > ce_sus4.result_dt_tm
     AND ce_sus4.suscep_seq_nbr=ce_sus1.suscep_seq_nbr
     AND ce_sus1.susceptibility_status_cd=cornum)
    ) ORJOIN ((dt10
    WHERE dt10.seq=1)
    JOIN (ce_sus3
    WHERE ce_sus3.event_id=ce_sus1.event_id
     AND ce_sus1.micro_seq_nbr=ce_sus3.micro_seq_nbr
     AND ce_sus1.antibiotic_cd=ce_sus3.antibiotic_cd
     AND ce_sus1.susceptibility_test_cd=ce_sus3.susceptibility_test_cd
     AND cnvtdatetime(ce_sus1.result_dt_tm) > ce_sus3.result_dt_tm
     AND ce_sus3.suscep_seq_nbr=ce_sus1.suscep_seq_nbr
     AND cornum=ce_sus1.susceptibility_status_cd)
    JOIN (cv2
    WHERE ce_sus3.result_cd=cv2.code_value
     AND cv2.code_set=1025)
    )) )) ))
   WITH outerjoin = dt1, outerjoin = dt8, outerjoin = dt7,
    outerjoin = dt4, outerjoin = dt5, outerjoin = dt6,
    organization = work, counter, dontcare = trade,
    dontcare = ce_spc, dontcare = mdt, dontcare = mtd_r,
    outerjoin = e, parser(with_add)
  ;end select
 ENDIF
 SET tmplocres = fillstring(20," ")
 IF (curqual > 0)
  SELECT
   *
   FROM cp_mic_2
   WITH nocounter
  ;end select
  FREE RECORD corr_display
  RECORD corr_display(
    1 organisms[*]
      2 organism_name = vc
      2 has_corrections = i2
      2 antibiotics[*]
        3 antibiotic_name = vc
        3 data_type = c1
        3 old_interp_type = vc
        3 old_result = vc
        3 old_interp = vc
        3 old_v_dt_tm = dq8
        3 new_v_dt_tm = dq8
        3 corrected_date = dq8
        3 res_type = c12
        3 column = i4
  )
  IF (showsuspath=1)
   SELECT DISTINCT INTO "nl:"
    c.longacc, mp.order_id, pathogen_desc = trim(uar_get_code_description(mp.pathogen_cd))
    FROM mic_pathogen mp,
     cp_mic_2 c
    PLAN (c)
     JOIN (mp
     WHERE mp.order_id=c.order_id
      AND ((mp.order_id+ 0) > 0))
    ORDER BY c.longacc, mp.order_id, pathogen_desc
    HEAD REPORT
     acc_cnt = 0, order_cnt = 0, do_nothing = 0
    HEAD c.longacc
     acc_cnt = (acc_cnt+ 1), stat = alterlist(pathogen_rec->accession_list,acc_cnt), pathogen_rec->
     accession_list[acc_cnt].accession_nbr = c.longacc,
     order_cnt = 0
    HEAD mp.order_id
     order_cnt = (order_cnt+ 1), stat = alterlist(pathogen_rec->accession_list[acc_cnt].orders,
      order_cnt), pathogen_rec->accession_list[acc_cnt].orders[order_cnt].order_id = mp.order_id,
     pathogen_cnt = 0
    DETAIL
     pathogen_cnt = (pathogen_cnt+ 1)
     IF (pathogen_cnt=1)
      pathogen_rec->accession_list[acc_cnt].orders[order_cnt].pathogen_descr = pathogen_desc
     ELSE
      pathogen_rec->accession_list[acc_cnt].orders[order_cnt].pathogen_descr = build(pathogen_rec->
       accession_list[acc_cnt].orders[order_cnt].pathogen_descr,", ",pathogen_desc)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  DECLARE reflab_display = i2
  DECLARE reflab_symbol = c1
  SELECT INTO "nl:"
   cf.ref_lab_flag
   FROM chart_format cf
   WHERE (cf.chart_format_id=request->chart_format_id)
   HEAD REPORT
    reflab_display =
    IF (cf.ref_lab_flag=0) 1
    ELSE 0
    ENDIF
    , nordcommentflag = cf.ord_comment_flag, reflab_symbol = substring(1,1,cf.ref_lab_symbol)
   WITH nocounter
  ;end select
  IF (reflab_display=1)
   FREE RECORD temp_request
   RECORD temp_request(
     1 debug_ind = i2
     1 qual[*]
       2 encntr_id = f8
       2 resource_cd = f8
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 qual[*]
       2 resource_cd = f8
       2 ref_lab_description = vc
       2 encntr_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT DISTINCT INTO "nl:"
    c.service_resource_cd_child, c.service_resource_cd_parent, c.order_id,
    catalog_cd_desc = trim(uar_get_code_description(c.catalog_cd))
    FROM cp_mic_2 c
    ORDER BY c.encntr_id, c.order_id, c.service_resource_cd_parent,
     c.service_resource_cd_child
    HEAD REPORT
     ecnt = 0, ocnt = 0, sr_cnt = 0
    HEAD c.encntr_id
     ecnt = (ecnt+ 1), stat = alterlist(reflab_rec->encntr_list,ecnt), reflab_rec->encntr_list[ecnt].
     encntr_id = c.encntr_id,
     ocnt = 0
    HEAD c.order_id
     ocnt = (ocnt+ 1), stat = alterlist(reflab_rec->encntr_list[ecnt].orders,ocnt), reflab_rec->
     encntr_list[ecnt].orders[ocnt].order_id = c.order_id
     IF (c.verified_dt_tm != null)
      IF (utc_on)
       zone = datetimezonebyindex(c.verified_tz,utcoffset,daylight,7,c.verified_dt_tm), reflab_rec->
       encntr_list[ecnt].orders[ocnt].verified_dt_tm = concat(trim(format(datetimezone(c
           .verified_dt_tm,c.verified_tz),sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c
           .verified_dt_tm,c.verified_tz),stimemask_tz))," ",zone)
      ELSE
       reflab_rec->encntr_list[ecnt].orders[ocnt].verified_dt_tm = concat(trim(format(c
          .verified_dt_tm,date_mask),3)," ",cnvtupper(format(c.verified_dt_tm,time_mask)))
      ENDIF
     ENDIF
     reflab_rec->encntr_list[ecnt].orders[ocnt].catalog_cd_descr = catalog_cd_desc, sr_cnt = 0
    DETAIL
     idx = 0, srindex = locateval(idx,1,size(reflab_rec->encntr_list[ecnt].orders[ocnt].
       resource_cd_list,5),c.service_resource_cd_parent,reflab_rec->encntr_list[ecnt].orders[ocnt].
      resource_cd_list[idx].service_resource_cd)
     IF (srindex=0)
      sr_cnt = (sr_cnt+ 1), stat = alterlist(reflab_rec->encntr_list[ecnt].orders[ocnt].
       resource_cd_list,sr_cnt), reflab_rec->encntr_list[ecnt].orders[ocnt].resource_cd_list[sr_cnt].
      service_resource_cd = c.service_resource_cd_parent
     ENDIF
     idx = 0, srindex = locateval(idx,1,size(reflab_rec->encntr_list[ecnt].orders[ocnt].
       resource_cd_list,5),c.service_resource_cd_child,reflab_rec->encntr_list[ecnt].orders[ocnt].
      resource_cd_list[idx].service_resource_cd)
     IF (srindex=0)
      sr_cnt = (sr_cnt+ 1), stat = alterlist(reflab_rec->encntr_list[ecnt].orders[ocnt].
       resource_cd_list,sr_cnt), reflab_rec->encntr_list[ecnt].orders[ocnt].resource_cd_list[sr_cnt].
      service_resource_cd = c.service_resource_cd_child
     ENDIF
    WITH nocounter
   ;end select
   FOR (e = 1 TO size(reflab_rec->encntr_list,5))
     FOR (o = 1 TO size(reflab_rec->encntr_list[e].orders,5))
       SET stat = alterlist(temp_request->qual,size(reflab_rec->encntr_list[e].orders[o].
         resource_cd_list,5))
       FOR (s = 1 TO size(reflab_rec->encntr_list[e].orders[o].resource_cd_list,5))
        SET temp_request->qual[s].encntr_id = reflab_rec->encntr_list[e].encntr_id
        SET temp_request->qual[s].resource_cd = reflab_rec->encntr_list[e].orders[o].
        resource_cd_list[s].service_resource_cd
       ENDFOR
       IF (size(temp_request->qual,5) > 0)
        SET stat = initrec(temp_reply)
        EXECUTE cr_get_reflab_footnote  WITH replace(request,temp_request), replace(reply,temp_reply)
        IF (size(temp_reply->qual,5) > 0)
         SET stat = alterlist(reflab_rec->encntr_list[e].orders[o].footnotes,size(temp_reply->qual,5)
          )
         FOR (r = 1 TO size(temp_reply->qual,5))
           SET reflab_rec->encntr_list[e].orders[o].footnotes[r].ref_lab_description = trim(
            temp_reply->qual[r].ref_lab_description)
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  DECLARE hdr_procedure_caption = vc
  DECLARE hdr_source_caption = vc
  DECLARE hdr_site_caption = vc
  DECLARE hdr_ft_source_caption = vc
  DECLARE hdr_pathogen_caption = vc
  DECLARE hdr_coll_date_caption = vc
  DECLARE hdr_recv_date_caption = vc
  DECLARE hdr_start_date_caption = vc
  DECLARE hdr_accession_caption = vc
  SET hdr_procedure_caption = substring(1,18,labelprocedure)
  SET hdr_source_caption = substring(1,18,labelsource)
  SET hdr_site_caption = substring(1,18,labelbodysite)
  SET hdr_ft_source_caption = substring(1,18,labelfreetext)
  SET hdr_pathogen_caption = substring(1,18,labelsuspath)
  SET hdr_coll_date_caption = substring(1,12,labelcollected)
  SET hdr_recv_date_caption = substring(1,12,labelreceived)
  SET hdr_start_date_caption = substring(1,12,labelstarted)
  SET hdr_accession_caption = substring(1,12,labelaccession)
  DECLARE hdr_procedure_column = i4
  DECLARE hdr_source_column = i4
  DECLARE hdr_site_column = i4
  DECLARE hdr_ft_source_column = i4
  DECLARE hdr_pathogen_column = i4
  DECLARE hdr_coll_date_column = i4
  DECLARE hdr_recv_date_column = i4
  DECLARE hdr_start_date_column = i4
  DECLARE hdr_accession_column = i4
  DECLARE constleftcolumn = i4
  SET constleftcolumn = 21
  DECLARE ft_max_size = i4
  DECLARE pathogen_max_size = i4
  IF (((constleftcolumn - size(trim(labelprocedure))) >= 0))
   SET hdr_procedure_column = (constleftcolumn - size(trim(labelprocedure)))
  ELSE
   SET hdr_procedure_column = 0
  ENDIF
  IF (((constleftcolumn - size(trim(labelsource))) >= 0))
   SET hdr_source_column = (constleftcolumn - size(trim(labelsource)))
  ELSE
   SET hdr_source_clumn = 0
  ENDIF
  IF (((constleftcolumn - size(trim(labelbodysite))) >= 0))
   SET hdr_site_column = (constleftcolumn - size(trim(labelbodysite)))
  ELSE
   SET hdr_site_column = 0
  ENDIF
  IF (((constleftcolumn - size(trim(labelfreetext))) >= 0))
   SET hdr_ft_source_column = (constleftcolumn - size(trim(labelfreetext)))
  ELSE
   SET hdr_ft_source_column = 0
  ENDIF
  IF (((constleftcolumn - size(trim(labelsuspath))) >= 0))
   SET hdr_pathogen_column = (constleftcolumn - size(trim(labelsuspath)))
  ELSE
   SET hdr_pathogen_column = 0
  ENDIF
  IF (size(trim(labelcollected)) >= 18)
   SET hdr_coll_date_column = (fontlbl - 3)
  ELSE
   SET hdr_coll_date_column = ((fontlbl+ 9) - size(trim(labelcollected)))
  ENDIF
  IF (size(trim(labelreceived)) >= 18)
   SET hdr_recv_date_column = (fontlbl - 3)
  ELSE
   SET hdr_recv_date_column = ((fontlbl+ 9) - size(trim(labelreceived)))
  ENDIF
  IF (size(trim(labelstarted)) >= 18)
   SET hdr_start_date_column = (fontlbl - 3)
  ELSE
   SET hdr_start_date_column = ((fontlbl+ 9) - size(trim(labelstarted)))
  ENDIF
  IF (size(trim(labelaccession)) >= 18)
   SET hdr_accession_column = (fontlbl - 3)
  ELSE
   SET hdr_accession_column = ((fontlbl+ 9) - size(trim(labelaccession)))
  ENDIF
  FREE RECORD header_rec
  RECORD header_rec(
    1 left_line_cnt = i4
    1 right_line_cnt = i4
    1 procedure[*]
      2 bold_value = c3
      2 left_column = i4
      2 left_caption = vc
      2 procedure_desc = vc
      2 dont_print = i2
    1 lines[*]
      2 bold_value = c3
      2 left_column = i4
      2 left_caption = vc
      2 left_value = vc
      2 right_column = i4
      2 right_caption = vc
      2 right_value = vc
      2 dont_print = i2
  )
  SELECT INTO "nl:"
   l.long_blob_id, c.*, note = decode(b.seq,"BLOB",l.seq,"BLOB2",lx.seq,
    "ORDC",lb.seq,"INTP","NONE"),
   csf.compression_cd, n.compression_cd, oc.order_id,
   oc.action_sequence, lx.long_text_id, lb.long_blob_id,
   text_contents = decode(lx.seq,substring(1,10000,lx.long_text),""), blob_contents = decode(b.seq,b
    .blob_contents,lb.seq,lb.long_blob,l.seq,
    l.long_blob)
   FROM cp_mic_2 c,
    ce_blob b,
    (dummyt d  WITH seq = 1),
    ce_suscep_footnote csf,
    ce_suscep_footnote_r csfr,
    long_blob l,
    ce_event_note n,
    long_blob lb,
    order_comment oc,
    long_text lx
   PLAN (c)
    JOIN (d)
    JOIN (((b
    WHERE c.blob_entry=1
     AND c.blob_id=b.event_id
     AND c.valid_until_dt_tm=b.valid_until_dt_tm
     AND c.blob_seq_num=b.blob_seq_num)
    ) ORJOIN ((((csfr
    WHERE csfr.event_id=c.event_id
     AND csfr.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
     AND csfr.micro_seq_nbr=c.micro_seq_nbr
     AND csfr.suscep_seq_nbr=c.suscep_seq_nbr)
    JOIN (csf
    WHERE csf.event_id=c.event_id
     AND csf.suscep_footnote_id=csfr.suscep_footnote_id
     AND csf.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (l
    WHERE l.parent_entity_id=csf.ce_suscep_footnote_id
     AND l.parent_entity_name="CE_SUSCEP_FOOTNOTE")
    ) ORJOIN ((((n
    WHERE c.event_id=n.event_id)
    JOIN (lb
    WHERE n.ce_event_note_id=lb.parent_entity_id
     AND n.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
     AND lb.parent_entity_name="CE_EVENT_NOTE"
     AND n.note_type_cd=interp_cd
     AND ((n.non_chartable_flag=0) OR (n.updt_task=csm_request_viewer_task)) )
    ) ORJOIN ((oc
    WHERE c.order_id=oc.order_id
     AND oc.comment_type_cd=comment_type_cd
     AND ((oc.order_id+ 0) > 0)
     AND (oc.action_sequence=
    (SELECT
     max(co2.action_sequence)
     FROM order_comment co2
     WHERE oc.order_id=co2.order_id
      AND co2.comment_type_cd=comment_type_cd)))
    JOIN (lx
    WHERE oc.long_text_id=lx.long_text_id)
    )) )) ))
   HEAD REPORT
    kountrows = 0, mycors = 0, mycors2 = 0,
    nlchars = concat(char(13),char(10)), pathogen_string = fillstring(100," "), pathogen_max_size = 0,
    v_from = cnvtdatetime((curdate - 1000),curtime), e_code = 0.0, numlines = 0,
    u50 = fillstring(50,"_"), u100 = fillstring(value(fontwidth),"_"), uuu = fillstring(value((
      fontwidth - 15)),"_"),
    ft_max_size = 0, current_source_rec = 0, source_text = fillstring(100," "),
    u_bug = fillstring(100," "), u_org = fillstring(100," "), u_long = fillstring(70,"_"),
    susc_print_rows = 0, max_row_num = 0, first_header_row = 0,
    last_header_row = 0, backup_row_cnt = 0, go_down_row_cnt = 0,
    formatted_drawn_dt_tm = fillstring(100," "), formatted_culture_start_dt_tm = fillstring(100," "),
    formatted_received_dt_tm = fillstring(100," "),
    printed_event = "F", printed_legend = "F"
   HEAD PAGE
    row + 0
   HEAD c.longacc
    row + 0
   HEAD c.parent_event_id
    source_text = uar_get_code_display(c.source_cd), did_accn_print_susc = "F"
   HEAD c.catalog_cd
    numcors = 0, stat = alterlist(cor_data->qual,numcors), num_interps = 0,
    stat = alterlist(interp_data->qual,num_interps), numnotes = 0, stat = alterlist(foot_data->qual,
     numnotes),
    numcoms = 0, stat = alterlist(order_comment->qual,numcoms), v_from = cnvtdatetime((curdate - 1000
     ),curtime),
    myorgs = 0, stat = alterlist(org_rec->qual,myorgs), mydrugs = 0,
    stat = alterlist(suscep_rec->drugresult,mydrugs), e_code = 0.0, sup_footer_needed = "F",
    total_rows = 0, printed_global_report_header = "f", org_cnt = 0,
    stat = alterlist(corr_display->organisms,org_cnt), pathogen_string = fillstring(100," "), col 0,
    ">>>", firstbug = "T", l_line_cnt = 0,
    proc_cnt = 0, r_line_cnt = 0, stat = alterlist(header_rec->lines,l_line_cnt),
    stat = alterlist(header_rec->procedure,proc_cnt), ret_description = fillstring(60," "),
    ret_meaning = fillstring(12," "),
    ret_display = fillstring(40," "), ret_description = fillstring(60," "),
    CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description)
    IF (showprocedure=1)
     proc_cnt = (proc_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat =
     alterlist(header_rec->procedure,proc_cnt),
     header_rec->procedure[proc_cnt].bold_value = boldchars, header_rec->procedure[proc_cnt].
     left_caption = hdr_procedure_caption, header_rec->procedure[proc_cnt].left_column = value(
      hdr_procedure_column),
     header_rec->procedure[proc_cnt].procedure_desc = concat(" ",ret_description)
     IF (use_smart_captions=1
      AND size(trim(ret_description))=0)
      header_rec->procedure[proc_cnt].left_caption = "", header_rec->procedure[proc_cnt].
      procedure_desc = "", proc_cnt = (proc_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      proc_cnt = (proc_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat =
      alterlist(header_rec->procedure,proc_cnt),
      header_rec->procedure[proc_cnt].bold_value = boldchars
     ENDIF
    ENDIF
    IF (showsource=1)
     l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
      = alterlist(header_rec->lines,l_line_cnt),
     header_rec->lines[l_line_cnt].bold_value = boldchars, header_rec->lines[l_line_cnt].left_caption
      = hdr_source_caption, header_rec->lines[l_line_cnt].left_column = value(hdr_source_column),
     header_rec->lines[l_line_cnt].left_value = concat(" ",source_text)
     IF (use_smart_captions=1
      AND size(trim(source_text))=0)
      header_rec->lines[l_line_cnt].left_caption = "", header_rec->lines[l_line_cnt].left_value = "",
      l_line_cnt = (l_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
       = alterlist(header_rec->lines,l_line_cnt),
      header_rec->lines[l_line_cnt].bold_value = boldchars
     ENDIF
    ENDIF
    ret_description = fillstring(60," ")
    IF (c.body_site_cd > 0)
     CALL uar_get_code(c.body_site_cd,ret_display,ret_meaning,ret_description)
    ENDIF
    IF (showbodysite=1)
     l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
      = alterlist(header_rec->lines,l_line_cnt),
     header_rec->lines[l_line_cnt].bold_value = boldchars, header_rec->lines[l_line_cnt].left_caption
      = hdr_site_caption, header_rec->lines[l_line_cnt].left_column = value(hdr_site_column),
     header_rec->lines[l_line_cnt].left_value = concat(" ",ret_description)
     IF (use_smart_captions=1
      AND size(trim(ret_description))=0)
      header_rec->lines[l_line_cnt].left_caption = "", header_rec->lines[l_line_cnt].left_value = "",
      l_line_cnt = (l_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
       = alterlist(header_rec->lines,l_line_cnt),
      header_rec->lines[l_line_cnt].bold_value = boldchars
     ENDIF
    ENDIF
    IF (showfreetext=1)
     ft_line1 = 0, ft_actual_size = size(trim(c.specimen_src_text))
     IF (ft_actual_size > 0)
      ft_max_size = (value(fontlbl) - 24), ival = wraptextforline(trim(c.specimen_src_text),
       ft_max_size)
      FOR (i = 1 TO size(wrapped_text->qual,5))
        l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1),
        stat = alterlist(header_rec->lines,l_line_cnt),
        header_rec->lines[l_line_cnt].bold_value = boldchars
        IF (ft_line1=0)
         header_rec->lines[l_line_cnt].left_caption = hdr_ft_source_caption, ft_line1 = 1
        ENDIF
        header_rec->lines[l_line_cnt].left_column = value(hdr_ft_source_column), header_rec->lines[
        l_line_cnt].left_value = concat(" ",trim(wrapped_text->qual[i].line,2))
      ENDFOR
     ELSEIF (use_smart_captions=0)
      l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
       = alterlist(header_rec->lines,l_line_cnt),
      header_rec->lines[l_line_cnt].left_column = value(hdr_ft_source_column), header_rec->lines[
      l_line_cnt].left_caption = hdr_ft_source_caption, header_rec->lines[l_line_cnt].left_value = "",
      header_rec->lines[l_line_cnt].bold_value = boldchars
     ENDIF
    ENDIF
    IF (showsuspath=1)
     pathogen_line1 = 0, pathogen_string = ""
     FOR (aa = 1 TO size(pathogen_rec->accession_list,5))
       IF ((pathogen_rec->accession_list[aa].accession_nbr=c.longacc))
        FOR (oo = 1 TO size(pathogen_rec->accession_list[aa].orders,5))
          IF (oo=1)
           pathogen_string = pathogen_rec->accession_list[aa].orders[oo].pathogen_descr
          ELSE
           pathogen_string = build(pathogen_string,", ",pathogen_rec->accession_list[aa].orders[oo].
            pathogen_descr)
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
     pathogen_length = size(trim(pathogen_string))
     IF (pathogen_length > 0)
      pathogen_max_size = (value(fontlbl) - 24), ival = wraptextforline(trim(pathogen_string),
       pathogen_max_size)
      FOR (i = 1 TO size(wrapped_text->qual,5))
        l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1),
        stat = alterlist(header_rec->lines,l_line_cnt),
        header_rec->lines[l_line_cnt].bold_value = boldchars
        IF (pathogen_line1=0)
         header_rec->lines[l_line_cnt].left_caption = hdr_pathogen_caption, pathogen_line1 = 1
        ENDIF
        header_rec->lines[l_line_cnt].left_column = value(hdr_pathogen_column), header_rec->lines[
        l_line_cnt].left_value = concat(" ",trim(wrapped_text->qual[i].line,2))
      ENDFOR
     ELSEIF (use_smart_captions=0)
      l_line_cnt = (l_line_cnt+ 1), header_rec->left_line_cnt = (header_rec->left_line_cnt+ 1), stat
       = alterlist(header_rec->lines,l_line_cnt),
      header_rec->lines[l_line_cnt].left_column = value(hdr_pathogen_column), header_rec->lines[
      l_line_cnt].left_caption = hdr_pathogen_caption, header_rec->lines[l_line_cnt].left_value = "",
      header_rec->lines[l_line_cnt].bold_value = boldchars
     ENDIF
    ENDIF
    IF (showcollected=1)
     r_line_cnt = (r_line_cnt+ 1)
     IF (r_line_cnt > l_line_cnt)
      stat = alterlist(header_rec->lines,r_line_cnt)
     ENDIF
     header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
     bold_value = boldchars, header_rec->lines[r_line_cnt].right_caption = hdr_coll_date_caption,
     header_rec->lines[r_line_cnt].right_column = value(hdr_coll_date_column)
     IF (c.collect_dt_tm != null)
      IF (utc_on)
       zone = datetimezonebyindex(c.drawn_tz,utcoffset,daylight,7,c.collect_dt_tm),
       formatted_drawn_dt_tm = concat(trim(format(datetimezone(c.collect_dt_tm,c.drawn_tz),
          sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c.collect_dt_tm,c.drawn_tz),stimemask_tz
          ))," ",zone)
      ELSE
       formatted_drawn_dt_tm = concat(trim(format(c.collect_dt_tm,date_mask),3)," ",cnvtupper(format(
          c.collect_dt_tm,time_mask)))
      ENDIF
     ENDIF
     header_rec->lines[r_line_cnt].right_value = concat(" ",trim(formatted_drawn_dt_tm))
     IF (use_smart_captions=1
      AND c.collect_dt_tm=null)
      header_rec->lines[r_line_cnt].right_caption = "", header_rec->lines[r_line_cnt].right_value =
      "", r_line_cnt = (r_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      r_line_cnt = (r_line_cnt+ 1)
      IF (r_line_cnt > l_line_cnt)
       stat = alterlist(header_rec->lines,r_line_cnt)
      ENDIF
      header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
      bold_value = boldchars
     ENDIF
    ENDIF
    IF (showreceived=1)
     r_line_cnt = (r_line_cnt+ 1)
     IF (r_line_cnt > l_line_cnt)
      stat = alterlist(header_rec->lines,r_line_cnt)
     ENDIF
     header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
     bold_value = boldchars, header_rec->lines[r_line_cnt].right_caption = hdr_recv_date_caption,
     header_rec->lines[r_line_cnt].right_column = value(hdr_recv_date_column)
     IF (c.recvd_dt_tm != null)
      IF (utc_on)
       zone = datetimezonebyindex(c.recvd_tz,utcoffset,daylight,7,c.recvd_dt_tm),
       formatted_received_dt_tm = concat(trim(format(datetimezone(c.recvd_dt_tm,c.recvd_tz),
          sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c.recvd_dt_tm,c.recvd_tz),stimemask_tz)),
        " ",zone)
      ELSE
       formatted_received_dt_tm = concat(trim(format(c.recvd_dt_tm,date_mask),3)," ",cnvtupper(format
         (c.recvd_dt_tm,time_mask)))
      ENDIF
     ENDIF
     header_rec->lines[r_line_cnt].right_value = concat(" ",trim(formatted_received_dt_tm))
     IF (use_smart_captions=1
      AND c.recvd_dt_tm=null)
      header_rec->lines[r_line_cnt].right_caption = "", header_rec->lines[r_line_cnt].right_value =
      "", r_line_cnt = (r_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      r_line_cnt = (r_line_cnt+ 1)
      IF (r_line_cnt > l_line_cnt)
       stat = alterlist(header_rec->lines,r_line_cnt)
      ENDIF
      header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
      bold_value = boldchars
     ENDIF
    ENDIF
    IF (showstarted=1)
     r_line_cnt = (r_line_cnt+ 1)
     IF (r_line_cnt > l_line_cnt)
      stat = alterlist(header_rec->lines,r_line_cnt)
     ENDIF
     header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
     bold_value = boldchars, header_rec->lines[r_line_cnt].right_caption = hdr_start_date_caption,
     header_rec->lines[r_line_cnt].right_column = value(hdr_start_date_column)
     IF (utc_on)
      zone = datetimezonebyindex(c.culture_start_tz,utcoffset,daylight,7,c.event_start_dt_tm),
      formatted_culture_start_dt_tm = concat(trim(format(datetimezone(c.event_start_dt_tm,c
          .culture_start_tz),sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c.event_start_dt_tm,c
          .culture_start_tz),stimemask_tz))," ",zone)
     ELSE
      formatted_culture_start_dt_tm = concat(trim(format(c.event_start_dt_tm,date_mask),3)," ",
       cnvtupper(format(c.event_start_dt_tm,time_mask)))
     ENDIF
     header_rec->lines[r_line_cnt].right_value = concat(" ",trim(formatted_culture_start_dt_tm))
     IF (use_smart_captions=1
      AND c.event_start_dt_tm=null)
      header_rec->lines[r_line_cnt].right_caption = "", header_rec->lines[r_line_cnt].right_value =
      "", r_line_cnt = (r_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      r_line_cnt = (r_line_cnt+ 1)
      IF (r_line_cnt > l_line_cnt)
       stat = alterlist(header_rec->lines,r_line_cnt)
      ENDIF
      header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
      bold_value = boldchars
     ENDIF
    ENDIF
    IF (showaccession=1)
     myacc = fillstring(20," ")
     IF (c.contributor_system_cd=dpowerchartcd)
      myacc = uar_fmt_accession(c.longacc,20)
     ELSEIF (substring(1,2,c.longacc) != "##")
      myacc = c.longacc
     ENDIF
     r_line_cnt = (r_line_cnt+ 1)
     IF (r_line_cnt > l_line_cnt)
      stat = alterlist(header_rec->lines,r_line_cnt)
     ENDIF
     header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
     bold_value = boldchars, header_rec->lines[r_line_cnt].right_caption = hdr_accession_caption,
     header_rec->lines[r_line_cnt].right_column = value(hdr_accession_column), header_rec->lines[
     r_line_cnt].right_value = concat(" ",myacc)
     IF (use_smart_captions=1
      AND size(trim(myacc))=0)
      header_rec->lines[r_line_cnt].right_caption = "", header_rec->lines[r_line_cnt].right_value =
      "", r_line_cnt = (r_line_cnt - 1)
     ENDIF
    ELSE
     IF (use_smart_captions=0)
      r_line_cnt = (r_line_cnt+ 1)
      IF (r_line_cnt > l_line_cnt)
       stat = alterlist(header_rec->lines,r_line_cnt)
      ENDIF
      header_rec->right_line_cnt = (header_rec->right_line_cnt+ 1), header_rec->lines[r_line_cnt].
      bold_value = boldchars
     ENDIF
    ENDIF
    FOR (x = 1 TO size(header_rec->lines,5))
      IF ((((header_rec->lines[x].left_caption > " ")) OR ((((header_rec->lines[x].left_value > " "))
       OR ((((header_rec->lines[x].right_caption > " ")) OR ((header_rec->lines[x].right_value > " ")
      )) )) )) )
       header_rec->lines[x].dont_print = 0
      ELSE
       header_rec->lines[x].dont_print = 1
      ENDIF
    ENDFOR
    FOR (x = 1 TO size(header_rec->procedure,5))
      IF ((header_rec->procedure[x].dont_print=0))
       row + 1, col 0, header_rec->procedure[x].bold_value,
       col header_rec->procedure[x].left_column, header_rec->procedure[x].left_caption, header_rec->
       procedure[x].procedure_desc
      ENDIF
    ENDFOR
    FOR (x = 1 TO size(header_rec->lines,5))
      IF ((header_rec->lines[x].dont_print=0))
       row + 1, col 0, header_rec->lines[x].bold_value,
       col header_rec->lines[x].left_column, header_rec->lines[x].left_caption, header_rec->lines[x].
       left_value,
       col header_rec->lines[x].right_column, header_rec->lines[x].right_caption, header_rec->lines[x
       ].right_value
      ENDIF
    ENDFOR
    row + 1, col 0, "<<<",
    row + 1
   HEAD c.side
    IF (c.side=1)
     row + 0
    ENDIF
    v_from = cnvtdatetime((curdate - 1000),curtime)
   HEAD c.event_id
    printed_event = "T"
    IF (((c.side=0) OR (c.text_order=otherrpt)) )
     printed_event = "F", firstbug = "T", reject = "F"
     CASE (c.text_order)
      OF stnrpt:
       IF (c.event_cd != e_code)
        e_code = c.event_cd, v_from = cnvtdatetime(c.verified_dt_tm), total_rows = (total_rows+ 1)
       ELSEIF (c.event_cd=e_code
        AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0)
        v_from = cnvtdatetime(c.verified_dt_tm), reject = "F"
       ELSE
        reject = "T"
       ENDIF
      OF prelim:
       IF (report_option=allfinadd)
        reject = "T"
       ELSEIF (nprelimreports=1
        AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0
        AND report_option IN (curresult, curprefinadd))
        reject = "T"
       ELSE
        v_from = cnvtdatetime(c.verified_dt_tm), prelim_v_from = cnvtdatetime(c.verified_dt_tm),
        total_rows = (total_rows+ 1)
       ENDIF
      OF final:
       IF (nfinalreports=1
        AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0
        AND report_option IN (curresult, curprefinadd))
        reject = "T"
       ELSE
        v_from = cnvtdatetime(c.verified_dt_tm), total_rows = (total_rows+ 1)
        IF (nprelimreports > 0
         AND report_option IN (curresult, allfinadd))
         stat = alterlist(report_data2->prelim,0), nprelimreports = 0
        ENDIF
       ENDIF
      OF amend:
       IF (namendedreports=1
        AND datetimediff(cnvtdatetime(c.verified_dt_tm),cnvtdatetime(v_from)) < 0
        AND report_option IN (curresult, curprefinadd))
        reject = "T"
       ELSE
        v_from = cnvtdatetime(c.verified_dt_tm), total_rows = (total_rows+ 1)
        IF (((nprelimreports > 0) OR (nfinalreports > 0))
         AND report_option=curresult)
         stat = alterlist(report_data2->prelim,0), stat = alterlist(report_data2->final,0),
         nprelimreports = 0,
         nfinalreports = 0
        ENDIF
        IF (nprelimreports > 0
         AND report_option=allfinadd)
         stat = alterlist(report_data2->prelim,0), nprelimreports = 0
        ENDIF
       ENDIF
     ENDCASE
     IF (reject="F"
      AND c.text_order != otherrpt)
      IF (c.text_order=0
       AND c.event_class_cd=ddoccd)
       total_rows = (total_rows+ 1)
      ENDIF
      IF (total_rows > 0)
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.compression_cd,ret_display,ret_meaning,ret_description), temp_blob =
       fillstring(30000," ")
       IF (trim(ret_meaning)="OCFCOMP")
        blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
         30000," "),
        blob_ret_len = 0,
        CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len), blob_out2 =
        blob_out,
        x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), temp_blob = blob_out3
       ELSE
        blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = trim(substring
         (1,(x1 - 8),blob_contents),3),
        temp_blob = blob_out2
       ENDIF
       IF (c.verified_dt_tm != null)
        IF (utc_on)
         zone = datetimezonebyindex(c.verified_tz,utcoffset,daylight,7,c.verified_dt_tm), temp_v_date
          = concat(trim(format(datetimezone(c.verified_dt_tm,c.verified_tz),sdatemask_tz),3)," ",
          cnvtupper(format(datetimezone(c.verified_dt_tm,c.verified_tz),stimemask_tz))," ",zone)
        ELSE
         temp_v_date = concat(trim(format(c.verified_dt_tm,date_mask),3)," ",cnvtupper(format(c
            .verified_dt_tm,time_mask)))
        ENDIF
       ELSE
        temp_v_date = ""
       ENDIF
       CASE (c.text_order)
        OF stnrpt:
         nstainreports = (nstainreports+ 1),stat = alterlist(report_data2->stain,nstainreports),
         report_data2->stain[nstainreports].report_text = temp_blob,
         report_data2->stain[nstainreports].stain_name =
         IF (c.text_type > " ") c.text_type
         ELSE uar_get_code_display(c.event_cd)
         ENDIF
         ,report_data2->stain[nstainreports].rep_type = c.text_type,report_data2->stain[nstainreports
         ].ver_dt_time = temp_v_date
        OF prelim:
         nprelimreports = (nprelimreports+ 1),stat = alterlist(report_data2->prelim,nprelimreports),
         report_data2->prelim[nprelimreports].report_text = temp_blob,
         report_data2->prelim[nprelimreports].stain_name =
         IF (c.text_type > " ") c.text_type
         ELSE uar_get_code_display(c.event_cd)
         ENDIF
         ,report_data2->prelim[nprelimreports].rep_type = c.text_type,report_data2->prelim[
         nprelimreports].ver_dt_time = temp_v_date
        OF final:
         nfinalreports = (nfinalreports+ 1),stat = alterlist(report_data2->final,nfinalreports),
         report_data2->final[nfinalreports].report_text = temp_blob,
         report_data2->final[nfinalreports].stain_name =
         IF (c.text_type > " ") c.text_type
         ELSE uar_get_code_display(c.event_cd)
         ENDIF
         ,report_data2->final[nfinalreports].rep_type = c.text_type,report_data2->final[nfinalreports
         ].ver_dt_time = temp_v_date
        OF amend:
         namendedreports = (namendedreports+ 1),stat = alterlist(report_data2->amend,namendedreports),
         report_data2->amend[namendedreports].report_text = temp_blob,
         report_data2->amend[namendedreports].stain_name =
         IF (c.text_type > " ") c.text_type
         ELSE uar_get_code_display(c.event_cd)
         ENDIF
         ,report_data2->amend[namendedreports].rep_type = c.text_type,report_data2->amend[
         namendedreports].ver_dt_time = temp_v_date
        ELSE
         notherreports = (notherreports+ 1),stat = alterlist(report_data2->other,notherreports),
         report_data2->other[notherreports].report_text = temp_blob,
         report_data2->other[notherreports].stain_name =
         IF (c.text_type > " ") c.text_type
         ELSE uar_get_code_display(c.event_cd)
         ENDIF
         ,report_data2->other[notherreports].rep_type = c.text_type,report_data2->other[notherreports
         ].ver_dt_time = temp_v_date
       ENDCASE
      ENDIF
     ENDIF
    ENDIF
   HEAD c.ord2
    IF (c.side=1)
     IF (firstbug="T")
      printed_event = "T", firstbug = "F", num_lines = 0,
      end_par = 0, line_len = 0
      IF (nstainreports > 0)
       row + 1, col 0, ">>",
       row + 1
       IF (size(trim(labelstain)) > 0)
        IF (isbold=1)
         col 0, boldchars, labelstain
        ELSE
         col 0, labelstain
        ENDIF
       ENDIF
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
       FOR (lvar = 1 TO nstainreports)
         text_line = fillstring(value(fontwidth)," ")
         IF (isbold=1)
          row + 2, col 0, boldchars,
          report_data2->stain[lvar].stain_name
         ELSE
          row + 2, col 0, report_data2->stain[lvar].stain_name
         ENDIF
         IF (verified_justification != 2)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
          IF (verified_justification=1)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
          ELSEIF (verified_justification=0)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
           tempstr
          ENDIF
          report_data2->stain[lvar].ver_dt_time
         ENDIF
         ival = wraptextforline(trim(report_data2->stain[lvar].report_text),fontwidth)
         FOR (i = 1 TO size(wrapped_text->qual,5))
           row + 1, col 0,
           CALL print(trim(wrapped_text->qual[i].line,2))
         ENDFOR
       ENDFOR
       row + 1, col 0, "<<",
       row + 1, col 0, " ",
       stat = alterlist(report_data2->stain,0), nstainreports = 0
      ENDIF
      report_type = 0
      IF (namendedreports > 0)
       row + 1, col 0, ">>"
       IF (size(trim(labelglobal)) > 0
        AND printed_global_report_header="f")
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelglobal
        ELSE
         row + 1, col 0, labelglobal
        ENDIF
        printed_global_report_header = "t"
       ENDIF
       report_type = 4
       IF (size(trim(labelamended)) > 0)
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelamended
        ELSE
         row + 1, col 0, labelamended
        ENDIF
       ENDIF
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
       FOR (lvar = 1 TO namendedreports)
         IF (isbold=1)
          row + 2, col 0, boldchars,
          report_data2->amend[lvar].stain_name
         ELSE
          row + 2, col 0, report_data2->amend[lvar].stain_name
         ENDIF
         IF (verified_justification != 2)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
          IF (verified_justification=1)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
          ELSEIF (verified_justification=0)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
           tempstr
          ENDIF
          report_data2->amend[lvar].ver_dt_time
         ENDIF
         ival = wraptextforline(trim(report_data2->amend[lvar].report_text),fontwidth)
         FOR (i = 1 TO size(wrapped_text->qual,5))
           row + 1, col 0,
           CALL print(trim(wrapped_text->qual[i].line,2))
         ENDFOR
       ENDFOR
       row + 1, col 0, "<<",
       row + 1, col 0, " ",
       stat = alterlist(report_data2->amend,0), namendedreports = 0
      ENDIF
      IF (nfinalreports > 0)
       row + 1, col 0, ">>"
       IF (size(trim(labelglobal)) > 0
        AND printed_global_report_header="f")
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelglobal
        ELSE
         row + 1, col 0, labelglobal
        ENDIF
        printed_global_report_header = "t"
       ENDIF
       report_type = 4
       IF (size(trim(labelfinal)) > 0)
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelfinal
        ELSE
         row + 1, col 0, labelfinal
        ENDIF
       ENDIF
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
       FOR (lvar = 1 TO nfinalreports)
         IF (isbold=1)
          row + 2, col 0, boldchars,
          report_data2->final[lvar].stain_name
         ELSE
          row + 2, col 0, report_data2->final[lvar].stain_name
         ENDIF
         IF (verified_justification != 2)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
          IF (verified_justification=1)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
          ELSEIF (verified_justification=0)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
           tempstr
          ENDIF
          report_data2->final[lvar].ver_dt_time
         ENDIF
         ival = wraptextforline(trim(report_data2->final[lvar].report_text),fontwidth)
         FOR (i = 1 TO size(wrapped_text->qual,5))
           row + 1, col 0,
           CALL print(trim(wrapped_text->qual[i].line,2))
         ENDFOR
       ENDFOR
       row + 1, col 0, "<<",
       row + 1, col 0, " ",
       stat = alterlist(report_data2->final,0), nfinalreports = 0
      ENDIF
      IF (nprelimreports > 0)
       row + 1, col 0, ">>"
       IF (size(trim(labelglobal)) > 0
        AND printed_global_report_header="f")
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelglobal
        ELSE
         row + 1, col 0, labelglobal
        ENDIF
        printed_global_report_header = "t"
       ENDIF
       report_type = 4
       IF (size(trim(labelfinal)) > 0)
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelprelim
        ELSE
         row + 1, col 0, labelprelim
        ENDIF
       ENDIF
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
       FOR (lvar = 1 TO nprelimreports)
         IF (isbold=1)
          row + 2, col 0, boldchars,
          report_data2->prelim[lvar].stain_name
         ELSE
          row + 2, col 0, report_data2->prelim[lvar].stain_name
         ENDIF
         IF (verified_justification != 2)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
          IF (verified_justification=1)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
          ELSEIF (verified_justification=0)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
           tempstr
          ENDIF
          report_data2->prelim[lvar].ver_dt_time
         ENDIF
         ival = wraptextforline(trim(report_data2->prelim[lvar].report_text),fontwidth)
         FOR (i = 1 TO size(wrapped_text->qual,5))
           row + 1, col 0,
           CALL print(trim(wrapped_text->qual[i].line,2))
         ENDFOR
       ENDFOR
       row + 1, col 0, "<<",
       row + 1, col 0, " ",
       stat = alterlist(report_data2->prelim,0), nprelimreports = 0
      ENDIF
      IF (notherreports > 0)
       row + 1, col 0, ">>"
       IF (size(trim(labelglobal)) > 0
        AND printed_global_report_header="f")
        IF (isbold=1)
         row + 1, col 0, boldchars,
         labelglobal
        ELSE
         row + 1, col 0, labelglobal
        ENDIF
        printed_global_report_header = "t"
       ENDIF
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
       FOR (lvar = 1 TO notherreports)
         IF (isbold=1)
          row + 2, col 0, boldchars,
          report_data2->other[lvar].stain_name
         ELSE
          row + 2, col 0, report_data2->other[lvar].stain_name
         ENDIF
         IF (verified_justification != 2)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
          IF (verified_justification=1)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
          ELSEIF (verified_justification=0)
           tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
           tempstr
          ENDIF
          report_data2->other[lvar].ver_dt_time
         ENDIF
         ival = wraptextforline(trim(report_data2->other[lvar].report_text),fontwidth)
         FOR (i = 1 TO size(wrapped_text->qual,5))
           row + 1, col 0,
           CALL print(trim(wrapped_text->qual[i].line,2))
         ENDFOR
       ENDFOR
       row + 1, col 0, "<<",
       row + 1, col 0, " ",
       stat = alterlist(report_data2->other,0), notherreports = 0
      ENDIF
     ENDIF
    ENDIF
   HEAD c.drug
    is_cor = 0
    IF (c.side=1)
     mynotes = 0, is_cor = 0, did_accn_print_susc = "T"
    ENDIF
    myorgs = 0, add_bug = "F", add_drug = "F"
   HEAD c.drugtest
    is_cor = 0
    IF (c.side=1)
     is_cor = 0, did_accn_print_susc = "T"
    ENDIF
   HEAD l.long_blob_id
    IF (note="BLOB2")
     found_note = "F", notenumber = 0
     FOR (kbgvar = 1 TO numnotes)
       IF ((foot_data->qual[kbgvar].long_blob_id=l.long_blob_id))
        found_note = "T", notenumber = kbgvar, found_drug = "F",
        k2 = size(foot_data->qual[kbgvar].qualx,5)
        IF (k2 > 0)
         FOR (kbhvar = 1 TO k2)
           IF ((foot_data->qual[kbgvar].qualx[kbhvar].antibiotic_cd=c.antibiotic_cd)
            AND (foot_data->qual[kbgvar].qualx[kbhvar].ord2=c.ord2))
            found_drug = "T", kbhvar = k2
           ENDIF
         ENDFOR
        ENDIF
        IF (found_drug="F")
         k2 = (k2+ 1), stat = alterlist(foot_data->qual[kbgvar].qualx,k2), foot_data->qual[kbgvar].
         qualx[k2].drug = c.drug,
         foot_data->qual[kbgvar].qualx[k2].antibiotic_cd = c.antibiotic_cd, foot_data->qual[kbgvar].
         qualx[k2].ord2 = c.ord2
        ENDIF
        kbgvar = numnotes
       ENDIF
     ENDFOR
     IF (found_note="F")
      numnotes = (numnotes+ 1), notenumber = numnotes, stat = alterlist(foot_data->qual,numnotes),
      stat = alterlist(foot_data->qual[numnotes].qualx,1), foot_data->qual[numnotes].qualx[1].drug =
      c.drug, foot_data->qual[numnotes].qualx[1].antibiotic_cd = c.antibiotic_cd,
      foot_data->qual[numnotes].qualx[1].ord2 = c.ord2, foot_data->qual[numnotes].long_blob_id = l
      .long_blob_id, foot_data->qual[numnotes].drug_id = c.antibiotic_cd,
      foot_data->qual[numnotes].printable_ind = 1, ret_meaning = fillstring(12," "), ret_display =
      fillstring(40," "),
      ret_description = fillstring(60," "),
      CALL uar_get_code(csf.compression_cd,ret_display,ret_meaning,ret_description)
      IF (trim(ret_meaning)="OCFCOMP")
       blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
        30000," "),
       blob_ret_len = 0,
       CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len),
       CALL uar_rtf2(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1),
       x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), x1 = size(trim(blob_out3))
       IF (x1 > 0)
        foot_data->qual[numnotes].text = blob_out3
       ENDIF
      ELSE
       blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = substring(1,(x1
         - 8),blob_contents),
       x1 = size(trim(blob_out2))
       IF (x1 > 0)
        foot_data->qual[numnotes].text = blob_out2
       ENDIF
      ENDIF
     ENDIF
     is_cor = 0, addbugger = "T", totnooforgs = size(org_rec->qual,5)
     FOR (xkount = 1 TO totnooforgs)
       IF ((c.ord2=org_rec->qual[xkount].ord2))
        addbugger = "F", currposorg = org_rec->qual[xkount].column
       ENDIF
     ENDFOR
     IF (addbugger="T")
      totnooforgs = (totnooforgs+ 1), stat = alterlist(org_rec->qual,totnooforgs), currposorg =
      totnooforgs,
      org_rec->qual[currposorg].accession_nbr = c.longacc, org_rec->qual[currposorg].isdosagepres = 0,
      org_rec->qual[currposorg].iscostperdosepres = 0,
      org_rec->qual[currposorg].istradenpres = 0, org_rec->qual[currposorg].bug_id = c.organism_cd,
      org_rec->qual[currposorg].bug_occur_num = c.organism_occurrence_nbr,
      org_rec->qual[currposorg].bug_name =
      IF (c.organism_occurrence_nbr <= 1) c.bug
      ELSE concat(trim(c.bug)," #",build(c.organism_occurrence_nbr))
      ENDIF
      , org_rec->qual[currposorg].column = currposorg, org_rec->qual[currposorg].ord2 = c.ord2,
      noofdetsusmethods = (size(org_rec->qual[currposorg].det_sus_method,5)+ 1), stat = alterlist(
       org_rec->qual[currposorg].det_sus_method,noofdetsusmethods), currdsm = noofdetsusmethods,
      org_rec->qual[currposorg].det_sus_method[currdsm].det_sus_cd = c.task_component_cd, org_rec->
      qual[currposorg].det_sus_method[currdsm].sus_test_cd = c.task_assay_cd, org_rec->qual[
      currposorg].det_sus_method[currdsm].mdt_ttf = c.mdt_ttf,
      org_rec->qual[currposorg].det_sus_method[currdsm].mt_ttf = c.mt_ttf, org_rec->qual[currposorg].
      det_sus_method[currdsm].display_order = c.display_order, org_rec->qual[currposorg].
      det_sus_method[currdsm].display =
      IF (suscmethoddisplay=0) c.susc_method_desc
      ELSE c.display
      ENDIF
      IF (size(trim(org_rec->qual[currposorg].det_sus_method[currdsm].display))=0)
       org_rec->qual[currposorg].det_sus_method[currdsm].display = c.display
      ENDIF
     ENDIF
     noofsm_inorgs = size(org_rec->qual[currposorg].det_sus_method,5), add_suscepmethbug = "T"
     FOR (xkount = 1 TO noofsm_inorgs)
       tmp_dscd = org_rec->qual[currposorg].det_sus_method[xkount].det_sus_cd, tmp_stcd = org_rec->
       qual[currposorg].det_sus_method[xkount].sus_test_cd, tmp_mdt_ttf = org_rec->qual[currposorg].
       det_sus_method[xkount].mdt_ttf,
       tmp_mt_ttf = org_rec->qual[currposorg].det_sus_method[xkount].mt_ttf, tmp_do = org_rec->qual[
       currposorg].det_sus_method[xkount].display_order
       IF (tmp_dscd=c.task_component_cd
        AND tmp_stcd=c.task_assay_cd
        AND tmp_mdt_ttf=c.mdt_ttf
        AND tmp_mt_ttf=c.mt_ttf)
        add_suscepmethbug = "F", currdsm = xkount, xkount = (noofsm_inorgs+ 1)
       ENDIF
     ENDFOR
     IF (add_suscepmethbug="T")
      noofsm_inorgs = (size(org_rec->qual[currposorg].det_sus_method,5)+ 1), stat = alterlist(org_rec
       ->qual[currposorg].det_sus_method,noofsm_inorgs), org_rec->qual[currposorg].det_sus_method[
      noofsm_inorgs].det_sus_cd = c.task_component_cd,
      org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].sus_test_cd = c.task_assay_cd, org_rec
      ->qual[currposorg].det_sus_method[noofsm_inorgs].mdt_ttf = c.mdt_ttf, org_rec->qual[currposorg]
      .det_sus_method[noofsm_inorgs].mt_ttf = c.mt_ttf,
      org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display_order = c.display_order,
      org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display =
      IF (suscmethoddisplay=0) c.susc_method_desc
      ELSE c.display
      ENDIF
      IF (size(trim(org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display))=0)
       org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display = c.display
      ENDIF
      currdsm = noofsm_inorgs
     ENDIF
     add_drug = "T", add_bug = "T", add_suscepmeth = "T",
     drug_qual = 0, totnoofdrugs = size(suscep_rec->drugresult,5)
     FOR (xkount = 1 TO totnoofdrugs)
       IF ((suscep_rec->drugresult[xkount].drug_id=c.antibiotic_cd))
        add_drug = "F", currposdrug = xkount, nooforgs_drug = size(suscep_rec->drugresult[xkount].
         orgresult,5)
        FOR (ykount = 1 TO nooforgs_drug)
          IF ((suscep_rec->drugresult[xkount].orgresult[ykount].ord2=c.ord2))
           add_bug = "F", currposorg_drug = ykount, noofsusceprsults = size(suscep_rec->drugresult[
            xkount].orgresult[ykount].suscep_result,5)
           FOR (zkount = 1 TO noofsusceprsults)
             tmp_dscd = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
             det_suscep_cd, tmp_stcd = suscep_rec->drugresult[xkount].orgresult[ykount].
             suscep_result[zkount].suscep_test_cd, tmp_mdt_ttf = suscep_rec->drugresult[xkount].
             orgresult[ykount].suscep_result[zkount].mdt_ttf,
             tmp_mt_ttf = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
             mt_ttf
             IF (tmp_dscd=c.task_component_cd
              AND tmp_stcd=c.task_assay_cd
              AND tmp_mdt_ttf=c.mdt_ttf
              AND tmp_mt_ttf=c.mt_ttf)
              add_suscepmeth = "F", currpossusmet_db = zkount, zkount = (noofsusceprsults+ 1)
             ENDIF
           ENDFOR
           ykount = (nooforgs_drug+ 1)
          ENDIF
        ENDFOR
        xkount = (totnoofdrugs+ 1)
       ENDIF
     ENDFOR
     IF (add_drug="T")
      totnoofdrugs = (totnoofdrugs+ 1), myorgs = 1, mynotes = 0,
      mycors = 0, mycors2 = 0, stat = alterlist(suscep_rec->drugresult,totnoofdrugs),
      currposdrug = totnoofdrugs, tmpsz = size(trim(c.drug),1)
      IF (maxdrugsize < tmpsz)
       maxdrugsize = (tmpsz+ 1)
      ENDIF
      suscep_rec->drugresult[currposdrug].drug_name = c.drug, suscep_rec->drugresult[currposdrug].
      drug_id = c.antibiotic_cd, nooforgs_drug = size(suscep_rec->drugresult[currposdrug].orgresult,5
       ),
      nooforgs_drug = (nooforgs_drug+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].
       orgresult,nooforgs_drug), currposorg_drug = nooforgs_drug,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].bug_id = c.organism_cd,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].ord2 = c.ord2, suscep_rec->
      drugresult[currposdrug].orgresult[currposorg_drug].bug_occur_num = c.organism_occurrence_nbr,
      noofsusrslts = (size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug],5)+ 1),
      currpossusmet_db = noofsusrslts, stat = alterlist(suscep_rec->drugresult[currposdrug].
       orgresult[currposorg_drug].suscep_result,noofsusrslts),
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      det_suscep_cd = c.task_component_cd, suscep_rec->drugresult[currposdrug].orgresult[
      currposorg_drug].suscep_result[noofsusrslts].suscep_test_cd = c.task_assay_cd, suscep_rec->
      drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].mt_ttf = c
      .mt_ttf,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      mdt_ttf = c.mdt_ttf, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
      suscep_result[noofsusrslts].display_order = c.display_order, suscep_rec->drugresult[currposdrug
      ].orgresult[currposorg_drug].suscep_result[noofsusrslts].column = currdsm,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      cost_per_dose = c.cost_per_dose, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug]
      .suscep_result[noofsusrslts].dosage = c.dosage, suscep_rec->drugresult[currposdrug].orgresult[
      currposorg_drug].suscep_result[noofsusrslts].trade_name = c.trade_name,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].column = currposorg,
      currpossusmet_db = noofsusrslts, last_ce_id = c.clinical_event_id,
      lastbug = c.organism_cd, lastoccur = c.organism_occurrence_nbr, lastdrug = c.antibiotic_cd,
      lastacc = myacc, s1 = currposdrug, s2 = 1,
      add_suscepmeth = "F"
     ELSEIF (add_bug="T"
      AND add_drug="F")
      nooforgs_drug = size(suscep_rec->drugresult[currposdrug].orgresult,5), nooforgs_drug = (
      nooforgs_drug+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult,nooforgs_drug
       ),
      currposorg_drug = nooforgs_drug, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug]
      .bug_id = c.organism_cd, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].ord2 =
      c.ord2,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].bug_occur_num = c
      .organism_occurrence_nbr, noofsusrslts = (size(suscep_rec->drugresult[currposdrug].orgresult[
       currposorg_drug],5)+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult[
       currposorg_drug].suscep_result,noofsusrslts),
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      det_suscep_cd = c.task_component_cd, suscep_rec->drugresult[currposdrug].orgresult[
      currposorg_drug].suscep_result[noofsusrslts].suscep_test_cd = c.task_assay_cd, suscep_rec->
      drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].mt_ttf = c
      .mt_ttf,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      mdt_ttf = c.mdt_ttf, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
      suscep_result[noofsusrslts].display_order = c.display_order, suscep_rec->drugresult[currposdrug
      ].orgresult[currposorg_drug].suscep_result[noofsusrslts].column = currdsm,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].column = currposorg, suscep_rec
      ->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].cost_per_dose
       = c.cost_per_dose, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
      suscep_result[noofsusrslts].dosage = c.dosage,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
      trade_name = c.trade_name, last_ce_id = c.clinical_event_id, lastbug = c.organism_cd,
      lastoccur = c.organism_occurrence_nbr, lastdrug = c.antibiotic_cd, lastacc = myacc,
      s2 = currposorg_drug, currpossusmet_db = noofsusrslts, add_suscepmeth = "F"
     ENDIF
     mynotes = size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].notes,5),
     found_note = "F"
     FOR (i = 1 TO mynotes)
       IF ((suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].notes[i].note_num=
       notenumber))
        found_note = "T"
       ENDIF
     ENDFOR
     IF (found_note="F")
      mynotes = (mynotes+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult[
       currposorg_drug].notes,mynotes), suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug
      ].notes[mynotes].note_num = notenumber,
      suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].note_ind = 1
     ENDIF
    ENDIF
   DETAIL
    kountrows = (kountrows+ 1)
    IF (c.text_order=otherrpt
     AND note="INTP")
     foundint = "F"
     FOR (intcheckvar = 1 TO num_interps)
       IF ((interp_data->qual[intcheckvar].event_id=c.event_id))
        IF ((n.valid_from_dt_tm > interp_data->qual[intcheckvar].valid_from_dt_tm))
         foundint = "R"
        ELSE
         foundint = "T"
        ENDIF
       ENDIF
     ENDFOR
     IF (((foundint="F") OR (foundint="R")) )
      ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
      fillstring(60," "),
      CALL uar_get_code(n.compression_cd,ret_display,ret_meaning,ret_description)
      IF (trim(ret_meaning)="OCFCOMP")
       blob_out = fillstring(30000," "), blob_out2 = fillstring(30000," "), blob_out3 = fillstring(
        30000," "),
       blob_ret_len = 0,
       CALL uar_ocf_uncompress(blob_contents,30000,blob_out,30000,blob_ret_len),
       CALL uar_rtf2(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1),
       x1 = size(trim(blob_out2)), blob_out3 = substring(1,x1,blob_out2), x1 = size(trim(blob_out3))
       IF (x1 > 0)
        IF (foundint="F")
         num_interps = (num_interps+ 1)
        ENDIF
        stat = alterlist(interp_data->qual,num_interps), interp_data->qual[num_interps].text_id = lb
        .long_blob_id, interp_data->qual[num_interps].catalog_cd = c.catalog_cd,
        interp_data->qual[num_interps].report_text = blob_out3, interp_data->qual[num_interps].
        event_id = c.event_id, interp_data->qual[num_interps].valid_from_dt_tm = n.valid_from_dt_tm
       ENDIF
      ELSE
       blob_out2 = fillstring(30000," "), x1 = size(trim(blob_contents)), blob_out2 = substring(1,(x1
         - 8),blob_contents),
       x1 = size(trim(blob_out2))
       IF (x1 > 0)
        IF (foundint="F")
         num_interps = (num_interps+ 1)
        ENDIF
        stat = alterlist(interp_data->qual,num_interps), interp_data->qual[num_interps].text_id = lb
        .long_blob_id, interp_data->qual[num_interps].catalog_cd = c.catalog_cd,
        interp_data->qual[num_interps].report_text = blob_out2, interp_data->qual[num_interps].
        event_id = c.event_id, interp_data->qual[num_interps].valid_from_dt_tm = n.valid_from_dt_tm
       ENDIF
      ENDIF
      reject = "T"
     ENDIF
    ENDIF
    IF (note="ORDC"
     AND nordcommentflag=0)
     addit = "T"
     IF (numcoms > 0)
      FOR (comvar = 1 TO numcoms)
        IF ((order_comment->qual[comvar].order_id=oc.order_id)
         AND (order_comment->qual[comvar].action_sequence=oc.action_sequence))
         addit = "F"
        ENDIF
      ENDFOR
     ENDIF
     IF (addit="T")
      numcoms = (numcoms+ 1), stat = alterlist(order_comment->qual,numcoms), order_comment->qual[
      numcoms].text_id = lx.long_text_id,
      order_comment->qual[numcoms].order_id = oc.order_id, order_comment->qual[numcoms].
      action_sequence = oc.action_sequence, order_comment->qual[numcoms].report_text = text_contents
     ENDIF
    ENDIF
    IF (c.side=0)
     row + 0
    ELSEIF (c.side=1
     AND did_accn_print_susc="T")
     is_cor = (is_cor+ 1), sup_footer_needed = "T"
     IF (is_cor IN (0, 1))
      add_drug = "F", add_bug = "F"
      IF (c.side=1)
       is_cor = 0, addbugger = "T", totnooforgs = size(org_rec->qual,5)
       FOR (xkount = 1 TO totnooforgs)
         IF ((c.ord2=org_rec->qual[xkount].ord2))
          addbugger = "F", currposorg = org_rec->qual[xkount].column
         ENDIF
       ENDFOR
       IF (addbugger="T")
        totnooforgs = (totnooforgs+ 1), stat = alterlist(org_rec->qual,totnooforgs), currposorg =
        totnooforgs,
        org_rec->qual[currposorg].accession_nbr = c.longacc, org_rec->qual[currposorg].isdosagepres
         = 0, org_rec->qual[currposorg].iscostperdosepres = 0,
        org_rec->qual[currposorg].istradenpres = 0, org_rec->qual[currposorg].bug_id = c.organism_cd,
        org_rec->qual[currposorg].bug_occur_num = c.organism_occurrence_nbr,
        org_rec->qual[currposorg].bug_name =
        IF (c.organism_occurrence_nbr <= 1) c.bug
        ELSE concat(trim(c.bug)," #",build(c.organism_occurrence_nbr))
        ENDIF
        , org_rec->qual[currposorg].column = currposorg, org_rec->qual[currposorg].ord2 = c.ord2,
        noofdetsusmethods = (size(org_rec->qual[currposorg].det_sus_method,5)+ 1), stat = alterlist(
         org_rec->qual[currposorg].det_sus_method,noofdetsusmethods), currdsm = noofdetsusmethods,
        org_rec->qual[currposorg].det_sus_method[currdsm].det_sus_cd = c.task_component_cd, org_rec->
        qual[currposorg].det_sus_method[currdsm].sus_test_cd = c.task_assay_cd, org_rec->qual[
        currposorg].det_sus_method[currdsm].mdt_ttf = c.mdt_ttf,
        org_rec->qual[currposorg].det_sus_method[currdsm].mt_ttf = c.mt_ttf, org_rec->qual[currposorg
        ].det_sus_method[currdsm].display_order = c.display_order, org_rec->qual[currposorg].
        det_sus_method[currdsm].display =
        IF (suscmethoddisplay=0) c.susc_method_desc
        ELSE c.display
        ENDIF
        IF (size(trim(org_rec->qual[currposorg].det_sus_method[currdsm].display))=0)
         org_rec->qual[currposorg].det_sus_method[currdsm].display = c.display
        ENDIF
       ENDIF
       noofsm_inorgs = size(org_rec->qual[currposorg].det_sus_method,5), add_suscepmethbug = "T"
       FOR (xkount = 1 TO noofsm_inorgs)
         tmp_dscd = org_rec->qual[currposorg].det_sus_method[xkount].det_sus_cd, tmp_stcd = org_rec->
         qual[currposorg].det_sus_method[xkount].sus_test_cd, tmp_mdt_ttf = org_rec->qual[currposorg]
         .det_sus_method[xkount].mdt_ttf,
         tmp_mt_ttf = org_rec->qual[currposorg].det_sus_method[xkount].mt_ttf, tmp_do = org_rec->
         qual[currposorg].det_sus_method[xkount].display_order
         IF (tmp_dscd=c.task_component_cd
          AND tmp_stcd=c.task_assay_cd
          AND tmp_mdt_ttf=c.mdt_ttf
          AND tmp_mt_ttf=c.mt_ttf)
          add_suscepmethbug = "F", currdsm = xkount, xkount = (noofsm_inorgs+ 1)
         ENDIF
       ENDFOR
       IF (add_suscepmethbug="T")
        noofsm_inorgs = (size(org_rec->qual[currposorg].det_sus_method,5)+ 1), stat = alterlist(
         org_rec->qual[currposorg].det_sus_method,noofsm_inorgs), org_rec->qual[currposorg].
        det_sus_method[noofsm_inorgs].det_sus_cd = c.task_component_cd,
        org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].sus_test_cd = c.task_assay_cd,
        org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].mdt_ttf = c.mdt_ttf, org_rec->qual[
        currposorg].det_sus_method[noofsm_inorgs].mt_ttf = c.mt_ttf,
        org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display_order = c.display_order,
        org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display =
        IF (suscmethoddisplay=0) c.susc_method_desc
        ELSE c.display
        ENDIF
        IF (size(trim(org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display))=0)
         org_rec->qual[currposorg].det_sus_method[noofsm_inorgs].display = c.display
        ENDIF
        currdsm = noofsm_inorgs
       ENDIF
       add_drug = "T", add_bug = "T", add_suscepmeth = "T",
       drug_qual = 0, totnoofdrugs = size(suscep_rec->drugresult,5)
       FOR (xkount = 1 TO totnoofdrugs)
         IF ((suscep_rec->drugresult[xkount].drug_id=c.antibiotic_cd))
          add_drug = "F", currposdrug = xkount, nooforgs_drug = size(suscep_rec->drugresult[xkount].
           orgresult,5)
          FOR (ykount = 1 TO nooforgs_drug)
            IF ((suscep_rec->drugresult[xkount].orgresult[ykount].ord2=c.ord2))
             add_bug = "F", currposorg_drug = ykount, noofsusceprsults = size(suscep_rec->drugresult[
              xkount].orgresult[ykount].suscep_result,5)
             FOR (zkount = 1 TO noofsusceprsults)
               tmp_dscd = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
               det_suscep_cd, tmp_stcd = suscep_rec->drugresult[xkount].orgresult[ykount].
               suscep_result[zkount].suscep_test_cd, tmp_mdt_ttf = suscep_rec->drugresult[xkount].
               orgresult[ykount].suscep_result[zkount].mdt_ttf,
               tmp_mt_ttf = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
               mt_ttf
               IF (tmp_dscd=c.task_component_cd
                AND tmp_stcd=c.task_assay_cd
                AND tmp_mdt_ttf=c.mdt_ttf
                AND tmp_mt_ttf=c.mt_ttf)
                add_suscepmeth = "F", currpossusmet_db = zkount, zkount = (noofsusceprsults+ 1)
               ENDIF
             ENDFOR
             ykount = (nooforgs_drug+ 1)
            ENDIF
          ENDFOR
          xkount = (totnoofdrugs+ 1)
         ENDIF
       ENDFOR
       IF (add_drug="T")
        totnoofdrugs = (totnoofdrugs+ 1), myorgs = 1, mynotes = 0,
        mycors = 0, mycors2 = 0, stat = alterlist(suscep_rec->drugresult,totnoofdrugs),
        currposdrug = totnoofdrugs, tmpsz = size(trim(c.drug),1)
        IF (maxdrugsize < tmpsz)
         maxdrugsize = (tmpsz+ 1)
        ENDIF
        suscep_rec->drugresult[currposdrug].drug_name = c.drug, suscep_rec->drugresult[currposdrug].
        drug_id = c.antibiotic_cd, nooforgs_drug = size(suscep_rec->drugresult[currposdrug].orgresult,
         5),
        nooforgs_drug = (nooforgs_drug+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].
         orgresult,nooforgs_drug), currposorg_drug = nooforgs_drug,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].bug_id = c.organism_cd,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].ord2 = c.ord2, suscep_rec->
        drugresult[currposdrug].orgresult[currposorg_drug].bug_occur_num = c.organism_occurrence_nbr,
        noofsusrslts = (size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug],5)+ 1),
        currpossusmet_db = noofsusrslts, stat = alterlist(suscep_rec->drugresult[currposdrug].
         orgresult[currposorg_drug].suscep_result,noofsusrslts),
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        det_suscep_cd = c.task_component_cd, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].suscep_test_cd = c.task_assay_cd, suscep_rec->
        drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].mt_ttf = c
        .mt_ttf,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        mdt_ttf = c.mdt_ttf, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
        suscep_result[noofsusrslts].display_order = c.display_order, suscep_rec->drugresult[
        currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].column = currdsm,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        cost_per_dose = c.cost_per_dose, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].dosage = c.dosage, suscep_rec->drugresult[
        currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].trade_name = c.trade_name,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].column = currposorg,
        currpossusmet_db = noofsusrslts, last_ce_id = c.clinical_event_id,
        lastbug = c.organism_cd, lastoccur = c.organism_occurrence_nbr, lastdrug = c.antibiotic_cd,
        lastacc = myacc, s1 = currposdrug, s2 = 1,
        add_suscepmeth = "F"
       ELSEIF (add_bug="T"
        AND add_drug="F")
        nooforgs_drug = size(suscep_rec->drugresult[currposdrug].orgresult,5), nooforgs_drug = (
        nooforgs_drug+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult,
         nooforgs_drug),
        currposorg_drug = nooforgs_drug, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].bug_id = c.organism_cd, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].ord2 = c.ord2,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].bug_occur_num = c
        .organism_occurrence_nbr, noofsusrslts = (size(suscep_rec->drugresult[currposdrug].orgresult[
         currposorg_drug],5)+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult[
         currposorg_drug].suscep_result,noofsusrslts),
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        det_suscep_cd = c.task_component_cd, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].suscep_test_cd = c.task_assay_cd, suscep_rec->
        drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].mt_ttf = c
        .mt_ttf,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        mdt_ttf = c.mdt_ttf, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
        suscep_result[noofsusrslts].display_order = c.display_order, suscep_rec->drugresult[
        currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].column = currdsm,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].column = currposorg,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        cost_per_dose = c.cost_per_dose, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].dosage = c.dosage,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        trade_name = c.trade_name, last_ce_id = c.clinical_event_id, lastbug = c.organism_cd,
        lastoccur = c.organism_occurrence_nbr, lastdrug = c.antibiotic_cd, lastacc = myacc,
        s2 = currposorg_drug, currpossusmet_db = noofsusrslts, add_suscepmeth = "F"
       ENDIF
       nosms_od = size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result,5
        )
       IF (add_suscepmeth="T")
        noofsusrslts = (size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
         suscep_result,5)+ 1), stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult[
         currposorg_drug].suscep_result,noofsusrslts), suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].det_suscep_cd = c.task_component_cd,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        suscep_test_cd = c.task_assay_cd, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].mt_ttf = c.mt_ttf, suscep_rec->drugresult[
        currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].mdt_ttf = c.mdt_ttf,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        display_order = c.display_order, suscep_rec->drugresult[currposdrug].orgresult[
        currposorg_drug].suscep_result[noofsusrslts].column = currdsm, suscep_rec->drugresult[
        currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].cost_per_dose = c
        .cost_per_dose,
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[noofsusrslts].
        dosage = c.dosage, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
        suscep_result[noofsusrslts].trade_name = c.trade_name, currpossusmet_db = noofsusrslts
       ENDIF
       IF (size(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[
        currpossusmet_db].result)=0)
        suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[currpossusmet_db
        ].result = c.result, suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
        suscep_result[currpossusmet_db].suscep_seq_nbr = c.suscep_seq_nbr
       ELSEIF ((suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].suscep_result[
       currpossusmet_db].suscep_seq_nbr != c.suscep_seq_nbr)
        AND numnotes > 0
        AND (foot_data->qual[numnotes].long_blob_id=l.long_blob_id))
        foot_data->qual[numnotes].printable_ind = 0, nbrnotes = size(suscep_rec->drugresult[
         currposdrug].orgresult[currposorg_drug].notes,5)
        IF (nbrnotes=1)
         suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].note_ind = 0
        ENDIF
        stat = alterlist(suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].notes,(
         nbrnotes - 1))
       ENDIF
       is_cor = 0
       IF (c.dosage > " ")
        org_rec->qual[currposorg].isdosagepres = 1
       ENDIF
       IF (c.cost_per_dose > " ")
        org_rec->qual[currposorg].iscostperdosepres = 1
       ENDIF
       IF (c.trade_name > " ")
        org_rec->qual[currposorg].istradenpres = 1
       ENDIF
      ENDIF
     ENDIF
     IF (c.status="C"
      AND c.cor_type != "X"
      AND (c.suscep_seq_nbr=suscep_rec->drugresult[currposdrug].orgresult[currposorg_drug].
     suscep_result[currpossusmet_db].suscep_seq_nbr))
      IF (((datetimediff(cnvtdatetime(c.corrected_date),cnvtdatetime(cor_data->qual[numcors].
        corrected_date)) != 0
       AND (c.cor_type=cor_data->qual[numcors].data_type)) OR (((numcors=0) OR ((((c.cor_type !=
      cor_data->qual[numcors].data_type)
       AND c.cor_type != "X") OR ((((c.drug != cor_data->qual[numcors].drug)) OR ((((c.res_type !=
      cor_data->qual[numcors].res_type)) OR ((c.suscep_seq_nbr != cor_data->qual[numcors].
      suscep_seq_nbr))) )) )) )) )) )
       numcors = (numcors+ 1), cc_column = 0
       FOR (cc = 1 TO size(org_rec->qual,5))
         IF ((org_rec->qual[cc].ord2=c.ord2))
          cc_column = org_rec->qual[cc].column
         ENDIF
       ENDFOR
       stat = alterlist(cor_data->qual,numcors), cor_data->qual[numcors].suscep_seq_nbr = c
       .suscep_seq_nbr, cor_data->qual[numcors].column = cc_column,
       cor_data->qual[numcors].corrected_date = c.corrected_date, cor_data->qual[numcors].data_type
        = c.cor_type, cor_data->qual[numcors].old_interp_type =
       IF (suscmethoddisplay=0) c.susc_method_desc
       ELSE c.display
       ENDIF
       IF (size(trim(cor_data->qual[numcors].old_interp_type))=0)
        cor_data->qual[numcors].old_interp_type = c.display
       ENDIF
       cor_data->qual[numcors].drug = c.drug, cor_data->qual[numcors].res_type = c.res_type
       IF (c.cor_type="I")
        cor_data->qual[numcors].old_interp_type =
        IF (suscmethoddisplay=0) c.susc_method_desc
        ELSE c.display
        ENDIF
        IF (size(trim(cor_data->qual[numcors].old_interp_type))=0)
         cor_data->qual[numcors].old_interp_type = c.display
        ENDIF
        cor_data->qual[numcors].old_interp = trim(c.old_interp)
       ELSEIF (c.cor_type="R")
        cor_data->qual[numcors].old_interp_type =
        IF (suscmethoddisplay=0) c.susc_method_desc
        ELSE c.display
        ENDIF
        IF (size(trim(cor_data->qual[numcors].old_interp_type))=0)
         cor_data->qual[numcors].old_interp_type = c.display
        ENDIF
        cor_data->qual[numcors].old_result = trim(c.old_result)
       ELSEIF (c.cor_type="K")
        cor_data->qual[numcors].old_interp_type =
        IF (suscmethoddisplay=0) c.susc_method_desc
        ELSE c.display
        ENDIF
        IF (size(trim(cor_data->qual[numcors].old_interp_type))=0)
         cor_data->qual[numcors].old_interp_type = c.display
        ENDIF
        cor_data->qual[numcors].old_result = format(c.old_zone,";c")
       ENDIF
       cor_data->qual[numcors].new_v_dt_tm =
       IF (((numcors=1) OR ((cor_data->qual[(numcors - 1)].data_type != c.cor_type))) ) cnvtdatetime(
         c.result_dt_tm)
       ELSEIF ((cor_data->qual[(numcors - 1)].data_type=c.cor_type)) cnvtdatetime(cor_data->qual[(
         numcors - 1)].corrected_date)
       ENDIF
       , cor_data->qual[numcors].old_v_dt_tm = cnvtdatetime(c.verified_dt_tm), totnoofdrugs = size(
        suscep_rec->drugresult,5)
       FOR (xkount = 1 TO totnoofdrugs)
         IF ((suscep_rec->drugresult[xkount].drug_id=c.antibiotic_cd))
          add_drug = "F", currposdrug = xkount, nooforgs_drug = size(suscep_rec->drugresult[xkount].
           orgresult,5)
          FOR (ykount = 1 TO nooforgs_drug)
            IF ((suscep_rec->drugresult[xkount].orgresult[ykount].bug_id=c.organism_cd)
             AND (suscep_rec->drugresult[xkount].orgresult[ykount].bug_occur_num=c
            .organism_occurrence_nbr))
             add_bug = "F", currposorg_drug = ykount, noofsusceprsults = size(suscep_rec->drugresult[
              xkount].orgresult[ykount].suscep_result,5)
             FOR (zkount = 1 TO noofsusceprsults)
               tmp_dscd = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
               det_suscep_cd, tmp_stcd = suscep_rec->drugresult[xkount].orgresult[ykount].
               suscep_result[zkount].suscep_test_cd, tmp_mdt_ttf = suscep_rec->drugresult[xkount].
               orgresult[ykount].suscep_result[zkount].mdt_ttf,
               tmp_mt_ttf = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
               mt_ttf
               IF (tmp_dscd=c.task_component_cd
                AND tmp_stcd=c.task_assay_cd
                AND tmp_mdt_ttf=c.mdt_ttf
                AND tmp_mt_ttf=c.mt_ttf)
                mycors = (size(suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount]
                 .cor_data)+ 1), stat = alterlist(suscep_rec->drugresult[xkount].orgresult[ykount].
                 suscep_result[zkount].cor_data,mycors)
                IF (c.verified_dt_tm != null)
                 IF (utc_on)
                  zone = datetimezonebyindex(c.verified_tz,utcoffset,daylight,7,c.verified_dt_tm),
                  suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].cor_data[
                  mycors].ver_dt_tm = concat(trim(format(datetimezone(c.verified_dt_tm,c.verified_tz),
                     sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c.verified_dt_tm,c
                      .verified_tz),stimemask_tz))," ",zone)
                 ELSE
                  suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].cor_data[
                  mycors].ver_dt_tm = concat(trim(format(c.verified_dt_tm,date_mask),3)," ",cnvtupper
                   (format(c.verified_dt_tm,time_mask)))
                 ENDIF
                ENDIF
                IF (utc_on)
                 zone = datetimezonebyindex(c.result_tz,utcoffset,daylight,7,c.result_dt_tm),
                 suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].cor_data[
                 mycors].cor_dt_tm = concat(trim(format(datetimezone(c.result_dt_tm,c.result_tz),
                    sdatemask_tz),3)," ",cnvtupper(format(datetimezone(c.result_dt_tm,c.result_tz),
                    stimemask_tz))," ",zone)
                ELSE
                 suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].cor_data[
                 mycors].cor_dt_tm = concat(trim(format(c.result_dt_tm,date_mask),3)," ",cnvtupper(
                   format(c.result_dt_tm,time_mask)))
                ENDIF
                suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].cor_data[
                mycors].cor_result = c.result, zkount = (noofsusceprsults+ 1)
               ENDIF
             ENDFOR
             ykount = (nooforgs_drug+ 1)
            ENDIF
          ENDFOR
          xkount = (totnoofdrugs+ 1)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   FOOT  c.catalog_cd
    bug_column = 0, org_cnt = 0, size_orgs = size(org_rec->qual,5),
    size_out = 0, size_cordata = 0, d = 0,
    e = 0, drug_cnt = 0
    IF (did_accn_print_susc="T")
     sup_footer_needed = "T", row + 1, col 0,
     ">>"
     IF (size(trim(labelsuscresults)) > 0)
      IF (isbold=1)
       row + 1, col 0, boldchars,
       labelsuscresults
      ELSE
       row + 1, col 0, labelsuscresults
      ENDIF
     ENDIF
     CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, "",
     row + 1, col 0, "<<"
    ELSE
     sup_footer_needed = "F"
    ENDIF
    FOR (d = 1 TO size_orgs)
      org_cnt = (org_cnt+ 1), stat = alterlist(corr_display->organisms,org_cnt), corr_display->
      organisms[org_cnt].organism_name = org_rec->qual[d].bug_name,
      bugcolumn = org_rec->qual[d].column, size_cordata = size(cor_data->qual,5), drug_cnt = 0
      FOR (e = 1 TO size_cordata)
        IF ((cor_data->qual[e].column=bugcolumn)
         AND (org_rec->qual[d].accession_nbr=c.longacc))
         drug_cnt = (drug_cnt+ 1), stat = alterlist(corr_display->organisms[d].antibiotics,drug_cnt),
         corr_display->organisms[d].antibiotics[drug_cnt].antibiotic_name = trim(cor_data->qual[e].
          drug),
         corr_display->organisms[d].antibiotics[drug_cnt].data_type = cor_data->qual[e].data_type,
         corr_display->organisms[d].antibiotics[drug_cnt].old_interp_type = trim(cor_data->qual[e].
          old_interp_type), corr_display->organisms[d].antibiotics[drug_cnt].old_result = trim(
          cor_data->qual[e].old_result),
         corr_display->organisms[d].antibiotics[drug_cnt].old_interp = trim(cor_data->qual[e].
          old_interp), corr_display->organisms[d].antibiotics[drug_cnt].old_v_dt_tm = cor_data->qual[
         e].old_v_dt_tm, corr_display->organisms[d].antibiotics[drug_cnt].new_v_dt_tm = cor_data->
         qual[e].new_v_dt_tm,
         corr_display->organisms[d].antibiotics[drug_cnt].corrected_date = cor_data->qual[e].
         corrected_date, corr_display->organisms[d].antibiotics[drug_cnt].res_type = trim(cor_data->
          qual[e].res_type), corr_display->organisms[d].antibiotics[drug_cnt].column = cor_data->
         qual[e].column,
         corr_display->organisms[d].has_corrections = 1
        ENDIF
      ENDFOR
    ENDFOR
    IF (((c.side=1) OR (size(suscep_rec->drugresult,5) > 0)) )
     totnooforgs = size(org_rec->qual,5)
     IF (totnooforgs > 3)
      overflow = "T"
     ELSE
      overflow = "F"
     ENDIF
     orgs_remaining = totnooforgs, definterpwidth = interp_width, defresultwidth = dilution_width,
     defstartpos = (maxdrugsize+ 5), defaultendpos = 120, def_trade_name_width = trade_name_width,
     def_cost_per_dose_width = cost_per_dos_width, def_dosage_width = dosage_width, stat = alterlist(
      table_rec->qual,max_no_of_orgs_horiz),
     offset = 0, done = "F", hrows = 0,
     tot_cols = 0, orgs_printed = 0
     WHILE (orgs_remaining > 0)
       susc_print_rows = 0, max_row_num = 0, row + 1,
       col 0, ">>", row + 1
       FOR (xkount = 1 TO max_no_of_orgs_horiz)
         table_rec->qual[xkount].noofinterps = 0
       ENDFOR
       noofbugsintable = 0, xkount = 1, forceout = 0,
       currcolpos = defstartpos, tot_cols = 0
       WHILE (forceout=0)
         noofbugsintable = (noofbugsintable+ 1), subval = ((xkount+ totnooforgs) - orgs_remaining),
         table_rec->qual[xkount].noofinterps = size(org_rec->qual[subval].det_sus_method,5),
         currcols = 0, currcols = (currcols+ table_rec->qual[xkount].noofinterps)
         IF (iscostperdosechartable=1)
          IF ((org_rec->qual[subval].iscostperdosepres=1))
           currcols = (currcols+ 1)
          ENDIF
         ENDIF
         IF (istradenchartable=1)
          IF ((org_rec->qual[subval].istradenpres=1))
           currcols = (currcols+ 2)
          ENDIF
         ENDIF
         IF (isdosagechartable=1)
          IF ((org_rec->qual[subval].isdosagepres=1))
           currcols = (currcols+ 1)
          ENDIF
         ENDIF
         tot_cols = (tot_cols+ currcols)
         IF (tot_cols > 6
          AND noofbugsintable > 1)
          tot_cols = (tot_cols - currcols), noofbugsintable = (noofbugsintable - 1), table_rec->qual[
          xkount].noofinterps = 0,
          forceout = 1
         ENDIF
         xkount = (xkount+ 1)
         IF (xkount > minval(max_no_of_orgs_horiz,orgs_remaining))
          forceout = 1
         ENDIF
       ENDWHILE
       currv = 1
       FOR (xkount = 1 TO noofbugsintable)
         subval = ((xkount+ totnooforgs) - orgs_remaining), noofdetsusmethods = size(org_rec->qual[
          subval].det_sus_method,5), stat = alterlist(table_rec->qual[xkount].sm,noofdetsusmethods)
         FOR (ykount = 1 TO noofdetsusmethods)
           table_rec->qual[xkount].sm[ykount].col = ykount, table_rec->qual[xkount].sm[ykount].
           sus_test_cd = org_rec->qual[subval].det_sus_method[ykount].sus_test_cd, table_rec->qual[
           xkount].sm[ykount].display_order = org_rec->qual[subval].det_sus_method[ykount].
           display_order
         ENDFOR
         FOR (ykount = 1 TO noofdetsusmethods)
           FOR (zkount = (ykount+ 1) TO noofdetsusmethods)
             IF ((table_rec->qual[xkount].sm[ykount].sus_test_cd > table_rec->qual[xkount].sm[zkount]
             .sus_test_cd))
              currv = table_rec->qual[xkount].sm[ykount].sus_test_cd, table_rec->qual[xkount].sm[
              ykount].sus_test_cd = table_rec->qual[xkount].sm[zkount].sus_test_cd, table_rec->qual[
              xkount].sm[zkount].sus_test_cd = currv,
              currv = table_rec->qual[xkount].sm[ykount].display_order, table_rec->qual[xkount].sm[
              ykount].display_order = table_rec->qual[xkount].sm[zkount].display_order, table_rec->
              qual[xkount].sm[zkount].display_order = currv,
              currv = table_rec->qual[xkount].sm[ykount].col, table_rec->qual[xkount].sm[ykount].col
               = table_rec->qual[xkount].sm[zkount].col, table_rec->qual[xkount].sm[zkount].col =
              currv
             ELSEIF ((table_rec->qual[xkount].sm[ykount].sus_test_cd=table_rec->qual[xkount].sm[
             zkount].sus_test_cd))
              IF ((table_rec->qual[xkount].sm[ykount].display_order > table_rec->qual[xkount].sm[
              zkount].display_order))
               currv = table_rec->qual[xkount].sm[ykount].sus_test_cd, table_rec->qual[xkount].sm[
               ykount].sus_test_cd = table_rec->qual[xkount].sm[zkount].sus_test_cd, table_rec->qual[
               xkount].sm[zkount].sus_test_cd = currv,
               currv = table_rec->qual[xkount].sm[ykount].display_order, table_rec->qual[xkount].sm[
               ykount].display_order = table_rec->qual[xkount].sm[zkount].display_order, table_rec->
               qual[xkount].sm[zkount].display_order = currv,
               currv = table_rec->qual[xkount].sm[ykount].col, table_rec->qual[xkount].sm[ykount].col
                = table_rec->qual[xkount].sm[zkount].col, table_rec->qual[xkount].sm[zkount].col =
               currv
              ENDIF
             ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
       startval = 30, isbugdisclaimer = 0
       FOR (xkount = 1 TO noofbugsintable)
         subval = ((xkount+ totnooforgs) - orgs_remaining), table_rec->qual[xkount].bugnames1 =
         currcolpos, noofdetsusmethods = size(org_rec->qual[subval].det_sus_method,5),
         CALL echo(build(" XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ",noofdetsusmethods))
         IF (noofdetsusmethods > 6)
          isbugdisclaimer = 1
         ENDIF
         FOR (ykount = 1 TO noofdetsusmethods)
           lcol = table_rec->qual[xkount].sm[ykount].col, org_rec->qual[subval].det_sus_method[lcol].
           col_start = currcolpos
           IF ((org_rec->qual[subval].det_sus_method[lcol].mdt_ttf=7))
            org_rec->qual[subval].det_sus_method[lcol].col_end = (currcolpos+ definterpwidth),
            currcolpos = ((currcolpos+ definterpwidth)+ 2)
            IF (underline_sus_headings=1)
             org_rec->qual[subval].det_sus_method[lcol].col_underline = substring(1,(defresultwidth
               - 2),u100)
            ENDIF
           ELSE
            org_rec->qual[subval].det_sus_method[lcol].col_end = (currcolpos+ defresultwidth),
            currcolpos = ((currcolpos+ defresultwidth)+ 2)
            IF (underline_sus_headings=1)
             org_rec->qual[subval].det_sus_method[lcol].col_underline = substring(1,(definterpwidth
               - 2),u100)
            ENDIF
           ENDIF
         ENDFOR
         IF (isdosagechartable=1)
          IF ((org_rec->qual[subval].isdosagepres=1))
           org_rec->qual[subval].d_start = currcolpos, currcolpos = ((currcolpos+ def_dosage_width)+
           2)
          ENDIF
         ENDIF
         IF (iscostperdosechartable=1)
          IF ((org_rec->qual[subval].iscostperdosepres=1))
           org_rec->qual[subval].cpd_start = currcolpos, currcolpos = ((currcolpos+
           def_cost_per_dose_width)+ 2)
          ENDIF
         ENDIF
         IF (istradenchartable=1)
          IF ((org_rec->qual[subval].istradenpres=1))
           org_rec->qual[subval].tn_start = currcolpos, currcolpos = ((currcolpos+
           def_trade_name_width)+ 2)
          ENDIF
         ENDIF
       ENDFOR
       IF (isisolateleft=0)
        IF (isisolateoneline=0)
         noofrows = 5
        ELSE
         noofrows = 1
        ENDIF
        line_cnt_for_org = 0, last_org_row_cnt = 0
        FOR (hrows = 1 TO noofrows)
          FOR (xkount = 1 TO minval(noofbugsintable,orgs_remaining))
            subval = ((xkount+ totnooforgs) - orgs_remaining), b1 = trim(substring(1,60,org_rec->
              qual[subval].bug_name)), outval1 = fillstring(60," "),
            outval2 = fillstring(60," "), outval3 = fillstring(60," "), outval4 = fillstring(60," "),
            outval5 = fillstring(60," "), outval6 = fillstring(60," "), outval7 = fillstring(60," "),
            outval8 = fillstring(60," "), outval9 = fillstring(60," "), outval10 = fillstring(60," "),
            len1 = findstring(" ",b1), len2 = (size(b1) - len1), stat = movestring(b1,1,outval1,1,
             len1),
            stat = movestring(b1,(len1+ 1),outval2,1,len2), len3 = findstring(" ",outval2), len4 = (
            size(outval2) - len3),
            stat = movestring(outval2,1,outval3,1,(len3 - 1)), stat = movestring(outval2,(len3+ 1),
             outval4,1,len4), len5 = findstring(" ",outval4),
            len6 = (size(outval3) - len5), stat = movestring(outval4,1,outval5,1,(len5 - 1)), stat =
            movestring(outval4,(len5+ 1),outval6,1,(len6 - 1)),
            len7 = findstring(" ",outval6), len8 = (size(outval6) - len7), stat = movestring(outval6,
             1,outval7,1,(len7 - 1)),
            stat = movestring(outval6,(len7+ 1),outval8,1,(len8 - 1)), len9 = findstring(" ",outval8),
            len10 = (size(outval8) - len9),
            stat = movestring(outval8,1,outval9,1,(len9 - 1)), stat = movestring(outval8,(len9+ 1),
             outval10,1,(len10 - 1))
            IF (hrows=1)
             IF (isisolateoneline=1)
              IF (isbold=1)
               col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
               b1
              ELSE
               col table_rec->qual[xkount].bugnames1, b1
              ENDIF
             ELSE
              IF (isbold=1)
               col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
               outval1
              ELSE
               col table_rec->qual[xkount].bugnames1, outval1
              ENDIF
             ENDIF
             line_cnt_for_org = (line_cnt_for_org+ 1)
            ELSEIF (hrows=2
             AND outval3 > " ")
             IF (isbold=1)
              col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
              outval3
             ELSE
              col table_rec->qual[xkount].bugnames1, outval3
             ENDIF
             line_cnt_for_org = (line_cnt_for_org+ 1)
            ELSEIF (hrows=3
             AND outval5 > " ")
             IF (isbold=1)
              col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
              outval5
             ELSE
              col table_rec->qual[xkount].bugnames1, outval5
             ENDIF
             line_cnt_for_org = (line_cnt_for_org+ 1)
            ELSEIF (hrows=4
             AND outval7 > " ")
             IF (isbold=1)
              col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
              outval7
             ELSE
              col table_rec->qual[xkount].bugnames1, outval7
             ENDIF
             line_cnt_for_org = (line_cnt_for_org+ 1)
            ELSEIF (hrows=5
             AND outval9 > " ")
             IF (isbold=1)
              col 0, boldchars, call reportmove('COL',(table_rec->qual[xkount].bugnames1+ 3),0),
              outval9
             ELSE
              col table_rec->qual[xkount].bugnames1, outval9
             ENDIF
             line_cnt_for_org = (line_cnt_for_org+ 1)
            ENDIF
          ENDFOR
          IF (last_org_row_cnt != line_cnt_for_org)
           row + 1
          ENDIF
          last_org_row_cnt = line_cnt_for_org
        ENDFOR
        row + 1
       ENDIF
       FOR (xkount = 1 TO 2)
         IF (isisolateleft=1
          AND xkount=1)
          outval1 = trim(substring(1,60,org_rec->qual[subval].bug_name))
          IF (isbold=1)
           row + 1, col 0, boldchars,
           CALL print(outval1)
          ELSE
           row + 1, col 0,
           CALL print(outval1)
          ENDIF
          size_out = size(trim(outval1)), u_org = substring(1,size_out,u_long)
          IF (isbold=1)
           row + 1, col 0, boldchars,
           CALL print(u_org)
          ELSE
           row + 1, col 0,
           CALL print(u_org)
          ENDIF
          row + 1
         ENDIF
         FOR (ykount = 1 TO noofbugsintable)
           subval = ((ykount+ totnooforgs) - orgs_remaining), noofsuscepmethods = size(org_rec->qual[
            subval].det_sus_method,5)
           FOR (zkount = 1 TO noofsuscepmethods)
             IF (xkount=1)
              row- (susc_print_rows), col_diff = ((org_rec->qual[subval].det_sus_method[zkount].
              col_end - org_rec->qual[subval].det_sus_method[zkount].col_start) - 1), row_cnt = 0,
              max_row_num = maxval(max_row_num,row), row_cnt = (size(trim(org_rec->qual[subval].
                det_sus_method[zkount].display))/ col_diff)
              IF (mod(size(trim(org_rec->qual[subval].det_sus_method[zkount].display)),col_diff) > 0)
               row_cnt = (row_cnt+ 1)
              ENDIF
              FOR (t = 1 TO row_cnt)
                IF (t=1)
                 col org_rec->qual[subval].det_sus_method[zkount].col_start,
                 CALL print(trim(substring(1,((col_diff * t)+ (t - 1)),org_rec->qual[subval].
                   det_sus_method[zkount].display)))
                ELSE
                 col org_rec->qual[subval].det_sus_method[zkount].col_start,
                 CALL print(trim(substring(((col_diff * (t - 1))+ 1),col_diff,org_rec->qual[subval].
                   det_sus_method[zkount].display)))
                ENDIF
                row + 1, max_row_num = maxval(max_row_num,row)
              ENDFOR
              susc_print_rows = row_cnt
             ENDIF
           ENDFOR
         ENDFOR
         diff_max = 0, diff_max = (max_row_num - row)
         IF (diff_max > 0)
          row + diff_max
         ENDIF
       ENDFOR
       row- (1)
       IF (underline_sus_headings=1)
        FOR (ykount = 1 TO noofbugsintable)
          subval = ((ykount+ totnooforgs) - orgs_remaining), noofsuscepmethods = size(org_rec->qual[
           subval].det_sus_method,5)
          FOR (zkount = 1 TO noofsuscepmethods)
            row + 1, col org_rec->qual[subval].det_sus_method[zkount].col_start,
            CALL print(trim(org_rec->qual[subval].det_sus_method[zkount].col_underline)),
            row- (1)
          ENDFOR
        ENDFOR
       ENDIF
       FOR (ykount = 1 TO noofbugsintable)
         subval = ((ykount+ totnooforgs) - orgs_remaining)
         IF (isdosagechartable=1)
          IF ((org_rec->qual[subval].isdosagepres=1))
           dosage_field = fillstring(value(dosage_width)," "), dosage_field = labeldosage, col
           org_rec->qual[subval].d_start,
           dosage_field";;c"
           IF (underline_sus_headings=1)
            row + 1, col org_rec->qual[subval].d_start,
            CALL print(substring(1,(dosage_width - 1),u100)),
            row- (1)
           ENDIF
          ENDIF
         ENDIF
         IF (iscostperdosechartable=1)
          IF ((org_rec->qual[subval].iscostperdosepres=1))
           cpd_field = fillstring(value(cost_per_dos_width)," "), cpd_field = labelcost, col org_rec
           ->qual[subval].cpd_start,
           cpd_field";;c"
           IF (underline_sus_headings=1)
            row + 1, col org_rec->qual[subval].cpd_start,
            CALL print(substring(1,(cost_per_dos_width - 1),u100)),
            row- (1)
           ENDIF
          ENDIF
         ENDIF
         IF (istradenchartable=1)
          IF ((org_rec->qual[subval].istradenpres=1))
           tn_field = fillstring(value(trade_name_width)," "), tn_field = labeltradename, col org_rec
           ->qual[subval].tn_start,
           tn_field";;c"
           IF (underline_sus_headings=1)
            row + 1, col org_rec->qual[subval].tn_start,
            CALL print(substring(1,(trade_name_width - 1),u100)),
            row- (1)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       row + 1
       IF (underline_sus_headings=2)
        col 0, u100, row + 1
       ELSEIF (underline_sus_headings=1)
        row + 1
       ENDIF
       idx1 = 1
       FOR (x = 1 TO numnotes)
         IF (locateval(idx2,1,numnotes,foot_data->qual[x].text,foot_data->qual[idx2].text)=x)
          foot_data->qual[x].index_num = idx1, idx1 = (idx1+ 1)
         ELSE
          locval = locateval(idx2,1,numnotes,foot_data->qual[x].text,foot_data->qual[idx2].text),
          foot_data->qual[x].index_num = foot_data->qual[locval].index_num, foot_data->qual[x].
          printable_ind = nochart_ind
         ENDIF
       ENDFOR
       totnoofdrugs = size(suscep_rec->drugresult,5)
       FOR (xkount = 1 TO totnoofdrugs)
         wr_drug = "F", nooforgs_drug = size(suscep_rec->drugresult[xkount].orgresult,5), c1 = "N",
         c2 = "N", c3 = "N", printed_it = "F"
         FOR (ykount = 1 TO nooforgs_drug)
           posorg = suscep_rec->drugresult[xkount].orgresult[ykount].column, fdg1 = (posorg - offset),
           tnotes = size(suscep_rec->drugresult[xkount].orgresult[ykount].notes,5)
           IF (fdg1 BETWEEN 1 AND noofbugsintable)
            drug_id = suscep_rec->drugresult[xkount].drug_id, col 0,
            CALL print(trim(build(suscep_rec->drugresult[xkount].drug_name))),
            tempstr = "", locaval = locateval(idx2,1,numnotes,drug_id,foot_data->qual[idx2].drug_id),
            orgsize = size(suscep_rec->drugresult[xkount].orgresult,5)
            IF (tnotes > 0)
             FOR (tnotevar = 1 TO orgsize)
              note_loc = suscep_rec->drugresult[xkount].orgresult[tnotevar].notes[1].note_num,
              IF ((suscep_rec->drugresult[xkount].orgresult[tnotevar].note_ind=1)
               AND (suscep_rec->drugresult[xkount].orgresult[ykount].ord2=foot_data->qual[note_loc].
              qualx[1].ord2))
               IF (temp_drug_id != drug_id)
                IF (tnotes > 1)
                 FOR (x = 1 TO tnotes)
                  note_loc = suscep_rec->drugresult[xkount].orgresult[ykount].notes[x].note_num,
                  tempstr = concat(trim(tempstr),build("(",foot_data->qual[note_loc].index_num,")"))
                 ENDFOR
                ELSE
                 CALL print(trim(build("(",foot_data->qual[note_loc].index_num,")"))), tempstr =
                 concat(trim(build("(",foot_data->qual[note_loc].index_num,")")))
                ENDIF
               ELSE
                tempstr = concat(trim(tempstr),trim(build("(",foot_data->qual[note_loc].index_num,")"
                   )))
               ENDIF
              ENDIF
             ENDFOR
             col 0,
             CALL print(trim(build(suscep_rec->drugresult[xkount].drug_name))), tempstr
            ENDIF
            temp_drug_id = drug_id, printed_it = "T", noofresults = size(suscep_rec->drugresult[
             xkount].orgresult[ykount].suscep_result,5)
            FOR (zkount = 1 TO noofresults)
              corsv = size(suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].
               cor_data,5)
              IF (corsv > 0)
               addcharsm = corrected_char
              ELSE
               addcharsm = ""
              ENDIF
              nresultsize = size(trim(suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[
                zkount].result,3),1)
              IF ((suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].mdt_ttf=7))
               IF (nresultsize >= interp_width)
                interp_width = (nresultsize+ 1)
               ENDIF
               locres = trim(substring(1,(value(interp_width) - 1),suscep_rec->drugresult[xkount].
                 orgresult[ykount].suscep_result[zkount].result))
              ELSE
               IF (nresultsize >= dilution_width)
                dilution_width = (nresultsize+ 1)
               ENDIF
               locres = trim(substring(1,(value(dilution_width) - 1),suscep_rec->drugresult[xkount].
                 orgresult[ykount].suscep_result[zkount].result))
              ENDIF
              loccol = suscep_rec->drugresult[xkount].orgresult[ykount].suscep_result[zkount].column,
              colum_start = org_rec->qual[posorg].det_sus_method[loccol].col_start, col colum_start,
              locres, addcharsm";l"
              IF (isdosagechartable=1)
               IF ((org_rec->qual[posorg].isdosagepres=1))
                locres_dosage = substring(1,value(dosage_width),suscep_rec->drugresult[xkount].
                 orgresult[ykount].suscep_result[zkount].dosage), mylocres1 = trim(locres_dosage,3),
                col org_rec->qual[posorg].d_start,
                mylocres1
               ENDIF
              ENDIF
              IF (iscostperdosechartable=1)
               IF ((org_rec->qual[posorg].iscostperdosepres=1))
                locres_cpd = substring(1,value(cost_per_dos_width),suscep_rec->drugresult[xkount].
                 orgresult[ykount].suscep_result[zkount].cost_per_dose), mylocres2 = trim(locres_cpd,
                 3), col org_rec->qual[posorg].cpd_start,
                mylocres2
               ENDIF
              ENDIF
              IF (istradenchartable=1)
               IF ((org_rec->qual[posorg].istradenpres=1))
                locres_tn = substring(1,value(trade_name_width),suscep_rec->drugresult[xkount].
                 orgresult[ykount].suscep_result[zkount].trade_name), mylocres3 = trim(locres_tn,3),
                col org_rec->qual[posorg].tn_start,
                mylocres3
               ENDIF
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
         IF (printed_it="T")
          row + 1
         ENDIF
       ENDFOR
       row + 1, col 0, "<<",
       row + 1
       IF (isbugdisclaimer=1)
        tempstr = uar_i18ngetmessage(i18nhandle,"WARNING1",
         "WARNING:  Not all susceptibility methods for this accession were displayed. Please use"),
        col 0, tempstr,
        row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"WARNING2",
         "online aplication to verify the other methods that did not get displayed"), col 0,
        tempstr, row + 1
       ENDIF
       IF (iscorrectedresultsdisplayend=0)
        size_drugs = 0, start_index = (orgs_printed+ 1)
        FOR (i = (orgs_printed+ 1) TO totnooforgs)
          IF (((i - start_index) < noofbugsintable))
           IF ((corr_display->organisms[i].has_corrections=1))
            row + 1, col 0, ">>",
            row + 2,
            CALL print(corr_display->organisms[i].organism_name), size_d = 0,
            size_d = size(trim(corr_display->organisms[i].organism_name)), u_bug = substring(1,size_d,
             u_long), row + 1,
            CALL print(u_bug), size_drugs = size(corr_display->organisms[i].antibiotics,5)
            FOR (y = 1 TO size_drugs)
              row + 1,
              CALL print(trim(corr_display->organisms[i].antibiotics[y].antibiotic_name)), " ",
              CALL print(trim(corr_display->organisms[i].antibiotics[y].old_interp_type)), tempstr =
              uar_i18ngetmessage(i18nhandle,"CORRFROM"," corrected from "), tempstr,
              col + 1
              IF ((corr_display->organisms[i].antibiotics[y].old_result > " "))
               CALL print(trim(corr_display->organisms[i].antibiotics[y].old_result,3))
              ELSE
               CALL print(trim(corr_display->organisms[i].antibiotics[y].old_interp,3))
              ENDIF
              tempstr = uar_i18ngetmessage(i18nhandle,"CORRON"," on "), tempstr, " "
              IF (utc_on)
               zone = datetimezonebyindex(c.corrected_tz,utcoffset,daylight,7,corr_display->
                organisms[i].antibiotics[y].new_v_dt_tm), formatted_date = concat(trim(format(
                  datetimezone(corr_display->organisms[i].antibiotics[y].new_v_dt_tm,c.corrected_tz),
                  sdatemask_tz),3)," ",cnvtupper(format(datetimezone(corr_display->organisms[i].
                   antibiotics[y].new_v_dt_tm,c.corrected_tz),stimemask_tz))," ",zone)
              ELSE
               formatted_date = concat(trim(format(corr_display->organisms[i].antibiotics[y].
                  new_v_dt_tm,date_mask),3)," ",cnvtupper(format(corr_display->organisms[i].
                  antibiotics[y].new_v_dt_tm,time_mask)))
              ENDIF
              CALL print(formatted_date)
            ENDFOR
            row + 3, col 0, "<<"
           ENDIF
          ELSE
           i = (totnooforgs+ 1)
          ENDIF
        ENDFOR
       ENDIF
       offset = (offset+ noofbugsintable), orgs_printed = (orgs_printed+ noofbugsintable),
       orgs_remaining = (orgs_remaining - noofbugsintable),
       row + 2
     ENDWHILE
     IF (iscorrectedresultsdisplayend=1)
      IF (numcors > 0)
       row + 1, col 0, ">>",
       row + 2, size_corr = 0, size_corr = size(corr_display->organisms,5),
       size_drugs = 0
       FOR (d = 1 TO size_corr)
         IF ((corr_display->organisms[d].has_corrections=1))
          row + 2,
          CALL print(corr_display->organisms[d].organism_name), size_d = 0,
          size_d = size(trim(corr_display->organisms[d].organism_name)), u_bug = substring(1,size_d,
           u_long), row + 1,
          CALL print(u_bug), size_drugs = size(corr_display->organisms[d].antibiotics,5)
          FOR (e = 1 TO size_drugs)
            row + 1,
            CALL print(trim(corr_display->organisms[d].antibiotics[e].antibiotic_name)), " ",
            CALL print(trim(corr_display->organisms[d].antibiotics[e].old_interp_type)), tempstr =
            uar_i18ngetmessage(i18nhandle,"CORRFROM"," corrected from "), tempstr,
            col + 1
            IF ((corr_display->organisms[d].antibiotics[e].old_result > " "))
             CALL print(trim(corr_display->organisms[d].antibiotics[e].old_result,3))
            ELSE
             CALL print(trim(corr_display->organisms[d].antibiotics[e].old_interp,3))
            ENDIF
            tempstr = uar_i18ngetmessage(i18nhandle,"CORRON"," on "), tempstr, " "
            IF (utc_on)
             zone = datetimezonebyindex(c.corrected_tz,utcoffset,daylight,7,corr_display->organisms[d
              ].antibiotics[e].new_v_dt_tm), formatted_date = concat(trim(format(datetimezone(
                 corr_display->organisms[d].antibiotics[e].new_v_dt_tm,c.corrected_tz),sdatemask_tz),
               3)," ",cnvtupper(format(datetimezone(corr_display->organisms[d].antibiotics[e].
                 new_v_dt_tm,c.corrected_tz),stimemask_tz))," ",zone)
            ELSE
             formatted_date = concat(trim(format(corr_display->organisms[d].antibiotics[e].
                new_v_dt_tm,date_mask),3)," ",cnvtupper(format(corr_display->organisms[d].
                antibiotics[e].new_v_dt_tm,time_mask)))
            ENDIF
            CALL print(formatted_date)
          ENDFOR
         ENDIF
       ENDFOR
       row + 3, col 0, "<<"
      ENDIF
     ENDIF
    ENDIF
    myorgs = 0, mydrugs = 0, stat = alterlist(org_rec->qual,myorgs),
    stat = alterlist(suscep_rec->drugresult,mydrugs)
    IF (sup_footer_needed="T")
     row + 1, col 0, ">>",
     printed_legend = "T"
     IF (trim(long_legend)="")
      long_legend = build(legendcharline1,char(13),char(10),legendcharline2)
     ENDIF
     ival = wraptextforline(trim(long_legend),fontwidth)
     FOR (i = 1 TO size(wrapped_text->qual,5))
       IF (legend_justification=0)
        row + 1, col 0,
        CALL center(trim(wrapped_text->qual[i].line,2),1,value(fontwidth))
       ELSE
        row + 1, col 0,
        CALL print(trim(wrapped_text->qual[i].line,2))
       ENDIF
     ENDFOR
     row + 1, col 0, "<<"
    ENDIF
    IF (printed_event="F")
     printed_event = "T", firstbug = "F", num_lines = 0,
     end_par = 0, line_len = 0
     IF (nstainreports > 0)
      row + 1, col 0, ">>",
      row + 1
      IF (size(trim(labelstain)) > 0)
       IF (isbold=1)
        col 0, boldchars, labelstain
       ELSE
        col 0, labelstain
       ENDIF
      ENDIF
      ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
      fillstring(60," "),
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
      FOR (lvar = 1 TO nstainreports)
        text_line = fillstring(value(fontwidth)," ")
        IF (isbold=1)
         row + 2, col 0, boldchars,
         report_data2->stain[lvar].stain_name
        ELSE
         row + 2, col 0, report_data2->stain[lvar].stain_name
        ENDIF
        IF (verified_justification != 2)
         tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","Unknown")
         IF (verified_justification=1)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
         ELSE
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
          tempstr
         ENDIF
         report_data2->stain[lvar].ver_dt_time
        ENDIF
        ival = wraptextforline(trim(report_data2->stain[lvar].report_text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
      ENDFOR
      row + 1, col 0, "<<",
      row + 1, col 0, " ",
      stat = alterlist(report_data2->stain,0), nstainreports = 0
     ENDIF
     IF (namendedreports > 0)
      row + 1, col 0, ">>"
      IF (size(trim(labelglobal)) > 0
       AND printed_global_report_header="f")
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelglobal
       ELSE
        row + 1, col 0, labelglobal
       ENDIF
       printed_global_report_header = "t"
      ENDIF
      report_type = 4
      IF (size(trim(labelamended)) > 0)
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelamended
       ELSE
        row + 1, col 0, labelamended
       ENDIF
      ENDIF
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
      FOR (lvar = 1 TO namendedreports)
        IF (isbold=1)
         row + 2, col 0, boldchars,
         report_data2->amend[lvar].stain_name
        ELSE
         row + 2, col 0, report_data2->amend[lvar].stain_name
        ENDIF
        IF (verified_justification != 2)
         tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
         IF (verified_justification=1)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
         ELSEIF (verified_justification=0)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
          tempstr
         ENDIF
         report_data2->amend[lvar].ver_dt_time
        ENDIF
        ival = wraptextforline(trim(report_data2->amend[lvar].report_text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
      ENDFOR
      row + 1, col 0, "<<",
      row + 1, col 0, " ",
      stat = alterlist(report_data2->amend,0), namendedreports = 0
     ENDIF
     IF (nfinalreports > 0)
      row + 1, col 0, ">>"
      IF (size(trim(labelglobal)) > 0
       AND printed_global_report_header="f")
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelglobal
       ELSE
        row + 1, col 0, labelglobal
       ENDIF
       printed_global_report_header = "t"
      ENDIF
      report_type = 4
      IF (size(trim(labelfinal)) > 0)
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelfinal
       ELSE
        row + 1, col 0, labelfinal
       ENDIF
      ENDIF
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
      FOR (lvar = 1 TO nfinalreports)
        IF (isbold=1)
         row + 2, col 0, boldchars,
         report_data2->final[lvar].stain_name
        ELSE
         row + 2, col 0, report_data2->final[lvar].stain_name
        ENDIF
        IF (verified_justification != 2)
         tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
         IF (verified_justification=1)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
         ELSEIF (verified_justification=0)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
          tempstr
         ENDIF
         report_data2->final[lvar].ver_dt_time
        ENDIF
        ival = wraptextforline(trim(report_data2->final[lvar].report_text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
      ENDFOR
      row + 1, col 0, "<<",
      row + 1, col 0, " ",
      stat = alterlist(report_data2->final,0), nfinalreports = 0
     ENDIF
     IF (nprelimreports > 0)
      row + 1, col 0, ">>"
      IF (size(trim(labelglobal)) > 0
       AND printed_global_report_header="f")
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelglobal
       ELSE
        row + 1, col 0, labelglobal
       ENDIF
       printed_global_report_header = "t"
      ENDIF
      report_type = 4
      IF (size(trim(labelfinal)) > 0)
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelprelim
       ELSE
        row + 1, col 0, labelprelim
       ENDIF
      ENDIF
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
      FOR (lvar = 1 TO nprelimreports)
        IF (isbold=1)
         row + 2, col 0, boldchars,
         report_data2->prelim[lvar].stain_name
        ELSE
         row + 2, col 0, report_data2->prelim[lvar].stain_name
        ENDIF
        IF (verified_justification != 2)
         tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
         IF (verified_justification=1)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
         ELSEIF (verified_justification=0)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
          tempstr
         ENDIF
         report_data2->prelim[lvar].ver_dt_time
        ENDIF
        ival = wraptextforline(trim(report_data2->prelim[lvar].report_text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
      ENDFOR
      row + 1, col 0, "<<",
      row + 1, col 0, " ",
      stat = alterlist(report_data2->prelim,0), nprelimreports = 0
     ENDIF
     IF (notherreports > 0)
      row + 1, col 0, ">>"
      IF (size(trim(labelglobal)) > 0
       AND printed_global_report_header="f")
       IF (isbold=1)
        row + 1, col 0, boldchars,
        labelglobal
       ELSE
        row + 1, col 0, labelglobal
       ENDIF
       printed_global_report_header = "t"
      ENDIF
      CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), col 60, ""
      FOR (lvar = 1 TO notherreports)
        IF (isbold=1)
         row + 2, col 0, boldchars,
         report_data2->other[lvar].stain_name
        ELSE
         row + 2, col 0, report_data2->other[lvar].stain_name
        ENDIF
        IF (verified_justification != 2)
         tempstr = uar_i18ngetmessage(i18nhandle,"RPTUNKN","**Unknown**")
         IF (verified_justification=1)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), col fontlbl, tempstr
         ELSEIF (verified_justification=0)
          tempstr = uar_i18ngetmessage(i18nhandle,"RPTVER","Verified: "), row + 1, col 0,
          tempstr
         ENDIF
         report_data2->other[lvar].ver_dt_time
        ENDIF
        ival = wraptextforline(trim(report_data2->other[lvar].report_text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
      ENDFOR
      row + 1, col 0, "<<",
      row + 1, col 0, " ",
      stat = alterlist(report_data2->other,0), notherreports = 0
     ENDIF
     CALL echorecord(report_data2), report_type = 0
    ENDIF
    IF (numcoms > 0)
     row + 1, col 0, ">>"
     IF (size(trim(labelordercomments)) > 0)
      IF (isbold=1)
       row + 2, col 0, boldchars,
       labelordercomments
      ELSE
       row + 2, col 0, labelordercomments
      ENDIF
     ENDIF
     FOR (comvar2 = 1 TO numcoms)
      ival = wraptextforline(trim(order_comment->qual[comvar2].report_text),fontwidth),
      FOR (i = 1 TO size(wrapped_text->qual,5))
        row + 1, col 0,
        CALL print(trim(wrapped_text->qual[i].line,2))
      ENDFOR
     ENDFOR
     row + 2, col 0, "<<",
     row + 1
    ENDIF
    IF (numnotes > 0)
     row + 2, col 0, ">>"
     IF (size(trim(labelfootnotes)) > 0)
      IF (isbold=1)
       row + 1, col 0, boldchars,
       labelfootnotes
      ELSE
       row + 1, col 0, labelfootnotes
      ENDIF
     ENDIF
     FOR (oivar = 1 TO numnotes)
       IF ((foot_data->qual[oivar].printable_ind != 0))
        row + 1, col 0,
        CALL print(build("(",foot_data->qual[oivar].index_num,")")),
        ival = wraptextforline(trim(foot_data->qual[oivar].text),fontwidth)
        FOR (i = 1 TO size(wrapped_text->qual,5))
          row + 1, col 0,
          CALL print(trim(wrapped_text->qual[i].line,2))
        ENDFOR
       ENDIF
     ENDFOR
     row + 1, col 0, "<<"
    ENDIF
    CALL echorecord(reflab_rec)
    IF (reflab_display=1)
     nencntrnbr = size(reflab_rec->encntr_list,5)
     FOR (e = 1 TO nencntrnbr)
       IF ((reflab_rec->encntr_list[e].encntr_id=c.encntr_id))
        nordernbr = size(reflab_rec->encntr_list[e].orders,5)
        FOR (o = 1 TO nordernbr)
          IF ((reflab_rec->encntr_list[e].orders[o].order_id=c.order_id)
           AND size(reflab_rec->encntr_list[e].orders[o].footnotes,5) > 0)
           row + 1, col 0, ">>",
           row + 2, col 0, reflab_rec->encntr_list[e].orders[o].verified_dt_tm,
           col + 2, reflab_rec->encntr_list[e].orders[o].catalog_cd_descr, ":"
           FOR (f = 1 TO size(reflab_rec->encntr_list[e].orders[o].footnotes,5))
            ival = wraptextforline(trim(reflab_rec->encntr_list[e].orders[o].footnotes[f].
              ref_lab_description),fontwidth),
            FOR (i = 1 TO size(wrapped_text->qual,5))
              row + 1, col 0,
              CALL print(trim(wrapped_text->qual[i].line,2))
            ENDFOR
           ENDFOR
           row + 2, col 0, "<<",
           o = (nordernbr+ 1)
          ENDIF
        ENDFOR
        e = (nencntrnbr+ 1)
       ENDIF
     ENDFOR
    ENDIF
    row + 1
    IF (num_interps > 0)
     row + 1, col 0, ">>",
     row + 1
     FOR (oivar = 1 TO num_interps)
       ret_meaning = fillstring(12," "), ret_display = fillstring(40," "), ret_description =
       fillstring(60," "),
       CALL uar_get_code(c.catalog_cd,ret_display,ret_meaning,ret_description), ival =
       wraptextforline(trim(interp_data->qual[oivar].report_text),fontwidth), col 0,
       "*** ", ret_display, labelinterpresults,
       row + 1
       FOR (i = 1 TO size(wrapped_text->qual,5))
         row + 1, col 0,
         CALL print(trim(wrapped_text->qual[i].line,2))
       ENDFOR
       row + 1
     ENDFOR
     row + 2, col 0, "<<",
     row + 1
    ENDIF
    row + 1, col 0, ">>",
    row + 2, col 0, uuu,
    row + 2, col 0, "<<",
    row + 1
   FOOT REPORT
    numrows = row, stat = alterlist(reply->qual,((numlines+ numrows)+ 1))
    FOR (pagevar = 0 TO numrows)
      IF (trim(reportrow((pagevar+ 1)))="{B}")
       do_nothing = 0
      ELSE
       numlines = (numlines+ 1), reply->qual[numlines].line = reportrow((pagevar+ 1)), done = "F"
       WHILE (done="F")
        nullpos = findstring(char(0),reply->qual[numlines].line),
        IF (nullpos > 0)
         stat = movestring(" ",1,reply->qual[numlines].line,nullpos,1)
        ELSE
         done = "T"
        ENDIF
       ENDWHILE
      ENDIF
    ENDFOR
   WITH memsort, outerjoin = c, noformfeed,
    maxcol = 255, outerjoin = d, maxrow = 62000
  ;end select
 ELSE
  SET numlines = 0
 ENDIF
#exit_script
 IF (numlines > 1)
  SELECT
   line = reply->qual[d.seq].line
   FROM (dummyt d  WITH seq = value(numlines))
   PLAN (d)
   WITH counter, maxrow = 1, noformfeed
  ;end select
 ENDIF
 SET reply->num_lines = numlines
 IF (numlines > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 FREE RECORD table_rec
 FREE RECORD interp_data
 FREE RECORD report_data2
 FREE RECORD cor_data
 FREE RECORD foot_data
 FREE RECORD out_rec
 FREE RECORD order_comment
 FREE RECORD org_rec
 FREE RECORD suscep_rec
 FREE RECORD pathogen_rec
 FREE RECORD reflab_rec
 FREE RECORD corr_display
 FREE RECORD source_rec
 FREE SELECT cp_mic_1
 FREE SELECT cp_mic_2
 CALL echo(reply->status_data.status)
 SUBROUTINE formatnumericvalue(nvalue,nflag)
   DECLARE sfill = vc
   DECLARE strsize = i4
   IF (nflag=chart_ind)
    SET sfill = trim(format(nvalue,"###############.##########;T(1)"),3)
    SET strsize = size(sfill,1)
    IF (strsize >= interp_width
     AND ntypeflag=7)
     SET interp_width = (strsize+ 1)
    ELSEIF (strsize >= dilution_width)
     SET dilution_width = (strsize+ 1)
    ENDIF
   ENDIF
   RETURN(sfill)
 END ;Subroutine
 SUBROUTINE resizewidthcolumn(nvalue)
   DECLARE sfill = vc
   DECLARE nsize = i4
   SET sfill = trim(substring(1,20,uar_get_code_display(nvalue)),3)
   SET nsize = size(sfill,1)
   IF (nsize >= interp_width
    AND ntypeflag=7)
    SET interp_width = (nsize+ 1)
   ELSEIF (nsize >= dilution_width)
    SET dilution_width = (nsize+ 1)
   ENDIF
   RETURN(nsize)
 END ;Subroutine
 SUBROUTINE validatecolumnwidth(nvalue,nflag)
   DECLARE sfill = vc
   DECLARE nsize = i4
   SET sfill = trim(nvalue,1)
   SET nsize = size(sfill,1)
   CASE (nflag)
    OF ndosage_flag:
     IF (nsize > dosage_width)
      SET dosage_width = nsize
     ENDIF
    OF ncost_flag:
     IF (nsize > cost_per_dos_width)
      SET cost_per_dos_width = nsize
     ENDIF
    OF ntrade_flag:
     IF (nsize > trade_name_width)
      SET trade_name_width = nsize
     ENDIF
   ENDCASE
   RETURN(nsize)
 END ;Subroutine
 SUBROUTINE settypeflag(ntype)
  SET ntypeflag = ntype
  RETURN(ntypeflag)
 END ;Subroutine
END GO
