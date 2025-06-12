CREATE PROGRAM dcp_get_ord_flow_info:dba
 RECORD reply(
   1 ref_qual_cnt = i4
   1 ref_qual[*]
     2 orderable_name = vc
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 ref_text_mask = i4
   1 act_qual_cnt = i4
   1 act_qual[*]
     2 encntr_id = f8
     2 orderable_name = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 order_id = f8
     2 ref_text_mask = i4
     2 status_display = vc
     2 display_dt_tm = dq8
     2 display_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET prefix_suffix_ind = 0
 SET prefix_string = fillstring(50," ")
 SET suffix_string = fillstring(50," ")
 SET suspend_string = fillstring(50," ")
 SET resume_string = fillstring(50," ")
 SET dc_string = fillstring(50," ")
 SET pref_string = fillstring(255," ")
 SET d_str = fillstring(10," ")
 SET bsub = 0
 SET esub = 0
 SET dlen = 0
 SET dvar = fillstring(50," ")
 SELECT INTO "nl:"
  nvp.pvc_name
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="PENDING_STATUS_FORMAT"
  HEAD REPORT
   pref_string = nvp.pvc_value
  WITH nocounter
 ;end select
 SET bsub = 1
 SET esub = findstring(",",pref_string,bsub)
 IF (esub=0)
  SET prefix_suffix_ind = 0
 ELSE
  SET dlen = (esub - bsub)
  SET dind = substring(bsub,1,pref_string)
  IF (dind="1")
   SET prefix_suffix_ind = 1
  ELSEIF (dind="2")
   SET prefix_suffix_ind = 2
  ELSE
   SET prefix_suffix_ind = 0
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET tmp_chk = substring(bsub,1,pref_string)
  IF (tmp_chk=",")
   SET esub = bsub
   SET prefix_string = ""
  ELSE
   SET esub = findstring(",",pref_string,bsub)
   IF (esub=0)
    SET prefix_suffix_ind = 0
   ELSE
    SET dlen = (esub - bsub)
    SET prefix_string = substring(bsub,dlen,pref_string)
   ENDIF
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET tmp_chk = substring(bsub,1,pref_string)
  IF (tmp_chk=",")
   SET esub = bsub
   SET suffix_string = ""
  ELSE
   SET esub = findstring(",",pref_string,bsub)
   IF (esub=0)
    SET prefix_suffix_ind = 0
   ELSE
    SET dlen = (esub - bsub)
    SET suffix_string = substring(bsub,dlen,pref_string)
   ENDIF
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET tmp_chk = substring(bsub,1,pref_string)
  IF (tmp_chk=",")
   SET esub = bsub
   SET suspend_string = ""
  ELSE
   SET esub = findstring(",",pref_string,bsub)
   IF (esub=0)
    SET prefix_suffix_ind = 0
   ELSE
    SET dlen = (esub - bsub)
    SET suspend_string = substring(bsub,dlen,pref_string)
   ENDIF
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET tmp_chk = substring(bsub,1,pref_string)
  IF (tmp_chk=",")
   SET esub = bsub
   SET resume_string = ""
  ELSE
   SET esub = findstring(",",pref_string,bsub)
   IF (esub=0)
    SET prefix_suffix_ind = 0
   ELSE
    SET dlen = (esub - bsub)
    SET resume_string = substring(bsub,dlen,pref_string)
   ENDIF
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET tmp_chk = substring(bsub,1,pref_string)
  IF (tmp_chk=",")
   SET esub = bsub
   SET dc_string = ""
  ELSE
   SET esub = findstring(",",pref_string,bsub)
   IF (esub=0)
    SET prefix_suffix_ind = 0
   ELSE
    SET dlen = (esub - bsub)
    SET dc_string = substring(bsub,dlen,pref_string)
   ENDIF
  ENDIF
 ENDIF
 IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
  SET bsub = (esub+ 1)
  SET d_str = substring(bsub,((textlen(pref_string) - bsub)+ 1),pref_string)
 ENDIF
 SET reply->act_qual_cnt = 0
 SET stat = alterlist(reply->act_qual,10)
 SET reply->status_data.status = "F"
 IF ((request->order_cnt > 0))
  SET reply->ref_qual_cnt = request->order_cnt
  SET stat = alterlist(reply->ref_qual,request->order_cnt)
  SELECT INTO "nl:"
   o.order_id
   FROM (dummyt d  WITH seq = value(request->order_cnt)),
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->qual[d.seq].order_id))
   DETAIL
    reply->ref_qual[d.seq].orderable_name = o.order_mnemonic, reply->ref_qual[d.seq].order_id = o
    .order_id, reply->ref_qual[d.seq].catalog_cd = o.catalog_cd,
    reply->ref_qual[d.seq].catalog_type_cd = o.catalog_type_cd, reply->ref_qual[d.seq].
    activity_type_cd = o.activity_type_cd, reply->ref_qual[d.seq].ref_text_mask = o.ref_text_mask
   WITH nocounter
  ;end select
 ELSE
  SET reply->ref_qual_cnt = 0
  SET stat = alterlist(reply->ref_qual,1)
 ENDIF
 IF ((request->person_id > 0))
  SET code_set = 0.0
  SET code_value = 0.0
  SET cdf_meaning = fillstring(12," ")
  SET code_set = 6004
  SET cdf_meaning = "COMPLETED"
  EXECUTE cpm_get_cd_for_cdf
  SET ord_stat_cd = code_value
  SET count1 = 0
  SELECT INTO "nl:"
   o.order_id, o.current_start_dt_tm, o.current_start_tz,
   o.order_status_cd
   FROM orders o
   WHERE (o.person_id=request->person_id)
    AND o.current_start_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.order_status_cd < ord_stat_cd) OR (o.order_status_cd > ord_stat_cd))
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > size(reply->act_qual,5))
     stat = alterlist(reply->act_qual,(count1+ 10))
    ENDIF
    reply->act_qual_cnt = count1, reply->act_qual[count1].encntr_id = o.encntr_id, reply->act_qual[
    count1].orderable_name = o.order_mnemonic,
    reply->act_qual[count1].order_id = o.order_id, reply->act_qual[count1].catalog_cd = o.catalog_cd,
    reply->act_qual[count1].catalog_type_cd = o.catalog_type_cd,
    reply->act_qual[count1].activity_type_cd = o.activity_type_cd, reply->act_qual[count1].
    ref_text_mask = o.ref_text_mask, reply->act_qual[count1].display_dt_tm = cnvtdatetime(o
     .current_start_dt_tm),
    reply->act_qual[count1].display_tz = o.current_start_tz, ord_status_display = trim(substring(1,20,
      uar_get_code_display(o.order_status_cd))), dept_status_display = trim(substring(1,20,
      uar_get_code_display(o.dept_status_cd))),
    pending_status_ind = 0, pending_susp_ind = 0, pending_resume_ind = 0,
    pending_dc_ind = 0
    IF (((prefix_suffix_ind=1) OR (prefix_suffix_ind=2)) )
     IF (o.suspend_ind=1
      AND o.suspend_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      pending_status_ind = 1, pending_susp_ind = 1
     ENDIF
     IF (o.resume_ind=1
      AND o.resume_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      pending_status_ind = 1, pending_resume_ind = 1
     ENDIF
     IF (o.discontinue_ind=1
      AND o.discontinue_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      pending_status_ind = 1, pending_dc_ind = 1
     ENDIF
     IF (pending_status_ind=1)
      IF (pending_susp_ind=1
       AND pending_resume_ind=1
       AND pending_dc_ind=1)
       pending_status_display = concat(trim(prefix_string),trim(suspend_string),trim(d_str),trim(
         resume_string),trim(d_str),
        trim(dc_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=1
       AND pending_resume_ind=1
       AND pending_dc_ind=0)
       pending_status_display = concat(trim(prefix_string),trim(suspend_string),trim(d_str),trim(
         resume_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=1
       AND pending_resume_ind=0
       AND pending_dc_ind=0)
       pending_status_display = concat(trim(prefix_string),trim(suspend_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=1
       AND pending_resume_ind=0
       AND pending_dc_ind=1)
       pending_status_display = concat(trim(prefix_string),trim(suspend_string),trim(d_str),trim(
         dc_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=0
       AND pending_resume_ind=1
       AND pending_dc_ind=1)
       pending_status_display = concat(trim(prefix_string),trim(resume_string),trim(d_str),trim(
         dc_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=0
       AND pending_resume_ind=1
       AND pending_dc_ind=0)
       pending_status_display = concat(trim(prefix_string),trim(resume_string),trim(suffix_string))
      ELSEIF (pending_susp_ind=0
       AND pending_resume_ind=0
       AND pending_dc_ind=1)
       pending_status_display = concat(trim(prefix_string),trim(dc_string),trim(suffix_string))
      ENDIF
     ENDIF
    ENDIF
    IF ((request->status_disp_flag=1))
     IF (pending_status_ind=1)
      IF (prefix_suffix_ind=1)
       reply->act_qual[count1].status_display = concat(trim(pending_status_display),trim(
         ord_status_display))
      ELSE
       reply->act_qual[count1].status_display = concat(trim(ord_status_display),trim(
         pending_status_display))
      ENDIF
     ELSE
      reply->act_qual[count1].status_display = trim(ord_status_display)
     ENDIF
    ELSEIF ((request->status_disp_flag=2))
     IF (pending_status_ind=1)
      IF (prefix_suffix_ind=1)
       reply->act_qual[count1].status_display = concat(trim(pending_status_display),trim(
         dept_status_display))
      ELSE
       reply->act_qual[count1].status_display = concat(trim(dept_status_display),trim(
         pending_status_display))
      ENDIF
     ELSE
      reply->act_qual[count1].status_display = trim(dept_status_display)
     ENDIF
    ELSE
     IF (pending_status_ind=1)
      IF (prefix_suffix_ind=1)
       reply->act_qual[count1].status_display = concat(trim(pending_status_display),trim(
         ord_status_display)," (",trim(dept_status_display),") ")
      ELSE
       reply->act_qual[count1].status_display = concat(trim(ord_status_display)," (",trim(
         dept_status_display),") ",trim(pending_status_display))
      ENDIF
     ELSE
      reply->act_qual[count1].status_display = concat(trim(ord_status_display)," (",trim(
        dept_status_display),") ")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->act_qual_cnt > 0))
  SET stat = alterlist(reply->act_qual,reply->act_qual_cnt)
 ELSE
  SET stat = alterlist(reply->act_qual,1)
 ENDIF
#exit_script
 IF ((reply->ref_qual_cnt=0)
  AND (reply->act_qual_cnt=0))
  SET reply->status_data.status = "Z"
  CALL echo(build("failed..."))
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("count",reply->ref_qual_cnt))
  FOR (zz = 1 TO reply->ref_qual_cnt)
    CALL echo(build("Orderablennn: ",reply->ref_qual[zz].orderable_name))
    CALL echo(build("catalog_type_cd: ",reply->ref_qual[zz].catalog_type_cd))
    CALL echo(build("activity_type_cd: ",reply->ref_qual[zz].activity_type_cd))
  ENDFOR
  CALL echo(build("count",reply->act_qual_cnt))
  FOR (zz = 1 TO reply->act_qual_cnt)
    CALL echo(build("Orderable: ",reply->act_qual[zz].orderable_name))
    CALL echo(build("Status:",reply->act_qual[zz].status_display))
    CALL echo(build("OrderId:",reply->act_qual[zz].order_id))
  ENDFOR
 ENDIF
END GO
