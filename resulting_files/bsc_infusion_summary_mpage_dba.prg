CREATE PROGRAM bsc_infusion_summary_mpage:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Person Id: " = 0,
  "Encounter Id: " = 0,
  "ENCNTR_FILTER: " = 0,
  "IV_DISP_LEVEL: " = 0,
  "Sort Flag: " = 0,
  "Start Time: " = "CURDATE",
  "End Time: " = "CURDATE"
  WITH outdev, inputpersonid, inputencounterid,
  encntrfilter, ivdisplevel, sortflag,
  starttime, endtime
 RECORD getreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD getrequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 RECORD putrequest(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 DECLARE i18nhandledetails = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandledetails,curprog,"",curcclrev)
 DECLARE i18n_sand = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,"i18n_AND",
    " and "),3))
 DECLARE i18n_spageheader = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_PAGE_HEADER","Continuous Infusion Summary"),3))
 DECLARE i18n_stableheadermain = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_TABLE_HEADER_MAIN","Summary of Active Continuous Infusion Orders"),3))
 DECLARE i18n_stableheadersub = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_TABLE_HEADER_SUB","Active Continuous Infusions"),3))
 DECLARE i18n_sorderinfohead = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_ORDER_INFO_HEADER","Order Information"),3))
 DECLARE i18n_sperformeddttmheader = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_PERFORMED_DT_TM_HEADER","Performed Date/Time"),3))
 DECLARE i18n_singredheader = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_INGRED_HEADER","Ingredient"),3))
 DECLARE i18n_singreddosegivenheader = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_DOSE_GIVEN_HEADER","Ingredient Dose Given"),3))
 DECLARE i18n_snoeventsdocumented = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_NO_EVENTS_DOCUMENTED",
    "No events documented for this order within timeframe"),3))
 DECLARE i18n_sendbagcompletedat = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_END_BAG_COMPLETED_AT","End Bag estimated to be completed at "),3))
 DECLARE i18n_snoendbagavailable = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_NO_END_BAG_AVAILABLE","No End Bag Available"),3))
 DECLARE i18n_snoendbagfoundwithintimeframe = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_NO_END_BAG_FOUND_WITHIN_TIME_FRAME",
    "No End Bag task found within timeframe"),3))
 DECLARE i18n_snoactiveorders = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_NO_ACTIVE_ORDERS","No active continuous infusion orders found"),3))
 DECLARE i18n_snoordersqualify = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_NO_ORDERS_QUALIFY","No orders qualify for the privileges set"),3))
 DECLARE i18n_snoprivileges = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_NO_PRIVILEGES","No privileges"),3))
 DECLARE i18n_sunabletoconvertunits = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_UNABLE_TO_CONVERT_UNITS","Unable to convert dose units See MAR"),3))
 DECLARE i18n_stotaladministered = vc WITH protect, constant(trim(uar_i18ngetmessage(
    i18nhandledetails,"i18n_TOTAL_ADMINISTERED","TOTAL ADMINISTERED"),3))
 DECLARE i18n_stotalvolume = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_TOTAL_VOLUME","TOTAL VOLUME"),3))
 DECLARE i18n_sloadfailure = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_LOAD_FAILURE","Failure To Load"),3))
 DECLARE sxml = vc WITH protect, noconstant("")
 SET sxml = "<?xml version='1.0' encoding='iso-8859-1' standalone='no' ?><RPT_DATA>"
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 SUBROUTINE (parsezeroes(pass_field_in=f8) =vc)
   DECLARE dsvalue = c16 WITH noconstant(fillstring(16," "))
   DECLARE move_fld = c16 WITH noconstant(fillstring(16," "))
   DECLARE strfld = c16 WITH noconstant(fillstring(16," "))
   DECLARE sig_dig = i4 WITH noconstant(0)
   DECLARE sig_dec = i4 WITH noconstant(0)
   DECLARE str_cnt = i4 WITH noconstant(1)
   DECLARE len = i4 WITH noconstant(0)
   SET strfld = cnvtstring(pass_field_in,16,4,r)
   WHILE (str_cnt < 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt += 1
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt -= 1
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt -= 1
   ENDIF
   SET sig_dec = str_cnt
   IF (sig_dig=11
    AND sig_dec=11)
    SET dsvalue = ""
   ELSE
    SET len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig))
    SET dsvalue = trim(move_fld)
    IF (substring(1,1,dsvalue)=".")
     SET dsvalue = concat("0",trim(move_fld))
    ENDIF
   ENDIF
   RETURN(dsvalue)
 END ;Subroutine
 SUBROUTINE (formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) =vc)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   IF (ltzindex > 0)
    SET lnewindex = ltzindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,"@SHORTDATE")
   IF (size(trim(snewdatetime)) > 0)
    SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
      "@TIMENOSECONDS"))
    IF (butcind=1
     AND bshowtz=1)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE (formatlabelbylength(slabel=vc,lmaxlen=i4) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = trim(slabel,3)
   IF (size(snewlabel) > 0
    AND lmaxlen > 0)
    IF (lmaxlen < 4)
     SET snewlabel = substring(1,lmaxlen,snewlabel)
    ELSEIF (size(snewlabel) > lmaxlen)
     SET snewlabel = concat(substring(1,(lmaxlen - 3),snewlabel),"...")
    ENDIF
   ENDIF
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatstrength(dstrength=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatvolume(dvolume=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatrate(drate=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE (formatpercentwithdecimal(dpercent=f8) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(format(dpercent,"###.##;I;F"))
   RETURN(snewlabel)
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
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 RECORD order_list(
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 clin_disp_line = vc
     2 comment_type_mask = i4
     2 order_comment_text = vc
     2 end_bag_exists = i2
     2 end_bag_in_time_range = i2
     2 end_bag_task_dt_tm = dq8
     2 end_bag_task_tm_tz = i4
     2 ingreds[*]
       3 catalog_cd = f8
       3 action_sequence = i4
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ingred_type_flag = i4
       3 volume = f8
       3 volume_unit = f8
       3 strength = f8
       3 strength_unit = f8
 ) WITH protect
 RECORD event_request(
   1 person_id = f8
   1 search_begin_dt_tm = dq8
   1 search_end_dt_tm = dq8
   1 order_id_list[*]
     2 order_id = f8
   1 iv_event_cd_list[*]
     2 iv_event_cd = f8
   1 encntr_list[*]
     2 encntr_id = f8
   1 status_cd_exclude_list[*]
     2 result_status_cd = f8
   1 children_flag = i2
   1 pop_seq_flag = i2
   1 use_ord_start_dt_tm_ind = i2
 ) WITH protect
 RECORD event_reply(
   1 error_code = f8
   1 error_msg = vc
   1 event_list[*]
     2 event_id = f8
     2 parent_event_id = f8
     2 catalog_cd = f8
     2 event_cd = f8
     2 collating_seq = vc
     2 order_id = f8
     2 template_order_id = f8
     2 event_title_text = vc
     2 clinical_event_id = f8
     2 med_result_list[*]
       3 admin_start_dt_tm = dq8
       3 dosage_unit_cd = f8
       3 initial_volume = f8
       3 initial_dosage = f8
       3 infused_volume_unit_cd = f8
       3 iv_event_cd = f8
       3 updt_dt_tm = dq8
       3 substance_lot_number = vc
       3 infusion_rate = f8
       3 infusion_unit_cd = f8
       3 admin_site_cd = f8
       3 admin_dosage = f8
       3 admin_start_tz = i4
     2 order_action_sequence = i4
     2 encntr_id = f8
     2 event_start_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
     2 result_status_cd = f8
     2 event_class_cd = f8
     2 child_event_list[*]
       3 event_cd = f8
       3 parent_event_id = f8
       3 event_id = f8
       3 catalog_cd = f8
       3 collating_seq = vc
       3 comp_sequence = i4
       3 order_id = f8
       3 template_order_id = f8
       3 event_title_text = vc
       3 clinical_event_id = f8
       3 result_status_cd = f8
       3 event_class_cd = f8
       3 med_result_list[*]
         4 synonym_id = f8
         4 initial_volume = f8
         4 infused_volume_unit_cd = f8
         4 infusion_rate = f8
         4 infusion_unit_cd = f8
         4 initial_dosage = f8
         4 dosage_unit_cd = f8
         4 admin_start_dt_tm = dq8
         4 admin_start_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD calc_struct(
   1 ingred_list[*]
     2 event_cd = f8
     2 ingred_disp_name = vc
     2 total_volume = f8
     2 total_volume_unit_cd = f8
     2 total_dosage = f8
     2 total_dosage_unit_cd = f8
 ) WITH protect
 RECORD priv_request(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 ) WITH protect
 RECORD priv_reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD reply(
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE medstudent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE unscheduled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"UNSCHEDULED"))
 DECLARE iv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE begin_bag_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE inerrnomut_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE inerrnoview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE order_comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE civparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE iv_end_bag_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"IVENDBAG"))
 DECLARE pending_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE overdue_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE inprocess_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE validation_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE viewrslts_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"VIEWRSLTS"))
 DECLARE vieworder_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"VIEWORDER"))
 DECLARE cactivitytype = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"ACTIVITYTYPE"))
 DECLARE ccatalogtype = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"CATALOGTYPE"))
 DECLARE corderables = f8 WITH protect, constant(uar_get_code_by("MEANING",6015,"ORDERABLES"))
 DECLARE priv_yes = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"YES"))
 DECLARE priv_no = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"NO"))
 DECLARE priv_yes_except_for = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"EXCLUDE"))
 DECLARE priv_no_except_for = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"INCLUDE"))
 DECLARE dcpgeneric_cd = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE encntr_clause = vc WITH protect, noconstant("")
 DECLARE exempt_orders_clause = vc WITH protect, noconstant("")
 DECLARE temp_string = vc WITH protect, noconstant("")
 DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE dordertotal = i4 WITH protect, noconstant(0)
 DECLARE deventtotal = i4 WITH protect, noconstant(0)
 DECLARE iingredtotal = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_ndx = i4 WITH protect, noconstant(1)
 DECLARE order_nstart = i4 WITH protect, noconstant(1)
 DECLARE encntr_ndx = i4 WITH protect, noconstant(1)
 DECLARE encntr_nstart = i4 WITH protect, noconstant(1)
 DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
 DECLARE borderisviewable = i2 WITH protect, noconstant(0)
 DECLARE filteredordercount = i4 WITH protect, noconstant(0)
 DECLARE dpriv = f8 WITH protect, noconstant(0)
 DECLARE bhasprivs = i2 WITH protect, noconstant(0)
 DECLARE dppr_cd = f8 WITH protect, noconstant(0)
 DECLARE dpositioncd = f8 WITH protect, noconstant(0)
 DECLARE current_dt_tm = dq8 WITH protect
 DECLARE encntrs_api_stat = i2 WITH protect, noconstant(0)
 DECLARE initialize(null) = null
 DECLARE loadorderswithalpdispsort(null) = null
 DECLARE loadorderswithendbagsort(null) = null
 DECLARE loadordercomments(null) = null
 DECLARE loadevents(null) = null
 DECLARE populateencounters(null) = null
 DECLARE checkresultpriv(null) = i2
 DECLARE checkorgsecurity(null) = null
 DECLARE checksecurity(null) = null
 DECLARE loadprivileges(null) = i2
 CALL initialize(null)
 IF (( $INPUTPERSONID=0))
  CALL buildxml(1,1)
 ELSE
  IF (checkresultpriv(null)=1)
   IF (loadprivileges(null)=1)
    SET bhasprivs = 1
   ENDIF
  ENDIF
  IF (bhasprivs=1)
   CALL checksecurity(null)
   IF (( $SORTFLAG=0))
    SET exempt_orders_clause = "0=0"
    CALL loadorderswithalpdispsort(null)
   ELSE
    SET exempt_orders_clause = concat(
     "not expand (order_ndx, order_nstart, size(order_list->orders, 5), o.order_id,",
     "order_list->orders[order_ndx].order_id)")
    CALL loadorderswithendbagsort(null)
    CALL loadorderswithalpdispsort(null)
   ENDIF
   IF (order_cnt > 0)
    CALL loadordercomments(null)
    CALL loadevents(null)
   ENDIF
  ENDIF
  SET error_cd = error(error_msg,1)
  CALL buildxml(bhasprivs,error_cd)
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
 ENDIF
 SUBROUTINE initialize(null)
  CALL echo("********Initialize********")
  SELECT INTO "nl:"
   FROM code_value_alias cva
   PLAN (cva
    WHERE cva.contributor_source_cd=powerchart
     AND cva.alias=cnvtupper("DCPGENERIC"))
   DETAIL
    dcpgeneric_cd = cva.code_value
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE checkresultpriv(null)
   CALL echo("********Entering CheckResultPriv Subroutine********")
   DECLARE currentpositioncd = f8 WITH protect, noconstant(0)
   SET currentpositioncd = getcurrentposition(null)
   IF (currentpositioncd)
    CALL echo(build("User's current position is ",sac_cur_pos_rep->position_cd))
    SET currentpositioncd = sac_cur_pos_rep->position_cd
   ELSE
    CALL echo(build("Default position lookup failed with status ",sac_cur_pos_rep->status_data.status
      ))
    SET currentpositioncd = 0.0
   ENDIF
   SET dpositioncd = currentpositioncd
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     priv_loc_reltn plr,
     privilege priv
    PLAN (epr
     WHERE (epr.encntr_id= $INPUTENCOUNTERID)
      AND (epr.prsnl_person_id=reqinfo->updt_id))
     JOIN (plr
     WHERE plr.ppr_cd=epr.encntr_prsnl_r_cd)
     JOIN (priv
     WHERE priv.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND priv.active_ind=1
      AND priv.privilege_cd=viewrslts_cd)
    DETAIL
     dpriv = priv.priv_value_cd, dppr_cd = plr.ppr_cd
    WITH nocounter
   ;end select
   IF (dpriv != priv_no)
    CALL echo(build("********Leaving CheckResultPriv (1) Subroutine [User Priv = ",dpriv,"]********")
     )
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl pr,
     priv_loc_reltn plr,
     privilege p
    PLAN (pr
     WHERE (pr.person_id=reqinfo->updt_id))
     JOIN (plr
     WHERE plr.position_cd=currentpositioncd)
     JOIN (p
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND p.active_ind=1
      AND p.privilege_cd=viewrslts_cd)
    DETAIL
     dpriv = p.priv_value_cd, dppr_cd = plr.ppr_cd
    WITH nocounter
   ;end select
   CALL echo(build("********Leaving CheckResultPriv (2) Subroutine [Position Priv = ",dpriv,
     "]********"))
   IF (dpriv != priv_no)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadprivileges(null)
   CALL echo("********LoadPrivileges********")
   SET priv_request->chk_prsnl_ind = 1
   SET priv_request->chk_psn_ind = 1
   SET priv_request->position_cd = dpositioncd
   SET priv_request->chk_ppr_ind = 1
   SET priv_request->ppr_cd = dppr_cd
   SET stat = alterlist(priv_request->plist,1)
   SET priv_request->plist[1].privilege_cd = vieworder_cd
   SET priv_request->plist[1].privilege_mean = "VIEWORDER"
   SET modify = nopredeclare
   EXECUTE dcp_get_privs  WITH replace("REQUEST","PRIV_REQUEST"), replace("REPLY","PRIV_REPLY")
   SET modify = predeclare
   IF (size(priv_reply->qual,5)=1)
    IF ((((priv_reply->status_data[1].status="Z")) OR ((priv_reply->qual[1].priv_value_cd=priv_yes)
    )) )
     CALL echo("**********User has privs to view orders**********")
     RETURN(1)
    ELSEIF ((((priv_reply->status_data[1].status="F")) OR ((priv_reply->qual[1].priv_value_cd=priv_no
    ))) )
     CALL echo("**********User does not have privs to view orders**********")
     RETURN(0)
    ENDIF
    CALL echo("**********User has privs to view orders, will check exceptions**********")
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (canorderbeviewed(dcatalogcd=f8,dactivitytypecd=f8,dcatalogtypecd=f8,dorderid=f8) =i2)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE prividx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE granted_ind = i2 WITH protect, noconstant(0)
   IF (size(priv_reply->qual,5)=1)
    SET prividx = 1
    SET granted_ind = privisgranted(priv_reply->qual[prividx].priv_value_cd)
    IF (size(priv_reply->qual[prividx].excepts,5)=0)
     IF (granted_ind=1)
      CALL logmessageinreply(2,build("Filtered order: ",dorderid))
     ENDIF
     RETURN(granted_ind)
    ELSE
     SET retval = doesexceptionexist(dcatalogcd,dactivitytypecd,dcatalogtypecd,prividx)
     IF (retval=1)
      IF (granted_ind=1)
       CALL echo("---->Will not display")
       SET filteredordercount += 1
       CALL logmessageinreply(2,build("Filtered order: ",dorderid))
       RETURN(0)
      ELSE
       CALL echo("---->Will display")
       RETURN(1)
      ENDIF
     ELSE
      IF (granted_ind=1)
       CALL echo(build("*********Did Not Find an exception for order id--->",dorderid,
         "-----Will display"))
      ELSE
       SET filteredordercount += 1
       CALL echo(build("*********Did Not Find an exception for order id--->",dorderid,
         "-----Will NOT display"))
       CALL logmessageinreply(2,build("Filtered order: ",dorderid))
      ENDIF
      RETURN(granted_ind)
     ENDIF
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (privisgranted(dpriv_value_cd=f8) =i2)
   IF (((dpriv_value_cd=priv_yes) OR (dpriv_value_cd=priv_yes_except_for)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (doesexceptionexist(dcatalogcd=f8,dactivitytypecd=f8,dcatalogtypecd=f8,iprividx=i4) =i2)
   DECLARE num = i4 WITH protect, noconstant(0)
   FOR (num = 1 TO size(priv_reply->qual[prividx].excepts,5))
     IF ((priv_reply->qual[prividx].excepts.exception_type_cd=cactivitytype))
      IF ((priv_reply->qual[prividx].excepts[num].exception_id=dactivitytypecd))
       CALL echo(build("*********FOUND AN EXCEPTION for activity type code--->",dactivitytypecd))
       RETURN(1)
      ENDIF
     ENDIF
     IF ((priv_reply->qual[prividx].excepts[num].exception_type_cd=ccatalogtype))
      IF ((priv_reply->qual[prividx].excepts[num].exception_id=dcatalogtypecd))
       CALL echo(build("*********FOUND AN EXCEPTION for catalog type code--->",dcatalogtypecd))
       RETURN(1)
      ENDIF
     ENDIF
     IF ((priv_reply->qual[prividx].excepts[num].exception_type_cd=corderables))
      IF ((priv_reply->qual[prividx].excepts[num].exception_id=dcatalogcd))
       CALL echo(build("*********FOUND AN EXCEPTION for catalog code--->",dcatalogcd))
       RETURN(1)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (logmessageinreply(iloglevel=i2,slogmessage=vc) =null)
   DECLARE count = i2 WITH protect, noconstant(0)
   SET count = size(reply->log_info,5)
   SET count += 1
   SET stat = alterlist(reply->log_info,count)
   SET reply->log_info[count].log_level = iloglevel
   SET reply->log_info[count].log_message = slogmessage
 END ;Subroutine
 SUBROUTINE populateencounters(null)
  CALL echo("********PopulateEncounters********")
  IF (( $ENCNTRFILTER=1))
   SET encntr_id =  $INPUTENCOUNTERID
   SET encntr_clause = "o.encntr_id = encntr_id"
   SET stat = alterlist(event_request->encntr_list,1)
   SET event_request->encntr_list[1].encntr_id =  $INPUTENCOUNTERID
  ELSE
   SET encntr_clause = concat(
    "expand (encntr_ndx, encntr_nstart, size(event_request->encntr_list, 5), o.encntr_id+0,",
    "event_request->encntr_list[encntr_ndx].encntr_id)")
   DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.person_id= $INPUTPERSONID)
    HEAD e.encntr_id
     encntr_cnt += 1
     IF (encntr_cnt > size(event_request->encntr_list,5))
      stat = alterlist(event_request->encntr_list,(encntr_cnt+ 9))
     ENDIF
     event_request->encntr_list[encntr_cnt].encntr_id = e.encntr_id
    FOOT  e.encntr_id
     stat = alterlist(event_request->encntr_list,encntr_cnt)
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE checksecurity(null)
   DECLARE lencntrcnt = i4 WITH protect, noconstant(0)
   DECLARE lencntridx = i4 WITH protect, noconstant(0)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET modify = nopredeclare
   RECORD accessible_encntr_person_ids(
     1 person_ids[*]
       2 person_id = f8
   ) WITH public
   RECORD accessible_encntr_ids(
     1 accessible_encntrs_cnt = i4
     1 accessible_encntrs[*]
       2 accessible_encntr_id = f8
   ) WITH public
   RECORD accessible_encntr_ids_maps(
     1 persons_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 accessible_encntrs_cnt = i4
       2 accessible_encntrs[*]
         3 accessible_encntr_id = f8
   ) WITH public
   DECLARE getaccessibleencntrerrormsg = vc WITH protect
   DECLARE getaccessibleencntrtoggleerrormsg = vc WITH protect
   DECLARE h3202611srvmsg = i4 WITH noconstant(0), protect
   DECLARE h3202611srvreq = i4 WITH noconstant(0), protect
   DECLARE h3202611srvrep = i4 WITH noconstant(0), protect
   DECLARE hsys = i4 WITH noconstant(0), protect
   DECLARE sysstat = i4 WITH noconstant(0), protect
   DECLARE slogtext = vc WITH noconstant(""), protect
   DECLARE access_encntr_req_number = i4 WITH constant(3202611), protect
   SUBROUTINE (get_accessible_encntr_ids_by_person_id(person_id=f8,concept=vc,
    disable_access_security_ind=i2(value,0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,encounter_count)
        SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids->accessible_encntrs[e_count].accessible_encntr_id =
         uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
      RETURN(0)
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids=vc(ref),concept=
    vc,disable_access_security_ind=i2(value,0),user_id=f8(value,0.0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE p_count = i4 WITH noconstant(0), protect
     DECLARE person_count = i4 WITH noconstant(0), protect
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     DECLARE curr_encntr_cnt = i4 WITH noconstant(0), protect
     DECLARE prev_encntr_cnt = i4 WITH noconstant(0), protect
     SET person_count = size(accessible_encntr_person_ids->person_ids,5)
     FOR (p_count = 1 TO person_count)
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
       IF (disable_access_security_ind=0)
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
       ELSE
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
       ENDIF
       SET stat = uar_srvsetdouble(h3202611srvreq,"userId",user_id)
       SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
       IF (stat=0)
        SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
        IF (htransactionstatus=0)
         SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
          build(access_encntr_req_number))
         RETURN(1)
        ELSE
         IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
          SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
            access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
            "debugErrorMessage"))
          RETURN(1)
         ELSE
          SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
          SET prev_encntr_cnt = curr_encntr_cnt
          SET curr_encntr_cnt += encounter_count
          SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,curr_encntr_cnt)
          SET accessible_encntr_ids->accessible_encntrs_cnt = curr_encntr_cnt
          FOR (e_count = 1 TO encounter_count)
           SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
           SET accessible_encntr_ids->accessible_encntrs[(e_count+ prev_encntr_cnt)].
           accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
        RETURN(1)
       ENDIF
     ENDFOR
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids_map(accessible_encntr_person_ids=vc(ref),
    concept=vc,disable_access_security_ind=i2(value,0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE p_count = i4 WITH noconstant(0), protect
     DECLARE person_count = i4 WITH noconstant(0), protect
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     SET person_count = size(accessible_encntr_person_ids->person_ids,5)
     SET accessible_encntr_ids_maps->persons_cnt = person_count
     FOR (p_count = 1 TO person_count)
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
       IF (disable_access_security_ind=0)
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
       ELSE
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
       ENDIF
       SET accessible_encntr_ids_maps->persons[p_count].person_id = accessible_encntr_person_ids->
       person_ids[p_count].person_id
       SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
       IF (stat=0)
        SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
        IF (htransactionstatus=0)
         SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
          build(access_encntr_req_number))
         RETURN(1)
        ELSE
         IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
          SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
            access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
            "debugErrorMessage"))
          RETURN(1)
         ELSE
          SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
          SET stat = alterlist(accessible_encntr_ids_maps->persons[p_count].accessible_encntrs,
           encounter_count)
          SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs_cnt = encounter_count
          FOR (e_count = 1 TO encounter_count)
           SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
           SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs[e_count].
           accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
        RETURN(1)
       ENDIF
     ENDFOR
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_toggle(result=i4(ref)) =i4)
     DECLARE concept_policies_req_concept = vc WITH constant("PowerChart_Framework"), protect
     DECLARE featuretoggleflag = i2 WITH noconstant(false), protect
     DECLARE chartaccessflag = i2 WITH noconstant(false), protect
     DECLARE featuretogglestat = i2 WITH noconstant(0), protect
     DECLARE chartaccessstat = i2 WITH noconstant(0), protect
     SET featuretogglestat = isfeaturetoggleon(
      "urn:cerner:millennium:accessible-encounters-by-concept","urn:cerner:millennium",
      featuretoggleflag)
     CALL uar_syscreatehandle(hsys,sysstat)
     IF (hsys > 0)
      SET slogtext = build2("get_accessible_encntr_toggle - featureToggleStat is ",build(
        featuretogglestat))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      SET slogtext = build2("get_accessible_encntr_toggle - featureToggleFlag is ",build(
        featuretoggleflag))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      CALL uar_sysdestroyhandle(hsys)
     ENDIF
     IF (featuretogglestat=0
      AND featuretoggleflag=true)
      SET result = 1
      RETURN(0)
     ENDIF
     IF (featuretogglestat != 0)
      CALL uar_syscreatehandle(hsys,sysstat)
      IF (hsys > 0)
       SET slogtext = build("Feature toggle service returned failure status.")
       CALL uar_sysevent(hsys,1,"pm_get_access_encntr_by_person",nullterm(slogtext))
       CALL uar_sysdestroyhandle(hsys)
      ENDIF
     ENDIF
     SET chartaccessstat = ischartaccesson(concept_policies_req_concept,chartaccessflag)
     CALL uar_syscreatehandle(hsys,sysstat)
     IF (hsys > 0)
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessStat is ",build(
        chartaccessstat))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessFlag is ",build(
        chartaccessflag))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      CALL uar_sysdestroyhandle(hsys)
     ENDIF
     IF (chartaccessstat != 0)
      RETURN(1)
     ENDIF
     IF (chartaccessflag=true)
      SET result = 1
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (isfeaturetoggleon(togglename=vc,systemidentifier=vc,featuretoggleflag=i2(ref)) =i4)
     DECLARE feature_toggle_req_number = i4 WITH constant(2030001), protect
     DECLARE toggle = vc WITH noconstant(""), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagmsg = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagreq = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagrep = i4 WITH noconstant(0), protect
     DECLARE rep2030001count = i4 WITH noconstant(0), protect
     DECLARE rep2030001successind = i2 WITH noconstant(0), protect
     SET hfeatureflagmsg = uar_srvselectmessage(feature_toggle_req_number)
     IF (hfeatureflagmsg=0)
      RETURN(0)
     ENDIF
     SET hfeatureflagreq = uar_srvcreaterequest(hfeatureflagmsg)
     IF (hfeatureflagreq=0)
      RETURN(0)
     ENDIF
     SET hfeatureflagrep = uar_srvcreatereply(hfeatureflagmsg)
     IF (hfeatureflagrep=0)
      RETURN(0)
     ENDIF
     SET stat = uar_srvsetstring(hfeatureflagreq,"system_identifier",nullterm(systemidentifier))
     SET stat = uar_srvsetshort(hfeatureflagreq,"ignore_overrides_ind",1)
     IF (uar_srvexecute(hfeatureflagmsg,hfeatureflagreq,hfeatureflagrep)=0)
      SET htransactionstatus = uar_srvgetstruct(hfeatureflagrep,"transaction_status")
      IF (htransactionstatus != 0)
       SET rep2030001successind = uar_srvgetshort(htransactionstatus,"success_ind")
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2(
        "Failed to get transaction status from reply of ",build(feature_toggle_req_number))
       RETURN(1)
      ENDIF
      IF (rep2030001successind=1)
       IF (uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",0) > 0)
        SET rep2030001count = uar_srvgetitemcount(hfeatureflagrep,"feature_toggle_keys")
        FOR (loop = 0 TO (rep2030001count - 1))
         SET toggle = uar_srvgetstringptr(uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",loop),
          "key")
         IF (togglename=toggle)
          SET featuretoggleflag = true
          RETURN(0)
         ENDIF
        ENDFOR
       ENDIF
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
         feature_toggle_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
         "debug_error_message"))
       RETURN(1)
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        feature_toggle_req_number))
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (ischartaccesson(concept=vc,chartaccessflag=i2(ref)) =i4)
     DECLARE concept_policies_req_number = i4 WITH constant(3202590), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesmsg = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesreq = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesrep = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesstruct = i4 WITH noconstant(0), protect
     DECLARE rep3202590count = i4 WITH noconstant(0), protect
     DECLARE rep3202590successind = i2 WITH noconstant(0), protect
     SET hconceptpoliciesmsg = uar_srvselectmessage(concept_policies_req_number)
     IF (hconceptpoliciesmsg=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesreq = uar_srvcreaterequest(hconceptpoliciesmsg)
     IF (hconceptpoliciesreq=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesrep = uar_srvcreatereply(hconceptpoliciesmsg)
     IF (hconceptpoliciesrep=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesreqstruct = uar_srvadditem(hconceptpoliciesreq,"concepts")
     IF (hconceptpoliciesreqstruct > 0)
      SET stat = uar_srvsetstring(hconceptpoliciesreqstruct,"concept",nullterm(concept))
      IF (uar_srvexecute(hconceptpoliciesmsg,hconceptpoliciesreq,hconceptpoliciesrep)=0)
       SET htransactionstatus = uar_srvgetstruct(hconceptpoliciesrep,"transaction_status")
       IF (htransactionstatus != 0)
        SET rep3202590successind = uar_srvgetshort(htransactionstatus,"success_ind")
       ELSE
        SET getaccessibleencntrtoggleerrormsg = build2(
         "Failed to get transaction status from reply of ",build(concept_policies_req_number))
        RETURN(1)
       ENDIF
       IF (rep3202590successind=1)
        IF (uar_srvgetitem(hconceptpoliciesrep,"concept_policies_batch",0) > 0)
         SET rep3202590count = uar_srvgetitemcount(hconceptpoliciesrep,"concept_policies_batch")
         FOR (loop = 0 TO (rep3202590count - 1))
          SET hconceptpoliciesstruct = uar_srvgetstruct(uar_srvgetitem(hconceptpoliciesrep,
            "concept_policies_batch",loop),"policies")
          IF (hconceptpoliciesstruct > 0)
           IF (uar_srvgetshort(hconceptpoliciesstruct,"chart_access_group_security_ind")=1)
            SET chartaccessflag = true
            RETURN(0)
           ENDIF
          ELSE
           SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
             concept_policies_req_number),build("Found an invalid hConceptPoliciesStruct : ",
             hconceptpoliciesstruct))
           RETURN(1)
          ENDIF
         ENDFOR
        ENDIF
       ELSE
        SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
          concept_policies_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debug_error_message"))
        RETURN(1)
       ENDIF
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
         concept_policies_req_number))
       RETURN(1)
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        concept_policies_req_number),build("Found an invalid hConceptPoliciesReqStruct : ",
        hconceptpoliciesreqstruct))
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (getaccessibleencounters(person_id=f8,debug_ind=i2) =i4)
     DECLARE accessible_encntrs_stat = i4 WITH protect, noconstant(0)
     DECLARE chart_access_stat = i2 WITH protect, noconstant(0)
     DECLARE chart_access_flag = i2 WITH protect, noconstant(false)
     DECLARE mrd_concept_string = vc WITH protect, constant("MEDICATION_RECORD")
     SET accessible_encntrs_stat = get_accessible_encntr_ids_by_person_id(person_id,
      mrd_concept_string)
     IF (accessible_encntrs_stat=0)
      IF (debug_ind)
       CALL echo("User's Accessible Encounters: ")
       CALL echorecord(accessible_encntr_ids)
      ENDIF
      RETURN(0)
     ELSE
      IF (debug_ind)
       CALL echo(build("Encounter Retrieval Failed because:",getaccessibleencntrerrormsg))
      ENDIF
      SET chart_access_stat = ischartaccesson(mrd_concept_string,chart_access_flag)
      IF (chart_access_stat=0
       AND chart_access_flag=false)
       IF (debug_ind)
        CALL echo("Chart Access is disabled, so legacy implementation can be used")
       ENDIF
       RETURN(1)
      ELSE
       IF (debug_ind)
        CALL echo("Chart Access is enabled, so legacy implementation can't be used")
       ENDIF
       RETURN(2)
      ENDIF
     ENDIF
   END ;Subroutine
   SET modify = predeclare
   SET encntrs_api_stat = getaccessibleencounters( $INPUTPERSONID,0)
   IF (encntrs_api_stat=0)
    SET lencntrcnt = accessible_encntr_ids->accessible_encntrs_cnt
    IF (( $ENCNTRFILTER=1))
     SET encntr_id =  $INPUTENCOUNTERID
     SET encntr_clause = "o.encntr_id = encntr_id"
     IF (lencntrcnt > 0)
      SET lpos = locateval(lencntridx,1,lencntrcnt,encntr_id,accessible_encntr_ids->
       accessible_encntrs[lencntridx].accessible_encntr_id)
      IF (lpos > 0)
       SET stat = alterlist(event_request->encntr_list,1)
       SET event_request->encntr_list[1].encntr_id =  $INPUTENCOUNTERID
      ENDIF
     ENDIF
    ELSE
     SET encntr_clause = concat(
      "expand (encntr_ndx, encntr_nstart, size(event_request->encntr_list, 5), o.encntr_id+0,",
      "event_request->encntr_list[encntr_ndx].encntr_id)")
     IF (lencntrcnt > 0)
      SET stat = alterlist(event_request->encntr_list,lencntrcnt)
      FOR (lencntridx = 1 TO lencntrcnt)
        SET event_request->encntr_list[lencntridx].encntr_id = accessible_encntr_ids->
        accessible_encntrs[lencntridx].accessible_encntr_id
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF (encntrs_api_stat=1)
    CALL populateencounters(null)
    CALL checkorgsecurity(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkorgsecurity(null)
   CALL echo("********CheckOrgSecurity********")
   DECLARE inencntridx = i4 WITH noconstant(0)
   DECLARE orgsecidx = i4 WITH noconstant(0)
   DECLARE curlistsize = i4 WITH noconstant(0)
   DECLARE locval = i4 WITH protect, noconstant(0)
   FREE RECORD valid_req
   RECORD valid_req(
     1 prsnl_id = f8
     1 person_id = f8
   )
   SET valid_req->person_id =  $INPUTPERSONID
   SET valid_req->prsnl_id = reqinfo->updt_id
   FREE RECORD pts_encntr
   RECORD pts_encntr(
     1 restrict_ind = i2
     1 encntrs
       2 data_cnt = i2
       2 data[1]
         3 encntr_id = f8
     1 lookup_status = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   FREE RECORD internal_encntrs
   RECORD internal_encntrs(
     1 encntr_list[*]
       2 encntr_id = f8
   )
   SET modify = nopredeclare
   EXECUTE pts_get_valid_encntrs  WITH replace(request,valid_req), replace(reply,pts_encntr)
   SET modify = predeclare
   IF ((pts_encntr->restrict_ind=1))
    IF (size(event_request->encntr_list,5) > 0)
     FOR (inencntridx = 1 TO size(event_request->encntr_list,5))
       FOR (orgsecidx = 1 TO pts_encntr->encntrs.data_cnt)
         IF ((event_request->encntr_list[inencntridx].encntr_id=pts_encntr->encntrs.data[orgsecidx].
         encntr_id))
          SET curlistsize = (size(internal_encntrs->encntr_list,5)+ 1)
          SET stat = alterlist(internal_encntrs->encntr_list,curlistsize)
          SET internal_encntrs->encntr_list[curlistsize].encntr_id = event_request->encntr_list[
          inencntridx].encntr_id
          SET orgsecidx = pts_encntr->encntrs.data_cnt
         ENDIF
       ENDFOR
     ENDFOR
    ELSE
     SET stat = alterlist(internal_encntrs->encntr_list,pts_encntr->encntrs.data_cnt)
     FOR (orgsecidx = 1 TO pts_encntr->encntrs.data_cnt)
       SET internal_encntrs->encntr_list[orgsecidx].encntr_id = pts_encntr->encntrs.data[orgsecidx].
       encntr_id
     ENDFOR
    ENDIF
    SET curlistsize = size(internal_encntrs->encntr_list,5)
    IF (curlistsize > 0)
     SET stat = alterlist(event_request->encntr_list,curlistsize)
     FOR (inencntridx = 1 TO curlistsize)
       IF (locateval(locval,1,curlistsize,internal_encntrs->encntr_list[inencntridx].encntr_id,
        event_request->encntr_list[locval].encntr_id)=0)
        SET event_request->encntr_list[inencntridx].encntr_id = internal_encntrs->encntr_list[
        inencntridx].encntr_id
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   FREE RECORD internal_encntrs
 END ;Subroutine
 SUBROUTINE loadorderswithalpdispsort(null)
  CALL echo("********LoadOrdersWithAlpDispSort********")
  SELECT
   IF (( $IVDISPLEVEL=1))
    order_display = cnvtupper(o.ordered_as_mnemonic)
   ELSE
    order_display = cnvtupper(o.hna_order_mnemonic)
   ENDIF
   INTO "nl:"
   FROM orders o,
    order_ingredient oi,
    order_catalog oc,
    order_catalog_synonym ocs,
    task_activity ta
   PLAN (o
    WHERE (o.person_id= $INPUTPERSONID)
     AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
     AND ((o.template_order_id+ 0)=0)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_clause)
     AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
     AND ((o.med_order_type_cd+ 0)=iv_cd)
     AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
    pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd)
     AND parser(exempt_orders_clause))
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE oi2.order_id=oi.order_id)))
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=oi.synonym_id)
    JOIN (ta
    WHERE (ta.order_id= Outerjoin(o.order_id))
     AND (ta.task_type_cd= Outerjoin(iv_end_bag_cd)) )
   ORDER BY order_display, o.order_id, oi.action_sequence DESC,
    oi.comp_sequence
   HEAD REPORT
    order_cnt = size(order_list->orders,5), borderisviewable = 0, ingred_cnt = 0
   HEAD o.order_id
    borderisviewable = canorderbeviewed(o.catalog_cd,o.activity_type_cd,o.catalog_type_cd,o.order_id)
    IF (borderisviewable=1)
     order_cnt += 1, ingred_cnt = 0
     IF (order_cnt > size(order_list->orders,5))
      stat = alterlist(order_list->orders,(order_cnt+ 9))
     ENDIF
     order_list->orders[order_cnt].order_id = o.order_id, order_list->orders[order_cnt].catalog_cd =
     o.catalog_cd, order_list->orders[order_cnt].catalog_type_cd = o.catalog_type_cd,
     order_list->orders[order_cnt].activity_type_cd = o.activity_type_cd, order_list->orders[
     order_cnt].clin_disp_line = o.clinical_display_line, order_list->orders[order_cnt].
     comment_type_mask = o.comment_type_mask,
     order_list->orders[order_cnt].hna_order_mnemonic = o.hna_order_mnemonic, order_list->orders[
     order_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, order_list->orders[order_cnt].
     clin_disp_line = o.clinical_display_line
     IF (ta.task_type_cd=iv_end_bag_cd
      AND ta.task_status_cd IN (pending_task_cd, overdue_task_cd, inprocess_task_cd,
     validation_task_cd))
      order_list->orders[order_cnt].end_bag_exists = 1, order_list->orders[order_cnt].
      end_bag_task_dt_tm = ta.task_dt_tm, order_list->orders[order_cnt].end_bag_task_tm_tz = ta
      .task_tz
      IF (ta.task_dt_tm <= cnvtdatetime( $ENDTIME)
       AND ta.task_dt_tm >= cnvtdatetime( $STARTTIME))
       order_list->orders[order_cnt].end_bag_in_time_range = 1
      ENDIF
     ELSE
      order_list->orders[order_cnt].end_bag_exists = 0
     ENDIF
    ENDIF
   DETAIL
    IF (borderisviewable=1)
     ingred_cnt += 1
     IF (ingred_cnt > size(order_list->orders[order_cnt].ingreds,5))
      stat = alterlist(order_list->orders[order_cnt].ingreds,(ingred_cnt+ 4))
     ENDIF
     order_list->orders[order_cnt].ingreds[ingred_cnt].catalog_cd = oc.catalog_cd, order_list->
     orders[order_cnt].ingreds[ingred_cnt].action_sequence = oi.action_sequence, order_list->orders[
     order_cnt].ingreds[ingred_cnt].ingred_type_flag = oi.ingredient_type_flag,
     order_list->orders[order_cnt].ingreds[ingred_cnt].volume = oi.volume, order_list->orders[
     order_cnt].ingreds[ingred_cnt].volume_unit = oi.volume_unit, order_list->orders[order_cnt].
     ingreds[ingred_cnt].strength = oi.strength,
     order_list->orders[order_cnt].ingreds[ingred_cnt].strength_unit = oi.strength_unit, order_list->
     orders[order_cnt].ingreds[ingred_cnt].order_mnemonic = oi.order_mnemonic, order_list->orders[
     order_cnt].ingreds[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
     order_list->orders[order_cnt].ingreds[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic
    ENDIF
   FOOT  o.order_id
    IF (size(order_list->orders,5) > 0)
     stat = alterlist(order_list->orders[order_cnt].ingreds,ingred_cnt)
    ENDIF
   FOOT REPORT
    stat = alterlist(order_list->orders,order_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadorderswithendbagsort(null)
  CALL echo("********LoadOrdersWithEndBagSort********")
  SELECT
   IF (( $IVDISPLEVEL=1))
    order_display = cnvtupper(o.ordered_as_mnemonic)
   ELSE
    order_display = cnvtupper(o.hna_order_mnemonic)
   ENDIF
   INTO "nl:"
   FROM orders o,
    order_ingredient oi,
    order_catalog oc,
    order_catalog_synonym ocs,
    task_activity ta
   PLAN (o
    WHERE (o.person_id= $INPUTPERSONID)
     AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
     AND ((o.template_order_id+ 0)=0)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11))
     AND parser(encntr_clause)
     AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
     AND ((o.med_order_type_cd+ 0)=iv_cd)
     AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, medstudent_cd, ordered_cd,
    pending_cd, pending_rev_cd, suspended_cd, unscheduled_cd))
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE oi2.order_id=oi.order_id)))
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=oi.synonym_id)
    JOIN (ta
    WHERE ta.order_id=o.order_id
     AND ta.task_status_cd IN (pending_task_cd, overdue_task_cd, inprocess_task_cd,
    validation_task_cd)
     AND ta.task_type_cd=iv_end_bag_cd
     AND ta.task_dt_tm <= cnvtdatetime( $ENDTIME)
     AND ta.task_dt_tm >= cnvtdatetime( $STARTTIME))
   ORDER BY ta.task_dt_tm, order_display, o.order_id,
    oi.action_sequence DESC, oi.comp_sequence
   HEAD REPORT
    borderisviewable = 0, order_cnt = 0, ingred_cnt = 0
   HEAD o.order_id
    borderisviewable = canorderbeviewed(o.catalog_cd,o.activity_type_cd,o.catalog_type_cd,o.order_id)
    IF (borderisviewable=1)
     order_cnt += 1, ingred_cnt = 0
     IF (order_cnt > size(order_list->orders,5))
      stat = alterlist(order_list->orders,(order_cnt+ 9))
     ENDIF
     order_list->orders[order_cnt].order_id = o.order_id, order_list->orders[order_cnt].catalog_cd =
     o.catalog_cd, order_list->orders[order_cnt].clin_disp_line = o.clinical_display_line,
     order_list->orders[order_cnt].comment_type_mask = o.comment_type_mask, order_list->orders[
     order_cnt].hna_order_mnemonic = o.hna_order_mnemonic, order_list->orders[order_cnt].
     ordered_as_mnemonic = o.ordered_as_mnemonic,
     order_list->orders[order_cnt].clin_disp_line = o.clinical_display_line, order_list->orders[
     order_cnt].end_bag_exists = 1, order_list->orders[order_cnt].end_bag_task_dt_tm = ta.task_dt_tm,
     order_list->orders[order_cnt].end_bag_task_tm_tz = ta.task_tz
     IF (ta.task_dt_tm <= cnvtdatetime( $ENDTIME)
      AND ta.task_dt_tm >= cnvtdatetime( $STARTTIME))
      order_list->orders[order_cnt].end_bag_in_time_range = 1
     ENDIF
    ENDIF
   DETAIL
    IF (borderisviewable=1)
     ingred_cnt += 1
     IF (ingred_cnt > size(order_list->orders[order_cnt].ingreds,5))
      stat = alterlist(order_list->orders[order_cnt].ingreds,(ingred_cnt+ 4))
     ENDIF
     order_list->orders[order_cnt].ingreds[ingred_cnt].catalog_cd = oc.catalog_cd, order_list->
     orders[order_cnt].ingreds[ingred_cnt].action_sequence = oi.action_sequence, order_list->orders[
     order_cnt].ingreds[ingred_cnt].ingred_type_flag = oi.ingredient_type_flag,
     order_list->orders[order_cnt].ingreds[ingred_cnt].volume = oi.volume, order_list->orders[
     order_cnt].ingreds[ingred_cnt].volume_unit = oi.volume_unit, order_list->orders[order_cnt].
     ingreds[ingred_cnt].strength = oi.strength,
     order_list->orders[order_cnt].ingreds[ingred_cnt].strength_unit = oi.strength_unit, order_list->
     orders[order_cnt].ingreds[ingred_cnt].order_mnemonic = oi.order_mnemonic, order_list->orders[
     order_cnt].ingreds[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic,
     order_list->orders[order_cnt].ingreds[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic
    ENDIF
   FOOT  o.order_id
    IF (size(order_list->orders,5) > 0)
     stat = alterlist(order_list->orders[order_cnt].ingreds,ingred_cnt)
    ENDIF
   FOOT REPORT
    stat = alterlist(order_list->orders,order_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE loadordercomments(null)
   CALL echo("********LoadOrderComments********")
   DECLARE loadordercommentstime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE tempcnt = i4 WITH protect, noconstant(0)
   DECLARE order_comment_mask = i4 WITH protect, constant(1)
   RECORD commenttemp(
     1 qual[*]
       2 index = i4
   )
   SET stat = alterlist(commenttemp->qual,order_cnt)
   FOR (x = 1 TO order_cnt)
     IF (band(order_list->orders[x].comment_type_mask,order_comment_mask)=order_comment_mask)
      SET tempcnt += 1
      SET commenttemp->qual[tempcnt].index = x
     ENDIF
   ENDFOR
   IF (tempcnt > 0)
    DECLARE y = i4 WITH protect, noconstant(0)
    DECLARE nstart = i4 WITH protect, noconstant(1)
    DECLARE nsize = i4 WITH protect, constant(50)
    DECLARE iordercnt = i4 WITH protect, noconstant(size(commenttemp->qual,5))
    DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(tempcnt)/ nsize)) * nsize))
    SET stat = alterlist(commenttemp->qual,ntotal)
    FOR (i = (tempcnt+ 1) TO ntotal)
      SET commenttemp->qual[i].index = commenttemp->qual[tempcnt].index
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      order_comment oc,
      long_text lt
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
      JOIN (oc
      WHERE expand(x,nstart,(nstart+ (nsize - 1)),oc.order_id,order_list->orders[commenttemp->qual[x]
       .index].order_id)
       AND oc.comment_type_cd=order_comment_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD oc.order_id
      idx = 0
      FOR (y = 1 TO tempcnt)
        IF ((order_list->orders[commenttemp->qual[y].index].order_id=oc.order_id))
         idx = commenttemp->qual[y].index, y = (tempcnt+ 1)
        ENDIF
      ENDFOR
     FOOT  oc.order_id
      order_list->orders[idx].order_comment_text = lt.long_text
     WITH nocounter
    ;end select
    SET stat = alterlist(commenttemp->qual,iordercnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadevents(null)
   CALL echo("********LoadEvents********")
   SET event_request->person_id =  $INPUTPERSONID
   SET event_request->search_begin_dt_tm = cnvtdatetime( $STARTTIME)
   SET event_request->search_end_dt_tm = cnvtdatetime( $ENDTIME)
   SET dordertotal = size(order_list->orders,5)
   SET stat = alterlist(event_request->order_id_list,dordertotal)
   FOR (order_cnt = 1 TO dordertotal)
     SET event_request->order_id_list[order_cnt].order_id = order_list->orders[order_cnt].order_id
   ENDFOR
   SET stat = alterlist(event_request->iv_event_cd_list,1)
   SET event_request->iv_event_cd_list[1].iv_event_cd = begin_bag_cd
   SET event_request->children_flag = 1
   SET event_request->pop_seq_flag = 1
   SET stat = alterlist(event_request->status_cd_exclude_list,4)
   SET event_request->status_cd_exclude_list[1].result_status_cd = in_error_cd
   SET event_request->status_cd_exclude_list[2].result_status_cd = inerrnomut_cd
   SET event_request->status_cd_exclude_list[3].result_status_cd = inerrnoview_cd
   SET event_request->status_cd_exclude_list[4].result_status_cd = inerror_cd
   SET modify = nopredeclare
   EXECUTE bsc_ce_event_query_order  WITH replace("REQUEST","EVENT_REQUEST"), replace("REPLY",
    "EVENT_REPLY")
   SET modify = predeclare
 END ;Subroutine
 SUBROUTINE (buildxml(bhasprivs=i2,error_code=i2) =null)
   CALL echo("********BuildXML********")
   DECLARE sdosage = vc WITH protect, noconstant("")
   DECLARE svolume = vc WITH protect, noconstant("")
   DECLARE stotaladminvol = vc WITH protect, noconstant("")
   DECLARE sadmin = vc WITH protect, noconstant("")
   DECLARE seventid = vc WITH protect, noconstant("")
   DECLARE sorder_comment = vc WITH protect, noconstant("")
   DECLARE singreddispname = vc WITH protect, noconstant("")
   DECLARE locit = i4 WITH protect, noconstant(0)
   DECLARE locingred = i4 WITH protect, noconstant(0)
   DECLARE dtotaladminvol = f8 WITH protect, noconstant(0.0)
   DECLARE dtotaladminvolunitcd = f8 WITH protect, noconstant(0.0)
   DECLARE index_loc = i2 WITH protect, noconstant(0)
   DECLARE calc_struct_size = i2 WITH protect, noconstant(0)
   DECLARE event_cnt = i2 WITH protect, noconstant(0)
   DECLARE bproblemfound = i2 WITH protect, noconstant(0)
   DECLARE beventexists = i2 WITH protect, noconstant(0)
   DECLARE bskipdosage = i2 WITH protect, noconstant(0)
   IF (bhasprivs=0)
    SET bproblemfound = 1
   ELSEIF (error_code != 0)
    SET bproblemfound = 2
   ENDIF
   IF (bproblemfound <= 0)
    SET temp_string = concat(temp_string,"<page_info>")
    SET temp_string = concat(temp_string,"<page_header>",i18n_spageheader,"</page_header>")
    SET temp_string = concat(temp_string,"<table_header_main>",i18n_stableheadermain,
     "</table_header_main>")
    SET temp_string = concat(temp_string,"<table_header_sub>",i18n_stableheadersub,
     "</table_header_sub>")
    SET temp_string = concat(temp_string,"<order_info_column_header>",i18n_sorderinfohead,
     "</order_info_column_header>")
    SET temp_string = concat(temp_string,"<event_dt_tm_header>",i18n_sperformeddttmheader,
     "</event_dt_tm_header>")
    SET temp_string = concat(temp_string,"<ingred_header>",i18n_singredheader,"</ingred_header>")
    SET temp_string = concat(temp_string,"<dose_given_header>",i18n_singreddosegivenheader,
     "</dose_given_header>")
    SET temp_string = concat(temp_string,"<total_admin_label>",i18n_stotaladministered,
     "</total_admin_label>")
    SET temp_string = concat(temp_string,"<total_volume_label>",i18n_stotalvolume,
     "</total_volume_label>")
    SET temp_string = concat(temp_string,"</page_info>")
    SET dordertotal = size(order_list->orders,5)
    IF (dordertotal > 0)
     FOR (order_cnt = 1 TO dordertotal)
       SET stat = alterlist(calc_struct->ingred_list,0)
       SET temp_string = concat(temp_string,"<cont_meds>")
       IF (( $IVDISPLEVEL=1))
        SET temp_string = concat(temp_string,"<med_name>",trim(order_list->orders[order_cnt].
          ordered_as_mnemonic),"</med_name>")
       ELSE
        SET temp_string = concat(temp_string,"<med_name>",trim(order_list->orders[order_cnt].
          hna_order_mnemonic),"</med_name>")
       ENDIF
       SET temp_string = concat(temp_string,"<med_details>",trim(order_list->orders[order_cnt].
         clin_disp_line),"</med_details>")
       SET sorder_comment = trim(order_list->orders[order_cnt].order_comment_text)
       SET sorder_comment = replace(sorder_comment,"<","< ",0)
       SET sorder_comment2 = concat("<![CDATA[",sorder_comment,"]]>")
       SET temp_string = concat(temp_string,"<med_order_comment>",sorder_comment2,
        "</med_order_comment>")
       IF (order_list->orders[order_cnt].end_bag_exists)
        IF (order_list->orders[order_cnt].end_bag_in_time_range)
         SET temp_string = concat(temp_string,"<end_bag_task_time>",i18n_sendbagcompletedat," ",
          formatutcdatetime(order_list->orders[order_cnt].end_bag_task_dt_tm,order_list->orders[
           order_cnt].end_bag_task_tm_tz,1),
          "</end_bag_task_time>")
        ELSE
         SET temp_string = concat(temp_string,"<end_bag_task_time>",
          i18n_snoendbagfoundwithintimeframe,"</end_bag_task_time>")
        ENDIF
       ELSE
        SET temp_string = concat(temp_string,"<end_bag_task_time>",i18n_snoendbagavailable,
         "</end_bag_task_time>")
       ENDIF
       SET dtotaladminvol = - (2)
       SET deventtotal = size(event_reply->event_list,5)
       SET beventexists = 0
       IF (deventtotal > 0)
        FOR (event_cnt = 1 TO deventtotal)
          IF ((event_reply->event_list[event_cnt].order_id=order_list->orders[order_cnt].order_id)
           AND (event_reply->event_list[event_cnt].event_cd=civparent))
           SET beventexists += 1
           SET temp_string = concat(temp_string,"<admin>")
           SET sadmin = formatutcdatetime(event_reply->event_list[event_cnt].event_end_dt_tm,
            event_reply->event_list[event_cnt].event_end_tz,1)
           SET temp_string = concat(temp_string,"<datetime>",sadmin,"</datetime>")
           SET iingredtotal = size(event_reply->event_list[event_cnt].child_event_list,5)
           FOR (ingred_sequence = 1 TO iingredtotal)
             SET bskipdosage = 0
             SET ingred_cnt = locateval(locingred,1,iingredtotal,ingred_sequence,event_reply->
              event_list[event_cnt].child_event_list[locingred].comp_sequence)
             SET temp_string = concat(temp_string,"<ingred>")
             SET iorderingredientstotal = size(order_list->orders[order_cnt].ingreds,5)
             SET singreddispname = "--"
             IF (ingred_cnt > 0)
              FOR (order_ingred_cnt = 1 TO iorderingredientstotal)
                IF (validate(event_reply->event_list[event_cnt].child_event_list[ingred_cnt].
                 catalog_cd,0) != 0
                 AND validate(order_list->orders[order_cnt].ingreds[order_ingred_cnt].catalog_cd,0)
                 != 0)
                 IF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].catalog_cd=
                 order_list->orders[order_cnt].ingreds[order_ingred_cnt].catalog_cd))
                  IF (( $IVDISPLEVEL=1))
                   SET singreddispname = order_list->orders[order_cnt].ingreds[order_ingred_cnt].
                   ordered_as_mnemonic
                  ELSE
                   SET singreddispname = order_list->orders[order_cnt].ingreds[order_ingred_cnt].
                   hna_order_mnemonic
                  ENDIF
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             SET temp_string = concat(temp_string,"<ingred_name>",singreddispname,"</ingred_name>")
             IF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1].
             initial_volume > 0))
              SET svolume = formatvolume(event_reply->event_list[event_cnt].child_event_list[
               ingred_cnt].med_result_list[1].initial_volume)
              SET svolume = concat(svolume," ",trim(uar_get_code_display(event_reply->event_list[
                 event_cnt].child_event_list[ingred_cnt].med_result_list[1].infused_volume_unit_cd)))
              SET temp_string = concat(temp_string,"<volume_disp>",svolume,"</volume_disp>")
             ENDIF
             IF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1].
             dosage_unit_cd=event_reply->event_list[event_cnt].child_event_list[ingred_cnt].
             med_result_list[1].infused_volume_unit_cd))
              IF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1]
              .initial_dosage != event_reply->event_list[event_cnt].child_event_list[ingred_cnt].
              med_result_list[1].initial_volume)
               AND (event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1
              ].initial_dosage > 0))
               SET sdosage = formatstrength(event_reply->event_list[event_cnt].child_event_list[
                ingred_cnt].med_result_list[1].initial_dosage)
               SET sdosage = concat(sdosage," ",trim(uar_get_code_display(event_reply->event_list[
                  event_cnt].child_event_list[ingred_cnt].med_result_list[1].dosage_unit_cd)))
               SET temp_string = concat(temp_string,"<dosage_disp>",sdosage,"</dosage_disp>")
              ELSE
               SET bskipdosage = 1
              ENDIF
             ELSE
              IF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1]
              .initial_dosage > 0))
               SET sdosage = formatstrength(event_reply->event_list[event_cnt].child_event_list[
                ingred_cnt].med_result_list[1].initial_dosage)
               SET sdosage = concat(sdosage," ",trim(uar_get_code_display(event_reply->event_list[
                  event_cnt].child_event_list[ingred_cnt].med_result_list[1].dosage_unit_cd)))
               SET temp_string = concat(temp_string,"<dosage_disp>",sdosage,"</dosage_disp>")
              ENDIF
             ENDIF
             SET temp_string = concat(temp_string,"</ingred>")
             SET index_loc = locateval(locit,1,size(calc_struct->ingred_list,5),event_reply->
              event_list[event_cnt].child_event_list[ingred_cnt].event_cd,calc_struct->ingred_list[
              locit].event_cd)
             IF (index_loc=0)
              SET calc_struct_size = (size(calc_struct->ingred_list,5)+ 1)
              SET stat = alterlist(calc_struct->ingred_list,calc_struct_size)
              SET calc_struct->ingred_list[calc_struct_size].event_cd = event_reply->event_list[
              event_cnt].child_event_list[ingred_cnt].event_cd
              SET calc_struct->ingred_list[calc_struct_size].ingred_disp_name = singreddispname
              SET calc_struct->ingred_list[calc_struct_size].total_volume = event_reply->event_list[
              event_cnt].child_event_list[ingred_cnt].med_result_list[1].initial_volume
              SET calc_struct->ingred_list[calc_struct_size].total_volume_unit_cd = event_reply->
              event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1].
              infused_volume_unit_cd
              IF (bskipdosage=0
               AND (event_reply->event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1
              ].initial_dosage > 0))
               SET calc_struct->ingred_list[calc_struct_size].total_dosage = event_reply->event_list[
               event_cnt].child_event_list[ingred_cnt].med_result_list[1].initial_dosage
               SET calc_struct->ingred_list[calc_struct_size].total_dosage_unit_cd = event_reply->
               event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1].dosage_unit_cd
              ENDIF
             ELSE
              IF ((calc_struct->ingred_list[index_loc].total_volume_unit_cd=event_reply->event_list[
              event_cnt].child_event_list[ingred_cnt].med_result_list[1].infused_volume_unit_cd))
               SET calc_struct->ingred_list[index_loc].total_volume += event_reply->event_list[
               event_cnt].child_event_list[ingred_cnt].med_result_list[1].initial_volume
              ELSE
               SET calc_struct->ingred_list[index_loc].total_volume = - (1)
              ENDIF
              IF (bskipdosage != 1)
               IF ((calc_struct->ingred_list[index_loc].total_dosage_unit_cd=0))
                SET calc_struct->ingred_list[index_loc].total_dosage += event_reply->event_list[
                event_cnt].child_event_list[ingred_cnt].med_result_list[1].initial_dosage
               ELSE
                IF ((calc_struct->ingred_list[index_loc].total_dosage_unit_cd=event_reply->
                event_list[event_cnt].child_event_list[ingred_cnt].med_result_list[1].dosage_unit_cd)
                )
                 SET calc_struct->ingred_list[index_loc].total_dosage += event_reply->event_list[
                 event_cnt].child_event_list[ingred_cnt].med_result_list[1].initial_dosage
                ELSEIF ((event_reply->event_list[event_cnt].child_event_list[ingred_cnt].
                med_result_list[1].initial_dosage > 0))
                 SET calc_struct->ingred_list[index_loc].total_dosage = - (1)
                ENDIF
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
           SET temp_string = concat(temp_string,"</admin>")
           IF ((dtotaladminvol=- (2)))
            SET dtotaladminvol = event_reply->event_list[event_cnt].med_result_list[1].initial_volume
            SET dtotaladminvolunitcd = event_reply->event_list[event_cnt].med_result_list[1].
            infused_volume_unit_cd
           ELSEIF (event_cnt > 1)
            IF ((dtotaladminvolunitcd=event_reply->event_list[event_cnt].med_result_list[1].
            infused_volume_unit_cd))
             SET dtotaladminvol += event_reply->event_list[event_cnt].med_result_list[1].
             initial_volume
            ELSE
             SET dtotaladminvol = - (1)
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
        IF (beventexists=0)
         SET temp_string = concat(temp_string,"<no_admin>",i18n_snoeventsdocumented,"</no_admin>")
        ELSE
         SET calc_struct_size = size(calc_struct->ingred_list,5)
         SET temp_string = concat(temp_string,"<subtotals>")
         FOR (ingred_cnt = 1 TO calc_struct_size)
           SET temp_string = concat(temp_string,"<ingred>")
           SET singreddispname = calc_struct->ingred_list[ingred_cnt].ingred_disp_name
           SET temp_string = concat(temp_string,"<ingred_name>",singreddispname,"</ingred_name>")
           IF ((calc_struct->ingred_list[ingred_cnt].total_volume > 0))
            SET svolume = formatvolume(calc_struct->ingred_list[ingred_cnt].total_volume)
            SET svolume = concat(svolume," ",trim(uar_get_code_display(calc_struct->ingred_list[
               ingred_cnt].total_volume_unit_cd)))
            SET temp_string = concat(temp_string,"<sub_total_volume_disp>",svolume,
             "</sub_total_volume_disp>")
           ELSEIF ((calc_struct->ingred_list[ingred_cnt].total_volume=- (1)))
            SET temp_string = concat(temp_string,"<sub_total_volume_disp>",i18n_sunabletoconvertunits,
             "</sub_total_volume_disp>")
           ENDIF
           IF ((calc_struct->ingred_list[ingred_cnt].total_dosage > 0))
            SET sdosage = formatstrength(calc_struct->ingred_list[ingred_cnt].total_dosage)
            SET sdosage = concat(sdosage," ",trim(uar_get_code_display(calc_struct->ingred_list[
               ingred_cnt].total_dosage_unit_cd)))
            SET temp_string = concat(temp_string,"<sub_total_dosage_disp>",sdosage,
             "</sub_total_dosage_disp>")
           ELSEIF ((calc_struct->ingred_list[ingred_cnt].total_dosage=- (1)))
            SET temp_string = concat(temp_string,"<sub_total_dosage_disp>",i18n_sunabletoconvertunits,
             "</sub_total_dosage_disp>")
           ENDIF
           SET temp_string = concat(temp_string,"</ingred>")
         ENDFOR
         SET temp_string = concat(temp_string,"</subtotals>")
         IF ((dtotaladminvol=- (2)))
          SET dtotaladminvol = 0
          SET stotaladminvol = ""
         ELSEIF ((dtotaladminvol=- (1)))
          SET stotaladminvol = i18n_sunabletoconvertunits
         ELSE
          SET stotaladminvol = formatvolume(dtotaladminvol)
          SET stotaladminvol = concat(stotaladminvol," ",trim(uar_get_code_display(
             dtotaladminvolunitcd)))
         ENDIF
         SET temp_string = concat(temp_string,"<total_vol>",stotaladminvol,"</total_vol>")
        ENDIF
       ELSE
        SET temp_string = concat(temp_string,"<no_admin>",i18n_snoeventsdocumented,"</no_admin>")
       ENDIF
       SET temp_string = concat(temp_string,"</cont_meds>")
     ENDFOR
    ELSEIF (filteredordercount > 0)
     SET bproblemfound = 3
    ELSE
     SET bproblemfound = 4
    ENDIF
   ENDIF
   IF (bproblemfound > 0)
    SET temp_string = concat(temp_string,"<problems>")
    CASE (bproblemfound)
     OF 1:
      SET temp_string = concat(temp_string,"<no_privs>",i18n_snoprivileges,"</no_privs>")
     OF 2:
      SET temp_string = concat(temp_string,"<load_failure>",i18n_sloadfailure,"</load_failure>")
     OF 3:
      SET temp_string = concat(temp_string,"<no_cont_meds>",i18n_snoordersqualify,"</no_cont_meds>")
     OF 4:
      SET temp_string = concat(temp_string,"<no_cont_meds>",i18n_snoactiveorders,"</no_cont_meds>")
    ENDCASE
    SET temp_string = concat(temp_string,"</problems>")
   ENDIF
   SET temp_string = replace(temp_string,char(10)," ",0)
   SET temp_string = replace(temp_string,char(13)," ",0)
   SET sxml = concat(sxml,temp_string)
 END ;Subroutine
 SET last_mod = "007"
 SET mod_date = "12/29/20"
 SET sxml = concat(sxml,"</RPT_DATA>")
 SET getrequest->module_dir = "cer_install:"
 SET getrequest->module_name = "infusion_summary.html"
 SET getrequest->basblob = 1
 EXECUTE eks_get_source  WITH replace(request,getrequest), replace(reply,getreply)
 SET putrequest->source_dir =  $OUTDEV
 SET putrequest->isblob = "1"
 SET sxml = replace(sxml,'"','\"',0)
 SET putrequest->document = replace(getreply->data_blob,"sXMLData",sxml,0)
 SET putrequest->document_size = size(putrequest->document)
 EXECUTE eks_put_source  WITH replace(request,putrequest), replace(reply,putreply)
 CALL echo(sxml)
#exit_script
END GO
