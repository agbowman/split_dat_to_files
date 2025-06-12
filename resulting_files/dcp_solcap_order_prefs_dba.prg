CREATE PROGRAM dcp_solcap_order_prefs:dba
 SET modify = predeclare
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE return_status = i1 WITH private, noconstant(0)
 DECLARE num_prefs = i2 WITH private, constant(10)
 DECLARE pref_cnt = i4 WITH public, noconstant(0)
 DECLARE batch_list_cnt = i4 WITH public, noconstant(0)
 FREE RECORD pref_list
 RECORD pref_list(
   1 list[*]
     2 section = vc
     2 section_id = vc
     2 subgroups[*]
       3 subgroup_name = vc
     2 pref_entry = vc
     2 capability_identifier = vc
     2 path_idx = i4
     2 restrict_default = i1
     2 restrict_facility = i1
     2 restrict_position = i1
     2 active_cnt = i4
 )
 SET stat = alterlist(pref_list->list,num_prefs)
 FREE RECORD batch_load_path_list
 RECORD batch_load_path_list(
   1 list[*]
     2 section = vc
     2 section_id = vc
     2 pref_handle = i4
 )
 SET stat = alterlist(batch_load_path_list->list,num_prefs)
 SET return_status = addpreference("2010.1.00042.2","component","om","powerorders/orderentry/",
  "enhanceddetailstab",
  0,0,0)
 SET return_status = addpreference("2010.1.00015.2","component","om","powerorders/orderprofile/",
  "allowdischargereportmedsrec",
  0,0,0)
 SET return_status = addpreference("2010.1.00062.2","config","ordermanagement",
  "powerorders/orderentry/","medicationhistoryconnectsurvey",
  0,0,0)
 SET return_status = addpreference("2010.2.00087.2","component","om","powerorders/orderprofile/",
  "displaydoseadjustment",
  0,0,0)
 SET return_status = addpreference("2014.1.00084.1","config","ordermanagement",
  "powerorders/orderentry/","createmedsrecsupplyreview",
  0,0,0)
 SET return_status = addpreference("2013.1.00054.4","component","om","powerorders","displaycost",
  0,0,0)
 SET return_status = addpreference("2014.2.00038.3","component","om","powerorders/orderentry/",
  "pbsdefault",
  0,0,0)
 SET return_status = addpreference("2014.2.00038.2","component","om","powerorders/orderprofile/",
  "pbsvenue",
  0,0,0)
 SET return_status = addpreference("2016.1.00042.2","component","om","powerorders/orderentry/",
  "enablemetricdosing",
  0,0,0)
 SET return_status = addpreference("2015.2.00168.3","component","om","powerorders/orderentry/",
  "pbsorderdetailsdefault",
  0,0,0)
 SET stat = alterlist(pref_list->list,pref_cnt)
 SET stat = alterlist(batch_load_path_list->list,batch_list_cnt)
 SET stat = alterlist(reply->solcap,pref_cnt)
 DECLARE pref_idx = i4 WITH private, noconstant(0)
 FOR (pref_idx = 1 TO pref_cnt)
  SET reply->solcap[pref_idx].degree_of_use_str = "NO"
  SET reply->solcap[pref_idx].identifier = pref_list->list[pref_idx].capability_identifier
 ENDFOR
 EXECUTE prefrtl
 FREE SET res_count
 DECLARE res_count = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(pref_list->list,5)))
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(request->start_dt_tm)
    AND cv.end_effective_dt_tm >= cnvtdatetime(request->end_dt_tm))
   JOIN (d
   WHERE  NOT ((pref_list->list[d.seq].restrict_facility=1)
    AND (pref_list->list[d.seq].restrict_default=1)))
  ORDER BY cv.display, cv.code_value
  HEAD REPORT
   batch_idx = 0, pref_idx = 0
  HEAD cv.code_value
   return_status = batchloadpreferencesforcontext(cv.code_value,"facility"), res_count += 1
  DETAIL
   IF (return_status=1)
    IF (mod(res_count,10)=1)
     stat = alterlist(reply->solcap[d.seq].facility,(res_count+ 9))
    ENDIF
    reply->solcap[d.seq].facility[res_count].display = cv.display, reply->solcap[d.seq].facility[
    res_count].value_str = retrievepreference(d.seq)
    IF (iscapabilityactive(pref_list->list[d.seq].pref_entry,reply->solcap[d.seq].facility[res_count]
     .value_str)=1)
     pref_list->list[d.seq].active_cnt += 1
    ENDIF
   ENDIF
  FOOT  cv.code_value
   FOR (batch_idx = 1 TO batch_list_cnt)
     IF ((batch_load_path_list->list[batch_idx].pref_handle != 0))
      CALL uar_prefdestroyinstance(batch_load_path_list->list[batch_idx].pref_handle),
      batch_load_path_list->list[batch_idx].pref_handle = 0
     ENDIF
   ENDFOR
  FOOT REPORT
   FOR (pref_idx = 1 TO pref_cnt)
     IF ( NOT ((pref_list->list[pref_idx].restrict_facility=1)
      AND (pref_list->list[pref_idx].restrict_default=1)))
      stat = alterlist(reply->solcap[pref_idx].facility,res_count)
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 FREE SET res_count
 DECLARE res_count = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(pref_list->list,5)))
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(request->start_dt_tm)
    AND cv.end_effective_dt_tm >= cnvtdatetime(request->end_dt_tm))
   JOIN (d
   WHERE  NOT ((pref_list->list[d.seq].restrict_position=1)
    AND (pref_list->list[d.seq].restrict_default=1)))
  ORDER BY cv.display, cv.code_value
  HEAD REPORT
   batch_idx = 0, pref_idx = 0
  HEAD cv.code_value
   return_status = batchloadpreferencesforcontext(cv.code_value,"position"), res_count += 1
  DETAIL
   IF (return_status=1)
    IF (mod(res_count,10)=1)
     stat = alterlist(reply->solcap[d.seq].position,(res_count+ 9))
    ENDIF
    reply->solcap[d.seq].position[res_count].display = cv.display, reply->solcap[d.seq].position[
    res_count].value_str = retrievepreference(d.seq)
    IF (iscapabilityactive(pref_list->list[d.seq].pref_entry,reply->solcap[d.seq].position[res_count]
     .value_str)=1)
     pref_list->list[d.seq].active_cnt += 1
    ENDIF
   ENDIF
  FOOT  cv.code_value
   FOR (batch_idx = 1 TO batch_list_cnt)
     IF ((batch_load_path_list->list[batch_idx].pref_handle != 0))
      CALL uar_prefdestroyinstance(batch_load_path_list->list[batch_idx].pref_handle),
      batch_load_path_list->list[batch_idx].pref_handle = 0
     ENDIF
   ENDFOR
  FOOT REPORT
   FOR (pref_idx = 1 TO pref_cnt)
     IF ( NOT ((pref_list->list[pref_idx].restrict_position=1)
      AND (pref_list->list[pref_idx].restrict_default=1)))
      stat = alterlist(reply->solcap[pref_idx].position,res_count)
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 FOR (pref_idx = 1 TO pref_cnt)
   IF ((pref_list->list[pref_idx].active_cnt > 0))
    SET reply->solcap[pref_idx].degree_of_use_str = "YES"
    SET reply->solcap[pref_idx].degree_of_use_num = pref_list->list[pref_idx].active_cnt
   ENDIF
 ENDFOR
 SUBROUTINE (addpreference(capability_identifier=vc,section=vc,section_id=vc,subgroup_path=vc,
  pref_entry=vc,restrict_default=i1,restrict_facility=i1,restrict_position=i1) =i1)
   DECLARE subgroup_name = vc WITH private, noconstant("")
   DECLARE search_idx = i4 WITH private, noconstant(1)
   DECLARE start_idx = i4 WITH private, noconstant(1)
   DECLARE subgroup_cnt = i2 WITH private, noconstant(0)
   DECLARE pref_list_size = i4 WITH private, constant(size(pref_list->list,5))
   IF (((section="") OR (((section_id="") OR (((pref_entry="") OR (capability_identifier="")) )) )) )
    CALL echo("AddPreference - section, section_id, pref_entry, or capability_identifier is empty.")
    RETURN(0)
   ENDIF
   SET pref_cnt += 1
   IF (pref_cnt > pref_list_size)
    SET stat = alterlist(pref_list->list,(pref_cnt+ 5))
   ENDIF
   SET pref_list->list[pref_cnt].capability_identifier = capability_identifier
   SET pref_list->list[pref_cnt].section = section
   SET pref_list->list[pref_cnt].section_id = section_id
   SET pref_list->list[pref_cnt].pref_entry = pref_entry
   SET pref_list->list[pref_cnt].restrict_default = restrict_default
   SET pref_list->list[pref_cnt].restrict_facility = restrict_facility
   SET pref_list->list[pref_cnt].restrict_position = restrict_position
   SET pref_list->list[pref_cnt].path_idx = addbatchloadpath(section,section_id)
   SET stat = alterlist(pref_list->list[pref_cnt].subgroups,3)
   WHILE (search_idx != 0)
    SET search_idx = findstring("/",subgroup_path,start_idx)
    IF (search_idx > 0)
     SET subgroup_cnt += 1
     IF (subgroup_cnt > size(pref_list->list[pref_cnt].subgroups,5))
      SET stat = alterlist(pref_list->list[pref_cnt].subgroups,(subgroup_cnt+ 5))
     ENDIF
     SET subgroup_name = trim(substring(start_idx,(search_idx - start_idx),subgroup_path),3)
     SET pref_list->list[pref_cnt].subgroups[subgroup_cnt].subgroup_name = subgroup_name
     SET start_idx = (search_idx+ 1)
    ENDIF
   ENDWHILE
   SET stat = alterlist(pref_list->list[pref_cnt].subgroups,subgroup_cnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (addbatchloadpath(section=vc,section_id=vc) =i4)
   DECLARE idx_cnt = i4 WITH private, noconstant(1)
   DECLARE path_list_size = i4 WITH private, constant(size(batch_load_path_list->list,5))
   IF (((section="") OR (section_id="")) )
    CALL echo("AddBatchLoadPath - section or section_id is empty.")
    RETURN(- (1))
   ENDIF
   FOR (idx_cnt = 1 TO path_list_size)
     IF ((batch_load_path_list->list[idx_cnt].section=section)
      AND (batch_load_path_list->list[idx_cnt].section_id=section_id))
      RETURN(idx_cnt)
     ENDIF
   ENDFOR
   SET batch_list_cnt += 1
   IF (batch_list_cnt > path_list_size)
    SET stat = alterlist(batch_load_path_list->list,(batch_list_cnt+ 5))
   ENDIF
   SET batch_load_path_list->list[batch_list_cnt].section = section
   SET batch_load_path_list->list[batch_list_cnt].section_id = section_id
   RETURN(batch_list_cnt)
 END ;Subroutine
 SUBROUTINE (batchloadpreferencesforcontext(contextcd=f8,contextname=vc) =i1)
   DECLARE prefstat = i4 WITH private, noconstant(0)
   DECLARE hpref = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE idx_cnt = i4 WITH private, noconstant(0)
   DECLARE section = vc WITH private, noconstant("")
   DECLARE section_id = vc WITH private, noconstant("")
   DECLARE path_list_size = i4 WITH private, constant(size(batch_load_path_list->list,5))
   FOR (idx_cnt = 1 TO path_list_size)
     SET section = batch_load_path_list->list[idx_cnt].section
     SET section_id = batch_load_path_list->list[idx_cnt].section_id
     SET hpref = uar_prefcreateinstance(0)
     IF (hpref=0)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefCreateInstance() failed.")
      RETURN(0)
     ENDIF
     SET prefstat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
     IF (prefstat != 1)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo(
       "BatchLoadPreferencesForContext - uar_PrefAddContext() for 'default/system' context failed.")
      RETURN(0)
     ENDIF
     IF (contextcd != 0)
      SET prefstat = uar_prefaddcontext(hpref,nullterm(contextname),nullterm(cnvtstring(contextcd,64,
         2)))
      IF (prefstat != 1)
       CALL uar_prefdestroyinstance(hpref)
       CALL echo(build2("BatchLoadPreferencesForContext - uar_PrefAddContext() for '",contextname,"/",
         contextcd,"' context failed."))
       RETURN(0)
      ENDIF
     ENDIF
     SET prefstat = uar_prefsetsection(hpref,nullterm(section))
     IF (prefstat != 1)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefSetSection() for '",section,
       "' section failed.")
      RETURN(0)
     ENDIF
     SET hgroup = uar_prefcreategroup()
     IF (hgroup=0)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefCreateGroup() failed.")
      RETURN(0)
     ENDIF
     SET prefstat = uar_prefsetgroupname(hgroup,nullterm(section_id))
     IF (prefstat != 1)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefSetGroupName() for '",section_id,
       "' section_id failed.")
      RETURN(0)
     ENDIF
     SET prefstat = uar_prefaddgroup(hpref,hgroup)
     IF (prefstat != 1)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefAddGroup() failed.")
      RETURN(0)
     ENDIF
     SET prefstat = uar_prefperform(hpref)
     IF (prefstat != 1)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL echo("BatchLoadPreferencesForContext - uar_PrefPerform() failed.")
      RETURN(0)
     ENDIF
     SET batch_load_path_list->list[idx_cnt].pref_handle = hpref
     CALL uar_prefdestroygroup(hgroup)
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (retrievepreference(preference_idx=i4) =vc)
   DECLARE pref_handle = i4 WITH private, noconstant(0)
   DECLARE idx_cnt = i4 WITH private, noconstant(0)
   DECLARE hsection = i4 WITH private, noconstant(0)
   DECLARE hgroup = i4 WITH private, noconstant(0)
   DECLARE prev_hgroup = i4 WITH private, noconstant(0)
   SET pref_handle = batch_load_path_list->list[pref_list->list[preference_idx].path_idx].pref_handle
   IF (pref_handle=0)
    CALL echo("RetrievePreference - pref_handle is invalid.")
    RETURN("Unknown")
   ENDIF
   SET hsection = uar_prefgetsectionbyname(pref_handle,nullterm(pref_list->list[preference_idx].
     section))
   IF (hsection=0)
    CALL echo(build2("RetrievePreference - uar_PrefGetSectionByName() failed for '",nullterm(
       pref_list->list[preference_idx].section),"'"))
    RETURN("Unknown")
   ENDIF
   SET hgroup = uar_prefgetgroupbyname(hsection,nullterm(pref_list->list[preference_idx].section_id))
   IF (hgroup=0)
    CALL echo(build2("RetrievePreference - uar_PrefGetGroupByName() failed for '",nullterm(pref_list
       ->list[preference_idx].section_id),"'"))
    CALL uar_prefdestroysection(hsection)
    RETURN("Unknown")
   ENDIF
   FOR (idx_cnt = 1 TO size(pref_list->list[preference_idx].subgroups,5))
     SET prev_hgroup = hgroup
     SET hgroup = getsubgroupbyname(hgroup,pref_list->list[preference_idx].subgroups[idx_cnt].
      subgroup_name)
     CALL uar_prefdestroygroup(prev_hgroup)
     IF (hgroup=0)
      CALL echo(build2("RetrievePreference - GetSubGroupByName() failed for '",pref_list->list[
        preference_idx].subgroups[idx_cnt].subgroup_name,"'"))
      CALL uar_prefdestroysection(hsection)
      RETURN("Unknown")
     ENDIF
   ENDFOR
   DECLARE result = vc WITH constant(getpreferencevalue(hgroup,pref_list->list[preference_idx].
     pref_entry))
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   RETURN(result)
 END ;Subroutine
 SUBROUTINE (getpreferencevalue(hgroup=i4,entry=vc) =vc)
   DECLARE prefstat = i4 WITH private, noconstant(0)
   DECLARE entryname = c255 WITH private, noconstant("")
   DECLARE len = i4 WITH private, noconstant(255)
   DECLARE hentry = i4 WITH private, noconstant(0)
   DECLARE entrycnt = i4 WITH private, noconstant(0)
   SET prefstat = uar_prefgetgroupentrycount(hgroup,entrycnt)
   IF (prefstat != 1)
    CALL echo("GetPreferenceValue - uar_PrefGetGroupEntryCount() failed.")
    RETURN("Unknown")
   ENDIF
   DECLARE idxentry = i4 WITH noconstant(0)
   FOR (idxentry = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hgroup,idxentry)
     IF (hentry=0)
      CALL echo("GetPreferenceValue - uar_PrefGetGroupEntry() failed.")
      RETURN("Unknown")
     ENDIF
     SET len = 255
     SET entryname = fillstring(255,"")
     SET prefstat = uar_prefgetentryname(hentry,entryname,len)
     IF (prefstat=1
      AND nullterm(entryname)=entry)
      DECLARE attrcnt = i4 WITH noconstant(0)
      SET prefstat = uar_prefgetentryattrcount(hentry,attrcnt)
      DECLARE idxattr = i4 WITH noconstant(0)
      FOR (idxattr = 0 TO (attrcnt - 1))
        DECLARE hattr = i4 WITH noconstant(0)
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        IF (hattr=0)
         CALL echo("GetPreferenceValue - uar_PrefGetEntryAttr() failed.")
         RETURN("Unknown")
        ENDIF
        IF (hattr != 0)
         SET len = 255
         DECLARE attrname = c255 WITH noconstant("")
         SET prefstat = uar_prefgetattrname(hattr,attrname,len)
         IF (prefstat=1
          AND trim(attrname)="prefvalue")
          SET len = 255
          DECLARE val = c255 WITH noconstant("")
          SET prefstat = uar_prefgetattrval(hattr,val,len,0)
          IF (prefstat != 1)
           CALL echo("GetPreferenceValue - uar_PrefGetAttrVal() failed.")
           RETURN("Unknown")
          ENDIF
          RETURN(trim(val))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN("Unknown")
 END ;Subroutine
 SUBROUTINE (getsubgroupbyname(hgroup=i4,subgrouptofind=vc) =i4)
   DECLARE entrycnt = i4 WITH private, noconstant(0)
   DECLARE idxsubgroup = i4 WITH private, noconstant(0)
   DECLARE hsubgroup = i4 WITH private, noconstant(0)
   DECLARE subgroupname = c255 WITH private, noconstant("")
   DECLARE strlen = i4 WITH private, constant(255)
   DECLARE prefstat = i4 WITH private, noconstant(0)
   SET prefstat = uar_prefgetsubgroupcount(hgroup,entrycnt)
   FOR (idxsubgroup = 0 TO (entrycnt - 1))
     SET hsubgroup = uar_prefgetsubgroup(hgroup,idxsubgroup)
     IF (hsubgroup=0)
      CALL echo("GetSubGroupByName - uar_PrefGetSubGroup() failed.")
      RETURN(0)
     ENDIF
     SET subgroupname = fillstring(255,"")
     SET prefstat = uar_prefgetgroupname(hsubgroup,subgroupname,strlen)
     IF (prefstat != 0
      AND nullterm(subgroupname)=subgrouptofind)
      RETURN(hsubgroup)
     ENDIF
     CALL uar_prefdestroygroup(hsubgroup)
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (iscapabilityactive(pref_entry=vc,pref_value=vc) =i1)
  IF (pref_entry="enhanceddetailstab"
   AND ((pref_value="1") OR (pref_value="2")) )
   RETURN(1)
  ELSEIF (pref_entry="allowdischargereportmedsrec"
   AND ((pref_value="2") OR (pref_value="3")) )
   RETURN(1)
  ELSEIF (pref_entry="medicationhistoryconnectsurvey"
   AND pref_value="1")
   RETURN(1)
  ELSEIF (pref_entry="displaydoseadjustment"
   AND pref_value="1")
   RETURN(1)
  ELSEIF (pref_entry="createmedsrecsupplyreview"
   AND ((pref_value="1") OR (pref_value="2")) )
   RETURN(1)
  ELSEIF (pref_entry="displaycost"
   AND pref_value="1")
   RETURN(1)
  ELSEIF (pref_entry="pbsdefault"
   AND pref_value="1")
   RETURN(1)
  ELSEIF (pref_entry="pbsvenue"
   AND ((pref_value="1") OR (((pref_value="2") OR (pref_value="3")) )) )
   RETURN(1)
  ELSEIF (pref_entry="enablemetricdosing"
   AND pref_value="1")
   RETURN(1)
  ELSEIF (pref_entry="pbsorderdetailsdefault"
   AND pref_value="1")
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 DECLARE script_version = vc WITH private, noconstant("")
 SET script_version = "MOD 007 SJ049730 02/13/18"
END GO
