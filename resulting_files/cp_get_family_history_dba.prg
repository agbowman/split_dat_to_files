CREATE PROGRAM cp_get_family_history:dba
 RECORD print(
   1 updtstatus = vc
   1 updtstatus_wrapcnt = i2
   1 updtstatus_wrap[*]
     2 line = vc
   1 adopted = vc
   1 unknown = vc
   1 negative = vc
   1 unable_to_obtain = vc
   1 relation[*]
     2 display = vc
     2 wrapcnt = i2
     2 wrap[*]
       3 line = vc
     2 negative = vc
     2 unknown = vc
     2 positive_display = vc
     2 positive_condition[*]
       3 display = vc
       3 wrapcnt = i2
       3 wrap[*]
         4 line = vc
       3 comment[*]
         4 display = vc
         4 wrapcnt = i2
         4 wrap[*]
           5 line = vc
       3 related_display = vc
       3 related_wrapcnt = i2
       3 related_wrap[*]
         4 line = vc
     2 negative_display = vc
     2 negative_condition[*]
       3 display = vc
       3 wrapcnt = i2
       3 wrap[*]
         4 line = vc
   1 incomplete_data_msg = vc
   1 incomplete_data_msg_wrapcnt = i2
   1 incomplete_data_msg_wrap[*]
     2 line = vc
 )
 RECORD date_temp(
   1 dt1 = dq8
 )
 RECORD relatedproblems(
   1 related[*]
     2 fhx_activity_group_id = f8
     2 source_string = vc
     2 fhx_value_flag = i2
 )
 RECORD includenom(
   1 size = i4
   1 exceptions[*]
     2 related_person_id = f8
     2 id = f8
 )
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
   1 slast = vc
   1 supdate = vc
   1 sby = vc
   1 snegative = vc
   1 sunknown = vc
   1 sunable = vc
   1 sto = vc
   1 sobtain = vc
   1 salive = vc
   1 sage = vc
   1 syears = vc
   1 sdays = vc
   1 smonths = vc
   1 sweeks = vc
   1 sdeceased = vc
   1 sat = vc
   1 slowage = vc
   1 scause = vc
   1 sof = vc
   1 sdeath = vc
   1 spatient = vc
   1 sis = vc
   1 sadopted = vc
   1 spositive = vc
   1 sonset = vc
   1 scomment = vc
   1 srelated = vc
   1 sabout = vc
   1 sbefore = vc
   1 safter = vc
   1 sdat = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->slast = trim(uar_i18ngetmessage(i18nhandle,"LAST","Last"))
   SET captions->supdate = trim(uar_i18ngetmessage(i18nhandle,"UPDATE","Update"))
   SET captions->sby = trim(uar_i18ngetmessage(i18nhandle,"BY","by"))
   SET captions->snegative = trim(uar_i18ngetmessage(i18nhandle,"NEGATIVE","Negative"))
   SET captions->sunknown = trim(uar_i18ngetmessage(i18nhandle,"UNKNOWN","Unknown"))
   SET captions->sunable = trim(uar_i18ngetmessage(i18nhandle,"UNABLE","Unable"))
   SET captions->sto = trim(uar_i18ngetmessage(i18nhandle,"TO","to"))
   SET captions->sobtain = trim(uar_i18ngetmessage(i18nhandle,"OBTAIN","Obtain"))
   SET captions->salive = trim(uar_i18ngetmessage(i18nhandle,"ALIVE","Alive"))
   SET captions->sage = trim(uar_i18ngetmessage(i18nhandle,"AGE","Age"))
   SET captions->syears = trim(uar_i18ngetmessage(i18nhandle,"YEARS","Years"))
   SET captions->sdays = trim(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
   SET captions->smonths = trim(uar_i18ngetmessage(i18nhandle,"MONTHS","Months"))
   SET captions->sweeks = trim(uar_i18ngetmessage(i18nhandle,"WEEKS","Weeks"))
   SET captions->syears = trim(uar_i18ngetmessage(i18nhandle,"YEARS","Years"))
   SET captions->sdays = trim(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
   SET captions->smonths = trim(uar_i18ngetmessage(i18nhandle,"MONTHS","Months"))
   SET captions->sdeceased = trim(uar_i18ngetmessage(i18nhandle,"DECEASED","Deceased"))
   SET captions->sat = trim(uar_i18ngetmessage(i18nhandle,"AT","at"))
   SET captions->slowage = trim(uar_i18ngetmessage(i18nhandle,"AGE","age"))
   SET captions->scause = trim(uar_i18ngetmessage(i18nhandle,"CAUSE","Cause"))
   SET captions->sof = trim(uar_i18ngetmessage(i18nhandle,"OF","of"))
   SET captions->sdeath = trim(uar_i18ngetmessage(i18nhandle,"DEATH","Death"))
   SET captions->spatient = trim(uar_i18ngetmessage(i18nhandle,"PATIENT","Patient"))
   SET captions->sis = trim(uar_i18ngetmessage(i18nhandle,"IS","is"))
   SET captions->sadopted = trim(uar_i18ngetmessage(i18nhandle,"ADOPTED","Adopted"))
   SET captions->spositive = trim(uar_i18ngetmessage(i18nhandle,"POSITIVE","Positive"))
   SET captions->sonset = trim(uar_i18ngetmessage(i18nhandle,"ONSET","Onset"))
   SET captions->scomment = trim(uar_i18ngetmessage(i18nhandle,"COMMENT","Comment"))
   SET captions->srelated = trim(uar_i18ngetmessage(i18nhandle,"RELATED","Related"))
   SET captions->sabout = trim(uar_i18ngetmessage(i18nhandle,"ABOUT","About"))
   SET captions->sbefore = trim(uar_i18ngetmessage(i18nhandle,"BEFORE","Before"))
   SET captions->safter = trim(uar_i18ngetmessage(i18nhandle,"AFTER","After"))
   SET captions->sdat = trim(uar_i18ngetmessage(i18nhandle,"DATA",
     "All recorded Family History data on this record is not viewable"))
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
     SET blob->cnt = (blob->cnt+ 1)
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
         SET l = (l+ 1)
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
        SET c = (c - 1)
       ENDWHILE
       IF (h=l)
        SET l = (l+ 1)
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
     SET l = (l+ 1)
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
   1 result_qual[*]
     2 fhx_activity_id = f8
     2 fhx_activity_group_id = f8
     2 person_id = f8
     2 type_mean = c12
     2 fhx_value_flag = i2
     2 related_person_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 onset_age_prec_cd = f8
     2 onset_age = i2
     2 onset_age_unit_cd = f8
     2 life_cycle_status_cd = f8
     2 severity_cd = f8
     2 course_cd = f8
     2 updt_cnt = i4
     2 concept_cki = vc
     2 comment_qual[*]
       3 fhx_long_text_r_id = f8
       3 long_text_id = f8
       3 long_text = vc
       3 comment_prsnl_id = f8
       3 comment_prsnl_full_name = vc
       3 comment_dt_tm = dq8
       3 comment_dt_tm_tz = i4
     2 prsnl_qual[*]
       3 fhx_action_id = f8
       3 prsnl_id = f8
       3 prsnl_full_name = vc
       3 action_type_mean = c12
       3 action_dt_tm = dq8
       3 action_tz = i4
     2 result_reltn_qual[*]
       3 fhx_activity_s_id = f8
       3 fhx_activity_t_id = f8
       3 type_mean = c12
   1 last_updt_prsnl_id = f8
   1 last_updt_prsnl_name = vc
   1 last_updt_dt_tm = dq8
   1 incomplete_data_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD relationdata(
   1 patient_id = f8
   1 relationships[*]
     2 related_person_id = f8
     2 person_reltn_cd = f8
     2 name_first = vc
     2 name_last = vc
     2 gender_cd = f8
     2 birth_dt_tm = dq8
     2 birth_prec_flag = i2
     2 deceased_ind = i2
     2 age_at_death = i4
     2 age_at_death_unit = i2
     2 age_at_death_mod_flag = i2
     2 cause_of_death = vc
     2 priority = i4
 )
 DECLARE numrows = i4 WITH noconstant(0)
 DECLARE numlines = i4 WITH noconstant(0)
 DECLARE pagevar = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE ln = i4 WITH noconstant(0)
 DECLARE size = i4 WITH noconstant(0)
 DECLARE relatedcnt = i4 WITH noconstant(0)
 DECLARE related_size = i4 WITH noconstant(0)
 DECLARE cnodata = c1 WITH noconstant("Y")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE nage = i4 WITH protect, noconstant(0)
 DECLARE nmonth = i4 WITH protect, noconstant(0)
 DECLARE exceptioncnt = i4 WITH noconstant(0)
 DECLARE loginfocnt = i4 WITH noconstant(0)
 DECLARE dummyvoid = i2 WITH constant(0)
 DECLARE debug = i2 WITH noconstant(0)
 IF ((request->scope_flag=777))
  SET debug = 1
 ENDIF
 DECLARE viewfhx_cd = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWFHX"))
 DECLARE mother_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"MOTHER"))
 DECLARE father_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"FATHER"))
 DECLARE sister_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"SISTER"))
 DECLARE brother_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"BROTHER"))
 DECLARE daughter_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"DAUGHTER"))
 DECLARE son_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"SON"))
 DECLARE unknown_cd = f8 WITH constant(uar_get_code_by("MEANING",25320,"UNKNOWN"))
 DECLARE stime = vc WITH protect
 DECLARE processprivileges(dummyvar=i2) = null
 DECLARE fetchdata(dummyvar=i2) = null
 DECLARE parsedata(dummyvar=i2) = null
 DECLARE formatreport(dummyvar=i2) = null
 DECLARE calculateage(birthdate=q8,currentdate=q8,dateflag=i2,sage=vc(ref)) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 CALL fillcaptions(dummyvoid)
 CALL fetchdata(dummyvoid)
 CALL parsedata(dummyvoid)
 CALL formatreport(dummyvoid)
 SUBROUTINE fetchdata(dummyvar)
   DECLARE hpmqueryapp = i4 WITH noconstant(0)
   DECLARE hpmquerytask = i4 WITH noconstant(0)
   DECLARE hpmquerystep = i4 WITH noconstant(0)
   DECLARE hpmreply = i4 WITH noconstant(0)
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE pmqueryappid = i4 WITH protect, constant(3202004)
   DECLARE pmquerytaskid = i4 WITH protect, constant(3202004)
   DECLARE pmqueryreqid = i4 WITH protect, constant(3200300)
   SET iret = uar_crmbeginapp(pmqueryappid,hpmqueryapp)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_app failed for appid =",build(pmqueryappid)))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   SET iret = uar_crmbegintask(hpmqueryapp,pmquerytaskid,hpmquerytask)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_task failed for taskid =",build(pmquerytaskid)))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   SET iret = uar_crmbeginreq(hpmquerytask,"",pmqueryreqid,hpmquerystep)
   IF (iret != 0)
    CALL echo(build2("uar_crm_begin_Request failed for ReqId =",build(pmqueryreqid)))
    SET cfailed = "T"
    GO TO exit_script
   ENDIF
   DECLARE hrequest = i4 WITH private, noconstant(0)
   DECLARE hreply = i4 WITH private, noconstant(0)
   DECLARE hpatientlist = i4 WITH private, noconstant(0)
   SET hrequest = uar_crmgetrequest(hpmquerystep)
   IF (hrequest)
    SET hpatientlist = uar_srvadditem(hrequest,"patients")
    IF (hpatientlist)
     SET srvstat = uar_srvsetdouble(hpatientlist,"patient_id",request->person_id)
    ENDIF
   ENDIF
   CALL echo(build2("Request ",build(pmqueryreqid),"(FamilyHistory)"))
   IF (debug=1)
    SET test = uar_oen_dump_object(hrequest)
   ENDIF
   SET iret = uar_crmperform(hpmquerystep)
   SET hreply = uar_crmgetreply(hpmquerystep)
   CALL echo(build2("Reply ",build(pmqueryreqid),"(FamilyHistory)"))
   IF (debug=1)
    SET test = uar_oen_dump_object(hreply)
   ENDIF
   SET hpatients = uar_srvgetitem(hreply,"patients",0)
   SET relationcnt = uar_srvgetitemcount(hpatients,"relationships")
   SET stat = alterlist(relationdata->relationships,(relationcnt+ 1))
   SET relationdata->patient_id = uar_srvgetdouble(hpatients,"patient_id")
   FOR (j = 1 TO relationcnt)
     SET hrelation = uar_srvgetitem(hpatients,"relationships",(j - 1))
     SET relationdata->relationships[j].related_person_id = uar_srvgetdouble(hrelation,
      "related_person_id")
     SET relationdata->relationships[j].person_reltn_cd = uar_srvgetdouble(hrelation,
      "person_reltn_cd")
     IF ((mother_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 1
     ELSEIF ((father_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 2
     ELSEIF ((sister_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 3
     ELSEIF ((brother_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 4
     ELSEIF ((daughter_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 5
     ELSEIF ((son_cd=relationdata->relationships[j].person_reltn_cd))
      SET relationdata->relationships[j].priority = 6
     ELSE
      SET relationdata->relationships[j].priority = 7
     ENDIF
     SET relationdata->relationships[j].name_first = uar_srvgetstringptr(hrelation,"name_first")
     SET relationdata->relationships[j].name_last = uar_srvgetstringptr(hrelation,"name_last")
     SET stat = uar_srvgetdate2(hrelation,"birth_dt_tm",date_temp)
     SET relationdata->relationships[j].birth_dt_tm = cnvtdatetime(date_temp->dt1)
     SET relationdata->relationships[j].birth_prec_flag = uar_srvgetshort(hrelation,"birth_prec_flag"
      )
     SET relationdata->relationships[j].deceased_ind = uar_srvgetshort(hrelation,"deceased_ind")
     SET relationdata->relationships[j].age_at_death = uar_srvgetlong(hrelation,"age_at_death")
     SET relationdata->relationships[j].age_at_death_unit = uar_srvgetshort(hrelation,
      "age_at_death_unit")
     SET relationdata->relationships[j].age_at_death_mod_flag = uar_srvgetshort(hrelation,
      "age_at_death_mod_flag")
     SET relationdata->relationships[j].cause_of_death = uar_srvgetstringptr(hrelation,
      "cause_of_death")
   ENDFOR
   SET relationdata->relationships[(relationcnt+ 1)].related_person_id = 0.0
   IF (hpmquerystep)
    CALL uar_crmendreq(hpmquerystep)
   ENDIF
   IF (hpmquerytask)
    CALL uar_crmendtask(hpmquerytask)
   ENDIF
   IF (hpmqueryapp)
    CALL uar_crmendapp(hpmqueryapp)
   ENDIF
   RECORD get_print_data(
     1 person_id = f8
     1 prsnl_id = f8
   )
   SET get_print_data->person_id = request->person_id
   SET get_print_data->prsnl_id = reqinfo->updt_id
   IF (debug=1)
    CALL echorecord(get_print_data)
   ENDIF
   EXECUTE kia_get_family_history  WITH replace("REQUEST","GET_PRINT_DATA"), replace("REPLY","DATA")
   IF ((data->status_data.status="F"))
    CALL report_failure("EXECUTE","F","CP_GET_","Call to KIA_GET_FAMILY_HISTORY failed")
    SET stat = alterlist(reply->log_info,1)
    SET reply->log_info[i].log_level = 1
    SET reply->log_info[i].log_message = "Call to KIA_GET_FAMILY_HISTORY failed"
    SET cfailed = "T"
    FOR (errcnt = 1 TO value(size(reply->status_data.subeventstatus,5)))
      CALL report_failure(data->status_data.subeventstatus[errcnt].operationname,data->status_data.
       subeventstatus[errcnt].operationstatus,data->status_data.subeventstatus[errcnt].
       targetobjectname,data->status_data.subeventstatus[errcnt].targetobjectvalue)
    ENDFOR
   ENDIF
   IF (cfailed="T")
    GO TO exit_script
   ELSE
    IF (value(size(data->result_qual,5)) > 0)
     SET cnodata = "N"
    ELSE
     GO TO exit_script
    ENDIF
   ENDIF
   CALL processprivileges(dummyvoid)
   SET size = size(data->result_qual,5)
   SET relatedcnt = 0
   FOR (j = 1 TO size)
    SET related_size = size(data->result_qual[j].result_reltn_qual,5)
    IF (related_size > 0)
     SELECT
      IF ((includenom->size > 0))
       WHERE (data->result_qual[d2.seq].fhx_activity_id=data->result_qual[j].result_reltn_qual[d1.seq
       ].fhx_activity_t_id)
        AND (data->result_qual[d2.seq].nomenclature_id=includenom->exceptions[d3.seq].id)
        AND (data->result_qual[d2.seq].related_person_id=includenom->exceptions[d3.seq].
       related_person_id)
      ELSE
       WHERE (data->result_qual[d2.seq].fhx_activity_id=data->result_qual[j].result_reltn_qual[d1.seq
       ].fhx_activity_t_id)
      ENDIF
      INTO "NL:"
      sourcestring = data->result_qual[d2.seq].source_string
      FROM (dummyt d1  WITH seq = related_size),
       (dummyt d2  WITH seq = size),
       (dummyt d3  WITH seq = includenom->size)
      ORDER BY sourcestring
      DETAIL
       relatedcnt = (relatedcnt+ 1)
       IF (relatedcnt > size(relatedproblems->related,5))
        stat = alterlist(relatedproblems->related,(relatedcnt+ 10))
       ENDIF
       relatedproblems->related[relatedcnt].fhx_activity_group_id = data->result_qual[j].
       fhx_activity_group_id, relatedproblems->related[relatedcnt].fhx_value_flag = data->
       result_qual[d2.seq].fhx_value_flag, relatedproblems->related[relatedcnt].source_string = data
       ->result_qual[d2.seq].source_string,
       data->result_qual[d2.seq].related_person_id = - (1)
      FOOT PAGE
       IF (size(relatedproblems->related,5) > relatedcnt)
        stat = alterlist(relatedproblems->related,relatedcnt)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
   IF (debug=1)
    CALL echorecord(relationdata)
    CALL echorecord(data)
    CALL echorecord(relatedproblems)
    CALL echorecord(includenom)
   ENDIF
 END ;Subroutine
 SUBROUTINE processprivileges(dummyvar)
   DECLARE exclude = i4 WITH protect, noconstant(0)
   IF (validate(request->privileges) <= 0)
    RETURN
   ENDIF
   FOR (i = 1 TO value(size(request->privileges,5)))
     IF ((request->privileges[i].privilege_cd=viewfhx_cd)
      AND value(size(request->privileges[i].default,5)) > 0)
      SET exceptioncnt = size(request->privileges[i].default[1].exceptions,5)
      IF ((request->privileges[i].default[1].granted_ind=1))
       IF (exceptioncnt > 0)
        SET includenom->size = size(data->result_qual,5)
        SET stat = alterlist(includenom->exceptions,includenom->size)
        SET y = 0
        FOR (j = 1 TO includenom->size)
          SET exclude = 0
          FOR (x = 1 TO exceptioncnt)
            IF ((data->result_qual[j].nomenclature_id=request->privileges[i].default[1].exceptions[x]
            .id))
             SET exclude = 1
            ENDIF
          ENDFOR
          IF (exclude=0)
           SET y = (y+ 1)
           SET includenom->exceptions[y].id = data->result_qual[j].nomenclature_id
           SET includenom->exceptions[y].related_person_id = data->result_qual[j].related_person_id
          ENDIF
        ENDFOR
        SET includenom->size = (y+ 1)
        SET stat = alterlist(includenom->exceptions,includenom->size)
        SET includenom->exceptions[includenom->size].id = 0
        SET includenom->exceptions[includenom->size].related_person_id = 0.0
       ENDIF
      ELSE
       IF (exceptioncnt < 1)
        SET cnodata = "Y"
        GO TO exit_script
       ENDIF
       SET includenom->size = size(data->result_qual,5)
       SET stat = alterlist(includenom->exceptions,includenom->size)
       SET y = 0
       FOR (j = 1 TO includenom->size)
         FOR (x = 1 TO exceptioncnt)
           IF ((data->result_qual[j].nomenclature_id=request->privileges[i].default[1].exceptions[x].
           id))
            SET y = (y+ 1)
            SET includenom->exceptions[y].id = data->result_qual[j].nomenclature_id
            SET includenom->exceptions[y].related_person_id = data->result_qual[j].related_person_id
           ENDIF
         ENDFOR
       ENDFOR
       SET includenom->size = (y+ 1)
       SET stat = alterlist(includenom->exceptions,includenom->size)
       SET includenom->exceptions[includenom->size].id = 0
       SET includenom->exceptions[includenom->size].related_person_id = 0.0
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE calculateage(birthdate,currentdate,dateflag,sage)
   SET nage = (datetimepart(currentdate,1) - datetimepart(birthdate,1))
   SET nmonth = (datetimepart(currentdate,2) - datetimepart(birthdate,2))
   IF (((nage >= 2) OR (dateflag=3)) )
    SET stempage = build(nage)
    SET sage = build2(trim(stempage)," ",captions->syears)
   ELSE
    IF (((nmonth >= 2) OR (dateflag=2)) )
     SET nmonth = (nmonth+ (nage * 12))
     SET stempage = build(nmonth)
     SET sage = build2(trim(stempage)," ",captions->smonths)
    ELSE
     SET nage = datetimediff(currentdate,birthdate)
     SET sage = concat(build(nage)," ",captions->sdays)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE parsedata(dummyvar)
   DECLARE relationcnt = i4 WITH protect, noconstant(0)
   DECLARE positivecnt = i4 WITH protect, noconstant(0)
   DECLARE negativecnt = i4 WITH protect, noconstant(0)
   DECLARE commentcnt = i4 WITH protect, noconstant(0)
   DECLARE max_length = i4 WITH noconstant(0)
   DECLARE birthdate = dq8
   RECORD pt(
     1 line_cnt = i2
     1 lns[*]
       2 line = vc
   )
   CALL echo(build("size: ",size(relationdata->relationships,5)))
   SELECT
    IF ((includenom->size > 0))
     WHERE (relationdata->relationships[d1.seq].related_person_id=data->result_qual[d2.seq].
     related_person_id)
      AND (data->result_qual[d2.seq].nomenclature_id=includenom->exceptions[d3.seq].id)
      AND (data->result_qual[d2.seq].related_person_id=includenom->exceptions[d3.seq].
     related_person_id)
    ELSE
     WHERE (relationdata->relationships[d1.seq].related_person_id=data->result_qual[d2.seq].
     related_person_id)
    ENDIF
    INTO "nl:"
    priority = relationdata->relationships[d1.seq].priority, relation = relationdata->relationships[
    d1.seq].related_person_id, positivecondition = data->result_qual[d2.seq].source_string
    FROM (dummyt d1  WITH seq = size(relationdata->relationships,5)),
     (dummyt d2  WITH seq = size(data->result_qual,5)),
     (dummyt d3  WITH seq = includenom->size)
    ORDER BY priority, relation, positivecondition
    HEAD REPORT
     relationcnt = 0, sage = fillstring(255," "), sdate = fillstring(255," ")
     IF ((data->incomplete_data_ind=1))
      print->incomplete_data_msg = concat(captions->sdat)
     ENDIF
     print->updtstatus = concat(captions->slast," ",captions->supdate,": ",format(data->
       last_updt_dt_tm,"MM/DD/YYYY;;D"),
      " ",format(data->last_updt_dt_tm,"HH:MM;;S")," ",captions->sby," ",
      data->last_updt_prsnl_name)
    HEAD relation
     IF ((data->result_qual[d2.seq].related_person_id > 0))
      relationcnt = (relationcnt+ 1)
      IF (relationcnt > size(print->relation,5))
       stat = alterlist(print->relation,(relationcnt+ 10))
      ENDIF
      print->relation[relationcnt].display = uar_get_code_display(relationdata->relationships[d1.seq]
       .person_reltn_cd)
      IF ((relationdata->relationships[d1.seq].name_last != "")
       AND (relationdata->relationships[d1.seq].name_first != ""))
       print->relation[relationcnt].display = concat(print->relation[relationcnt].display," (",
        relationdata->relationships[d1.seq].name_last,", ",relationdata->relationships[d1.seq].
        name_first,
        ")")
      ELSEIF ((relationdata->relationships[d1.seq].name_last != ""))
       print->relation[relationcnt].display = concat(print->relation[relationcnt].display," (",
        relationdata->relationships[d1.seq].name_last,")")
      ELSEIF ((relationdata->relationships[d1.seq].name_first != ""))
       print->relation[relationcnt].display = concat(print->relation[relationcnt].display," (",
        relationdata->relationships[d1.seq].name_first,")")
      ENDIF
      IF ((relationdata->relationships[d1.seq].deceased_ind=0))
       IF ((relationdata->relationships[d1.seq].birth_dt_tm > 0))
        CALL calculateage(relationdata->relationships[d1.seq].birth_dt_tm,cnvtdatetime(curdate,0),
        relationdata->relationships[d1.seq].birth_prec_flag,sage), print->relation[relationcnt].
        display = concat(print->relation[relationcnt].display,", ",captions->sage,": ",sage)
       ENDIF
      ELSE
       print->relation[relationcnt].display = concat(print->relation[relationcnt].display,": ",
        captions->sdeceased)
       IF ((((relationdata->relationships[d1.seq].age_at_death > 0)) OR ((relationdata->
       relationships[d1.seq].age_at_death_mod_flag=0))) )
        print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
         captions->sat," ",captions->sage,
         ":")
        IF ((relationdata->relationships[d1.seq].age_at_death_mod_flag=0))
         print->relation[relationcnt].display = concat(print->relation[relationcnt].display,captions
          ->sunknown)
        ELSE
         IF ((relationdata->relationships[d1.seq].age_at_death_mod_flag=1))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->sbefore)
         ELSEIF ((relationdata->relationships[d1.seq].age_at_death_mod_flag=2))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->safter)
         ELSEIF ((relationdata->relationships[d1.seq].age_at_death_mod_flag=3))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->sabout)
         ENDIF
         print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",build
          (relationdata->relationships[d1.seq].age_at_death))
         IF ((relationdata->relationships[d1.seq].age_at_death_unit=0))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->syears)
         ELSEIF ((relationdata->relationships[d1.seq].age_at_death_unit=1))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->smonths)
         ELSEIF ((relationdata->relationships[d1.seq].age_at_death_unit=2))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->sweeks)
         ELSEIF ((relationdata->relationships[d1.seq].age_at_death_unit=3))
          print->relation[relationcnt].display = concat(print->relation[relationcnt].display," ",
           captions->sdays)
         ENDIF
        ENDIF
       ENDIF
       IF ((relationdata->relationships[d1.seq].cause_of_death != ""))
        print->relation[relationcnt].display = concat(print->relation[relationcnt].display,", ",
         captions->scause," ",captions->sof,
         " ",captions->sdeath,": ",relationdata->relationships[d1.seq].cause_of_death)
       ENDIF
      ENDIF
     ENDIF
     poscondcnt = 0, negcondcnt = 0
    DETAIL
     IF ((data->result_qual[d2.seq].type_mean="PERSON"))
      IF ((data->result_qual[d2.seq].fhx_value_flag=0))
       print->negative = captions->snegative
      ELSEIF ((data->result_qual[d2.seq].fhx_value_flag=2))
       print->unknown = captions->sunknown
      ELSEIF ((data->result_qual[d2.seq].fhx_value_flag=3))
       print->unable_to_obtain = concat(captions->sunable," ",captions->sto," ",captions->sobtain)
      ELSEIF ((data->result_qual[d2.seq].fhx_value_flag=4))
       print->adopted = concat(captions->spatient," ",captions->sis," ",captions->sadopted)
      ENDIF
     ELSEIF ((data->result_qual[d2.seq].type_mean="RELTN"))
      IF ((data->result_qual[d2.seq].fhx_value_flag=0))
       print->relation[relationcnt].negative = captions->snegative
      ELSEIF ((data->result_qual[d2.seq].fhx_value_flag=2))
       print->relation[relationcnt].unknown = captions->sunknown
      ENDIF
     ELSEIF ((data->result_qual[d2.seq].type_mean="CONDITION"))
      IF ((data->result_qual[d2.seq].fhx_value_flag=1))
       poscondcnt = (poscondcnt+ 1)
       IF (poscondcnt > size(print->relation[relationcnt].positive_condition,5))
        stat = alterlist(print->relation[relationcnt].positive_condition,(poscondcnt+ 10))
       ENDIF
       print->relation[relationcnt].positive_condition[poscondcnt].display = data->result_qual[d2.seq
       ].source_string
       IF ((((data->result_qual[d2.seq].onset_age > 0)) OR ((data->result_qual[d2.seq].
       onset_age_prec_cd=unknown_cd))) )
        print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->relation[
         relationcnt].positive_condition[poscondcnt].display,", ",captions->sonset," ",captions->sage,
         ":")
        IF ((data->result_qual[d2.seq].onset_age_prec_cd > 0))
         print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->
          relation[relationcnt].positive_condition[poscondcnt].display," ",uar_get_code_display(data
           ->result_qual[d2.seq].onset_age_prec_cd))
        ENDIF
        IF ((data->result_qual[d2.seq].onset_age_prec_cd != unknown_cd))
         print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->
          relation[relationcnt].positive_condition[poscondcnt].display," ",build(data->result_qual[d2
           .seq].onset_age))
         IF ((data->result_qual[d2.seq].onset_age_unit_cd > 0))
          print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->
           relation[relationcnt].positive_condition[poscondcnt].display," ",uar_get_code_display(data
            ->result_qual[d2.seq].onset_age_unit_cd))
         ENDIF
        ENDIF
       ENDIF
       IF ((data->result_qual[d2.seq].life_cycle_status_cd > 0))
        print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->relation[
         relationcnt].positive_condition[poscondcnt].display,", ",uar_get_code_display(data->
          result_qual[d2.seq].life_cycle_status_cd))
       ENDIF
       IF ((data->result_qual[d2.seq].severity_cd > 0))
        print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->relation[
         relationcnt].positive_condition[poscondcnt].display,", ",uar_get_code_display(data->
          result_qual[d2.seq].severity_cd))
       ENDIF
       IF ((data->result_qual[d2.seq].course_cd > 0))
        print->relation[relationcnt].positive_condition[poscondcnt].display = concat(print->relation[
         relationcnt].positive_condition[poscondcnt].display,", ",uar_get_code_display(data->
          result_qual[d2.seq].course_cd))
       ENDIF
       commentcnt = size(data->result_qual[d2.seq].comment_qual,5)
       IF (commentcnt > 0)
        stat = alterlist(print->relation[relationcnt].positive_condition[poscondcnt].comment,
         commentcnt)
        FOR (j = 1 TO commentcnt)
          print->relation[relationcnt].positive_condition[poscondcnt].comment[j].display = concat(
           captions->scomment,": ",data->result_qual[d2.seq].comment_qual[j].long_text," (",format(
            data->result_qual[d2.seq].comment_qual[j].comment_dt_tm,"MM/DD/YYYY;;D"),
           " ",format(data->result_qual[d2.seq].comment_qual[j].comment_dt_tm,"HH:MM;;S")," - ",data
           ->result_qual[d2.seq].comment_qual[j].comment_prsnl_full_name,")")
        ENDFOR
       ENDIF
       IF (size(data->result_qual[d2.seq].result_reltn_qual,5) > 0)
        CALL echo("RELATED"), print->relation[relationcnt].positive_condition[poscondcnt].
        related_display = concat(captions->srelated,": "), commaflag = 0
        FOR (j = 1 TO size(relatedproblems->related,5))
          IF ((relatedproblems->related[j].fhx_activity_group_id=data->result_qual[d2.seq].
          fhx_activity_group_id))
           IF (commaflag=1)
            print->relation[relationcnt].positive_condition[poscondcnt].related_display = concat(
             print->relation[relationcnt].positive_condition[poscondcnt].related_display,", ")
           ENDIF
           commaflag = 1, print->relation[relationcnt].positive_condition[poscondcnt].related_display
            = concat(print->relation[relationcnt].positive_condition[poscondcnt].related_display," ",
            relatedproblems->related[j].source_string)
           IF ((relatedproblems->related[j].fhx_value_flag=0))
            print->relation[relationcnt].positive_condition[poscondcnt].related_display = concat(
             print->relation[relationcnt].positive_condition[poscondcnt].related_display," (",
             captions->snegative,")")
           ELSEIF ((relatedproblems->related[j].fhx_value_flag=1))
            print->relation[relationcnt].positive_condition[poscondcnt].related_display = concat(
             print->relation[relationcnt].positive_condition[poscondcnt].related_display," (",
             captions->spositive,")")
           ELSEIF ((relatedproblems->related[j].fhx_value_flag=2))
            print->relation[relationcnt].positive_condition[poscondcnt].related_display = concat(
             print->relation[relationcnt].positive_condition[poscondcnt].related_display," (",
             captions->sunknown,")")
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ELSEIF ((data->result_qual[d2.seq].fhx_value_flag=0))
       negcondcnt = (negcondcnt+ 1)
       IF (negcondcnt > size(print->relation[relationcnt].negative_condition,5))
        stat = alterlist(print->relation[relationcnt].negative_condition,(negcondcnt+ 10))
       ENDIF
       print->relation[relationcnt].negative_condition[negcondcnt].display = data->result_qual[d2.seq
       ].source_string
      ENDIF
     ENDIF
    FOOT  relation
     IF (poscondcnt > 0)
      stat = alterlist(print->relation[relationcnt].positive_condition,poscondcnt)
     ENDIF
     IF (negcondcnt > 0)
      stat = alterlist(print->relation[relationcnt].negative_condition,negcondcnt)
     ENDIF
    FOOT REPORT
     IF (relationcnt > 0)
      stat = alterlist(print->relation,relationcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET relationcnt = value(size(print->relation,5))
   IF (relationcnt < 1
    AND (print->negative="")
    AND (print->unable_to_obtain="")
    AND (print->unknown=""))
    SET cnodata = "Y"
    GO TO exit_script
   ENDIF
   SET max_length = 100
   SET pt->line_cnt = 0
   CALL parsetext(print->incomplete_data_msg,max_length)
   SET stat = alterlist(print->incomplete_data_msg_wrap,pt->line_cnt)
   SET print->incomplete_data_msg_wrapcnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET print->incomplete_data_msg_wrap[j].line = pt->lns[j].line
   ENDFOR
   SET max_length = 100
   SET pt->line_cnt = 0
   CALL parsetext(print->updtstatus,max_length)
   SET stat = alterlist(print->updtstatus_wrap,pt->line_cnt)
   SET print->updtstatus_wrapcnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET print->updtstatus_wrap[j].line = pt->lns[j].line
   ENDFOR
   FOR (i = 1 TO relationcnt)
     SET max_length = 110
     SET pt->line_cnt = 0
     CALL parsetext(print->relation[i].display,max_length)
     SET stat = alterlist(print->relation[i].wrap,pt->line_cnt)
     SET print->relation[i].wrapcnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET print->relation[i].wrap[j].line = pt->lns[j].line
     ENDFOR
     SET positivecnt = value(size(print->relation[i].positive_condition,5))
     FOR (x = 1 TO positivecnt)
       SET max_length = 100
       SET pt->line_cnt = 0
       CALL parsetext(value(print->relation[i].positive_condition[x].display),value(max_length))
       SET stat = alterlist(print->relation[i].positive_condition[x].wrap,pt->line_cnt)
       SET print->relation[i].positive_condition[x].wrapcnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET print->relation[i].positive_condition[x].wrap[j].line = pt->lns[j].line
       ENDFOR
       SET commentcnt = value(size(print->relation[i].positive_condition[x].comment,5))
       FOR (y = 1 TO commentcnt)
         SET max_length = 95
         SET pt->line_cnt = 0
         CALL parsetext(value(print->relation[i].positive_condition[x].comment[y].display),value(
           max_length))
         SET stat = alterlist(print->relation[i].positive_condition[x].comment[y].wrap,pt->line_cnt)
         SET print->relation[i].positive_condition[x].comment[y].wrapcnt = pt->line_cnt
         FOR (j = 1 TO pt->line_cnt)
           SET print->relation[i].positive_condition[x].comment[y].wrap[j].line = pt->lns[j].line
         ENDFOR
       ENDFOR
       SET max_length = 90
       SET pt->line_cnt = 0
       CALL parsetext(value(print->relation[i].positive_condition[x].related_display),value(
         max_length))
       SET stat = alterlist(print->relation[i].positive_condition[x].related_wrap,pt->line_cnt)
       SET print->relation[i].positive_condition[x].related_wrapcnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET print->relation[i].positive_condition[x].related_wrap[j].line = pt->lns[j].line
       ENDFOR
     ENDFOR
     SET negativecnt = value(size(print->relation[i].negative_condition,5))
     FOR (x = 1 TO negativecnt)
       SET max_length = 100
       SET pt->line_cnt = 0
       CALL parsetext(value(print->relation[i].negative_condition[x].display),value(max_length))
       SET stat = alterlist(print->relation[i].negative_condition[x].wrap,pt->line_cnt)
       SET print->relation[i].negative_condition[x].wrapcnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET print->relation[i].negative_condition[x].wrap[j].line = pt->lns[j].line
       ENDFOR
     ENDFOR
   ENDFOR
   FREE RECORD blob
   IF (debug=1)
    CALL echorecord(print)
   ENDIF
 END ;Subroutine
 SUBROUTINE formatreport(dummyvar)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    HEAD REPORT
     FOR (j = 1 TO print->updtstatus_wrapcnt)
       col 0, print->updtstatus_wrap[j].line, row + 1
     ENDFOR
     row + 1
     IF ((print->negative != ""))
      col 0, print->negative
      IF ((print->adopted != ""))
       col 8, ". ", col 10,
       print->adopted
      ENDIF
     ELSEIF ((print->unknown != ""))
      col 0, print->unknown
      IF ((print->adopted != ""))
       col 7, ". ", col 9,
       print->adopted
      ENDIF
     ELSEIF ((print->unable_to_obtain != ""))
      col 0, print->unable_to_obtain
      IF ((print->adopted != ""))
       col 16, ". ", col 18,
       print->adopted
      ENDIF
     ELSEIF ((print->adopted != ""))
      col 0, print->adopted, row + 2
     ENDIF
    DETAIL
     FOR (i = 1 TO size(print->relation,5))
       FOR (j = 1 TO print->relation[i].wrapcnt)
         col 0, print->relation[i].wrap[j].line, row + 1
       ENDFOR
       positivecnt = size(print->relation[i].positive_condition,5), negativecnt = size(print->
        relation[i].negative_condition,5), row + 1
       IF (((positivecnt > 0) OR (negativecnt > 0)) )
        IF (positivecnt > 0)
         col 5, captions->spositive, ":",
         row + 2
         FOR (x = 1 TO positivecnt)
           FOR (j = 1 TO print->relation[i].positive_condition[x].wrapcnt)
             col 10, print->relation[i].positive_condition[x].wrap[j].line, row + 1
           ENDFOR
           IF (size(print->relation[i].positive_condition[x].comment,5))
            FOR (y = 1 TO size(print->relation[i].positive_condition[x].comment,5))
              FOR (j = 1 TO print->relation[i].positive_condition[x].comment[y].wrapcnt)
                col 15, print->relation[i].positive_condition[x].comment[y].wrap[j].line, row + 1
              ENDFOR
            ENDFOR
           ENDIF
           IF ((print->relation[i].positive_condition[x].related_display != ""))
            FOR (j = 1 TO print->relation[i].positive_condition[x].related_wrapcnt)
              row + 1, col 20, print->relation[i].positive_condition[x].related_wrap[j].line
            ENDFOR
            row + 2
           ELSE
            row + 1
           ENDIF
         ENDFOR
        ENDIF
        IF (negativecnt > 0)
         col 5, captions->snegative, ":",
         row + 2
         FOR (x = 1 TO negativecnt)
           FOR (j = 1 TO print->relation[i].negative_condition[x].wrapcnt)
             col 10, print->relation[i].negative_condition[x].wrap[j].line, row + 1
           ENDFOR
         ENDFOR
         row + 1
        ENDIF
       ELSEIF ((print->relation[i].negative != ""))
        col 5, print->relation[i].negative, row + 2
       ELSEIF ((print->relation[i].unknown != ""))
        col 5, print->relation[i].unknown, row + 2
       ENDIF
     ENDFOR
    FOOT PAGE
     numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
     FOR (pagevar = 0 TO numrows)
       ln = (ln+ 1), reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
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
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
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
 FREE RECORD print
 FREE RECORD data
 FREE RECORD relationdata
 FREE RECORD relatedproblems
 FREE RECORD includenom
 FREE RECORD captions
 FREE RECORD get_print_data
END GO
