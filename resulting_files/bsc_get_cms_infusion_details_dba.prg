CREATE PROGRAM bsc_get_cms_infusion_details:dba
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
 DECLARE debug_ind = i2 WITH public, noconstant(0)
 FREE RECORD report_struct
 RECORD report_struct(
   1 patient_name = vc
   1 fin = vc
   1 mrn = vc
   1 encounter_type = vc
   1 encounter_range = vc
   1 location = vc
   1 order_list[*]
     2 order_id = f8
     2 med_order_type_cd = f8
     2 mnemonic = vc
     2 clin_disp_line = vc
     2 order_comment = vc
     2 order_start_dt_tm = dq8
     2 infusion_entries[*]
       3 infuse_start_dt_tm = dq8
       3 infuse_end_dt_tm = dq8
       3 infuse_tz = i4
       3 duration = f8
       3 zero_rate_string = vc
       3 prsnl_name = vc
       3 infusion_comment = vc
       3 infusion_volume = f8
       3 event_id_list[*]
         4 event_id = f8
       3 site_list[*]
         4 site_cd = f8
         4 site_dt_tm = dq8
         4 site_tz = i4
       3 route_list[*]
         4 route_cd = f8
 )
 FREE RECORD event_info
 RECORD event_info(
   1 order_list[*]
     2 order_id = f8
     2 event_list[*]
       3 event_end_dt_tm = dq8
       3 event_tz = i4
       3 event_id = f8
       3 infusion_found_ind = i4
       3 route_cd = f8
       3 site_cd = f8
 )
 FREE RECORD pca_events
 RECORD pca_events(
   1 event_list[*]
     2 event_id = f8
 )
 FREE RECORD pca_orders
 RECORD pca_orders(
   1 order_list[*]
     2 order_id = f8
 )
 FREE RECORD site_struct
 RECORD site_struct(
   1 order_list[*]
     2 order_id = f8
     2 site_list[*]
       3 event_id = f8
       3 site_dt_tm = dq8
       3 site_cd = f8
 )
 FREE RECORD zero_rate_struct
 RECORD zero_rate_struct(
   1 order_list[*]
     2 order_id = f8
     2 rate_list[*]
       3 zero_rate_start = f8
       3 zero_rate_end = f8
 )
 FREE RECORD orderlist
 RECORD orderlist(
   1 qual[*]
     2 order_id = f8
 )
 FREE RECORD order_comment_list
 RECORD order_comment_list(
   1 qual[*]
     2 order_idx = i4
     2 infuse_idx = i4
     2 comment_long_text_id = f8
 )
 FREE RECORD cvbe_request
 RECORD cvbe_request(
   1 code_set = i4
   1 field_name = c32
 )
 FREE RECORD cvbe_reply
 RECORD cvbe_reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = c32
     2 code_set = i4
     2 field_type = i4
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE checkpriv(null) = vc
 DECLARE checkviewpriv(null) = i2
 DECLARE getinfusionbillingroutes(null) = null
 DECLARE populateencntrinfo(null) = null
 DECLARE populateorderswithinfusiontasks(null) = null
 DECLARE getibtaskpref(null) = i2
 DECLARE getibgappref(null) = i2
 DECLARE populateorderswithinfusionresults(null) = null
 DECLARE processcontinuousinfusionresults(null) = null
 DECLARE processsites(null) = null
 DECLARE processzerorates(null) = null
 DECLARE generatereport(null) = null
 DECLARE writeheader(null) = vc
 DECLARE getiblookbackpref(null) = i2
 DECLARE getpcaeventcodes(null) = null
 DECLARE ipreffound = i2 WITH protect, constant(1)
 DECLARE iprefnotfound = i2 WITH protect, constant(2)
 DECLARE ipreferror = i2 WITH protect, constant(0)
 DECLARE itypestr = i2 WITH protect, constant(0)
 DECLARE itypedbl = i2 WITH protect, constant(1)
 DECLARE itypeint = i2 WITH protect, constant(2)
 FREE RECORD preference_struct
 RECORD preference_struct(
   1 prefs[*]
     2 pref_name = vc
     2 pref_name_upper = vc
     2 pref_type = i4
     2 pref_stat = i2
     2 pref_val[*]
       3 val_str = vc
       3 val_int = i4
       3 val_dbl = f8
 )
 DECLARE initalizeprefread(null) = i2
 DECLARE proccesssingleprefread(null) = i2
 DECLARE releasehandles(null) = null
 DECLARE cnvtprefnamestoupper(null) = null
 SUBROUTINE (getprefbycontextint(spreftofetch=vc,scontextstring=vc,svaluestring=vc,iretprefvalue=i4(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextInt********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypeint
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      IF (validate(request->debug_ind,1))
       CALL echorecord(preference_struct)
      ENDIF
      SET iretprefvalue = preference_struct->prefs[1].pref_val[1].val_int
      CALL debugecho(build("GetPrefByContextInt returning value: ",iretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontextdbl(spreftofetch=vc,scontextstring=vc,svaluestring=vc,dretprefvalue=f8(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextDbl********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypedbl
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET dretprefvalue = preference_struct->prefs[1].pref_val[1].val_dbl
      CALL debugecho(build("GetPrefByContextDbl returning value: ",dretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontext(spreftofetch=vc,scontextstring=vc,svaluestring=vc,sretprefvalue=vc(ref)
  ) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypestr
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET sretprefvalue = preference_struct->prefs[1].pref_val[1].val_str
      CALL debugecho(build("GetPrefByContext returning value: ",sretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbystruct(scontextstring=vc,svaluestring=vc) =i2)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,0)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE (getprefbystructsub(scontextstring=vc,svaluestring=vc,bsimplepref=i2) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE ssectionname = vc WITH protect, noconstant("config")
   DECLARE sgroupname = vc WITH protect, noconstant("medication_administration")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = h WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = h WITH protect, noconstant(0)
   DECLARE idxval = h WITH protect, noconstant(0)
   DECLARE hentry = h WITH protect, noconstant(0)
   DECLARE attrcount = h WITH protect, noconstant(0)
   DECLARE idxattr = h WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = h WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrname = c100
   DECLARE entryname = c100
   DECLARE namelen = h WITH noconstant(100)
   DECLARE valname = c100
   DECLARE stempstring = c20 WITH public, noconstant("")
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   CALL debugecho(build("Fetching preference at level: ",scontextstring))
   CALL debugecho(build("Fetching preference for context_id: ",svaluestring))
   CALL debugecho(build("Fetching preference from section: ",ssectionname))
   CALL debugecho(build("Fetching preference from group: ",sgroupname))
   CALL cnvtprefnamestoupper(null)
   IF (initalizeprefread(null)=ipreferror)
    CALL debugecho("Error Setting up to read Preferences")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefperform(hpref)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to perform.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET iretstat = proccessprefreply(null)
   CALL releasehandles(null)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE releasehandles(null)
   CALL debugecho("Cleaning up...")
   IF (hattr > 0)
    CALL debugecho("Destroyed hAttr")
    SET status = uar_prefdestroyinstance(hattr)
   ENDIF
   IF (hgroup > 0)
    CALL debugecho("Destroyed hGroup")
    SET status = uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hgroup2 > 0)
    CALL debugecho("Destroyed hGroup2")
    SET status = uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hsection > 0)
    CALL debugecho("Destroyed hSection")
    SET status = uar_prefdestroysection(hsection)
   ENDIF
   IF (hpref > 0)
    CALL debugecho("Destroyed hPref")
    SET status = uar_prefdestroyinstance(hpref)
   ENDIF
   CALL debugecho("...Done Cleaning")
 END ;Subroutine
 SUBROUTINE proccesssingleprefread(null)
   CALL debugecho("Proccessing a Single Pref Value...")
   DECLARE idxsearch = i4 WITH protect, noconstant(0)
   DECLARE idxfound = i4 WITH protect, noconstant(0)
   DECLARE istat = i4 WITH protect, noconstant(0)
   DECLARE iprefvalcnt = i4 WITH protect, noconstant(0)
   DECLARE upentryname = c100 WITH protect, noconstant("")
   SET upentryname = cnvtupper(trim(entryname,3))
   SET idxfound = locateval(idxsearch,1,size(preference_struct->prefs,5),upentryname,
    preference_struct->prefs[idxsearch].pref_name_upper)
   IF (idxfound > 0)
    SET iprefvalcnt = (size(preference_struct->prefs[idxfound].pref_val,5)+ 1)
    SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
    IF ((preference_struct->prefs[idxfound].pref_type=itypestr))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str = valname
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypedbl))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl = cnvtreal(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypeint))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int = cnvtint(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSE
     SET iprefvalcnt -= 1
     SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
     CALL debugecho("...Unknown Pref Type")
     RETURN(iprefnotfound)
    ENDIF
    CALL debugecho("...Pref Found And Added")
    RETURN(ipreffound)
   ENDIF
   CALL debugecho("... Pref not matched")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE initalizeprefread(null)
   CALL debugecho("Initalizing for pref read...")
   DECLARE idxit = i4 WITH protect, noconstant(0)
   FOR (idxit = 1 TO size(preference_struct->prefs,5))
    SET preference_struct->prefs[idxit].pref_stat = iprefnotfound
    SET istat = alterlist(preference_struct->prefs[idxit].pref_val,0)
   ENDFOR
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL debugecho("Error:GetPrefByContext - Invalid hPref handle. Try logging in.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddcontext(hpref,nullterm(scontextstring),nullterm(svaluestring))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to add context: ",stempcontlvl))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetsection(hpref,nullterm(ssectionname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL debugecho("Error:GetPrefByContext - Failed to create group.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetgroupname(hgroup,nullterm(sgroupname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddgroup(hpref,hgroup)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to add group.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   CALL debugecho("...Initalize Complete")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE proccessprefreply(null)
   CALL debugecho("Processing returned prefrences...")
   DECLARE iprefsubstatus = i4 WITH protect, noconstant(0)
   DECLARE batleastonepreffound = i2 WITH protect, noconstant(0)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(ssectionname))
   IF (hsection=0)
    CALL debugecho(build("Error:GetPrefByContext - Failed to get",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup2 = uar_prefgetgroupbyname(hsection,nullterm(sgroupname))
   IF (hgroup2=0)
    CALL echo(build("Error:GetPrefByContext - Failed to get ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET entrycount = 0
   SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to get number of entry count.")
    RETURN(ipreferror)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET entryname = ""
     SET namelen = 100
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET status = uar_prefgetentryname(hentry,entryname,namelen)
     CALL debugecho("Entry Found")
     CALL debugecho(build("entryName: ",entryname,"|<END"))
     SET attrcount = 0
     SET status = uar_prefgetentryattrcount(hentry,attrcount)
     IF (status != 1)
      CALL debugecho("GetPrefByContext - Invalid entryAttrCount.")
     ELSE
      FOR (idxattr = 0 TO (attrcount - 1))
        SET attrname = ""
        SET namelen = 100
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        SET status = uar_prefgetattrname(hattr,attrname,namelen)
        CALL debugecho("Attribute Found")
        CALL debugecho(build("attrName: ",attrname,"|<END"))
        SET valcount = 0
        SET status = uar_prefgetattrvalcount(hattr,valcount)
        FOR (idxval = 0 TO (valcount - 1))
          SET valname = ""
          SET namelen = 100
          SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
          CALL debugecho("Preference Found")
          CALL debugecho(build("valName: ",valname,"|<END"))
          SET iprefsubstatus = proccesssingleprefread(null)
          IF (iprefsubstatus=ipreferror)
           CALL debugecho("...ERROR FOUND ")
           RETURN(ipreferror)
          ELSEIF (iprefsubstatus=ipreffound)
           SET batleastonepreffound = 1
           IF (bsimplepref)
            CALL debugecho("...Simple Pref Found, Return")
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   IF (batleastonepreffound=1)
    CALL debugecho(build("Matching Prefs Found"))
    CALL debugecho("...Processing Complete")
    RETURN(ipreffound)
   ELSE
    CALL debugecho(build("No Matching Preference found."))
    CALL debugecho("...Processing Complete")
    RETURN(iprefnotfound)
   ENDIF
 END ;Subroutine
 SUBROUTINE (debugecho(sprint=vc) =null)
   IF (validate(request->debug_ind,1))
    CALL echo(sprint)
   ENDIF
 END ;Subroutine
 SUBROUTINE cnvtprefnamestoupper(null)
   CALL debugecho("Capitalize all requested pref names...")
   DECLARE idxpref = i4 WITH protect, noconstant(0)
   FOR (idxpref = 1 TO size(preference_struct->prefs,5))
     SET preference_struct->prefs[idxpref].pref_name_upper = cnvtupper(trim(preference_struct->prefs[
       idxpref].pref_name,3))
   ENDFOR
   CALL debugecho("...Done capitalizing")
 END ;Subroutine
 SET rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}",
  "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1300 \deflang1033 \widoctrl")
 SET reol = "\line "
 SET reop = "\par "
 SET rbop = "\pard "
 SET rbopt = "\pard \tx1300\tx2300\tx3300\tx4300\tx5100 "
 SET rtab = "\tab "
 SET wr = "\plain \f0 \fs18 \cb2 "
 SET wb = "\plain \f0 \fs18 \b \cb2 "
 SET wu = "\plain \f0 \fs18 \ul \b \cb2 "
 SET wbi = "\plain \f0 \fs18 \b \i \cb2 "
 SET ws = "\plain \f0 \fs18 \strike \cb2 "
 SET hi = "\pard\fi-2340\li2340 "
 SET rtfeof = "}"
 SET headtabs = "\tx2880\tx5760\tx8640\tx11520 "
 SET coltabs = "\tx360 \tx2400 \tx4500 \tx6520 \tx8770 \tx10210 \tx11940 "
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE bhasprivs = i2 WITH public, noconstant(0)
 DECLARE dibgappref = f8 WITH public, noconstant(0)
 DECLARE dfacilitycd = f8 WITH public, noconstant(0)
 DECLARE istat = i4 WITH public, noconstant(0)
 DECLARE ireplyidx = i4 WITH public, noconstant(0)
 DECLARE bvolumeover = i2 WITH public, noconstant(0)
 DECLARE bdurover = i2 WITH public, noconstant(0)
 DECLARE diblookbackpref = f8 WITH public, noconstant(0)
 DECLARE infusionlbdttm = dq8 WITH public, noconstant(0)
 DECLARE dpersonid = f8 WITH public, noconstant(0)
 DECLARE cspace = c1 WITH public, constant("@")
 DECLARE tablen = i4 WITH public, constant(5)
 DECLARE last_col = i4 WITH public, constant(175)
 DECLARE start_dttm = i4 WITH public, constant(20)
 DECLARE end_dttm = i4 WITH public, constant(20)
 DECLARE route = i4 WITH public, constant(20)
 DECLARE site = i4 WITH public, constant(20)
 DECLARE duration = i4 WITH public, constant(14)
 DECLARE volume = i4 WITH public, constant(14)
 DECLARE personnel = i4 WITH public, constant(20)
 DECLARE iv_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE auth_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE unauth_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE altered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE begin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",180,"BEGIN"))
 DECLARE ratechg_cd = f8 WITH public, constant(uar_get_code_by("MEANING",180,"RATECHG"))
 DECLARE sitechg_cd = f8 WITH public, constant(uar_get_code_by("MEANING",180,"SITECHG"))
 DECLARE waste_cd = f8 WITH public, constant(uar_get_code_by("MEANING",180,"WASTE"))
 DECLARE ml_cd = f8 WITH public, constant(uar_get_code_by("MEANING",54,"ML"))
 DECLARE pca_dose_cki = vc WITH public, constant("CERNER!261BD337-D806-41BD-A257-0A54E9FC53CC")
 DECLARE continuous_dose_cki = vc WITH public, constant("CERNER!61F095F2-DB50-488A-9131-B01A077EF039"
  )
 DECLARE pca_dose_cd = f8 WITH public, noconstant(0)
 DECLARE continuous_dose_cd = f8 WITH public, noconstant(0)
 DECLARE pcadose = f8 WITH public, constant(2341)
 DECLARE pcadoseunit = f8 WITH public, constant(2342)
 DECLARE basalrate = f8 WITH public, constant(2349)
 DECLARE basalrateunit = f8 WITH public, constant(2350)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sprivmsg = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PRIV_MSG",
    "You do not have privileges to view this report."),3))
 DECLARE i18n_sinfsbilltaskfailmsg = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INFS_BILL_TASK_FAIL_MSG",
    "System is not set up for Infusion Billing. Please contact your administrator."),3))
 DECLARE i18n_snoresults = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFY","No Results Qualified."),3))
 DECLARE i18n_stitle = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TITLE",
    "Infusion Billing Report"),3))
 DECLARE i18n_sfin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FIN","FIN"),3
   ))
 DECLARE i18n_smrn = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MRN","MRN"),3
   ))
 DECLARE i18n_slocation = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_LOCATION","Location:"),3))
 DECLARE i18n_sarrivedtunknown = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ARRIVE_DT_UNKNOWN","UNKNOWN"),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_To","to"),3))
 DECLARE i18n_sstartdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_START_DATE_TIME","Start Date/Time"),3))
 DECLARE i18n_senddatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_END_DATE_TIME","End Date/Time"),3))
 DECLARE i18n_ssite = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SITE","Site"
    ),3))
 DECLARE i18n_sroute = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ROUTE",
    "Route"),3))
 DECLARE i18n_sduration = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DURATION","Duration"),3))
 DECLARE i18n_sinfusevolume = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INFUSE_VOLUME","Infuse Volume"),3))
 DECLARE i18n_stotalvolume = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_VOLUME","Total Volume for Order:"),3))
 DECLARE i18n_stotalduration = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_DURATION","Total Duration for Order:"),3))
 DECLARE i18n_shr = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_HR","hr"),3))
 DECLARE i18n_smin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MIN","min"),3
   ))
 DECLARE i18n_spersonnel = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_PERSONNEL","Personnel"),3))
 DECLARE i18n_scontinuous = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CONTINUOUS","Continuous"),3))
 DECLARE i18n_sincomplete = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_INCOMPLETE","Incomplete"),3))
 DECLARE i18n_snotincluded = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOT_INCLUDED","Not Included"),3))
 DECLARE i18n_scomment = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_COMMENT",
    "Comment:"),3))
 DECLARE i18n_sgenericerror = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_GENERIC_ERROR","An unexpected error has occurred. Please contact your administrator."),3))
 DECLARE i18n_sunabletocalculate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNABLE_TO_CALCULATE","Unable to Calculate."),3))
 DECLARE i18n_szerorate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ZERO_RATE","Rate = 0"),3))
 DECLARE i18n_szrdelimiter = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ZERO_RATE_DELIMITER",","),3))
 DECLARE i18n_sovervoldisp = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVER_VOL_DISP","*****"),3))
 DECLARE i18n_soverdurdisp = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVER_DUR_DISP","---"),3))
 DECLARE i18n_sovervoldispnote = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVER_VOL_DISP_NOTE",concat("    *****: The volume exceeds 99999 ",trim(uar_get_code_display
      (ml_cd)),".  Please review the Infusion Billing ","Window for complete volume display.")),3))
 DECLARE i18n_soverdurdispnote = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_OVER_DUR_DISP_NOTE",concat(
     "---: The duration of the infusion exceeds 999 hours.  Please review the Infusion Billing Window for",
     " complete infusion duration documentation.")),3))
 DECLARE i18n_sunitml = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_UNIT_ML",
    trim(uar_get_code_display(ml_cd))),3))
 DECLARE i18n_spcamsg = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PCA_MSG",
    "Information: Please review Medication Administration Record for complete order history and documentation."
    ),3))
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ENDIF
 SET istat = alterlist(reply->large_text_qual,2)
 SET ireplyidx = 1
 SET reply->large_text_qual[ireplyidx].text_segment = concat(rhead,wr,rbopt)
 SET bhasprivs = checkpriv(null)
 IF ((bhasprivs=- (1)))
  SET ireplyidx += 1
  SET reply->large_text_qual[ireplyidx].text_segment = concat(reply->text,rbopt,wb,i18n_sprivmsg,
   rtfeof)
  IF (debug_ind)
   CALL echo("!!! CheckPriv failed because user does not appropriate prviliges.")
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT
  e.loc_facility_cd
  FROM encounter e
  WHERE (e.encntr_id=request->visit[1].encntr_id)
  DETAIL
   dfacilitycd = e.loc_facility_cd
  WITH nocounter
 ;end select
 IF (dfacilitycd <= 0)
  SET ireplyidx += 1
  SET reply->large_text_qual[ireplyidx].text_segment = concat(reply->text,rbopt,wb,i18n_sgenericerror,
   rtfeof)
  CALL echo(build("!!! Unable to determine facility code for encounter = ",request->visit[1].
    encntr_id))
  GO TO exit_script
 ENDIF
 SELECT
  e.person_id
  FROM encounter e
  WHERE (e.encntr_id=request->visit[1].encntr_id)
  DETAIL
   dpersonid = e.person_id
  WITH nocounter
 ;end select
 IF (dpersonid <= 0)
  SET ireplyidx += 1
  SET reply->large_text_qual[ireplyidx].text_segment = concat(reply->text,rbopt,wb,i18n_sgenericerror,
   rtfeof)
  CALL echo(build("!!! Unable to determine the person id for encounter = ",request->visit[1].
    encntr_id))
  GO TO exit_script
 ENDIF
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
 CALL getpcaeventcodes(null)
 CALL getiblookbackpref(null)
 CALL getinfusionbillingroutes(null)
 CALL populateencntrinfo(null)
 CALL populateorderswithinfusiontasks(null)
 CALL populateorderswithinfusionresults(null)
 CALL generatereport(null)
 SET ireplyidx += 1
 SET istat = alterlist(reply->large_text_qual,ireplyidx)
 SET reply->large_text_qual[ireplyidx].text_segment = rtfeof
 GO TO exit_script
 SUBROUTINE checkpriv(null)
   IF (debug_ind)
    CALL echo("~! Entering CheckPriv Subroutine !~")
   ENDIF
   DECLARE bpriv = i2 WITH protect, noconstant(0)
   SET bpriv = checkviewpriv(null)
   IF (bpriv=0)
    IF (debug_ind)
     CALL echo(build("~! Leaving CheckPriv Subroutine [Result = ",bpriv,"]"))
    ENDIF
    RETURN(- (1))
   ENDIF
   IF (debug_ind)
    CALL echo(build("~! Leaving CheckPriv Subroutine [Result = ",bpriv,"]"))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE checkviewpriv(null)
   IF (debug_ind)
    CALL echo("~! Entering CheckViewPriv Subroutine !~")
   ENDIF
   DECLARE dpriv = f8 WITH protect, noconstant(0)
   DECLARE docinfsnbill = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"DOCINFSNBILL"))
   DECLARE priv_yes = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"YES"))
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     priv_loc_reltn plr,
     privilege priv
    PLAN (epr
     WHERE (epr.encntr_id=request->visit[1].encntr_id)
      AND (epr.prsnl_person_id=reqinfo->updt_id))
     JOIN (plr
     WHERE plr.ppr_cd=epr.encntr_prsnl_r_cd)
     JOIN (priv
     WHERE priv.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND priv.active_ind=1
      AND priv.privilege_cd=docinfsnbill)
    DETAIL
     dpriv = priv.priv_value_cd
    WITH nocounter
   ;end select
   IF (dpriv=priv_yes)
    IF (debug_ind)
     CALL echo(build("~! Leaving CheckViewPriv (1) Subroutine [User Priv = ",dpriv,"]"))
    ENDIF
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl pr,
     priv_loc_reltn plr,
     privilege p
    PLAN (pr
     WHERE (pr.person_id=reqinfo->updt_id))
     JOIN (plr
     WHERE plr.position_cd=pr.position_cd)
     JOIN (p
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND p.active_ind=1
      AND p.privilege_cd=docinfsnbill)
    DETAIL
     dpriv = p.priv_value_cd
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL echo(build("~! Leaving CheckViewPriv (2) Subroutine [Postion Priv = ",dpriv,"]"))
   ENDIF
   IF (dpriv=priv_yes)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getinfusionbillingroutes(null)
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   SET nobjstatus = checkprg("BSC_GET_CODE_VALUE_BY_EXT")
   IF (debug_ind)
    CALL echo(build("bsc_get_cms_infusion_details :: bsc_get_code_value_by_ext script object status:",
      nobjstatus))
   ENDIF
   IF (nobjstatus > 0)
    SET cvbe_request->code_set = 4001
    SET cvbe_request->field_name = "Create_Infusion_Billing_Tasks"
    SET modify = nopredeclare
    EXECUTE bsc_get_code_value_by_ext  WITH replace("REQUEST","CVBE_REQUEST"), replace("REPLY",
     "CVBE_REPLY")
    SET modify = predeclare
    IF ((cvbe_reply->status_data.status="F"))
     CALL echo("bsc_get_cms_infusion_details : bsc_get_code_value_by_ext could not be executed!")
     SET ireplyidx += 1
     SET reply->large_text_qual[ireplyidx].text_segment = concat(i18n_sgenericerror,rtfeof)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populateencntrinfo(null)
   IF (debug_ind)
    CALL echo("~! Entering PopulateEncntrInfo Subroutine !~")
   ENDIF
   DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
   DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
   DECLARE sarrivedttm = vc WITH protect, noconstant("")
   DECLARE sinfusionlbdttm = vc WITH protect, noconstant("")
   SET infusionlbdttm = datetimeadd(cnvtdatetime(sysdate),- ((1 * diblookbackpref)))
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea,
     person p
    PLAN (e
     WHERE (e.encntr_id=request->visit[1].encntr_id))
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1)
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
      AND (ea.active_ind= Outerjoin(1))
      AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    DETAIL
     report_struct->patient_name = addrtfescapesequence(p.name_full_formatted), report_struct->
     encounter_type = uar_get_code_display(e.encntr_type_cd), sarrivedttm = formatutcdatetime(e
      .arrive_dt_tm,0,1),
     sinfusionlbdttm = formatutcdatetime(cnvtdatetime(infusionlbdttm),0,1)
     IF (diblookbackpref > 0
      AND cnvtdatetime(e.arrive_dt_tm) < cnvtdatetime(infusionlbdttm))
      sarrivedttm = sinfusionlbdttm
     ELSEIF (sarrivedttm="")
      sarrivedttm = i18n_sarrivedtunknown
     ENDIF
     report_struct->encounter_range = concat(sarrivedttm," ",i18n_sto," ",formatutcdatetime(
       cnvtdatetime(sysdate),0,1)), report_struct->location = uar_get_code_display(e.location_cd)
     IF (ea.encntr_alias_type_cd=fin_cd)
      report_struct->fin = trim(ea.alias)
     ELSEIF (ea.encntr_alias_type_cd=mrn_cd)
      report_struct->mrn = trim(ea.alias)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL echo("##################################################################")
    CALL echo(build(" Patient = ",report_struct->patient_name))
    CALL echo(build(" Enctr   = ",report_struct->encounter_type))
    CALL echo(build(" local   = ",report_struct->location))
    CALL echo(build(" FIN     = ",report_struct->fin))
    CALL echo(build(" MRN     = ",report_struct->mrn))
    CALL echo(build(" Range   = ",report_struct->encounter_range))
    CALL echo("##################################################################")
   ENDIF
   IF (debug_ind)
    CALL echo("~! Leaving PopulateEncntrInfo Subroutine ")
   ENDIF
 END ;Subroutine
 SUBROUTINE getibgappref(null)
   DECLARE positioncd = c20 WITH public, noconstant("")
   DECLARE facilitycd = c20 WITH public, noconstant("")
   DECLARE system = c20 WITH public, noconstant("")
   DECLARE ibgap = vc WITH protect, constant("CONCURRENT_INFUSION_GAP")
   DECLARE currentpositioncd = f8 WITH protect, noconstant(0)
   SET currentpositioncd = getcurrentposition(null)
   IF (currentpositioncd)
    IF (debug_ind)
     CALL echo(build("User's current position is ",sac_cur_pos_rep->position_cd))
    ENDIF
    SET currentpositioncd = sac_cur_pos_rep->position_cd
   ELSE
    IF (debug_ind)
     CALL echo(build("Default position lookup failed with status ",sac_cur_pos_rep->status_data.
       status))
    ENDIF
    SET currentpositioncd = 0.0
   ENDIF
   SET dibgappref = 0
   SET positioncd = trim(cnvtstring(currentpositioncd,20,2))
   IF (getprefbycontextdbl(ibgap,"position",positioncd,dibgappref)=ipreffound)
    IF (debug_ind)
     CALL echo("IB Gap Pref found at position level")
    ENDIF
    RETURN(1)
   ENDIF
   SET facilitycd = trim(cnvtstring(dfacilitycd,20,2))
   IF (getprefbycontextdbl(ibgap,"facility",facilitycd,dibgappref)=ipreffound)
    IF (debug_ind)
     CALL echo("IB Gap Pref found at facility level")
    ENDIF
    RETURN(1)
   ENDIF
   SET system = "system"
   IF (getprefbycontextdbl(ibgap,"default",system,dibgappref)=ipreffound)
    IF (debug_ind)
     CALL echo("IB Gap Pref found at system level")
    ENDIF
    RETURN(1)
   ELSE
    IF (debug_ind)
     CALL echo("IB Gap Pref pref not found at position, facility, or system level")
    ENDIF
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getiblookbackpref(null)
   DECLARE positioncd = c20 WITH public, noconstant("")
   DECLARE facilitycd = c20 WITH public, noconstant("")
   DECLARE system = c20 WITH public, noconstant("")
   DECLARE iblookback = vc WITH protect, constant("INFUSION_BILLING_RPT_LOOKBACK_DAYS")
   SET diblookbackpref = 0
   SET facilitycd = trim(cnvtstring(dfacilitycd,20,2))
   IF (getprefbycontextdbl(iblookback,"facility",facilitycd,diblookbackpref)=ipreffound)
    IF (debug_ind)
     CALL echo("Infusion Billing Lookback found at facility level")
    ENDIF
    RETURN(1)
   ENDIF
   SET system = "system"
   IF (getprefbycontextdbl(iblookback,"default",system,diblookbackpref)=ipreffound)
    IF (debug_ind)
     CALL echo("Infusion Billing Lookback Pref found at system level")
    ENDIF
    RETURN(1)
   ELSE
    IF (debug_ind)
     CALL echo("Infusion Billing Lookback Pref not found at system level")
    ENDIF
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE populateorderswithinfusiontasks(null)
   IF (debug_ind)
    CALL echo("~! Entering PopulateOrdersWithInufsionTasks Subroutine !~")
   ENDIF
   DECLARE pref_infusion_billing_task = vc WITH protect, constant("INFUSION_BILLING_TASK")
   DECLARE dibtaskpref = f8 WITH public, noconstant(0)
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE iorder = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE ireportordercnt = i4 WITH protect, noconstant(0)
   DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE ordercmt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   DECLARE infusebill_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"INFUSEBILL"))
   IF (getprefbycontextdbl(pref_infusion_billing_task,"default","system",dibtaskpref) != ipreffound)
    SET ireplyidx += 1
    SET reply->large_text_qual[ireplyidx].text_segment = concat(reply->text,rbopt,wb,
     i18n_sinfsbilltaskfailmsg,rtfeof)
    IF (debug_ind)
     CALL echo(i18n_sinfsbilltaskfailmsg)
    ENDIF
    GO TO exit_script
   ENDIF
   SET infusionlbdttm = datetimeadd(cnvtdatetime(sysdate),- ((1 * diblookbackpref)))
   SELECT INTO "nl:"
    FROM task_activity ta
    WHERE ((ta.reference_task_id+ 0)=dibtaskpref)
     AND (ta.encntr_id=request->visit[1].encntr_id)
     AND ta.task_type_cd=infusebill_cd
     AND ta.task_status_cd=pending_cd
    HEAD REPORT
     iordercnt = 0, istat = alterlist(orderlist->qual,10)
    DETAIL
     IF (ta.order_id > 0)
      iordercnt += 1
      IF (mod(iordercnt,10)=1)
       istat = alterlist(orderlist->qual,(iordercnt+ 9))
      ENDIF
      orderlist->qual[iordercnt].order_id = ta.order_id
     ENDIF
    FOOT REPORT
     istat = alterlist(orderlist->qual,iordercnt)
    WITH nocounter
   ;end select
   SELECT
    IF (diblookbackpref > 0)
     PLAN (ibe
      WHERE (ibe.encntr_id=request->visit[1].encntr_id)
       AND ibe.infusion_end_dt_tm >= cnvtdatetime(infusionlbdttm))
    ELSE
     PLAN (ibe
      WHERE (ibe.encntr_id=request->visit[1].encntr_id))
    ENDIF
    INTO "nl:"
    FROM infusion_billing_event ibe
    HEAD ibe.order_id
     IF (ibe.order_id > 0)
      istat = alterlist(orderlist->qual,(iordercnt+ 10)), iordercnt += 1
      IF (iordercnt=size(orderlist->qual,5))
       istat = alterlist(orderlist->qual,(iordercnt+ 10))
      ENDIF
      orderlist->qual[iordercnt].order_id = ibe.order_id
     ENDIF
    FOOT  ibe.order_id
     istat = alterlist(orderlist->qual,iordercnt)
    WITH nocounter
   ;end select
   SET iordercnt = size(orderlist->qual,5)
   IF (iordercnt=0)
    SET ireplyidx += 1
    SET istat = alterlist(reply->large_text_qual,(ireplyidx+ 2))
    SET reply->large_text_qual[ireplyidx].text_segment = writeheader(null)
    SET ireplyidx += 1
    SET reply->large_text_qual[ireplyidx].text_segment = concat(wb,reop,reop,rbopt,tabtocenter(
      i18n_snoresults),
     i18n_snoresults,rtfeof)
    IF (debug_ind)
     CALL echo(i18n_snoresults)
    ENDIF
    GO TO exit_script
   ENDIF
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(40)
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(iordercnt)/ nsize)) * nsize))
   DECLARE iterator = i4 WITH protect, noconstant(0)
   SET istat = alterlist(orderlist->qual,ntotal)
   FOR (iterator = (iordercnt+ 1) TO ntotal)
     SET orderlist->qual[iterator].order_id = orderlist->qual[iordercnt].order_id
   ENDFOR
   SET ireportordercnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),o.order_id,orderlist->qual[iterator].order_id
      ))
    ORDER BY o.order_id, o.current_start_dt_tm
    HEAD o.order_id
     ireportordercnt += 1
     IF (size(report_struct->order_list,5) <= ireportordercnt)
      istat = alterlist(report_struct->order_list,(ireportordercnt+ 9))
     ENDIF
     report_struct->order_list[ireportordercnt].order_id = o.order_id, report_struct->order_list[
     ireportordercnt].mnemonic = addrtfescapesequence(o.order_mnemonic), report_struct->order_list[
     ireportordercnt].med_order_type_cd = o.med_order_type_cd,
     report_struct->order_list[ireportordercnt].clin_disp_line = addrtfescapesequence(o
      .clinical_display_line), report_struct->order_list[ireportordercnt].order_start_dt_tm = o
     .current_start_dt_tm
    FOOT REPORT
     istat = alterlist(report_struct->order_list,ireportordercnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   SET ntotal = (ceil((cnvtreal(ireportordercnt)/ nsize)) * nsize)
   SET istat = alterlist(report_struct->order_list,ntotal)
   FOR (iterator = (ireportordercnt+ 1) TO ntotal)
     SET report_struct->order_list[iterator].order_id = report_struct->order_list[ireportordercnt].
     order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_comment oc,
     long_text lt
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (oc
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oc.order_id,report_struct->order_list[
      iterator].order_id)
      AND oc.comment_type_cd=ordercmt_cd
      AND oc.long_text_id > 0.0)
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    DETAIL
     iorder = locateval(inum,1,ireportordercnt,oc.order_id,report_struct->order_list[inum].order_id)
     IF (iorder > 0)
      report_struct->order_list[iorder].order_comment = addrtfescapesequence(lt.long_text)
     ENDIF
    FOOT REPORT
     istat = alterlist(report_struct->order_list,ireportordercnt)
    WITH nocounter
   ;end select
   FOR (iorder = 1 TO ireportordercnt)
     IF ((report_struct->order_list[iorder].med_order_type_cd=iv_cd))
      CALL processcontinuousorder(report_struct->order_list[iorder].order_id)
     ELSE
      CALL processintermittentorder(report_struct->order_list[iorder].order_id)
     ENDIF
   ENDFOR
   IF (debug_ind)
    CALL echo("~! Leaving PopulateOrdersWithInufsionTasks Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE (processcontinuousorder(dorderid=f8) =null)
   IF (debug_ind)
    CALL echo("~! Entering ProcessContinuousOrder Subroutine !~")
    CALL echo(build("-- Order id = ",dorderid))
   ENDIF
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE ifoundevent = i2 WITH protect, noconstant(0)
   CALL storepcaevents(dorderid)
   CALL storepcaorders(dorderid)
   SELECT
    IF (diblookbackpref > 0)
     PLAN (ce
      WHERE ce.order_id=dorderid
       AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(sysdate),- ((1 *
        diblookbackpref)))))
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.iv_event_cd=begin_cd
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ELSE
     PLAN (ce
      WHERE ce.order_id=dorderid
       AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.iv_event_cd=begin_cd
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ENDIF
    INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr
    ORDER BY ce.order_id, ce.parent_event_id
    HEAD REPORT
     iordercnt = size(event_info->order_list,5)
    HEAD ce.order_id
     iordercnt += 1
     IF (size(event_info->order_list,5) <= iordercnt)
      istat = alterlist(event_info->order_list,(iordercnt+ 9))
     ENDIF
    HEAD ce.parent_event_id
     ifoundevent = 0
     FOR (ieventnum = 1 TO size(pca_events->event_list,5))
       IF ((pca_events->event_list[ieventnum].event_id=ce.parent_event_id))
        ifoundevent = 1
       ENDIF
     ENDFOR
     IF (ifoundevent=0)
      ieventcnt += 1
      IF (mod(ieventcnt,5)=1)
       istat = alterlist(event_info->order_list[iordercnt].event_list,(ieventcnt+ 4))
      ENDIF
      event_info->order_list[iordercnt].order_id = ce.order_id, event_info->order_list[iordercnt].
      event_list[ieventcnt].event_end_dt_tm = ce.event_end_dt_tm, event_info->order_list[iordercnt].
      event_list[ieventcnt].event_tz = ce.event_end_tz,
      event_info->order_list[iordercnt].event_list[ieventcnt].event_id = ce.parent_event_id,
      event_info->order_list[iordercnt].event_list[ieventcnt].infusion_found_ind = 0, event_info->
      order_list[iordercnt].event_list[ieventcnt].route_cd = 0,
      event_info->order_list[iordercnt].event_list[ieventcnt].site_cd = cmr.admin_site_cd
     ENDIF
    FOOT  ce.order_id
     istat = alterlist(event_info->order_list[iordercnt].event_list,ieventcnt)
    FOOT REPORT
     istat = alterlist(event_info->order_list,iordercnt)
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL echo("~! Leaving ProcessContinuousOrder Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE (processintermittentorder(dorderid=f8) =null)
   IF (debug_ind)
    CALL echo("~! Entering ProcessIntermittentOrder Subroutine !~")
    CALL echo(build("    ~ Order Id = ",dorderid))
   ENDIF
   DECLARE iroute = i4 WITH protect, noconstant(0)
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   SELECT
    IF (diblookbackpref > 0)
     PLAN (ceol
      WHERE ceol.parent_order_ident=dorderid)
      JOIN (ce
      WHERE ceol.event_id=ce.event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
       AND ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(sysdate),- ((1 *
        diblookbackpref)))))
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND expand(iroute,1,size(cvbe_reply->qual,5),cmr.admin_route_cd,cvbe_reply->qual[iroute].
       code_value)
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ELSE
     PLAN (ceol
      WHERE ceol.parent_order_ident=dorderid)
      JOIN (ce
      WHERE ceol.event_id=ce.event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd))
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND expand(iroute,1,size(cvbe_reply->qual,5),cmr.admin_route_cd,cvbe_reply->qual[iroute].
       code_value)
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ENDIF
    INTO "nl:"
    FROM ce_event_order_link ceol,
     clinical_event ce,
     ce_med_result cmr
    ORDER BY ceol.parent_order_ident, ce.parent_event_id
    HEAD REPORT
     iordercnt = size(event_info->order_list,5)
    HEAD ceol.parent_order_ident
     iordercnt += 1
     IF (size(event_info->order_list,5) <= iordercnt)
      istat = alterlist(event_info->order_list,(iordercnt+ 10))
     ENDIF
     event_info->order_list[iordercnt].order_id = ceol.parent_order_ident
    HEAD ce.parent_event_id
     ieventcnt += 1
     IF (size(event_info->order_list[iordercnt].event_list,5) <= ieventcnt)
      istat = alterlist(event_info->order_list[iordercnt].event_list,(ieventcnt+ 4))
     ENDIF
     event_info->order_list[iordercnt].event_list[ieventcnt].event_end_dt_tm = ce.event_end_dt_tm,
     event_info->order_list[iordercnt].event_list[ieventcnt].event_tz = ce.event_end_tz, event_info->
     order_list[iordercnt].event_list[ieventcnt].event_id = ce.parent_event_id,
     event_info->order_list[iordercnt].event_list[ieventcnt].infusion_found_ind = 0, event_info->
     order_list[iordercnt].event_list[ieventcnt].route_cd = cmr.admin_route_cd, event_info->
     order_list[iordercnt].event_list[ieventcnt].site_cd = cmr.admin_site_cd
    FOOT  ce.parent_event_id
     istat = alterlist(event_info->order_list[iordercnt].event_list,ieventcnt)
    FOOT  ce.order_id
     istat = alterlist(event_info->order_list,iordercnt)
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL echo("~! Leaving ProcessIntermittentOrder Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateorderswithinfusionresults(null)
   IF (debug_ind)
    CALL echo("~! Entering PopulateOrdersWithInfusionResults Subroutine !~")
   ENDIF
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE iorder = i4 WITH protect, noconstant(0)
   DECLARE iinfuseevent = i4 WITH protect, noconstant(0)
   DECLARE ievent = i4 WITH protect, noconstant(0)
   DECLARE iroute = i4 WITH protect, noconstant(0)
   DECLARE isite = i4 WITH protect, noconstant(0)
   DECLARE ieiorder = i4 WITH protect, noconstant(0)
   DECLARE ieiordersize = i4 WITH protect, noconstant(0)
   DECLARE ieieventsize = i4 WITH protect, noconstant(0)
   DECLARE ieievent = i4 WITH protect, noconstant(0)
   DECLARE icomment = i4 WITH protect, noconstant(0)
   DECLARE ifoundevent = i2 WITH protect, noconstant(0)
   SELECT
    IF (diblookbackpref > 0)
     PLAN (ibe
      WHERE (ibe.encntr_id=request->visit[1].encntr_id)
       AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
       AND ibe.infusion_end_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(sysdate),- ((1 *
        diblookbackpref)))))
      JOIN (icr
      WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id
       AND icr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (ce
      WHERE ce.clinical_event_id=icr.clinical_event_id
       AND ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(sysdate),- ((1 *
        diblookbackpref)))))
      JOIN (p
      WHERE p.person_id=ibe.create_prsnl_id)
    ELSE
     PLAN (ibe
      WHERE (ibe.encntr_id=request->visit[1].encntr_id)
       AND ibe.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
      JOIN (icr
      WHERE icr.infusion_billing_event_id=ibe.infusion_billing_event_id
       AND icr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (ce
      WHERE ce.clinical_event_id=icr.clinical_event_id)
      JOIN (p
      WHERE p.person_id=ibe.create_prsnl_id)
    ENDIF
    INTO "nl:"
    FROM infusion_billing_event ibe,
     infusion_ce_reltn icr,
     clinical_event ce,
     prsnl p
    ORDER BY ibe.order_id, ibe.infusion_start_dt_tm, ibe.infusion_billing_event_id,
     icr.clinical_event_seq
    HEAD ibe.order_id
     iorder = locateval(inum,1,size(report_struct->order_list,5),ibe.order_id,report_struct->
      order_list[inum].order_id), iinfuseevent = 0
    HEAD ibe.infusion_start_dt_tm
     iinfuseevent = iinfuseevent
    HEAD ibe.infusion_billing_event_id
     ifoundevent = 0
     FOR (ieventnum = 1 TO size(pca_events->event_list,5))
       IF ((pca_events->event_list[ieventnum].event_id=ce.parent_event_id))
        ifoundevent = 1
       ENDIF
     ENDFOR
     IF (ifoundevent=0)
      IF (iorder > 0)
       iinfuseevent += 1
       IF (size(report_struct->order_list[iorder].infusion_entries,5) <= iinfuseevent)
        istat = alterlist(report_struct->order_list[iorder].infusion_entries,(iinfuseevent+ 9))
       ENDIF
       report_struct->order_list[iorder].infusion_entries[iinfuseevent].infuse_start_dt_tm = ibe
       .infusion_start_dt_tm, report_struct->order_list[iorder].infusion_entries[iinfuseevent].
       infuse_end_dt_tm = ibe.infusion_end_dt_tm, report_struct->order_list[iorder].infusion_entries[
       iinfuseevent].infuse_tz = ibe.infusion_end_tz,
       report_struct->order_list[iorder].infusion_entries[iinfuseevent].duration = ibe
       .infusion_duration_mins, report_struct->order_list[iorder].infusion_entries[iinfuseevent].
       prsnl_name = addrtfescapesequence(p.name_full_formatted), report_struct->order_list[iorder].
       infusion_entries[iinfuseevent].infusion_volume = ibe.infused_volume_value,
       ievent = 0, icomment += 1
       IF (size(order_comment_list->qual,5) <= icomment)
        istat = alterlist(order_comment_list->qual,(icomment+ 9))
       ENDIF
       order_comment_list->qual[icomment].order_idx = iorder, order_comment_list->qual[icomment].
       infuse_idx = iinfuseevent, order_comment_list->qual[icomment].comment_long_text_id = ibe
       .comment_long_text_id
      ENDIF
     ENDIF
    DETAIL
     IF (ifoundevent=0)
      IF (iorder > 0)
       ievent += 1
       IF (size(report_struct->order_list[iorder].infusion_entries[iinfuseevent].event_id_list,5) <=
       ievent)
        istat = alterlist(report_struct->order_list[iorder].infusion_entries[iinfuseevent].
         event_id_list,(ievent+ 9))
       ENDIF
       report_struct->order_list[iorder].infusion_entries[iinfuseevent].event_id_list[ievent].
       event_id = ce.event_id, ieiordersize = size(event_info->order_list,5)
       FOR (ieiorder = 1 TO ieiordersize)
         IF ((event_info->order_list[ieiorder].order_id=ibe.order_id))
          ieieventsize = size(event_info->order_list[ieiorder].event_list,5), ieievent = 0, ieievent
           = locateval(inum,1,ieieventsize,ce.event_id,event_info->order_list[ieiorder].event_list[
           inum].event_id)
          IF (ieievent > 0)
           event_info->order_list[ieiorder].event_list[ieievent].infusion_found_ind = 1
           IF ((event_info->order_list[ieiorder].event_list[ieievent].route_cd > 0))
            iroute = (size(report_struct->order_list[iorder].infusion_entries[iinfuseevent].
             route_list,5)+ 1), istat = alterlist(report_struct->order_list[iorder].infusion_entries[
             iinfuseevent].route_list,iroute), report_struct->order_list[iorder].infusion_entries[
            iinfuseevent].route_list[iroute].route_cd = event_info->order_list[ieiorder].event_list[
            ieievent].route_cd
            IF ((event_info->order_list[ieiorder].event_list[ieievent].site_cd > 0))
             isite = (size(report_struct->order_list[iorder].infusion_entries[iinfuseevent].site_list,
              5)+ 1), istat = alterlist(report_struct->order_list[iorder].infusion_entries[
              iinfuseevent].site_list,isite), report_struct->order_list[iorder].infusion_entries[
             iinfuseevent].site_list[isite].site_cd = event_info->order_list[ieiorder].event_list[
             ieievent].site_cd,
             report_struct->order_list[iorder].infusion_entries[iinfuseevent].site_list[isite].
             site_dt_tm = event_info->order_list[ieiorder].event_list[ieievent].event_end_dt_tm,
             report_struct->order_list[iorder].infusion_entries[iinfuseevent].site_list[isite].
             site_tz = event_info->order_list[ieiorder].event_list[ieievent].event_tz
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    FOOT  ibe.infusion_billing_event_id
     IF (ifoundevent=0)
      IF (iorder > 0)
       istat = alterlist(report_struct->order_list[iorder].infusion_entries[iinfuseevent].
        event_id_list[ievent],ievent), istat = alterlist(order_comment_list->qual,icomment)
      ENDIF
     ENDIF
    FOOT  ibe.infusion_start_dt_tm
     iinfuseevent = iinfuseevent
    FOOT  ibe.order_id
     IF (iorder > 0)
      istat = alterlist(report_struct->order_list[iorder].infusion_entries,iinfuseevent)
     ENDIF
    WITH nocounter
   ;end select
   IF (size(order_comment_list->qual,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(order_comment_list->qual,5))),
      long_text lt
     PLAN (d)
      JOIN (lt
      WHERE (lt.long_text_id=order_comment_list->qual[d.seq].comment_long_text_id))
     DETAIL
      iorder = order_comment_list->qual[d.seq].order_idx, iinfuseevent = order_comment_list->qual[d
      .seq].infuse_idx, report_struct->order_list[iorder].infusion_entries[iinfuseevent].
      infusion_comment = addrtfescapesequence(lt.long_text)
     WITH nocounter
    ;end select
   ENDIF
   CALL processcontinuousinfusionresults(null)
   IF (debug_ind)
    CALL echo("~! Leaving PopulateOrdersWithInfusionResults Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE processcontinuousinfusionresults(null)
   IF (debug_ind)
    CALL echo("~! Entering ProcessContinuousInfusionResults Subroutine !~")
   ENDIF
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE iorder = i4 WITH protect, noconstant(0)
   DECLARE isite = i4 WITH protect, noconstant(0)
   DECLARE izerorate = i4 WITH protect, noconstant(0)
   DECLARE izerorateeventid = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE isiteorder = i4 WITH protect, noconstant(0)
   DECLARE izerorateorder = i4 WITH protect, noconstant(0)
   DECLARE dprevsitecd = f8 WITH protect, noconstant(0)
   DECLARE zeroratestartdttm = dq8 WITH protect, noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(40)
   DECLARE ntotal = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE ifoundevent = i2 WITH protect, noconstant(0)
   CALL getibgappref(null)
   SET iordercnt = size(report_struct->order_list,5)
   SET ntotal = (ceil((cnvtreal(iordercnt)/ nsize)) * nsize)
   SET istat = alterlist(report_struct->order_list,ntotal)
   FOR (iterator = (iordercnt+ 1) TO ntotal)
     SET report_struct->order_list[iterator].order_id = report_struct->order_list[iordercnt].order_id
   ENDFOR
   SET iterator = 0
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr,
     (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (ce
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),ce.order_id,report_struct->order_list[
      iterator].order_id)
      AND ce.result_status_cd IN (auth_cd, unauth_cd, altered_cd, modified_cd)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (cmr
     WHERE cmr.iv_event_cd IN (begin_cd, ratechg_cd, sitechg_cd, waste_cd)
      AND cmr.event_id=ce.parent_event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ORDER BY ce.order_id, ce.parent_event_id, ce.event_end_dt_tm
    HEAD ce.order_id
     izerorateeventid = 0, zeroratestartdttm = 0, dprevsitecd = 0
    HEAD ce.parent_event_id
     ifoundevent = 0
     FOR (ieventnum = 1 TO size(pca_events->event_list,5))
       IF ((pca_events->event_list[ieventnum].event_id=ce.parent_event_id))
        ifoundevent = 1
       ENDIF
     ENDFOR
     IF (ifoundevent=0)
      IF (cmr.admin_site_cd > 0)
       IF (((cmr.iv_event_cd=begin_cd) OR (dprevsitecd != cmr.admin_site_cd)) )
        isiteorder = locateval(inum,1,size(site_struct->order_list,5),ce.order_id,site_struct->
         order_list[inum].order_id)
        IF (isiteorder=0)
         isiteorder = (size(site_struct->order_list,5)+ 1), istat = alterlist(site_struct->order_list,
          isiteorder), site_struct->order_list[isiteorder].order_id = ce.order_id,
         isite = 1
        ELSE
         isite = (size(site_struct->order_list[isiteorder].site_list,5)+ 1)
        ENDIF
        istat = alterlist(site_struct->order_list[isiteorder].site_list,isite), site_struct->
        order_list[isiteorder].site_list[isite].site_cd = cmr.admin_site_cd, site_struct->order_list[
        isiteorder].site_list[isite].site_dt_tm = ce.event_end_dt_tm,
        site_struct->order_list[isiteorder].site_list[isite].event_id = ce.parent_event_id,
        dprevsitecd = cmr.admin_site_cd
       ENDIF
      ENDIF
      IF (((cmr.iv_event_cd=begin_cd) OR (cmr.iv_event_cd=ratechg_cd)) )
       IF (cmr.infusion_rate=0)
        izerorateeventid = cmr.event_id, zeroratestartdttm = ce.event_end_dt_tm
       ELSEIF (cmr.infusion_rate > 0
        AND izerorateeventid > 0)
        IF (datetimediff(ce.event_end_dt_tm,zeroratestartdttm,4) > dibgappref)
         izerorateorder = locateval(inum,1,size(zero_rate_struct->order_list,5),ce.order_id,
          zero_rate_struct->order_list[inum].order_id)
         IF (izerorateorder=0)
          izerorateorder = (size(zero_rate_struct->order_list,5)+ 1), istat = alterlist(
           zero_rate_struct->order_list,izerorateorder), zero_rate_struct->order_list[izerorateorder]
          .order_id = ce.order_id,
          izerorate = 1
         ELSE
          izerorate = (size(zero_rate_struct->order_list[izerorateorder].rate_list,5)+ 1)
         ENDIF
         istat = alterlist(zero_rate_struct->order_list[izerorateorder].rate_list,izerorate),
         zero_rate_struct->order_list[izerorateorder].rate_list[izerorate].zero_rate_start =
         zeroratestartdttm, zero_rate_struct->order_list[izerorateorder].rate_list[izerorate].
         zero_rate_end = ce.event_end_dt_tm
        ENDIF
        izerorateeventid = 0, zeroratestartdttm = 0
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET istat = alterlist(report_struct->order_list,iordercnt)
   CALL processsites(null)
   CALL processzerorates(null)
   IF (debug_ind)
    CALL echo("~! Leaving ProcessContinuousInfusionResults Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE processsites(null)
   IF (debug_ind)
    CALL echo("~! Entering ProcessSites Subroutine !~")
   ENDIF
   DECLARE isiteorder = i4 WITH protect, noconstant(0)
   DECLARE isiteordersize = i4 WITH protect, noconstant(0)
   DECLARE irptorder = i4 WITH protect, noconstant(0)
   DECLARE iinfuse = i4 WITH protect, noconstant(0)
   DECLARE iinfusesize = i4 WITH protect, noconstant(0)
   DECLARE isiteevent = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE isite = i4 WITH protect, noconstant(0)
   DECLARE isitecnt = i4 WITH protect, noconstant(0)
   DECLARE isitesize = i4 WITH protect, noconstant(0)
   DECLARE dprevsitecd = f8 WITH protect, noconstant(0)
   SET isiteordersize = size(site_struct->order_list,5)
   FOR (isiteorder = 1 TO isiteordersize)
    SET irptorder = locateval(inum,1,size(report_struct->order_list,5),site_struct->order_list[
     isiteorder].order_id,report_struct->order_list[inum].order_id)
    IF (irptorder > 0)
     SET iinfusesize = size(report_struct->order_list[irptorder].infusion_entries,5)
     FOR (iinfuse = 1 TO iinfusesize)
      SET isiteevent = locateval(inum,1,size(site_struct->order_list[isiteorder].site_list,5),
       report_struct->order_list[irptorder].infusion_entries[iinfuse].event_id_list[1].event_id,
       site_struct->order_list[isiteorder].site_list[inum].event_id)
      IF (isiteevent > 0)
       SET isite = (size(report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list,5)
       + 1)
       SET istat = alterlist(report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list,
        isite)
       SET report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list[isite].site_cd =
       site_struct->order_list[isiteorder].site_list[isiteevent].site_cd
       SET report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list[isite].site_dt_tm
        = site_struct->order_list[isiteorder].site_list[isiteevent].site_dt_tm
       SET isitesize = size(site_struct->order_list[isiteorder].site_list,5)
       SET dprevsitecd = site_struct->order_list[isiteorder].site_list[isiteevent].site_cd
       FOR (isitecnt = (isiteevent+ 1) TO isitesize)
         IF ((site_struct->order_list[isiteorder].site_list[isitecnt].site_dt_tm >= report_struct->
         order_list[irptorder].infusion_entries[iinfuse].infuse_start_dt_tm)
          AND (site_struct->order_list[isiteorder].site_list[isitecnt].site_dt_tm <= report_struct->
         order_list[irptorder].infusion_entries[iinfuse].infuse_end_dt_tm))
          IF ((site_struct->order_list[isiteorder].site_list[isitecnt].site_cd != dprevsitecd))
           SET isite = (size(report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list,
            5)+ 1)
           SET istat = alterlist(report_struct->order_list[irptorder].infusion_entries[iinfuse].
            site_list,isite)
           SET report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list[isite].
           site_cd = site_struct->order_list[isiteorder].site_list[isitecnt].site_cd
           SET report_struct->order_list[irptorder].infusion_entries[iinfuse].site_list[isite].
           site_dt_tm = site_struct->order_list[isiteorder].site_list[isitecnt].site_dt_tm
           SET dprevsitecd = site_struct->order_list[isiteorder].site_list[isitecnt].site_cd
          ENDIF
         ELSE
          SET isitecnt = (isitesize+ 1)
         ENDIF
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   IF (debug_ind)
    CALL echo("~! Leaving ProcessSites Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE processzerorates(null)
   IF (debug_ind)
    CALL echo("~! Entering ProcessZeroRates Subroutine !~")
   ENDIF
   DECLARE iorder = i4 WITH protect, noconstant(0)
   DECLARE iordersize = i4 WITH protect, noconstant(0)
   DECLARE iinfusesize = i4 WITH protect, noconstant(0)
   DECLARE iinfuse = i4 WITH protect, noconstant(0)
   DECLARE iratesize = i4 WITH protect, noconstant(0)
   DECLARE irate = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE szerorate = vc WITH protect, noconstant("")
   DECLARE sformatteddt = vc WITH protect, noconstant("")
   SET iordersize = size(zero_rate_struct->order_list,5)
   FOR (iorder = 1 TO iordersize)
    SET ipos = locateval(inum,1,size(report_struct->order_list,5),zero_rate_struct->order_list[iorder
     ].order_id,report_struct->order_list[inum].order_id)
    IF (ipos > 0)
     SET iratesize = size(zero_rate_struct->order_list[iorder].rate_list,5)
     FOR (irate = 1 TO iratesize)
      SET iinfusesize = size(report_struct->order_list[ipos].infusion_entries,5)
      FOR (iinfuse = 1 TO iinfusesize)
        IF ((((zero_rate_struct->order_list[iorder].rate_list[irate].zero_rate_start >= report_struct
        ->order_list[ipos].infusion_entries[iinfuse].infuse_start_dt_tm)
         AND (zero_rate_struct->order_list[iorder].rate_list[irate].zero_rate_start <= report_struct
        ->order_list[ipos].infusion_entries[iinfuse].infuse_end_dt_tm)) OR ((zero_rate_struct->
        order_list[iorder].rate_list[irate].zero_rate_end >= report_struct->order_list[ipos].
        infusion_entries[iinfuse].infuse_start_dt_tm)
         AND (zero_rate_struct->order_list[iorder].rate_list[irate].zero_rate_end <= report_struct->
        order_list[ipos].infusion_entries[iinfuse].infuse_end_dt_tm))) )
         SET sformatteddt = formatutcdatetime(zero_rate_struct->order_list[iorder].rate_list[irate].
          zero_rate_start,0,curutc)
         SET szerorate = concat(sformatteddt," ",i18n_sto)
         SET sformatteddt = formatutcdatetime(zero_rate_struct->order_list[iorder].rate_list[irate].
          zero_rate_end,0,curutc)
         SET szerorate = concat(szerorate," ",sformatteddt)
         IF (size(report_struct->order_list[ipos].infusion_entries[iinfuse].zero_rate_string) > 0)
          SET report_struct->order_list[ipos].infusion_entries[iinfuse].zero_rate_string = concat(
           report_struct->order_list[ipos].infusion_entries[iinfuse].zero_rate_string,
           i18n_szrdelimiter,szerorate)
         ELSE
          SET report_struct->order_list[ipos].infusion_entries[iinfuse].zero_rate_string = szerorate
         ENDIF
        ENDIF
      ENDFOR
     ENDFOR
    ENDIF
   ENDFOR
   IF (debug_ind)
    CALL echo("~! Leaving ProcessZeroRates Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE generatereport(null)
   IF (debug_ind)
    CALL echo("~! Entering GenerateReport Subroutine !~")
   ENDIF
   DECLARE iorder = i4 WITH protect, noconstant(0)
   DECLARE iordersize = i4 WITH protect, noconstant(0)
   DECLARE ireplysize = i4 WITH protect, noconstant(0)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE ireqreplysize = i4 WITH protect, noconstant(0)
   DECLARE ilargetextqual = i4 WITH protect, noconstant(0)
   DECLARE iindexcount = i4 WITH protect, noconstant(0)
   SET ireplysize = size(reply->large_text_qual,5)
   SET iordersize = size(report_struct->order_list,5)
   SET istat = alterlist(reply->large_text_qual,((ireplysize+ iordersize)+ 3))
   SET ireplyidx = ireplysize
   SET reply->large_text_qual[ireplyidx].text_segment = writeheader(null)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(iordersize))
    ORDER BY report_struct->order_list[d.seq].order_start_dt_tm, cnvtlower(report_struct->order_list[
      d.seq].mnemonic)
    DETAIL
     ireplyidx += 1, reply->large_text_qual[ireplyidx].text_segment = writeorder(d.seq)
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL echo("Logic for chunking large data into segments - Start")
   ENDIF
   SET max_size = 64000
   SET ilargetextqual = ireplyidx
   IF (debug_ind)
    CALL echo(build("iReplyIdx = ",ireplyidx))
   ENDIF
   FOR (inum = 1 TO ireplyidx)
     IF (size(reply->large_text_qual[inum].text_segment,1) >= max_size)
      IF (debug_ind)
       CALL echo("Record having large data than the allowed size(64000)")
       CALL echo(build("inum = ",inum))
       CALL echo(build("Size = ",size(reply->large_text_qual[inum].text_segment,1)))
      ENDIF
      SET iindexcount = 0
      SET reply->text = reply->large_text_qual[inum].text_segment
      SET ireqreplysize = (size(reply->text,1)/ max_size)
      IF (mod(size(reply->text,1),max_size) != 0)
       SET ireqreplysize += 1
      ENDIF
      SET reply->text = ""
      IF (debug_ind)
       CALL echo(build("iReqReplySize  = ",ireqreplysize))
      ENDIF
      SET ilargetextqual += ireqreplysize
      SET istat = alterlist(reply->large_text_qual,ilargetextqual)
      FOR (iindexcount = 1 TO ireqreplysize)
        IF (debug_ind)
         CALL echo("Populating large data into smaller segments(64000)")
         CALL echo(build("iIndexcount = ",iindexcount))
        ENDIF
        SET reply->large_text_qual[(ireplyidx+ iindexcount)].text_segment = substring(1,max_size,
         reply->large_text_qual[inum].text_segment)
        SET reply->large_text_qual[inum].text_segment = substring((max_size+ 1),(size(reply->
          large_text_qual[inum].text_segment,1) - max_size),reply->large_text_qual[inum].text_segment
         )
      ENDFOR
      SET ireplyidx = ilargetextqual
     ENDIF
   ENDFOR
   IF (debug_ind)
    CALL echo("Logic for chunking large data into segments - End")
   ENDIF
   IF (((bdurover=1) OR (bvolumeover=1)) )
    SET ireplyidx += 1
    SET sdisplay = reol
    IF (bvolumeover=1)
     SET sdisplay = concat(sdisplay,i18n_sovervoldispnote,wr,reol)
    ENDIF
    IF (bdurover=1)
     SET sdisplay = concat(sdisplay,i18n_soverdurdispnote,wr,reol)
    ENDIF
    SET reply->large_text_qual[ireplyidx].text_segment = sdisplay
   ENDIF
   IF (debug_ind)
    CALL echo("~! Leaving GenerateReport Subroutine !~")
   ENDIF
 END ;Subroutine
 SUBROUTINE (tabtocenter(stext=vc) =vc)
   DECLARE icenter = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE inumtabs = i4 WITH protect, noconstant(0)
   DECLARE string = vc WITH protect, noconstant(" ")
   SET icenter = (floor((last_col/ 2)) - floor((size(stext)/ 2)))
   SET inumtabs = floor((icenter/ 10))
   FOR (inum = 1 TO inumtabs)
     SET string = concat(rtab,string)
   ENDFOR
   SET string = build("{",string,"}")
   RETURN(string)
 END ;Subroutine
 SUBROUTINE (getduration(iduration=i4) =vc)
   DECLARE string = vc WITH protect, noconstant(" ")
   DECLARE ihours = i4 WITH protect, noconstant(0)
   DECLARE imins = i4 WITH protect, noconstant(0)
   SET ihours = floor((iduration/ 60))
   SET imins = mod(iduration,60)
   IF (ihours > 999)
    SET string = i18n_soverdurdisp
    SET bdurover = 1
   ELSEIF (ihours > 0
    AND imins=0)
    SET string = concat(cnvtstring(ihours,3)," ",i18n_shr)
   ELSEIF (ihours=0
    AND imins > 0)
    SET string = concat(cnvtstring(imins,2)," ",i18n_smin)
   ELSE
    SET string = concat(cnvtstring(ihours,3)," ",i18n_shr," ",cnvtstring(imins,2),
     " ",i18n_smin)
   ENDIF
   RETURN(string)
 END ;Subroutine
 SUBROUTINE (storepcaevents(dorderid=f8) =null)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE ieventlistpos = i4 WITH protect, noconstant(0)
   SET ieventlistpos = size(pca_events->event_list,5)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr
    PLAN (ce
     WHERE ce.order_id=dorderid
      AND ce.person_id=dpersonid
      AND ce.result_status_cd IN (auth_cd, unauth_cd, modified_cd, altered_cd)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ce.event_cd IN (pca_dose_cd, continuous_dose_cd)
      AND (ce.updt_dt_tm=
     (SELECT
      max(updt_dt_tm)
      FROM clinical_event
      WHERE order_id=dorderid
       AND event_id=ce.event_id)))
     JOIN (cmr
     WHERE cmr.event_id=ce.parent_event_id
      AND cmr.iv_event_cd=begin_cd
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    ORDER BY ce.parent_event_id DESC
    HEAD ce.parent_event_id
     ieventcnt += 1
     IF ((size(pca_events->event_list,5) <= (ieventlistpos+ ieventcnt)))
      istat = alterlist(pca_events->event_list,(ieventlistpos+ ieventcnt))
     ENDIF
     pca_events->event_list[(ieventlistpos+ ieventcnt)].event_id = ce.parent_event_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (storepcaorders(dorderid=f8) =null)
   DECLARE iordercnt = i4 WITH protect, noconstant(0)
   DECLARE iorderlistpos = i4 WITH protect, noconstant(size(pca_orders->order_list,5))
   SELECT
    od1.order_id
    FROM order_detail od1,
     order_detail od2
    PLAN (od1
     WHERE od1.order_id=dorderid)
     JOIN (od2
     WHERE od2.order_id=od1.order_id
      AND ((od1.oe_field_meaning_id=pcadose
      AND od2.oe_field_meaning_id=pcadoseunit) OR (od1.oe_field_meaning_id=basalrate
      AND od2.oe_field_meaning_id=basalrateunit))
      AND od2.action_sequence=od1.action_sequence)
    ORDER BY od1.oe_field_value DESC
    HEAD od1.order_id
     iordercnt += 1
     IF (od1.oe_field_value > 0
      AND od2.oe_field_value > 0)
      IF ((size(pca_orders->order_list,5) <= (iorderlistpos+ iordercnt)))
       istat = alterlist(pca_orders->order_list,(iorderlistpos+ iordercnt))
      ENDIF
      pca_orders->order_list[(iorderlistpos+ iordercnt)].order_id = od1.order_id
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpcaeventcodes(null)
   SELECT INTO "nl:"
    d.seq, vesc.event_set_cd, vec.event_cd
    FROM (dummyt d  WITH seq = value(2)),
     code_value cv,
     v500_event_set_code vesc,
     v500_event_set_explode vese,
     v500_event_code vec
    PLAN (d)
     JOIN (cv
     WHERE cv.concept_cki IN (pca_dose_cki, continuous_dose_cki)
      AND cv.code_set=93
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (vesc
     WHERE vesc.event_set_cd=cv.code_value)
     JOIN (vese
     WHERE vese.event_set_cd=vesc.event_set_cd)
     JOIN (vec
     WHERE vec.event_cd=vese.event_cd
      AND cnvtupper(vec.event_set_name)=cnvtupper(vesc.event_set_name))
    ORDER BY cv.concept_cki
    HEAD cv.concept_cki
     IF (cv.concept_cki=pca_dose_cki)
      pca_dose_cd = vec.event_cd
     ENDIF
     IF (cv.concept_cki=continuous_dose_cki)
      continuous_dose_cd = vec.event_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE writeheader(null)
   DECLARE stext = vc WITH protect, noconstant(" ")
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE patient_name = i4 WITH protect, constant(25)
   DECLARE fin = i4 WITH protect, constant(24)
   DECLARE mrn = i4 WITH protect, constant(24)
   DECLARE encntr_type = i4 WITH protect, constant(25)
   DECLARE location = i4 WITH protect, constant(29)
   SET sdisplay = tabtocenter(i18n_stitle)
   SET sdisplay = concat(sdisplay,wu,i18n_stitle,wr,reol)
   SET sdisplay = concat(sdisplay,tabtocenter(report_struct->encounter_range))
   SET sdisplay = concat(sdisplay,report_struct->encounter_range,reol,reol)
   SET sdisplay = concat(sdisplay,rbop,headtabs)
   SET sdisplay = concat(sdisplay,wb,formatlabelbylength(report_struct->patient_name,patient_name))
   IF ((report_struct->fin != " "))
    SET stext = concat(i18n_sfin," ",report_struct->fin)
    SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(stext,fin))
   ELSE
    SET sdisplay = concat(sdisplay,rtab," ")
   ENDIF
   IF ((report_struct->mrn != " "))
    SET stext = concat(i18n_smrn," ",report_struct->mrn)
    SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(stext,mrn))
   ELSE
    SET sdisplay = concat(sdisplay,rtab," ")
   ENDIF
   SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(report_struct->encounter_type,encntr_type)
    )
   SET stext = concat(i18n_slocation," ",report_struct->location)
   SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(stext,location))
   SET sdisplay = concat(sdisplay,reop,rbop)
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writeorder(iorderidx=i4) =vc)
   DECLARE sdisplay = vc WITH protect, noconstant("")
   DECLARE sline = vc WITH protect, noconstant("")
   DECLARE ilinelength = i4 WITH protect, noconstant(0)
   DECLARE ipos = i4 WITH protect, noconstant(0)
   DECLARE iindx = i4 WITH protect, noconstant(0)
   IF (size(report_struct->order_list[iorderidx].mnemonic)=0)
    RETURN(sdisplay)
   ENDIF
   SET sdisplay = concat(rbop,coltabs,reol)
   SET sline = report_struct->order_list[iorderidx].mnemonic
   SET sdisplay = concat(sdisplay,wb,sline,wr,reol)
   SET sline = report_struct->order_list[iorderidx].clin_disp_line
   SET sdisplay = concat(sdisplay," ",sline,reol)
   IF ((report_struct->order_list[iorderidx].order_comment != ""))
    SET sdisplay = concat(sdisplay," ",report_struct->order_list[iorderidx].order_comment,reol)
   ENDIF
   SET ipos = locateval(iindx,1,size(pca_orders->order_list,5),report_struct->order_list[iorderidx].
    order_id,pca_orders->order_list[iindx].order_id)
   IF (ipos > 0)
    SET sdisplay = concat(sdisplay,reol,wb,i18n_spcamsg,reol)
   ENDIF
   IF ((report_struct->order_list[iorderidx].med_order_type_cd=iv_cd))
    SET sdisplay = concat(sdisplay,writeiv(iorderidx))
   ELSE
    SET sdisplay = concat(sdisplay,writeintermittent(iorderidx))
   ENDIF
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writeintermittent(iorderidx=i4) =vc)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   SET sdisplay = concat(reol,rtab," ")
   SET sdisplay = concat(sdisplay,wu,i18n_sstartdatetime,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_senddatetime,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_sroute,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_ssite,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_sduration,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_sinfusevolume,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_spersonnel,wr)
   SET sdisplay = concat(sdisplay," ",writeorderevents(iorderidx,0))
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writeiv(iorderidx=i4) =vc)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE sevents = vc WITH protect, noconstant(" ")
   SET sdisplay = concat(reol,rtab," ")
   SET sdisplay = concat(sdisplay,wu,i18n_sstartdatetime,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_senddatetime,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,rtab," ")
   SET sdisplay = concat(sdisplay,wu,i18n_ssite,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_sduration,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_sinfusevolume,wr,rtab,
    " ")
   SET sdisplay = concat(sdisplay,wu,i18n_spersonnel,wr)
   SET sevents = writeorderevents(iorderidx,1)
   SET sdisplay = concat(sdisplay," ",sevents)
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writeorderevents(iorderidx=i4,bisiv=i2) =vc)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE sline = vc WITH protect, noconstant(" ")
   DECLARE bmultisite = i2 WITH protect, noconstant(0)
   DECLARE iinfuse = i4 WITH protect, noconstant(0)
   DECLARE iinfusesize = i4 WITH protect, noconstant(0)
   DECLARE ievent = i4 WITH protect, noconstant(0)
   DECLARE ieventsize = i4 WITH protect, noconstant(0)
   DECLARE isite = i4 WITH protect, noconstant(0)
   DECLARE isitesize = i4 WITH protect, noconstant(0)
   DECLARE iroute = i4 WITH protect, noconstant(0)
   DECLARE iroutesize = i4 WITH protect, noconstant(0)
   DECLARE ieiorder = i4 WITH protect, noconstant(0)
   DECLARE inum = i4 WITH protect, noconstant(0)
   DECLARE dtotalvol = f8 WITH protect, noconstant(0)
   DECLARE dinfusevol = f8 WITH protect, noconstant(0)
   DECLARE dinfuseduration = i4 WITH protect, noconstant(0)
   DECLARE dtotalduration = i4 WITH protect, noconstant(0)
   DECLARE previnfusedttm = dq8 WITH protect, noconstant(0)
   DECLARE boverlappedinf = i2 WITH protect, noconstant(0)
   SET iinfusesize = size(report_struct->order_list[iorderidx].infusion_entries,5)
   FOR (iinfuse = 1 TO iinfusesize)
     SET dinfusevol = 0
     SET dinfuseduration = 0
     SET bmultisite = 0
     SET ieventsize = size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].
      event_id_list,5)
     IF (ieventsize=1)
      SET sdisplay = concat(sdisplay,reol,rtab," ")
      SET sdisplay = concat(sdisplay,wr,formatutcdatetime(report_struct->order_list[iorderidx].
        infusion_entries[iinfuse].infuse_start_dt_tm,report_struct->order_list[iorderidx].
        infusion_entries[iinfuse].infuse_tz,1))
      SET sdisplay = concat(sdisplay,rtab,formatutcdatetime(report_struct->order_list[iorderidx].
        infusion_entries[iinfuse].infuse_end_dt_tm,report_struct->order_list[iorderidx].
        infusion_entries[iinfuse].infuse_tz,1))
      IF (bisiv=1)
       SET sdisplay = concat(sdisplay,rtab," ")
      ELSE
       SET iroutesize = size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].
        route_list,5)
       IF (iroutesize=1)
        SET sline = uar_get_code_display(report_struct->order_list[iorderidx].infusion_entries[
         iinfuse].route_list[1].route_cd)
        SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(sline,route))
       ELSE
        SET sdisplay = concat(sdisplay,rtab," ")
       ENDIF
      ENDIF
      SET isitesize = size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].site_list,5
       )
      IF (isitesize=1)
       SET sline = uar_get_code_display(report_struct->order_list[iorderidx].infusion_entries[iinfuse
        ].site_list[1].site_cd)
       SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(sline,site))
      ELSE
       IF (isitesize > 1)
        SET bmultisite = 1
       ENDIF
       SET sdisplay = concat(sdisplay,rtab," ")
      ENDIF
      SET dinfuseduration = report_struct->order_list[iorderidx].infusion_entries[iinfuse].duration
      SET sdisplay = concat(sdisplay,rtab,getduration(dinfuseduration))
      SET dinfusevol = report_struct->order_list[iorderidx].infusion_entries[iinfuse].infusion_volume
      IF (dinfusevol >= 100000)
       SET sdisplay = concat(sdisplay,rtab,i18n_sovervoldisp)
       SET bvolumeover = 1
      ELSE
       SET sdisplay = concat(sdisplay,rtab,trim(format(dinfusevol,"#####.##;LIt(1)"))," ",
        i18n_sunitml)
      ENDIF
      SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(report_struct->order_list[iorderidx].
        infusion_entries[iinfuse].prsnl_name,personnel))
      IF (bmultisite=1)
       SET sdisplay = concat(sdisplay," ",writemultiplesites(iorderidx,iinfuse))
      ENDIF
     ELSEIF (ieventsize > 1)
      SET previnfusedttm = 0
      SET boverlappedinf = 0
      FOR (ievent = 1 TO ieventsize)
        SET bmultisite = 0
        SET sdisplay = concat(sdisplay,reol,rtab," ")
        IF (ievent=1)
         SET sdisplay = concat(sdisplay,wr,formatutcdatetime(report_struct->order_list[iorderidx].
           infusion_entries[iinfuse].infuse_start_dt_tm,report_struct->order_list[iorderidx].
           infusion_entries[iinfuse].infuse_tz,1))
         SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(i18n_scontinuous,end_dttm))
        ELSEIF (ievent=ieventsize)
         SET sdisplay = concat(sdisplay," ",formatlabelbylength(i18n_scontinuous,start_dttm))
         SET sdisplay = concat(sdisplay,rtab,formatutcdatetime(report_struct->order_list[iorderidx].
           infusion_entries[iinfuse].infuse_end_dt_tm,report_struct->order_list[iorderidx].
           infusion_entries[iinfuse].infuse_tz,1))
        ELSE
         SET sdisplay = concat(sdisplay," ",formatlabelbylength(i18n_scontinuous,start_dttm))
         SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(i18n_scontinuous,end_dttm))
        ENDIF
        SET sdisplay = concat(sdisplay,rtab," ")
        SET isitesize = size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].site_list,
         5)
        IF (isitesize=1)
         SET sline = uar_get_code_display(report_struct->order_list[iorderidx].infusion_entries[
          iinfuse].site_list[1].site_cd)
         SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(sline,site))
        ELSE
         IF (isitesize > 1)
          SET bmultisite = 1
         ENDIF
         SET sdisplay = concat(sdisplay,rtab," ")
        ENDIF
        IF (ievent=ieventsize)
         SET dinfuseduration = report_struct->order_list[iorderidx].infusion_entries[iinfuse].
         duration
         SET dinfusevol = report_struct->order_list[iorderidx].infusion_entries[iinfuse].
         infusion_volume
         SET sdisplay = concat(sdisplay,rtab,getduration(dinfuseduration))
         IF (dinfusevol >= 100000)
          SET sdisplay = concat(sdisplay,rtab,i18n_sovervoldisp)
          SET bvolumeover = 1
         ELSE
          SET sdisplay = concat(sdisplay,rtab,trim(format(dinfusevol,"#####.##;LIt(1)"))," ",
           i18n_sunitml)
         ENDIF
         SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(report_struct->order_list[iorderidx]
           .infusion_entries[iinfuse].prsnl_name,personnel))
         IF (bmultisite=1)
          SET sdisplay = concat(sdisplay," ",writemultiplesites(iorderidx,iinfuse))
         ENDIF
        ELSE
         SET sdisplay = concat(sdisplay,rtab,rtab," ")
        ENDIF
      ENDFOR
     ENDIF
     IF (size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].infusion_comment) > 0)
      SET sline = report_struct->order_list[iorderidx].infusion_entries[iinfuse].infusion_comment
      SET sdisplay = concat(sdisplay,reol,"{",rtab,rtab,
       rtab,rtab,"}")
      SET sdisplay = concat(sdisplay,i18n_scomment," ",sline)
     ENDIF
     SET sline = writezerorates(iorderidx,iinfuse)
     IF (size(sline) > 0)
      SET sdisplay = concat(sdisplay,sline,reol)
     ENDIF
     IF ((previnfusedttm > report_struct->order_list[iorderidx].infusion_entries[iinfuse].
     infuse_start_dt_tm))
      SET boverlappedinf = 1
     ENDIF
     SET previnfusedttm = report_struct->order_list[iorderidx].infusion_entries[iinfuse].
     infuse_end_dt_tm
     SET dtotalvol += dinfusevol
     SET dtotalduration += dinfuseduration
     IF (iinfuse != iinfusesize)
      SET sdisplay = concat(sdisplay,reol)
     ENDIF
   ENDFOR
   SET ieiorder = locateval(inum,1,size(event_info->order_list,5),report_struct->order_list[iorderidx
    ].order_id,event_info->order_list[inum].order_id)
   SET ieventsize = size(event_info->order_list[ieiorder].event_list,5)
   IF (ieiorder > 0)
    FOR (ievent = 1 TO ieventsize)
      IF ((event_info->order_list[ieiorder].event_list[ievent].infusion_found_ind=0))
       SET sdisplay = concat(sdisplay,reol,rbop,coltabs,wr)
       SET sline = formatutcdatetime(event_info->order_list[ieiorder].event_list[ievent].
        event_end_dt_tm,event_info->order_list[ieiorder].event_list[ievent].event_tz,1)
       SET sdisplay = concat(sdisplay,"{",rtab,"}",sline)
       SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(i18n_sincomplete,end_dttm))
       IF (bisiv=1)
        SET sdisplay = concat(sdisplay,rtab," ")
       ELSE
        SET sline = uar_get_code_display(event_info->order_list[ieiorder].event_list[ievent].route_cd
         )
        SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(sline,route))
       ENDIF
       SET sline = uar_get_code_display(event_info->order_list[ieiorder].event_list[ievent].site_cd)
       SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(sline,site))
       SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(i18n_snotincluded,duration))
       SET sdisplay = concat(sdisplay,rtab,formatlabelbylength(i18n_snotincluded,volume))
      ENDIF
    ENDFOR
   ENDIF
   SET sdisplay = concat(sdisplay,reol,"{",rtab,rtab,
    rtab)
   SET sdisplay = concat(sdisplay,rtab,"}")
   IF (boverlappedinf=0)
    IF (dtotalvol >= 100000)
     SET sdisplay = concat(sdisplay,wb,i18n_stotalvolume,"{",rtab,
      "}",i18n_sovervoldisp,wr)
    ELSE
     SET sdisplay = concat(sdisplay,wb,i18n_stotalvolume,"{",rtab,
      "}",trim(format(dtotalvol,"#####.##;LIt(1)"))," ",i18n_sunitml)
    ENDIF
   ELSE
    SET sdisplay = concat(sdisplay,wb,i18n_stotalvolume,"{",rtab,
     "}",i18n_sunabletocalculate,wr)
   ENDIF
   SET sdisplay = concat(sdisplay,reol,"{",rtab,rtab,
    rtab)
   SET sdisplay = concat(sdisplay,rtab,"}")
   IF (boverlappedinf=0)
    SET sdisplay = concat(sdisplay,wb,i18n_stotalduration,rtab,getduration(dtotalduration),
     wr,reol)
   ELSE
    SET sdisplay = concat(sdisplay,wb,i18n_stotalduration,rtab,i18n_sunabletocalculate,
     wr,reol)
   ENDIF
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writemultiplesites(iorder=i4,iinfuse=i4) =vc)
   DECLARE isite = i4 WITH protect, noconstant(0)
   DECLARE isitesize = i4 WITH protect, noconstant(0)
   DECLARE iduration = i4 WITH protect, noconstant(0)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE date1 = dq8 WITH protect, noconstant(0)
   DECLARE date2 = dq8 WITH protect, noconstant(0)
   SET isitesize = size(report_struct->order_list[iorder].infusion_entries[iinfuse].site_list,5)
   FOR (isite = 1 TO (isitesize - 1))
     SET sdisplay = concat(sdisplay,reol,"{",rtab,rtab,
      rtab,rtab,"}")
     SET sdisplay = concat(sdisplay,uar_get_code_display(report_struct->order_list[iorder].
       infusion_entries[iinfuse].site_list[isite].site_cd))
     SET date1 = report_struct->order_list[iorder].infusion_entries[iinfuse].site_list[(isite+ 1)].
     site_dt_tm
     SET date2 = report_struct->order_list[iorder].infusion_entries[iinfuse].site_list[isite].
     site_dt_tm
     SET iduration = cnvtint(abs(datetimediff(date1,date2,4)))
     SET sdisplay = concat(sdisplay," (",getduration(iduration),")")
   ENDFOR
   SET sdisplay = concat(sdisplay,reol,"{",rtab,rtab,
    rtab,rtab,"}")
   SET sdisplay = concat(sdisplay,uar_get_code_display(report_struct->order_list[iorder].
     infusion_entries[iinfuse].site_list[isite].site_cd))
   SET date1 = report_struct->order_list[iorder].infusion_entries[iinfuse].site_list[isitesize].
   site_dt_tm
   SET date2 = report_struct->order_list[iorder].infusion_entries[iinfuse].infuse_end_dt_tm
   SET iduration = cnvtint(abs(datetimediff(date1,date2,4)))
   SET sdisplay = concat(sdisplay," (",getduration(iduration),")")
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (writezerorates(iorder=i4,iinfuse=i4) =vc)
   DECLARE sdisplay = vc WITH protect, noconstant(" ")
   DECLARE idelimpos = i4 WITH protect, noconstant(0)
   DECLARE szstring = vc WITH protect, noconstant(" ")
   DECLARE stabbing = vc WITH protect, noconstant(" ")
   DECLARE bdone = i2 WITH protect, noconstant(0)
   IF (size(report_struct->order_list[iorderidx].infusion_entries[iinfuse].zero_rate_string) > 0)
    SET szstring = report_struct->order_list[iorderidx].infusion_entries[iinfuse].zero_rate_string
    SET stabbing = concat("{",rtab,rtab,rtab,rtab,
     rtab,"}")
    SET bdone = 0
    WHILE (bdone != 1)
      SET sdisplay = concat(sdisplay,reol,stabbing)
      SET idelimpos = findstring(i18n_szrdelimiter,szstring,0,0)
      IF (idelimpos=0)
       SET sdisplay = concat(sdisplay,"(",i18n_szerorate,i18n_szrdelimiter," ",
        szstring,")")
       SET bdone = 1
      ELSE
       SET sdisplay = concat(sdisplay,"(",i18n_szerorate,i18n_szrdelimiter,substring(1,idelimpos,
         szstring),
        ")")
       SET szstring = substring((idelimpos+ 1),(size(szstring) - idelimpos),szstring)
      ENDIF
    ENDWHILE
   ENDIF
   RETURN(sdisplay)
 END ;Subroutine
 SUBROUTINE (addrtfescapesequence(slabel=vc) =vc)
   DECLARE snewlabel = vc WITH protect, noconstant(slabel)
   SET snewlabel = replace(snewlabel,"\","\\",0)
   SET snewlabel = replace(snewlabel,"}","\}",0)
   SET snewlabel = replace(snewlabel,"{","\{",0)
   RETURN(trim(snewlabel,2))
 END ;Subroutine
#exit_script
 SET last_mod = "021"
 SET mod_date = "12/15/2021"
END GO
