CREATE PROGRAM cv_fetch_demog:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 FREE SET uids
 RECORD uids(
   1 encntr[*]
     2 encntr_id = f8
   1 person[*]
     2 person_id = f8
 )
 DECLARE proc_cnt = i4 WITH protect, noconstant(size(request->cv_proc,5))
 IF (proc_cnt < 1)
  CALL cv_log_stat(cv_warning,"SELECT","Z","CV_PROC","")
  GO TO exit_script
 ENDIF
 DECLARE proc_idx = i4 WITH protect, noconstant(0)
 DECLARE block_size = i4 WITH protect, noconstant(40)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE encntr_cnt = i4 WITH protect
 DECLARE encntr_idx = i4 WITH protect
 DECLARE encntr_pad = i4 WITH protect
 DECLARE person_cnt = i4 WITH protect
 DECLARE person_idx = i4 WITH protect
 DECLARE person_pad = i4 WITH protect
 DECLARE location_building = vc WITH protect
 SELECT DISTINCT INTO "nl:"
  l_person_id = request->cv_proc[d.seq].person_id, l_encntr_id = request->cv_proc[d.seq].encntr_id
  FROM (dummyt d  WITH seq = proc_cnt)
  ORDER BY l_person_id, l_encntr_id
  HEAD l_person_id
   person_cnt += 1
   IF (person_cnt > person_pad)
    person_pad += block_size, stat = alterlist(uids->person,person_pad)
   ENDIF
   uids->person[person_cnt].person_id = l_person_id
  DETAIL
   IF (l_encntr_id > 0.0)
    encntr_cnt += 1
    IF (encntr_cnt > encntr_pad)
     encntr_pad += block_size, stat = alterlist(uids->encntr,encntr_pad)
    ENDIF
    uids->encntr[encntr_cnt].encntr_id = l_encntr_id
   ENDIF
  WITH nocounter
 ;end select
 FOR (person_idx = (person_cnt+ 1) TO person_pad)
   SET uids->person[person_idx].person_id = uids->person[person_cnt].person_id
 ENDFOR
 FOR (encntr_idx = (encntr_cnt+ 1) TO encntr_pad)
   SET uids->encntr[encntr_idx].encntr_id = uids->encntr[encntr_cnt].encntr_id
 ENDFOR
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(uids)
 ENDIF
 IF (encntr_cnt=0)
  CALL cv_log_msg(cv_info,"All encntr_id are 0.0")
  GO TO skip_encntr
 ENDIF
 DECLARE now_dt_tm = q8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE ea_type_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ea_type_finnbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 IF (ea_type_mrn_cd <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:319:MRN",build(ea_type_mrn_cd))
 ENDIF
 IF (ea_type_finnbr_cd <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:319:FIN NBR",build(ea_type_finnbr_cd))
 ENDIF
 IF (ea_type_mrn_cd <= 0.0
  AND ea_type_finnbr_cd <= 0.0)
  GO TO skip_encntr
 ELSE
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    (dummyt d  WITH seq = value((encntr_pad/ block_size)))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (ea
    WHERE expand(encntr_idx,nstart,((nstart+ block_size) - 1),ea.encntr_id,uids->encntr[encntr_idx].
     encntr_id)
     AND ea.encntr_alias_type_cd IN (ea_type_mrn_cd, ea_type_finnbr_cd)
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(now_dt_tm)
     AND ea.end_effective_dt_tm > cnvtdatetime(now_dt_tm))
   DETAIL
    proc_idx = locateval(proc_idx,1,proc_cnt,ea.encntr_id,request->cv_proc[proc_idx].encntr_id)
    WHILE (proc_idx != 0)
     IF (ea.encntr_alias_type_cd=ea_type_mrn_cd)
      request->cv_proc[proc_idx].encntr_mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)), request->
      cv_proc[proc_idx].encntr_mrn_raw = trim(ea.alias)
     ELSE
      request->cv_proc[proc_idx].encntr_finnbr = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
     ENDIF
     ,proc_idx = locateval(proc_idx,(proc_idx+ 1),proc_cnt,ea.encntr_id,request->cv_proc[proc_idx].
      encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_stat(cv_warning,"SELECT","Z","ENCNTR_ALIAS","")
  ENDIF
 ENDIF
 DECLARE pa_type_dodid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MILITARYID"))
 DECLARE pa_type_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 IF (pa_type_dodid_cd <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:4:MILITARYID",build(pa_type_dodid_cd))
 ENDIF
 IF (pa_type_cmrn_cd <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:4:CMRN",build(pa_type_cmrn_cd))
 ENDIF
 IF (((pa_type_dodid_cd > 0.0) OR (pa_type_cmrn_cd > 0.0)) )
  SELECT INTO "nl:"
   FROM person_alias pa,
    (dummyt d  WITH seq = value((person_pad/ block_size)))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (pa
    WHERE expand(person_idx,nstart,((nstart+ block_size) - 1),pa.person_id,uids->person[person_idx].
     person_id)
     AND pa.person_alias_type_cd IN (pa_type_dodid_cd, pa_type_cmrn_cd)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(now_dt_tm)
     AND pa.end_effective_dt_tm > cnvtdatetime(now_dt_tm))
   DETAIL
    proc_idx = locateval(proc_idx,1,proc_cnt,pa.person_id,request->cv_proc[proc_idx].person_id)
    WHILE (proc_idx != 0)
      IF (pa.person_alias_type_cd=pa_type_dodid_cd)
       request->cv_proc[proc_idx].dod_id = trim(pa.alias)
      ENDIF
      IF (pa.person_alias_type_cd=pa_type_cmrn_cd)
       request->cv_proc[proc_idx].cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
      ENDIF
      proc_idx = locateval(proc_idx,(proc_idx+ 1),proc_cnt,pa.person_id,request->cv_proc[proc_idx].
       person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_stat(cv_warning,"SELECT","Z","PERSON_ALIAS","")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  location_building = uar_get_code_display(e.loc_building_cd)
  FROM encounter e,
   (dummyt d  WITH seq = value((encntr_pad/ block_size)))
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
   JOIN (e
   WHERE expand(encntr_idx,nstart,((nstart+ block_size) - 1),e.encntr_id,uids->encntr[encntr_idx].
    encntr_id))
  DETAIL
   proc_idx = locateval(proc_idx,1,proc_cnt,e.encntr_id,request->cv_proc[proc_idx].encntr_id)
   WHILE (proc_idx != 0)
     request->cv_proc[proc_idx].location_cd = e.location_cd, request->cv_proc[proc_idx].
     loc_nurse_unit_cd = e.loc_nurse_unit_cd, request->cv_proc[proc_idx].loc_room_cd = e.loc_room_cd,
     request->cv_proc[proc_idx].loc_bed_cd = e.loc_bed_cd, request->cv_proc[proc_idx].
     encounter_type_cd = e.encntr_type_cd, request->cv_proc[proc_idx].organization_id = e
     .organization_id,
     request->cv_proc[proc_idx].loc_building_cd = e.loc_building_cd, request->cv_proc[proc_idx].
     loc_building_disp = location_building, request->cv_proc[proc_idx].financial_class_cd = e
     .financial_class_cd,
     request->cv_proc[proc_idx].loc_facility_cd = e.loc_facility_cd, proc_idx = locateval(proc_idx,(
      proc_idx+ 1),proc_cnt,e.encntr_id,request->cv_proc[proc_idx].encntr_id)
   ENDWHILE
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_stat(cv_warning,"SELECT","Z","ENCOUNTER","")
 ENDIF
 DECLARE c_encntr_prsnl_referdoc = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"REFERDOC"
   ))
 DECLARE c_encntr_prsnl_admitdoc = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ADMITDOC"
   ))
 IF (c_encntr_prsnl_referdoc <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:333:REFERDOC",build(
    c_encntr_prsnl_referdoc))
 ENDIF
 IF (c_encntr_prsnl_admitdoc <= 0.0)
  CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F","MEANING:333:ADMITDOC",build(
    c_encntr_prsnl_admitdoc))
 ENDIF
 IF (c_encntr_prsnl_referdoc <= 0.0
  AND c_encntr_prsnl_admitdoc <= 0.0)
  GO TO skip_encntr
 ELSE
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn epr,
    (dummyt d  WITH seq = value((encntr_pad/ block_size)))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
    JOIN (epr
    WHERE expand(encntr_idx,nstart,((nstart+ block_size) - 1),epr.encntr_id,uids->encntr[encntr_idx].
     encntr_id)
     AND epr.encntr_prsnl_r_cd IN (c_encntr_prsnl_referdoc, c_encntr_prsnl_admitdoc)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(now_dt_tm)
     AND epr.end_effective_dt_tm > cnvtdatetime(now_dt_tm))
   ORDER BY epr.encntr_id
   HEAD epr.encntr_id
    l_refer_cnt = 0, l_admit_cnt = 0
   DETAIL
    l_refer_cnt += 1, l_admit_cnt += 1, proc_idx = locateval(proc_idx,1,proc_cnt,epr.encntr_id,
     request->cv_proc[proc_idx].encntr_id)
    WHILE (proc_idx > 0)
     IF (epr.encntr_prsnl_r_cd=c_encntr_prsnl_referdoc)
      stat = alterlist(request->cv_proc[proc_idx].refer_phys,l_refer_cnt)
      IF (epr.prsnl_person_id > 0)
       request->cv_proc[proc_idx].refer_phys[l_refer_cnt].refer_phys_id = epr.prsnl_person_id
      ELSE
       request->cv_proc[proc_idx].refer_phys[l_refer_cnt].ft_prsnl_name = epr.ft_prsnl_name
      ENDIF
     ELSE
      stat = alterlist(request->cv_proc[proc_idx].admit_phys,l_admit_cnt)
      IF (epr.prsnl_person_id > 0)
       request->cv_proc[proc_idx].admit_phys[l_admit_cnt].admit_phys_id = epr.prsnl_person_id
      ELSE
       request->cv_proc[proc_idx].admit_phys[l_admit_cnt].ft_phys_prsnl_name = epr.ft_prsnl_name
      ENDIF
     ENDIF
     ,proc_idx = locateval(proc_idx,(proc_idx+ 1),proc_cnt,epr.encntr_id,request->cv_proc[proc_idx].
      encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
#skip_encntr
 SELECT INTO "nl:"
  FROM person p,
   (dummyt d  WITH seq = value((person_pad/ block_size)))
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ block_size))))
   JOIN (p
   WHERE expand(person_idx,nstart,((nstart+ block_size) - 1),p.person_id,uids->person[person_idx].
    person_id))
  DETAIL
   proc_idx = locateval(proc_idx,1,proc_cnt,p.person_id,request->cv_proc[proc_idx].person_id)
   WHILE (proc_idx != 0)
     request->cv_proc[proc_idx].person_name_last = p.name_last, request->cv_proc[proc_idx].
     person_name_first = p.name_first, request->cv_proc[proc_idx].person_name_middle = p.name_middle,
     request->cv_proc[proc_idx].birth_dt_tm = p.birth_dt_tm, request->cv_proc[proc_idx].sex_cd = p
     .sex_cd, request->cv_proc[proc_idx].birth_tz = p.birth_tz,
     proc_idx = locateval(proc_idx,(proc_idx+ 1),proc_cnt,p.person_id,request->cv_proc[proc_idx].
      person_id)
   ENDWHILE
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_stat(cv_error,"SELECT","Z","PERSON","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_FETCH_DEMOG failed")
  CALL echorecord(reply)
  CALL echorecord(uids)
  CALL echorecord(request)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE SET uids
 CALL cv_log_msg_post("017 09/16/22 SB032903")
END GO
