CREATE PROGRAM dcp_get_gravida_info:dba
 RECORD reply(
   1 gravida = i4
   1 para = i4
   1 aborted = i4
   1 living = i4
   1 fullterm = i4
   1 premature = i4
   1 ectopic = i4
   1 induced_abortions = i4
   1 spontaneous_abortions = i4
   1 multiple_births = i4
   1 gravida_ind = i2
   1 para_ind = i2
   1 aborted_ind = i2
   1 living_ind = i2
   1 fullterm_ind = i2
   1 premature_ind = i2
   1 ectopic_ind = i2
   1 induced_abortions_ind = i2
   1 spontaneous_abortions_ind = i2
   1 multiple_births_ind = i2
   1 living_comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD org_sec_reply(
   1 preg_org_sec_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD encntr_request(
   1 force_org_security_ind = i2
   1 prsnl_id = f8
   1 persons[*]
     2 person_id = f8
   1 force_encntrs_ind = i2
   1 provider_ind = i2
   1 exclude_life_reltns[*]
     2 person_prsnl_reltn_id = f8
   1 exclude_visit_reltns[*]
     2 encntr_prsnl_reltn_id = f8
   1 include_reltn_type_cd = f8
   1 retrieve_aliases_ind = i4
   1 encntr_lookback_days = i4
 )
 RECORD encntr_reply(
   1 restrict_ind = i2
   1 persons[*]
     2 person_id = f8
     2 restrict_ind = i2
     2 encntrs[*]
       3 encntr_id = f8
       3 encntr_type_cd = f8
       3 encntr_type_disp = vc
       3 encntr_type_class_cd = f8
       3 encntr_type_class_disp = vc
       3 encntr_status_cd = f8
       3 encntr_status_disp = vc
       3 reg_dt_tm = dq8
       3 pre_reg_dt_tm = dq8
       3 location_cd = f8
       3 loc_facility_cd = f8
       3 loc_facility_disp = vc
       3 loc_building_cd = f8
       3 loc_building_disp = vc
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = vc
       3 loc_room_cd = f8
       3 loc_room_disp = vc
       3 loc_bed_cd = f8
       3 loc_bed_disp = vc
       3 reason_for_visit = vc
       3 financial_class_cd = f8
       3 financial_class_disp = vc
       3 beg_effective_dt_tm = dq8
       3 disch_dt_tm = dq8
       3 med_service_cd = f8
       3 diet_type_cd = f8
       3 isolation_cd = f8
       3 encntr_financial_id = f8
       3 arrive_dt_tm = dq8
       3 provider_list[*]
         4 provider_id = f8
         4 provider_name = vc
         4 relationship_cd = f8
         4 relationship_disp = vc
         4 relationship_mean = c12
       3 organization_id = f8
       3 time_zone_indx = i4
       3 est_arrive_dt_tm = dq8
       3 est_disch_dt_tm = dq8
       3 contributor_system_cd = f8
       3 contributor_system_disp = vc
       3 contributor_system_mean = vc
       3 loc_temp_cd = f8
       3 loc_temp_disp = vc
       3 alias_list[*]
         4 alias = vc
         4 alias_type_cd = f8
         4 alias_type_disp = vc
         4 alias_type_mean = vc
         4 alias_status_cd = f8
         4 alias_status_disp = vc
         4 alias_status_mean = vc
         4 contributor_system_cd = f8
         4 contributor_system_disp = vc
         4 contributor_system_mean = vc
       3 encntr_type_class_mean = c12
       3 encntr_status_mean = c12
       3 med_service_disp = vc
       3 isolation_disp = vc
       3 location_disp = vc
       3 diet_type_disp = vc
       3 diet_type_mean = vc
       3 inpatient_admit_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD gravida_event_sets(
   1 qual[*]
     2 pref_entry_name = vc
     2 event_set_name = vc
 )
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE debug = i2 WITH protect, constant(validate(request->debug_ind))
 DECLARE locateindex = i4 WITH protect, noconstant(0)
 DECLARE termindex = i4 WITH protect, noconstant(0)
 DECLARE prsnl_position_cd = f8 WITH protect, noconstant(0.0)
 DECLARE preg_org_sec_on = i2 WITH protect, noconstant(0)
 DECLARE check_org_sec(null) = i2
 DECLARE get_valid_encounters_org_sec(null) = null
 DECLARE get_gravida_event_set_pref(null) = null
 DECLARE get_psnl_position_cd(null) = null
 DECLARE get_gravida_info(null) = null
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "S"
 IF (validate(request->patient_id)=0)
  SET cfailed = "T"
  GO TO exit_script
 ENDIF
 SET preg_org_sec_on = check_org_sec(null)
 CALL echo(build("Is preg org sec on:",preg_org_sec_on))
 IF (preg_org_sec_on=1)
  CALL get_valid_encounters_org_sec(null)
 ENDIF
 CALL get_gravida_event_set_pref(null)
 CALL get_psnl_position_cd(null)
 CALL get_gravida_info(null)
 SUBROUTINE check_org_sec(null)
   DECLARE retval = i2 WITH noconstant(0.0), private
   EXECUTE dcp_chk_preg_org_security  WITH replace("REPLY",org_sec_reply)
   IF (validate(request->org_sec_override,- (1))=1)
    SET retval = 0
   ELSE
    SET retval = org_sec_reply->preg_org_sec_ind
   ENDIF
   CALL echo(build("Pre_org_sec_enabled: ",retval))
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE get_valid_encounters_org_sec(null)
   SET encntr_request->force_org_security_ind = 1
   SET encntr_request->prsnl_id = request->prsnl_id
   CALL echo(build("Personnel id: ",request->prsnl_id))
   SET stat = alterlist(encntr_request->persons,1)
   SET encntr_request->persons[1].person_id = request->patient_id
   EXECUTE dcp_get_valid_encounters  WITH replace("REQUEST",encntr_request), replace("REPLY",
    encntr_reply)
   IF ((encntr_reply->status_data.status="F"))
    CALL echo("*Failed - dcp_get_valid_encounters in dcp_get_gravida_info*")
    GO TO exit_script
   ELSE
    CALL echorecord(encntr_reply)
    CALL echo("Valid Encounters retrieved")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_gravida_event_set_pref(null)
   SET stat = alterlist(gravida_event_sets->qual,10)
   SET gravida_event_sets->qual[1].pref_entry_name = "gravida"
   SET gravida_event_sets->qual[1].event_set_name = "Gravida"
   SET gravida_event_sets->qual[2].pref_entry_name = "para"
   SET gravida_event_sets->qual[2].event_set_name = "Para"
   SET gravida_event_sets->qual[3].pref_entry_name = "abortion"
   SET gravida_event_sets->qual[3].event_set_name = "Aborted"
   SET gravida_event_sets->qual[4].pref_entry_name = "living"
   SET gravida_event_sets->qual[4].event_set_name = "Living Children"
   SET gravida_event_sets->qual[5].pref_entry_name = "fullterm"
   SET gravida_event_sets->qual[5].event_set_name = "Fullterm"
   SET gravida_event_sets->qual[6].pref_entry_name = "premature"
   SET gravida_event_sets->qual[6].event_set_name = "Premature Birth"
   SET gravida_event_sets->qual[7].pref_entry_name = "ectopic"
   SET gravida_event_sets->qual[7].event_set_name = "Ectopic"
   SET gravida_event_sets->qual[8].pref_entry_name = "induced abortions"
   SET gravida_event_sets->qual[8].event_set_name = "Induced Abortions"
   SET gravida_event_sets->qual[9].pref_entry_name = "spontaneous abortions"
   SET gravida_event_sets->qual[9].event_set_name = "Spontaneous Abortions"
   SET gravida_event_sets->qual[10].pref_entry_name = "multiple births"
   SET gravida_event_sets->qual[10].event_set_name = "Multiple Births"
   EXECUTE prefrtl
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE hrepgroup = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hattr = i4 WITH private, noconstant(0)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE entrycnt = i4 WITH private, noconstant(0)
   DECLARE entryidx = i4 WITH private, noconstant(0)
   DECLARE arraysize = i4 WITH private, noconstant(size(gravida_event_sets->qual,5))
   DECLARE ilen = i4 WITH private, noconstant(255)
   DECLARE attrcnt = i4 WITH private, noconstant(0)
   DECLARE attridx = i4 WITH private, noconstant(0)
   DECLARE valcnt = i4 WITH private, noconstant(0)
   DECLARE entryname = c255 WITH private, noconstant("")
   DECLARE attrname = c255 WITH private, noconstant("")
   DECLARE sval = c255 WITH private, noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   SET stat = uar_prefsetsection(hpref,nullterm("component"))
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,nullterm("Pregnancy"))
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm("component"))
   SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm("Pregnancy"))
   SET stat = uar_prefgetgroupentrycount(hrepgroup,entrycnt)
   FOR (entryidx = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,entryidx)
     SET ilen = 255
     SET entryname = ""
     SET stat = uar_prefgetentryname(hentry,entryname,ilen)
     SET termindex = locateval(locateindex,1,arraysize,trim(entryname),gravida_event_sets->qual[
      locateindex].pref_entry_name)
     IF (termindex > 0)
      SET attrcnt = 0
      SET stat = uar_prefgetentryattrcount(hentry,attrcnt)
      FOR (attridx = 0 TO (attrcnt - 1))
        SET hattr = uar_prefgetentryattr(hentry,attridx)
        SET ilen = 255
        SET attrname = ""
        SET stat = uar_prefgetattrname(hattr,attrname,ilen)
        IF (attrname="prefvalue")
         SET valcnt = 0
         SET stat = uar_prefgetattrvalcount(hattr,valcnt)
         IF (valcnt > 0)
          SET sval = ""
          SET ilen = 255
          SET stat = uar_prefgetattrval(hattr,sval,ilen,0)
          SET gravida_event_sets->qual[termindex].event_set_name = trim(sval)
          CALL echo(build(concat("entry: ",trim(entryname),"  value: ",trim(sval))))
         ENDIF
         SET attridx = attrcnt
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
 END ;Subroutine
 SUBROUTINE get_psnl_position_cd(null)
   IF ((request->prsnl_id=0.0))
    CALL echo(build("request->prsnl_id is invalid. cannot continue with dcp_get_gravida_info."))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   SET prsnl_position_cd = 0.0
   SELECT INTO "NL:"
    FROM prsnl p
    WHERE (p.person_id=request->prsnl_id)
     AND p.active_ind=1
    ORDER BY p.position_cd
    HEAD p.position_cd
     prsnl_position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(build("Looking up position_cd for the prsnl failed in get_psnl_position_cd."))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   CALL echo(build("Leaving get_prsnl_position_cd"))
 END ;Subroutine
 SUBROUTINE get_gravida_info(null)
   CALL echo("Entering GetGravidaInfo")
   DECLARE appid_gravida = i4 WITH constant(600005), protect
   DECLARE tskid_gravida = i4 WITH constant(601560), protect
   DECLARE reqid_gravida = i4 WITH constant(3200264), protect
   DECLARE happ_gravida = i4 WITH noconstant(0), protect
   DECLARE htask_gravida = i4 WITH noconstant(0), protect
   DECLARE hstep_gravida = i4 WITH noconstant(0), protect
   DECLARE hrequest_gravida = i4 WITH noconstant(0), protect
   DECLARE hreply_gravida = i4 WITH noconstant(0), protect
   DECLARE irtn = i4 WITH noconstant(0), protect
   SET irtn = uar_crmbeginapp(appid_gravida,happ_gravida)
   IF (irtn != 0)
    SET cfailed = "T"
    CALL echo("uar_crm_begin_app failed in MSVC Service for Gravida from dcp_get_phx")
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbegintask(happ_gravida,tskid_gravida,htask_gravida)
   IF (irtn != 0)
    SET cfailed = "T"
    CALL echo("uar_crm_begin_task failed in MSVC Service for Gravida from dcp_get_phx")
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbeginreq(htask_gravida,"",reqid_gravida,hstep_gravida)
   IF (irtn != 0)
    SET cfailed = "T"
    CALL echo("uar_crm_begin_Request failed in MSVC Service for Gravida from dcp_get_phx")
    GO TO exit_script
   ENDIF
   SET hrequest_gravida = uar_crmgetrequest(hstep_gravida)
   IF (hrequest_gravida)
    CALL set_gravida_request(hrequest_gravida)
   ENDIF
   SET irtn = uar_crmperform(hstep_gravida)
   SET hreply_gravida = uar_crmgetreply(hstep_gravida)
   IF (hreply_gravida)
    CALL check_reply_status(hreply_gravida)
    CALL get_gravida_reply(hreply_gravida)
   ENDIF
   CALL echo("Leaving GetGravidaInfo")
 END ;Subroutine
 SUBROUTINE (set_gravida_request(hrequest_gra=i4) =null)
   CALL echo("Entering set_gravida_request")
   DECLARE heventsets = i4 WITH private, noconstant(0)
   DECLARE hclinicalevent = i4 WITH private, noconstant(0)
   DECLARE hloadind = i4 WITH private, noconstant(0)
   DECLARE hcontext = i4 WITH private, noconstant(0)
   SET stat = uar_srvsetdouble(hrequest_gra,"patient_id",request->patient_id)
   SET stat = uar_srvsetlong(hrequest_gra,"result_count",1)
   IF (preg_org_sec_on=1)
    FOR (person_idx = 1 TO size(encntr_reply->persons,5))
      FOR (encntr_idx = 1 TO size(encntr_reply->persons[person_idx].encntrs,5))
       SET hencntridlist = uar_srvadditem(hrequest_gra,"encntr_id_list")
       IF (hencntridlist)
        SET stat = uar_srvsetdouble(hencntridlist,"encntr_id",encntr_reply->persons[person_idx].
         encntrs[encntr_idx].encntr_id)
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   FOR (name_idx = 1 TO size(gravida_event_sets->qual,5))
    SET heventsets = uar_srvadditem(hrequest_gra,"event_set_list")
    IF (heventsets)
     SET stat = uar_srvsetstring(heventsets,"event_set_name",nullterm(gravida_event_sets->qual[
       name_idx].event_set_name))
    ENDIF
   ENDFOR
   SET hcontext = uar_srvgetstruct(hrequest_gra,"context")
   IF (hcontext)
    SET stat = uar_srvsetdouble(hcontext,"provider_id",request->prsnl_id)
    SET stat = uar_srvsetdouble(hcontext,"position_cd",prsnl_position_cd)
   ENDIF
   SET hloadind = uar_srvgetstruct(hrequest_gra,"load_indicators")
   IF (hloadind)
    SET hclinicalevent = uar_srvgetstruct(hloadind,"clinical_event")
    IF (hclinicalevent)
     SET stat = uar_srvsetshort(hclinicalevent,"meas_value_ind",1)
     SET stat = uar_srvsetshort(hclinicalevent,"comments_ind",1)
    ENDIF
   ENDIF
   CALL echo("Leaving set_gravida_request")
 END ;Subroutine
 SUBROUTINE (check_reply_status(hreply=i4) =null)
   CALL echo("Entering check_reply_status")
   IF (hreply=0)
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   DECLARE hstatus_data = i4 WITH protect, noconstant(0)
   DECLARE status_vc = c1 WITH protect, noconstant(fillstring(1," "))
   SET hstatus_data = uar_srvgetstruct(hreply,"status_data")
   IF (hstatus_data)
    SET status_vc = uar_srvgetstringptr(hstatus_data,"status")
    CALL echo(build("Reply Status: ",status_vc))
    IF (((status_vc="S") OR (status_vc="s")) )
     SET cfailed = "F"
    ELSEIF (((status_vc="Z") OR (status_vc="z")) )
     SET cfailed = "Z"
    ELSE
     SET cfailed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_gravida_reply(hreply_gra=i4) =null)
   CALL echo("Entering get_gravida_reply")
   IF (hreply_gra=0)
    RETURN
   ENDIF
   DECLARE cnt_results = i4 WITH protect, noconstant(0)
   DECLARE idx_results = i4 WITH protect, noconstant(0)
   DECLARE hresult = i4 WITH protect, noconstant(0)
   DECLARE tmp_event_set_name = vc WITH protect, noconstant(fillstring(255,"  "))
   DECLARE hclinicalevents = i4 WITH protect, noconstant(0)
   DECLARE hmeasurement = i4 WITH protect, noconstant(0)
   DECLARE hmeasurementval = i4 WITH protect, noconstant(0)
   DECLARE hcomments = i4 WITH protect, noconstant(0)
   DECLARE tmp_num = i4 WITH protect, noconstant(0)
   DECLARE comment_size = i4 WITH protect, noconstant(0)
   DECLARE cnt_names = i4 WITH protect, noconstant(size(gravida_event_sets->qual,5))
   SET cnt_results = uar_srvgetitemcount(hreply_gra,"results")
   FOR (idx_results = 0 TO (cnt_results - 1))
    SET hresult = uar_srvgetitem(hreply_gra,"results",idx_results)
    IF (hresult)
     SET tmp_event_set_name = uar_srvgetstringptr(hresult,"event_set_grouper_name")
     SET termindex = 0
     SET termindex = locateval(locateindex,1,cnt_names,trim(tmp_event_set_name),gravida_event_sets->
      qual[locateindex].event_set_name)
     IF (termindex > 0)
      SET hclinicalevents = uar_srvgetitem(hresult,"clinical_events",0)
      IF (hclinicalevents)
       SET hmeasurement = uar_srvgetitem(hclinicalevents,"measurement",0)
       IF (hmeasurement)
        SET hmeasurementval = uar_srvgetitem(hmeasurement,"string_value",0)
        IF (hmeasurementval > 0)
         SET tmp_num = cnvtint(uar_srvgetstringptr(hmeasurementval,"value"))
        ELSE
         SET hmeasurementval = uar_srvgetitem(hmeasurement,"quantity_value",0)
         SET tmp_num = uar_srvgetdouble(hmeasurementval,"number")
        ENDIF
        CALL echo(build2("Measurement value is: ",tmp_num))
        IF (hmeasurementval)
         CASE (termindex)
          OF 1:
           SET reply->gravida = tmp_num
           SET reply->gravida_ind = 1
          OF 2:
           SET reply->para = tmp_num
           SET reply->para_ind = 1
          OF 3:
           SET reply->aborted = tmp_num
           SET reply->aborted_ind = 1
          OF 4:
           SET reply->living = tmp_num
           SET reply->living_ind = 1
           CALL echo("Found a living event")
           SET hcomments = uar_srvgetitem(hclinicalevents,"comments",0)
           CALL echo(build2("HCOMMENT: ",hcomments))
           IF (hcomments)
            SET comment_size = uar_srvgetasissize(hcomments,"comment_text")
            CALL echo(build2("SiZE: ",comment_size))
            IF (comment_size > 0)
             SET reply->living_comment = substring(1,comment_size,uar_srvgetasisptr(hcomments,
               "comment_text"))
            ENDIF
           ENDIF
          OF 5:
           SET reply->fullterm = tmp_num
           SET reply->fullterm_ind = 1
          OF 6:
           SET reply->premature = tmp_num
           SET reply->premature_ind = 1
          OF 7:
           SET reply->ectopic = tmp_num
           SET reply->ectopic_ind = 1
          OF 8:
           SET reply->induced_abortions = tmp_num
           SET reply->induced_abortions_ind = 1
          OF 9:
           SET reply->spontaneous_abortions = tmp_num
           SET reply->spontaneous_abortions_ind = 1
          OF 10:
           SET reply->multiple_births = tmp_num
           SET reply->multiple_births_ind = 1
         ENDCASE
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   CALL echo("Leaving get_gravida_reply")
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSEIF (cfailed="Z")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD gravida_event_sets
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
END GO
