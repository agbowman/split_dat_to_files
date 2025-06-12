CREATE PROGRAM cp_get_past_medical_history:dba
 SET modify = nopredeclare
 RECORD print(
   1 problem[*]
     2 display = vc
     2 wrapcnt = i4
     2 wrap[*]
       3 line = vc
     2 comments[*]
       3 value = vc
       3 wrapcnt = i4
       3 wrap[*]
         4 line = vc
 )
 RECORD includenom(
   1 size = i4
   1 exceptions[*]
     2 id = f8
 )
 RECORD includeclass(
   1 size = i4
   1 exceptions[*]
     2 type_cd = f8
 )
 DECLARE cleanupcrm(dummy) = null
 DECLARE happlication = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH public, noconstant(0)
 DECLARE application = i4 WITH protect, noconstant(600005)
 SUBROUTINE (setupcrm(itasknumber=i4,irequestnumber=i4) =i4)
   IF (uar_crmbeginapp(application,happlication) != 0)
    CALL echo("Unable to create an application handle")
    RETURN(0)
   ENDIF
   IF (uar_crmbegintask(happlication,itasknumber,htask) != 0)
    CALL echo(build("Unable to create a task handle",itasknumber))
    RETURN(0)
   ENDIF
   IF (uar_crmbeginreq(htask,0,irequestnumber,hstep) != 0)
    CALL echo(build("Unable to create a step handle",irequestnumber))
    RETURN(0)
   ENDIF
   SET hrequest = uar_crmgetrequest(hstep)
   IF (hrequest <= 0)
    CALL echo(build("Unable to create a request handle",irequestnumber))
    RETURN(0)
   ENDIF
   RETURN(hrequest)
 END ;Subroutine
 SUBROUTINE cleanupcrm(dummy)
   IF (hstep > 0)
    CALL uar_crmendreq(hstep)
    SET hstep = 0
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
    SET htask = 0
   ENDIF
   IF (happlication > 0)
    CALL uar_crmendapp(happlication)
    SET happlication = 0
   ENDIF
 END ;Subroutine
 DECLARE problem_access_sharing = i4 WITH protect, constant(2)
 DECLARE bhasaccessright = i2 WITH protect, noconstant(0)
 DECLARE iorganizationindex = i4 WITH protect, noconstant(0)
 DECLARE task_demographics = i4 WITH protect, noconstant(961010)
 DECLARE request_pco_get_prsnl_override = i4 WITH protect, noconstant(969696)
 DECLARE task_query_prsnl_org_info = i4 WITH protect, noconstant(966800)
 DECLARE request_pco_get_prsnl_orgs = i4 WITH protect, noconstant(966800)
 RECORD organization_list(
   1 has_all_access = i2
   1 organizations[*]
     2 organization_id = f8
 )
 SUBROUTINE (initializeorganizationdata(dpersonid=f8,iorganizationsetattributebits=i4,requestprsnlid=
  f8) =null)
   SET organization_list->has_all_access = 0
   CALL loadorganizationsecurityoverride(dpersonid,requestprsnlid)
   CALL cleanupcrm(0)
   IF ((organization_list->has_all_access=0))
    CALL loadorganizations(iorganizationsetattributebits,requestprsnlid)
    CALL cleanupcrm(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (hasaccessright(iorganizationid=f8) =i2)
   SET bhasaccessright = 0
   IF ((organization_list->has_all_access != 0))
    SET bhasaccessright = 1
   ELSE
    SET inumberoforganizations = size(organization_list->organizations,5)
    SET ifoundindex = locateval(iorganizationindex,1,inumberoforganizations,iorganizationid,
     organization_list->organizations[iorganizationindex].organization_id)
    IF (ifoundindex != 0)
     SET bhasaccessright = 1
    ENDIF
   ENDIF
   RETURN(bhasaccessright)
 END ;Subroutine
 SUBROUTINE (loadorganizationsecurityoverride(dpersonid=f8,requestprsnlid=f8) =null)
   SET hrequest = setupcrm(task_demographics,request_pco_get_prsnl_override)
   IF (hrequest <= 0)
    RETURN
   ENDIF
   SET istat = uar_srvsetdouble(hrequest,"prsnl_id",requestprsnlid)
   SET istat = uar_srvsetdouble(hrequest,"person_id",dpersonid)
   IF (uar_crmperform(hstep) != 0)
    CALL echo("Unable to perform the request")
    RETURN
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF (hreply <= 0)
    CALL echo("Unable to obtain the reply")
    RETURN
   ENDIF
   SET borganizationsecurityoverride = uar_srvgetshort(hreply,"OVERRIDE_IND")
   IF (borganizationsecurityoverride != 0)
    SET organization_list->has_all_access = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadorganizations(iorganizationsetattributebits=i4,requestprsnlid=f8) =null)
   SET hrequest = setupcrm(task_query_prsnl_org_info,request_pco_get_prsnl_orgs)
   IF (hrequest <= 0)
    RETURN
   ENDIF
   SET istat = uar_srvsetdouble(hrequest,"prsnl_id",requestprsnlid)
   SET istat = uar_srvsetshort(hrequest,"load_name_loc_ind",1)
   IF (uar_crmperform(hstep) != 0)
    CALL echo("Unable to perform the request")
    RETURN
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF (hreply <= 0)
    CALL echo("Unable to obtain the reply")
    RETURN
   ENDIF
   CALL unpackorganizations(hreply,iorganizationsetattributebits)
 END ;Subroutine
 SUBROUTINE (unpackorganizations(hreply=i4,iorganizationsetattributebits=i4) =null)
   SET bpersonorganizationsecurity = uar_srvgetshort(hreply,"PERSON_ORG_SECURITY_ON")
   IF (bpersonorganizationsecurity=0)
    SET organization_list->has_all_access = 1
    RETURN
   ENDIF
   SET iorganizationindex = 0
   SET iindex = 1
   SET itotal = 0
   SET iorganizationcount = uar_srvgetitemcount(hreply,"ORG")
   SET itotal = iorganizationcount
   SET stat = alterlist(organization_list->organizations,itotal)
   FOR (iorganizationindex = 0 TO (iorganizationcount - 1))
     SET horganizationitem = uar_srvgetitem(hreply,"ORG",iorganizationindex)
     SET organization_list->organizations[iindex].organization_id = uar_srvgetdouble(
      horganizationitem,"ORGANIZATION_ID")
     SET iindex += 1
   ENDFOR
   SET iorganizationsetindex = 0
   SET iorganizationsetcount = uar_srvgetitemcount(hreply,"ORG_SET")
   FOR (iorganizationsetindex = 0 TO (iorganizationsetcount - 1))
     SET horganizationsetitem = uar_srvgetitem(hreply,"ORG_SET",iorganizationsetindex)
     SET isourceorganizationsetaccessright = uar_srvgetlong(horganizationsetitem,"ACCESS_PRIVS")
     IF (band(isourceorganizationsetaccessright,iorganizationsetattributebits) > 0)
      SET iorganizationcount = uar_srvgetitemcount(horganizationsetitem,"ORG_LIST")
      SET itotal += iorganizationcount
      SET stat = alterlist(organization_list->organizations,itotal)
      FOR (iorganizationindex = 0 TO (iorganizationcount - 1))
        SET horganizationitem = uar_srvgetitem(horganizationsetitem,"ORG_LIST",iorganizationindex)
        SET organization_list->organizations[iindex].organization_id = uar_srvgetdouble(
         horganizationitem,"ORGANIZATION_ID")
        SET iindex += 1
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
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
 )
 SET reply->status_data.status = "F"
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
   1 scomment = vc
   1 sage = vc
   1 sat = vc
   1 sonset = vc
   1 sdate = vc
   1 sresolved = vc
   1 sresponsible = vc
   1 sprovider = vc
   1 syears = vc
   1 sdays = vc
   1 smonths = vc
   1 sweeks = vc
   1 sweek = vc
   1 sof = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->scomment = trim(uar_i18ngetmessage(i18nhandle,"COMMENT","Comment"))
   SET captions->sage = trim(uar_i18ngetmessage(i18nhandle,"AGE","Age"))
   SET captions->sat = trim(uar_i18ngetmessage(i18nhandle,"AT","at"))
   SET captions->sonset = trim(uar_i18ngetmessage(i18nhandle,"ONSET","Onset"))
   SET captions->sdate = trim(uar_i18ngetmessage(i18nhandle,"DATE","Date"))
   SET captions->sresolved = trim(uar_i18ngetmessage(i18nhandle,"RESOLVED","Resolved"))
   SET captions->sresponsible = trim(uar_i18ngetmessage(i18nhandle,"RESPONSIBLE","Responsible"))
   SET captions->sprovider = trim(uar_i18ngetmessage(i18nhandle,"PROVIDER","Provider"))
   SET captions->syears = trim(uar_i18ngetmessage(i18nhandle,"YEARS","Years"))
   SET captions->sdays = trim(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
   SET captions->smonths = trim(uar_i18ngetmessage(i18nhandle,"MONTHS","Months"))
   SET captions->sweeks = trim(uar_i18ngetmessage(i18nhandle,"WEEKS","Weeks"))
   SET captions->sweek = trim(uar_i18ngetmessage(i18nhandle,"WEEK","Week"))
   SET captions->sof = trim(uar_i18ngetmessage(i18nhandle,"OF","of"))
 END ;Subroutine
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 SUBROUTINE parsetext(stext,nmax_length)
   DECLARE lf = vc WITH protect, noconstant(concat(char(13),char(10)))
   DECLARE l = i4 WITH protect, noconstant(0)
   DECLARE h = i4 WITH protect, noconstant(0)
   DECLARE cr = i4 WITH protect, noconstant(0)
   DECLARE length = i4 WITH protect, noconstant(0)
   DECLARE check_blob = c32000 WITH protect, noconstant(fillstring(32000," "))
   DECLARE max_length = i4 WITH protect, noconstant(0)
   DECLARE ntab = i4 WITH protect, noconstant(5)
   DECLARE stempstring = c5 WITH protect, noconstant(fillstring(5," "))
   DECLARE c = i4 WITH noconstant(0)
   SET check_blob = stext
   SET max_length = nmax_length
   SET check_blob = concat(trim(check_blob),lf)
   SET blob->cnt = 0
   SET cr = findstring(lf,check_blob)
   SET length = textlen(check_blob)
   WHILE (cr > 0)
     SET blob->line = substring(1,(cr - 1),check_blob)
     SET check_blob = substring((cr+ 2),(length - (cr+ 2)),check_blob)
     SET blob->cnt += 1
     SET stat = alterlist(blob->qual,blob->cnt)
     SET blob->qual[blob->cnt].line = trim(blob->line)
     SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
     SET cr = findstring(lf,check_blob)
   ENDWHILE
   FOR (j = 1 TO blob->cnt)
     WHILE ((blob->qual[j].sze > max_length))
       SET h = l
       SET c = max_length
       WHILE (c > 0)
        IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
         SET l += 1
         SET stat = alterlist(pt->lns,l)
         IF (l=1)
          SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
          SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
          SET max_length = (nmax_length - ntab)
          SET c = max_length
         ELSE
          SET pt->lns[l].line = build2(stempstring,substring(1,c,blob->qual[j].line))
          SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
         ENDIF
         SET c = 1
        ENDIF
        SET c -= 1
       ENDWHILE
       IF (h=l)
        SET l += 1
        SET stat = alterlist(pt->lns,l)
        IF (l=1)
         SET pt->lns[l].line = substring(1,max_length,blob->qual[j].line)
         SET blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
          qual[j].line)
         SET max_length = (nmax_length - ntab)
        ELSE
         SET pt->lns[l].line = build2(stempstring,substring(1,max_length,blob->qual[j].line))
         SET blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
          qual[j].line)
        ENDIF
       ENDIF
       SET blob->qual[j].sze = size(trim(blob->qual[j].line))
     ENDWHILE
     SET l += 1
     SET stat = alterlist(pt->lns,l)
     IF (l=1)
      SET max_length = (nmax_length - ntab)
      SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
     ELSE
      SET pt->lns[l].line = build2(stempstring,substring(1,blob->qual[j].sze,blob->qual[j].line))
      CALL echo(build2(stempstring,substring(1,blob->qual[j].sze,blob->qual[j].line)))
     ENDIF
     SET pt->line_cnt = l
   ENDFOR
 END ;Subroutine
 RECORD data(
   1 person_org_sec_on = i2
   1 problem[*]
     2 problem_instance_id = f8
     2 problem_id = f8
     2 nomenclature_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 annotated_display = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_mean = c12
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 classification_disp = c40
     2 classification_mean = c12
     2 confirmation_status_cd = f8
     2 confirmation_status_disp = c40
     2 confirmation_status_mean = c12
     2 qualifier_cd = f8
     2 qualifier_disp = c40
     2 qualifier_mean = c12
     2 life_cycle_status_cd = f8
     2 life_cycle_status_disp = c40
     2 life_cycle_status_mean = c12
     2 life_cycle_dt_tm = dq8
     2 persistence_cd = f8
     2 persistence_disp = c40
     2 persistence_mean = c12
     2 certainty_cd = f8
     2 certainty_disp = c40
     2 certainty_mean = c12
     2 ranking_cd = f8
     2 ranking_disp = c40
     2 ranking_mean = c12
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_disp = c40
     2 onset_dt_mean = c12
     2 onset_dt_tm = dq8
     2 course_cd = f8
     2 course_disp = c40
     2 course_mean = c12
     2 severity_class_cd = f8
     2 severity_class_disp = c40
     2 severity_class_mean = c12
     2 severity_cd = f8
     2 severity_disp = c40
     2 severity_mean = c12
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 prognosis_disp = c40
     2 prognosis_mean = c12
     2 person_aware_cd = f8
     2 person_aware_disp = c40
     2 person_aware_mean = c12
     2 family_aware_cd = f8
     2 family_aware_disp = c40
     2 family_aware_mean = c12
     2 person_aware_prognosis_cd = f8
     2 person_aware_prognosis_disp = c40
     2 person_aware_prognosis_mean = c12
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_precision_disp = c40
     2 status_upt_precision_mean = c12
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 cancel_reason_mean = c12
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_mean = c12
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 recorder_prsnl_id = f8
     2 recorder_prsnl_name = vc
     2 concept_cki = vc
     2 updt_id = f8
     2 updt_name_full_formatted = vc
     2 problem_discipline[*]
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 management_discipline_disp = c40
       3 management_discipline_mean = c12
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 name_full_formatted = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc[*]
       3 group_sequence = i2
       3 group[*]
         4 sequence = i2
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 source_string = vc
     2 problem_prsnl[*]
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 problem_prsnl_full_name = vc
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_reltn_disp = c40
       3 problem_reltn_mean = c12
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 problem_action_dt_tm = dq8
     2 problem_type_flag = i4
     2 show_in_pm_history_ind = i2
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 originating_source_string = vc
     2 onset_tz = i4
     2 originating_active_ind = i2
     2 originating_end_effective_dt_tm = dq8
     2 originating_source_vocab_cd = f8
     2 active_status_prsnl_id = f8
     2 active_prsnl_name_ful_formatted = vc
   1 related_problem_list[*]
     2 nomen_entity_reltn_id = f8
     2 parent_entity_id = f8
     2 parent_nomen_id = f8
     2 parent_source_string = vc
     2 parent_ftdesc = vc
     2 child_entity_id = f8
     2 child_nomen_id = f8
     2 child_source_string = vc
     2 child_ftdesc = vc
     2 reltn_subtype_cd = f8
     2 reltn_subtype_disp = vc
     2 reltn_subtype_mean = c12
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE numrows = i4 WITH noconstant(0)
 DECLARE numlines = i4 WITH noconstant(0)
 DECLARE pagevar = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE ln = i4 WITH noconstant(0)
 DECLARE cnodata = c1 WITH noconstant("Y")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE requestprsnlid = f8 WITH noconstant(0.0)
 DECLARE nage = i4 WITH protect, noconstant(0)
 DECLARE nmonth = i4 WITH protect, noconstant(0)
 DECLARE exceptioncnt = i4 WITH noconstant(0)
 DECLARE loginfocnt = i4 WITH noconstant(0)
 DECLARE dummyvoid = i2 WITH constant(0)
 DECLARE debug = i2 WITH noconstant(0)
 IF ((request->scope_flag=777))
  SET debug = 1
 ENDIF
 DECLARE viewproblem_cd = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWPROB"))
 DECLARE viewproblemitem_cd = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWPROBNOM"))
 DECLARE unknown_cd = f8 WITH constant(uar_get_code_by("MEANING",25320,"UNKNOWN"))
 DECLARE resolved_cd = f8 WITH constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE stime = vc WITH protect
 IF ((request->chart_request_id > 0.0))
  CALL fetchrequestprsnlid(dummyvoid)
 ELSE
  CALL report_failure("UNKNOWN","F","CP_GET_PAST_MEDICAL_HISTORY","chart request id is zero")
  GO TO exit_script
 ENDIF
 CALL initializeorganizationdata(request->person_id,problem_access_sharing,requestprsnlid)
 CALL fillcaptions(dummyvoid)
 CALL fetchdata(dummyvoid)
 CALL parsedata(dummyvoid)
 CALL formatreport(dummyvoid)
 SUBROUTINE (fetchrequestprsnlid(dummyvar=i2) =null)
   SELECT INTO "nl:"
    c.chart_request_id, c.request_prsnl_id
    FROM chart_request c
    WHERE (c.chart_request_id=request->chart_request_id)
    DETAIL
     requestprsnlid = c.request_prsnl_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (fetchdata(dummyvar=i2) =null)
   RECORD get_print_data(
     1 person_id = f8
     1 life_cycle_status_flag = i4
   )
   SET get_print_data->person_id = request->person_id
   SET get_print_data->life_cycle_status_flag = 3
   IF (debug=1)
    CALL echorecord(get_print_data)
   ENDIF
   EXECUTE kia_get_problem_list  WITH replace("REQUEST","GET_PRINT_DATA"), replace("REPLY","DATA")
   IF ((data->status_data.status="F"))
    SET stat = alterlist(reply->log_info,1)
    SET reply->log_info[i].log_level = 1
    SET reply->log_info[i].log_message = "Call to kia_get_problem_list failed"
    SET cfailed = "T"
    CALL report_failure("EXECUTE","F","CP_GET_PAST_MEDICAL_HISTORY",
     "Call to kia_get_problem_list failed")
    FOR (errcnt = 1 TO value(size(reply->status_data.subeventstatus,5)))
      CALL report_failure(data->status_data.subeventstatus[errcnt].operationname,data->status_data.
       subeventstatus[errcnt].operationstatus,data->status_data.subeventstatus[errcnt].
       targetobjectname,data->status_data.subeventstatus[errcnt].targetobjectvalue)
    ENDFOR
   ENDIF
   IF (debug=1)
    CALL echorecord(data)
   ENDIF
   IF (cfailed="T")
    GO TO exit_script
   ELSE
    IF (value(size(data->problem,5)) > 0)
     SET cnodata = "N"
    ELSE
     GO TO exit_script
    ENDIF
   ENDIF
   CALL processprivileges(dummyvoid)
   IF (debug=1)
    CALL echorecord(includeclass)
    CALL echorecord(includenom)
   ENDIF
 END ;Subroutine
 SUBROUTINE (processprivileges(dummyvar=i2) =null)
  IF (validate(request->privileges) <= 0)
   RETURN
  ENDIF
  FOR (i = 1 TO value(size(request->privileges,5)))
    IF ((request->privileges[i].privilege_cd=viewproblem_cd)
     AND value(size(request->privileges[i].default,5)) > 0)
     SET exceptioncnt = size(request->privileges[i].default[1].exceptions,5)
     IF ((request->privileges[i].default[1].granted_ind=1))
      IF (exceptioncnt > 0)
       SET includeclass->size = size(data->problem,5)
       SET stat = alterlist(includeclass->exceptions,includeclass->size)
       SET y = 0
       FOR (j = 1 TO includeclass->size)
         SET exclude = 0
         FOR (x = 1 TO exceptioncnt)
           IF ((data->problem[j].classification_cd=request->privileges[i].default[1].exceptions[x].id
           ))
            SET exclude = 1
           ENDIF
         ENDFOR
         IF (exclude=0)
          SET y += 1
          SET includeclass->exceptions[y].t = data->problem[j].classification_cd
         ENDIF
       ENDFOR
       SET includeclass->size = y
       SET stat = alterlist(includeclass->exceptions,includeclass->size)
       IF ((includeclass->size=0))
        SET cnodata = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSE
      IF (exceptioncnt < 1)
       SET cnodata = "Y"
       GO TO exit_script
      ENDIF
      SET stat = alterlist(includeclass->exceptions,exceptioncnt)
      FOR (j = 1 TO exceptioncnt)
        SET includeclass->exceptions[j].type_cd = request->privileges[i].default[1].exceptions[j].id
      ENDFOR
      SET includeclass->size = exceptioncnt
     ENDIF
    ELSEIF ((request->privileges[i].privilege_cd=viewproblemitem_cd)
     AND value(size(request->privileges[i].default,5)) > 0)
     SET exceptioncnt = size(request->privileges[i].default[1].exceptions,5)
     IF ((request->privileges[i].default[1].granted_ind=1))
      IF (exceptioncnt > 0)
       SET includenom->size = size(data->problem,5)
       SET stat = alterlist(includenom->exceptions,includenom->size)
       SET y = 0
       FOR (j = 1 TO includenom->size)
         SET exclude = 0
         FOR (x = 1 TO exceptioncnt)
           IF ((data->problem[j].nomenclature_id=request->privileges[i].default[1].exceptions[x].id))
            SET exclude = 1
           ENDIF
         ENDFOR
         IF (exclude=0)
          SET y += 1
          SET includenom->exceptions[y].id = data->problem[j].nomenclature_id
         ENDIF
       ENDFOR
       SET includenom->size = y
       SET stat = alterlist(includenom->exceptions,includenom->size)
       IF ((includenom->size=0))
        SET cnodata = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSE
      IF (exceptioncnt < 1)
       SET cnodata = "Y"
       GO TO exit_script
      ENDIF
      SET stat = alterlist(includenom->exceptions,exceptioncnt)
      FOR (j = 1 TO exceptioncnt)
        SET includenom->exceptions[j].id = request->privileges[i].default[1].exceptions[j].id
      ENDFOR
      SET includenom->size = exceptioncnt
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE (calculateage(birthdate=q8,currentdate=q8,precision_cd=f8,dateflag=i2,sage=vc(ref)) =null
  )
   SET nage = (datetimepart(currentdate,1) - datetimepart(birthdate,1))
   SET nmonth = (datetimepart(currentdate,2) - datetimepart(birthdate,2))
   IF (precision_cd=unknown_cd)
    SET sage = trim(uar_get_code_display(precision_cd),3)
   ELSE
    IF (((nage >= 2) OR (dateflag=2)) )
     SET stempage = build(nage)
     IF (precision_cd > 0)
      SET sage = build2(trim(uar_get_code_display(precision_cd),3)," ",trim(stempage)," ",captions->
       syears)
     ELSE
      SET sage = build2(trim(stempage)," ",captions->syears)
     ENDIF
    ELSE
     IF (((nmonth >= 2) OR (dateflag=1)) )
      SET nmonth += (nage * 12)
      SET stempage = build(nmonth)
      IF (precision_cd > 0)
       SET sage = build2(trim(uar_get_code_display(precision_cd),3)," ",trim(stempage)," ",captions->
        smonths)
      ELSE
       SET sage = build2(trim(stempage)," ",captions->smonths)
      ENDIF
     ELSE
      SET nage = datetimediff(currentdate,birthdate,2)
      IF (((nage >= 2) OR (dateflag=3)) )
       SET stempage = build(nage)
       IF (precision_cd > 0)
        SET sage = build2(trim(uar_get_code_display(precision_cd),3)," ",trim(stempage)," ",captions
         ->sweeks)
       ELSE
        SET sage = build2(trim(stempage)," ",captions->sweeks)
       ENDIF
      ELSE
       SET nage = datetimediff(currentdate,birthdate)
       SET stempage = build(nage)
       IF (precision_cd > 0)
        SET sage = build2(trim(uar_get_code_display(precision_cd),3)," ",trim(stempage)," ",captions
         ->sdays)
       ELSE
        SET sage = build2(trim(stempage)," ",captions->sdays)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (processdate(currentdate=q8,precision_cd=f8,dateflag=i2,sdate=vc(ref)) =null)
   IF (precision_cd=unknown_cd)
    SET sdate = trim(uar_get_code_display(precision_cd),3)
   ELSEIF (dateflag=0)
    IF (precision_cd > 0)
     SET sdate = build2(trim(uar_get_code_display(precision_cd),3)," ",format(cnvtdatetime(
        currentdate),"MM/DD/YYYY;;D"))
    ELSE
     SET sdate = format(cnvtdatetime(currentdate),"MM/DD/YYYY;;D")
    ENDIF
   ELSEIF (dateflag=1)
    IF (precision_cd > 0)
     SET sdate = build2(trim(uar_get_code_display(precision_cd),3)," ",format(cnvtdatetime(
        currentdate),"MM/YYYY;;D"))
    ELSE
     SET sdate = format(cnvtdatetime(currentdate),"MM/YYYY;;D")
    ENDIF
   ELSEIF (dateflag=2)
    IF (precision_cd > 0)
     SET sdate = build2(trim(uar_get_code_display(precision_cd),3)," ",format(cnvtdatetime(
        currentdate),"YYYY;;D"))
    ELSE
     SET sdate = format(cnvtdatetime(currentdate),"YYYY;;D")
    ENDIF
   ELSEIF (dateflag=3)
    IF (precision_cd > 0)
     SET sdate = build2(trim(uar_get_code_display(precision_cd),3)," ",captions->sweek," ",captions->
      sof,
      " ",format(cnvtdatetime(currentdate),"MM/DD/YYYY;;D"))
    ELSE
     SET sdate = build2(captions->sweek," ",captions->sof," ",format(cnvtdatetime(currentdate),
       "MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (parsedata(dummyvar=i2) =null)
   DECLARE problemcnt = i4 WITH protect, noconstant(0)
   DECLARE commentcnt = i4 WITH protect, noconstant(0)
   DECLARE max_length = i4 WITH noconstant(0)
   DECLARE birthdate = dq8
   RECORD pt(
     1 line_cnt = i2
     1 lns[*]
       2 line = vc
   )
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=request->person_id)
    DETAIL
     birthdate = p.birth_dt_tm
    WITH nocounter
   ;end select
   SELECT
    IF ((includeclass->size > 0)
     AND (includenom->size > 0))
     WHERE (data->problem[d1.seq].show_in_pm_history_ind > 0)
      AND (data->problem[d1.seq].classification_cd=includeclass->exceptions[d2.seq].type_cd)
      AND (data->problem[d1.seq].nomenclature_id=includenom->exceptions[d3.seq].id)
    ELSEIF ((includeclass->size > 0))
     WHERE (data->problem[d1.seq].show_in_pm_history_ind > 0)
      AND (data->problem[d1.seq].classification_cd=includeclass->exceptions[d2.seq].type_cd)
    ELSEIF ((includenom->size > 0))
     WHERE (data->problem[d1.seq].show_in_pm_history_ind > 0)
      AND (data->problem[d1.seq].nomenclature_id=includenom->exceptions[d3.seq].id)
    ELSE
     WHERE (data->problem[d1.seq].show_in_pm_history_ind > 0)
    ENDIF
    INTO "nl:"
    ssourcestring = data->problem[d1.seq].annotated_display
    FROM (dummyt d1  WITH seq = size(data->problem,5)),
     (dummyt d2  WITH seq = includeclass->size),
     (dummyt d3  WITH seq = includenom->size)
    ORDER BY ssourcestring
    HEAD REPORT
     prblmcnt = 0, sage = fillstring(255," "), sdate = fillstring(255," ")
    HEAD ssourcestring
     bhasaccessright = hasaccessright(data->problem[d1.seq].organization_id)
     IF (bhasaccessright != 0)
      prblmcnt += 1
      IF (prblmcnt > size(print->problem,5))
       stat = alterlist(print->problem,(prblmcnt+ 10))
      ENDIF
      print->problem[prblmcnt].display = data->problem[d1.seq].annotated_display
      IF ((data->problem[d1.seq].source_string != "")
       AND (data->problem[d1.seq].source_string != data->problem[d1.seq].annotated_display))
       print->problem[prblmcnt].display = concat(print->problem[prblmcnt].display," (",data->problem[
        d1.seq].source_string,")")
      ENDIF
      IF ((data->problem[d1.seq].life_cycle_status_cd > 0))
       print->problem[prblmcnt].display = concat(print->problem[prblmcnt].display,", ",
        uar_get_code_display(data->problem[d1.seq].life_cycle_status_cd))
      ENDIF
      IF ((((data->problem[d1.seq].onset_dt_tm > 0)) OR ((data->problem[d1.seq].onset_dt_cd=
      unknown_cd))) )
       CALL calculateage(birthdate,data->problem[d1.seq].onset_dt_tm,data->problem[d1.seq].
       onset_dt_cd,data->problem[d1.seq].onset_dt_flag,sage),
       CALL processdate(data->problem[d1.seq].onset_dt_tm,data->problem[d1.seq].onset_dt_cd,data->
       problem[d1.seq].onset_dt_flag,sdate), print->problem[prblmcnt].display = concat(print->
        problem[prblmcnt].display,", ",captions->sage," ",captions->sat,
        " ",captions->sonset,": ",sage),
       print->problem[prblmcnt].display = concat(print->problem[prblmcnt].display,", ",captions->
        sonset," ",captions->sdate,
        ": ",sdate)
      ENDIF
      IF ((data->problem[d1.seq].life_cycle_status_cd=resolved_cd))
       IF ((((data->problem[d1.seq].life_cycle_dt_tm > 0)) OR ((data->problem[d1.seq].
       life_cycle_dt_cd=unknown_cd))) )
        CALL calculateage(birthdate,data->problem[d1.seq].life_cycle_dt_tm,data->problem[d1.seq].
        life_cycle_dt_cd,data->problem[d1.seq].life_cycle_dt_flag,sage),
        CALL processdate(data->problem[d1.seq].life_cycle_dt_tm,data->problem[d1.seq].
        life_cycle_dt_cd,data->problem[d1.seq].life_cycle_dt_flag,sdate), print->problem[prblmcnt].
        display = concat(print->problem[prblmcnt].display,", ",captions->sage," ",captions->sat,
         " ",captions->sresolved,": ",sage),
        print->problem[prblmcnt].display = concat(print->problem[prblmcnt].display,", ",captions->
         sresolved," ",captions->sdate,
         ": ",sdate)
       ENDIF
      ENDIF
      IF ((data->problem[d1.seq].responsible_prsnl_id > 0))
       print->problem[prblmcnt].display = concat(print->problem[prblmcnt].display,", ",captions->
        sresponsible," ",captions->sprovider,
        ": ",data->problem[d1.seq].responsible_prsnl_name)
      ENDIF
      cmtcnt = size(data->problem[d1.seq].problem_comment,5), stat = alterlist(print->problem[
       prblmcnt].comments,cmtcnt)
      FOR (x = 1 TO cmtcnt)
        print->problem[prblmcnt].comments[x].value = concat(captions->scomment,": ",data->problem[d1
         .seq].problem_comment[x].problem_comment," (",format(cnvtdatetime(data->problem[d1.seq].
           problem_comment[x].comment_dt_tm),"MM/DD/YYYY;;D"),
         " ",format(data->problem[d1.seq].problem_comment[x].comment_dt_tm,"HH:MM;;S")," - ",data->
         problem[d1.seq].problem_comment[x].name_full_formatted,")")
      ENDFOR
     ENDIF
    FOOT  ssourcestring
     dummy = 0
    FOOT REPORT
     IF (prblmcnt > 0)
      stat = alterlist(print->problem,prblmcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET problemcnt = value(size(print->problem,5))
   IF (problemcnt < 1)
    SET cnodata = "Y"
    GO TO exit_script
   ENDIF
   FOR (i = 1 TO problemcnt)
     SET max_length = 110
     SET pt->line_cnt = 0
     CALL parsetext(print->problem[i].display,max_length)
     SET stat = alterlist(print->problem[i].wrap,pt->line_cnt)
     SET print->problem[i].wrapcnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET print->problem[i].wrap[j].line = pt->lns[j].line
     ENDFOR
     SET commentcnt = value(size(print->problem[i].comments,5))
     FOR (x = 1 TO commentcnt)
       SET max_length = 100
       SET pt->line_cnt = 0
       CALL parsetext(value(print->problem[i].comments[x].value),value(max_length))
       SET stat = alterlist(print->problem[i].comments[x].wrap,pt->line_cnt)
       SET print->problem[i].comments[x].wrapcnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET print->problem[i].comments[x].wrap[j].line = pt->lns[j].line
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debug=1)
    CALL echorecord(print)
   ENDIF
 END ;Subroutine
 SUBROUTINE (formatreport(dummyvar=i2) =null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    DETAIL
     prblmcnt = size(print->problem,5)
     FOR (i = 1 TO prblmcnt)
       wrapcnt = print->problem[i].wrapcnt
       FOR (j = 1 TO wrapcnt)
         col 0, print->problem[i].wrap[j].line, row + 1
       ENDFOR
       cmtcnt = size(print->problem[i].comments,5)
       IF (cmtcnt > 0)
        FOR (x = 1 TO cmtcnt)
         cmtwrapcnt = print->problem[i].comments[x].wrapcnt,
         FOR (y = 1 TO cmtwrapcnt)
           col 10, print->problem[i].comments[x].wrap[y].line, row + 1
         ENDFOR
        ENDFOR
       ENDIF
       row + 1
     ENDFOR
    FOOT PAGE
     numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
     FOR (pagevar = 0 TO numrows)
       ln += 1, reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
       WHILE (done="F")
        nullpos = findstring(char(0),reply->qual[ln].line),
        IF (nullpos > 0)
         stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
        ELSE
         done = "T"
        ENDIF
       ENDWHILE
     ENDFOR
     reply->num_lines = ln
    WITH nocounter, maxcol = 132, maxrow = 10000
   ;end select
 END ;Subroutine
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (cnodata="Y")
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD get_print_data
 FREE RECORD data
 FREE RECORD includenom
 FREE RECORD includeclass
 FREE RECORD blob
 FREE RECORD print
 FREE RECORD captions
 FREE RECORD organization_list
END GO
