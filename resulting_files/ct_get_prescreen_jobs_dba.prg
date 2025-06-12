CREATE PROGRAM ct_get_prescreen_jobs:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 job_list[*]
      2 job_id = f8
      2 prsnl_id = f8
      2 prsnl_name = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 details = vc
      2 prot_list[*]
        3 prot_master_id = f8
        3 primary_mnemonic = vc
        3 nbr_qual_pts = i4
      2 job_type = i2
      2 job_status_cd = f8
      2 job_status_disp = vc
      2 job_status_desc = vc
      2 job_status_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE job_cnt = i2 WITH protect, noconstant(0)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE acknowledged = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"ACKNOWLEDGE"))
 DECLARE forcedcomp = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"FORCEDCOMP"))
 DECLARE prsnl_qualification = vc WITH protect
 DECLARE status_qualification = vc WITH protect
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE cur_idx = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->prsnl_id > 0))
  SET prsnl_qualification = build("cpj.prsnl_id = request->prsnl_id")
 ELSE
  SET prsnl_qualification = build("cpj.prsnl_id+0 > 0.0")
 ENDIF
 IF ((request->view_all_statuses=1))
  SET status_qualification = build("cpj.job_status_cd+0 > 0.0")
 ELSE
  SET status_qualification = build("cpj.job_status_cd+0 != ACKNOWLEDGED")
 ENDIF
 SELECT INTO "NL:"
  cpj.ct_prescreen_job_id
  FROM ct_prescreen_job cpj,
   long_text lt,
   prsnl p
  PLAN (cpj
   WHERE cpj.ct_prescreen_job_id > 0.0
    AND cpj.job_status_cd != forcedcomp
    AND parser(prsnl_qualification)
    AND parser(status_qualification))
   JOIN (p
   WHERE p.person_id=cpj.prsnl_id)
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(cpj.long_text_id))
  ORDER BY cpj.ct_prescreen_job_id
  HEAD REPORT
   job_cnt = 0
  HEAD cpj.ct_prescreen_job_id
   job_cnt = (job_cnt+ 1)
   IF (mod(job_cnt,10)=1)
    stat = alterlist(reply->job_list,(job_cnt+ 9))
   ENDIF
   reply->job_list[job_cnt].job_id = cpj.ct_prescreen_job_id, reply->job_list[job_cnt].prsnl_id = cpj
   .prsnl_id, reply->job_list[job_cnt].prsnl_name = p.name_full_formatted,
   reply->job_list[job_cnt].start_dt_tm = cpj.job_start_dt_tm, reply->job_list[job_cnt].end_dt_tm =
   cpj.job_end_dt_tm, reply->job_list[job_cnt].details = lt.long_text,
   reply->job_list[job_cnt].job_type = cpj.job_type_flag, reply->job_list[job_cnt].job_status_cd =
   cpj.job_status_cd
  FOOT REPORT
   stat = alterlist(reply->job_list,job_cnt)
  WITH nocounter
 ;end select
 IF (job_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET cur_list_size = size(reply->job_list,5)
  SET batch_size = 100
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->job_list,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->job_list[idx].job_id = reply->job_list[cur_list_size].job_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    ct_prot_prescreen_job_info cpi,
    prot_master pm
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cpi
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),cpi.ct_prescreen_job_id,reply->job_list[num].
     job_id))
    JOIN (pm
    WHERE pm.prot_master_id=cpi.prot_master_id
     AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY cpi.ct_prescreen_job_id
   HEAD cpi.ct_prescreen_job_id
    prot_cnt = 0, cur_idx = 0
   DETAIL
    cur_idx = locateval(num,1,cur_list_size,cpi.ct_prescreen_job_id,reply->job_list[num].job_id),
    CALL echo(build("cur_idx is:",cur_idx))
    IF (cur_idx > 0)
     prot_cnt = (prot_cnt+ 1)
     IF (mod(prot_cnt,10)=1)
      stat = alterlist(reply->job_list[cur_idx].prot_list,(prot_cnt+ 9))
     ENDIF
     reply->job_list[cur_idx].prot_list[prot_cnt].prot_master_id = cpi.prot_master_id, reply->
     job_list[cur_idx].prot_list[prot_cnt].primary_mnemonic = pm.primary_mnemonic, reply->job_list[
     cur_idx].prot_list[prot_cnt].nbr_qual_pts = cpi.pt_qualified_nbr
    ENDIF
   FOOT  cpi.ct_prescreen_job_id
    stat = alterlist(reply->job_list[cur_idx].prot_list,prot_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->job_list,job_cnt)
  IF (prot_cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SET last_mod = "000"
 SET mod_date = "April 14, 2010"
END GO
