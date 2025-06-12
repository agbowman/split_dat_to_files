CREATE PROGRAM dcp_cs_task_sel_sort_pref
 SET modify = predeclare
 DECLARE totalscripttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 FREE RECORD reply
 RECORD reply(
   1 solcap[*]
     2 identifier = vc
     2 degree_of_use_num = i4
     2 degree_of_use_str = vc
     2 distinct_user_count = i4
     2 position[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 facility[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 other[*]
       3 category_name = vc
       3 value[*]
         4 display = vc
         4 value_num = i4
         4 value_str = vc
 )
 RECORD pref_reply(
   1 app
     2 application_number = i4
     2 nv_cnt = i4
     2 nv[*]
       3 name_value_prefs_id = f8
       3 nv_type_flag = i2
       3 pvc_name = c32
       3 pvc_value = vc
       3 sequence = i2
       3 merge_id = f8
       3 merge_name = vc
       3 updt_cnt = i4
       3 position_cd = f8
       3 prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getapplevelprefs(null) = null
 DECLARE getpositionsforpref(null) = null
 DECLARE getusersforpref(null) = null
 DECLARE iprefcount = i4 WITH noconstant(0)
 DECLARE res_count = i4 WITH noconstant(0)
 DECLARE sprefname = vc WITH constant("task_window_sorting")
 DECLARE res_string = vc WITH noconstant("")
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,2)
 SET reply->solcap[1].identifier = "2010.1.00002.2"
 SET reply->solcap[1].degree_of_use_str = sprefname
 CALL getapplevelprefs(null)
 CALL getpositionsforpref(null)
 CALL getusersforpref(null)
 CALL getglobalforpref(null)
 SET iprefcount = pref_reply->app.nv_cnt
 CALL echo("*********************************")
 CALL echo(build("Total preference count = ",iprefcount))
 CALL echo(build("Total script time in seconds = ",datetimediff(cnvtdatetime(curdate,curtime3),
    totalscripttime,5)))
 CALL echo("*********************************")
#exit_program
 SUBROUTINE getapplevelprefs(null)
   SELECT INTO "nl:"
    ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
    nv.pvc_name, nv.seq, ap.seq
    FROM app_prefs ap,
     name_value_prefs nv
    PLAN (ap
     WHERE ap.application_number=600005
      AND ap.active_ind=1)
     JOIN (nv
     WHERE nv.parent_entity_name="APP_PREFS"
      AND nv.parent_entity_id=ap.app_prefs_id
      AND cnvtupper(nv.pvc_name)=cnvtupper(sprefname)
      AND nv.active_ind=1)
    ORDER BY nv.pvc_name, nv.sequence
    HEAD REPORT
     nvi = 0, pvc_cnt = 0, seq_cnt = 0
    HEAD nv.pvc_name
     pvc_cnt = (pvc_cnt+ 1)
    HEAD nv.sequence
     seq_cnt = (seq_cnt+ 1)
    DETAIL
     nvi = (nvi+ 1)
     IF (nvi > size(pref_reply->app.nv,5))
      stat = alterlist(pref_reply->app.nv,(nvi+ 10))
     ENDIF
     pref_reply->app.nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, pref_reply->app.nv[nvi].
     pvc_name = nv.pvc_name, pref_reply->app.nv[nvi].pvc_value = nv.pvc_value,
     pref_reply->app.nv[nvi].sequence = nv.sequence, pref_reply->app.nv[nvi].merge_id = nv.merge_id,
     pref_reply->app.nv[nvi].merge_name = nv.merge_name,
     pref_reply->app.nv[nvi].position_cd = ap.position_cd, pref_reply->app.nv[nvi].prsnl_id = ap
     .prsnl_id
     IF (ap.prsnl_id > 0)
      pref_reply->app.nv[nvi].nv_type_flag = 2
     ELSE
      IF (ap.position_cd > 0)
       pref_reply->app.nv[nvi].nv_type_flag = 1
      ELSE
       pref_reply->app.nv[nvi].nv_type_flag = 0
      ENDIF
     ENDIF
    FOOT  nv.sequence
     seq_cnt = seq_cnt
    FOOT  nv.pvc_name
     pvc_cnt = pvc_cnt
    FOOT REPORT
     IF (nvi > 0)
      stat = alterlist(pref_reply->app.nv,nvi), pref_reply->app.nv_cnt = nvi
     ENDIF
    WITH nocounter, dontcare(nv)
   ;end select
 END ;Subroutine
 SUBROUTINE getglobalforpref(null)
   SET res_count = 0
   SET reply->solcap[1].other[2].category_name = "global"
   SELECT INTO "nl:"
    pref_reply->app.nv[dprefno.seq].pvc_name, pref_reply->app.nv[dprefno.seq].pvc_value
    FROM (dummyt dprefno  WITH seq = value(size(pref_reply->app.nv,5)))
    PLAN (dprefno
     WHERE (pref_reply->app.nv[dprefno.seq].position_cd=0)
      AND (pref_reply->app.nv[dprefno.seq].prsnl_id=0))
    DETAIL
     res_count = (res_count+ 1)
     IF (mod(res_count,10)=1)
      stat = alterlist(reply->solcap[1].other[2].value,(res_count+ 9))
     ENDIF
     reply->solcap[1].other[2].value[res_count].display = pref_reply->app.nv[dprefno.seq].pvc_name,
     reply->solcap[1].other[2].value[res_count].value_str = pref_reply->app.nv[dprefno.seq].pvc_value
    FOOT REPORT
     stat = alterlist(reply->solcap[1].other[2].value,res_count)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpositionsforpref(null)
   SET res_count = 0
   SET res_string = ""
   SELECT INTO "nl:"
    encounters = count(p.position_cd), res_string = uar_get_code_display(p.position_cd), p
    .position_cd
    FROM prsnl p,
     (dummyt dprefno  WITH seq = value(size(pref_reply->app.nv,5)))
    PLAN (dprefno
     WHERE (pref_reply->app.nv[dprefno.seq].position_cd > 0)
      AND (pref_reply->app.nv[dprefno.seq].prsnl_id=0))
     JOIN (p
     WHERE (p.position_cd=pref_reply->app.nv[dprefno.seq].position_cd))
    GROUP BY p.position_cd
    ORDER BY res_string
    DETAIL
     res_count = (res_count+ 1)
     IF (mod(res_count,10)=1)
      stat = alterlist(reply->solcap[1].position,(res_count+ 9))
     ENDIF
     reply->solcap[1].position[res_count].display = uar_get_code_display(p.position_cd), reply->
     solcap[1].position[res_count].value_num = encounters
    FOOT REPORT
     stat = alterlist(reply->solcap[1].position,res_count)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getusersforpref(null)
   SET res_count = 0
   SET reply->solcap[1].other[1].category_name = "user"
   SELECT INTO "nl:"
    prsnlcnt = count(p.person_id), p.name_last_key, p.name_first_key,
    p.person_id
    FROM prsnl p,
     (dummyt dprefno  WITH seq = value(size(pref_reply->app.nv,5)))
    PLAN (dprefno
     WHERE (pref_reply->app.nv[dprefno.seq].prsnl_id > 0)
      AND (pref_reply->app.nv[dprefno.seq].position_cd=0))
     JOIN (p
     WHERE (p.person_id=pref_reply->app.nv[dprefno.seq].prsnl_id))
    GROUP BY p.person_id, p.name_last_key, p.name_first_key
    ORDER BY p.name_last_key, p.name_first_key
    DETAIL
     res_count = (res_count+ 1)
     IF (mod(res_count,10)=1)
      stat = alterlist(reply->solcap[1].other[1].value,(res_count+ 9))
     ENDIF
     reply->solcap[1].other[1].value[res_count].display = concat(trim(p.name_last_key,3),", ",trim(p
       .name_first_key,3)), reply->solcap[1].other[1].value[res_count].value_num = prsnlcnt
    FOOT REPORT
     stat = alterlist(reply->solcap[1].other[1].value,res_count)
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL echorecord(reply)
 SET last_mod = "000 6/10/2010"
 SET modify = nopredeclare
END GO
