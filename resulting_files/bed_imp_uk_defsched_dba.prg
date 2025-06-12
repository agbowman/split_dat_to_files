CREATE PROGRAM bed_imp_uk_defsched:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 SET all_blocks = 0
 IF ((tempreq->mode="S"))
  SET all_blocks = 1
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE log_msg = vc
 DECLARE log_temp = vc
 SET lstat = 0.0
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET nbr_rows = size(requestin->list_0,5)
 CALL echo(build("nbr rows:",nbr_rows))
 DECLARE hold_temp_name = vc
 SET hold_temp_name = " "
 SET dup_template = 0
 DECLARE br_sch_template_id = f8
 SET br_sch_template_id = 0.0
 DECLARE bstr1 = vc
 DECLARE bstr2 = vc
 DECLARE estr1 = vc
 DECLARE estr2 = vc
 DECLARE temp_dt1 = dq8
 DECLARE temp_dt2 = dq8
 SET fc = 0
 SET begtime = 0
 SET endtime = 0
 DECLARE logfilename = vc
 SET logfilename = "defsched_imp_"
 SET logfilename = concat(logfilename,format(curdate,"MMDDYYYY;;D"),format(curtime,"HHMM;;M"))
 DECLARE import_name = vc
 SET defsched_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=23007
    AND c.cdf_meaning="DEFSCHED")
  DETAIL
   defsched_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO nbr_rows)
  IF (x=1)
   IF (trim(requestin->list_0[x].import_name) > " ")
    SET import_name = trim(requestin->list_0[x].import_name)
   ELSE
    SET import_name = concat(format(curdate,"DDMMMYYYY;;D"),format(curtime,"HHMM;;M"))
   ENDIF
  ENDIF
  IF (trim(requestin->list_0[x].template_name) > " ")
   IF (trim(requestin->list_0[x].template_name) != hold_temp_name)
    SET hold_temp_name = trim(requestin->list_0[x].template_name)
    SET dup_template = 0
    IF (all_blocks=1)
     SET time_block = 1
     SET hold_time_block = 1
    ELSE
     SET time_block = 0
     SET hold_time_block = 0
    ENDIF
    SET stat = new_template(x)
   ENDIF
   IF (dup_template=0
    AND trim(requestin->list_0[x].resource) > " ")
    SET stat = new_resource(x)
   ENDIF
   IF (dup_template=0
    AND trim(requestin->list_0[x].slot_type) > " ")
    IF (trim(requestin->list_0[x].slot_start_time)=" "
     AND trim(requestin->list_0[x].slot_end_time)=" ")
     IF (hold_time_block=0)
      SET time_block = (time_block+ 1)
      SET hold_time_block = 1
     ELSE
      SET hold_time_block = 0
     ENDIF
    ELSEIF (hold_time_block=0)
     SET time_block = (time_block+ 1)
     SET stat = new_slot(x)
    ELSE
     SET stat = new_slot(x)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE new_template(t)
  IF (dup_template=0)
   SET br_sch_template_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     br_sch_template_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET bstr1 = " "
   SET bstr2 = " "
   SET fc = 0
   SET begtime = 0
   SET estr1 = " "
   SET estr2 = " "
   SET endtime = 0
   SET begtime = cnvtreal(requestin->list_0[x].day_begin)
   IF (begtime=0)
    SET bstr1 = trim(requestin->list_0[x].day_begin)
    SET fc = findstring(":",bstr1,1,0)
    IF (fc=2)
     SET bstr2 = substring(1,1,bstr1)
     SET bstr2 = concat(bstr2,substring(3,2,bstr1))
     SET begtime = cnvtint(bstr2)
    ELSEIF (fc=3)
     SET bstr2 = substring(1,2,bstr1)
     SET bstr2 = concat(bstr2,substring(4,2,bstr1))
     SET begtime = cnvtint(bstr2)
    ENDIF
   ENDIF
   SET endtime = cnvtreal(requestin->list_0[x].day_end)
   IF (endtime=0)
    SET estr1 = trim(requestin->list_0[x].day_end)
    SET fc = findstring(":",estr1,1,0)
    IF (fc=2)
     SET estr2 = substring(1,1,estr1)
     SET estr2 = concat(estr2,substring(3,2,estr1))
     SET endtime = cnvtint(estr2)
    ELSEIF (fc=3)
     SET estr2 = substring(1,2,estr1)
     SET estr2 = concat(estr2,substring(4,2,estr1))
     SET endtime = cnvtint(estr2)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].apply_begin_date > " "))
    SET fdate = trim(concat(requestin->list_0[x].apply_begin_date,"    "))
    SET fstat = format_date(x)
    SET temp_dt1 = cnvtdate2(fdate,"DD/MM/YYYY")
   ENDIF
   IF ((requestin->list_0[x].apply_end_date > " "))
    SET fdate = trim(concat(requestin->list_0[x].apply_end_date,"    "))
    SET fstat = format_date(x)
    SET temp_dt2 = cnvtdate2(fdate,"DD/MM/YYYY")
   ENDIF
   SET apply_range_str = trim(requestin->list_0[x].def_range,3)
   SET apply_range = cnvtint(apply_range_str)
   INSERT  FROM br_sch_template bst
    SET bst.br_sch_template_id = br_sch_template_id, bst.template_name = hold_temp_name, bst
     .dayofweek = trim(requestin->list_0[x].days_of_the_week),
     bst.weekofmonth = trim(requestin->list_0[x].weeks_of_the_month), bst.daybegin_str = trim(
      requestin->list_0[x].day_begin), bst.dayend_str = trim(requestin->list_0[x].day_end),
     bst.daybegin = begtime, bst.dayend = endtime, bst.template_status_flag = 0,
     bst.def_sched_id = 0, bst.apply_beg_dt_tm_string = trim(requestin->list_0[x].apply_begin_date),
     bst.apply_end_dt_tm_string = trim(requestin->list_0[x].apply_end_date),
     bst.apply_beg_dt_tm =
     IF ((requestin->list_0[x].apply_begin_date > " ")) cnvtdatetime(temp_dt1,begtime)
     ENDIF
     , bst.apply_end_dt_tm =
     IF ((requestin->list_0[x].apply_end_date > " ")) cnvtdatetime(temp_dt2,endtime)
     ENDIF
     , bst.import_name = import_name,
     bst.apply_range_str = apply_range_str, bst.apply_range = apply_range
    WITH nocounter
   ;end insert
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE new_resource(t)
   SET resource_cd = 0.0
   SET fstat = 0.0
   DECLARE fdate = vc
   SET vc = " "
   SELECT INTO "nl:"
    FROM sch_resource sr
    PLAN (sr
     WHERE sr.mnemonic_key=trim(cnvtupper(requestin->list_0[x].resource)))
    DETAIL
     resource_cd = sr.resource_cd
    WITH nocounter
   ;end select
   IF (resource_cd=0)
    SET log_msg = concat(trim(cnvtupper(requestin->list_0[x].resource)),
     " - resource not found on SCH_RESOURCE table.")
    SET log_temp = hold_temp_name
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].apply_begin_date > " "))
    SET fdate = trim(requestin->list_0[x].apply_begin_date)
    SET fstat = format_date(x)
    SET temp_dt1 = cnvtdate2(fdate,"DD/MM/YYYY")
   ENDIF
   IF ((requestin->list_0[x].apply_end_date > " "))
    SET fdate = trim(requestin->list_0[x].apply_end_date)
    SET fstat = format_date(x)
    SET temp_dt2 = cnvtdate2(fdate,"DD/MM/YYYY")
   ENDIF
   INSERT  FROM br_sch_temp_res_r bstrr
    SET bstrr.br_sch_temp_res_r_id = seq(bedrock_seq,nextval), bstrr.br_sch_template_id =
     br_sch_template_id, bstrr.resource_name = trim(requestin->list_0[x].resource),
     bstrr.resource_status_flag =
     IF (resource_cd > 0) 1
     ELSE 0
     ENDIF
     , bstrr.apply_begin_str = trim(requestin->list_0[x].apply_begin_date), bstrr.apply_end_str =
     trim(requestin->list_0[x].apply_end_date),
     bstrr.apply_begin_dt_tm =
     IF ((requestin->list_0[x].apply_begin_date > " ")) cnvtdatetime(temp_dt1,0)
     ENDIF
     , bstrr.apply_end_dt_tm =
     IF ((requestin->list_0[x].apply_end_date > " ")) cnvtdatetime(temp_dt2,0)
     ENDIF
     , bstrr.resource_cd = resource_cd
    WITH nocounter
   ;end insert
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE new_slot(t)
   SET slot_type_id = 0.0
   SELECT INTO "nl:"
    FROM sch_slot_type sst
    PLAN (sst
     WHERE sst.mnemonic_key=trim(cnvtupper(requestin->list_0[x].slot_type)))
    DETAIL
     slot_type_id = sst.slot_type_id
    WITH nocounter
   ;end select
   IF (slot_type_id=0)
    SET log_msg = concat(trim(cnvtupper(requestin->list_0[x].slot_type)),
     " - slot type not found on SCH_SLOT_TABLE table.")
    SET log_temp = hold_temp_name
    SET lstat = log_message(t)
   ENDIF
   SET slot_release_to_id = 0.0
   IF ((requestin->list_0[x].slot_release_to > " "))
    SELECT INTO "nl:"
     FROM sch_slot_type sst
     PLAN (sst
      WHERE sst.mnemonic_key=trim(cnvtupper(requestin->list_0[x].slot_release_to)))
     DETAIL
      slot_release_to_id = sst.slot_type_id
     WITH nocounter
    ;end select
    IF (slot_release_to_id=0)
     SET log_msg = concat(trim(cnvtupper(requestin->list_0[x].slot_release_to)),
      " - slot release not found on SCH_SLOT_TABLE table.")
     SET log_temp = hold_temp_name
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   SET bstr1 = " "
   SET bstr2 = " "
   SET fc = 0
   SET begtime = 0
   SET estr1 = " "
   SET estr2 = " "
   SET endtime = 0
   SET begtime = cnvtreal(requestin->list_0[x].slot_start_time)
   IF (begtime=0)
    SET bstr1 = trim(requestin->list_0[x].slot_start_time)
    SET fc = findstring(":",bstr1,1,0)
    IF (fc=2)
     SET bstr2 = substring(1,1,bstr1)
     SET bstr2 = concat(bstr2,substring(3,2,bstr1))
     SET begtime = cnvtint(bstr2)
    ELSEIF (fc=3)
     SET bstr2 = substring(1,2,bstr1)
     SET bstr2 = concat(bstr2,substring(4,2,bstr1))
     SET begtime = cnvtint(bstr2)
    ENDIF
   ENDIF
   SET endtime = cnvtreal(requestin->list_0[x].slot_end_time)
   IF (endtime=0)
    SET estr1 = trim(requestin->list_0[x].slot_end_time)
    SET fc = findstring(":",estr1,1,0)
    IF (fc=2)
     SET estr2 = substring(1,1,estr1)
     SET estr2 = concat(estr2,substring(3,2,estr1))
     SET endtime = cnvtint(estr2)
    ELSEIF (fc=3)
     SET estr2 = substring(1,2,estr1)
     SET estr2 = concat(estr2,substring(4,2,estr1))
     SET endtime = cnvtint(estr2)
    ENDIF
   ENDIF
   SET interval_str = trim(requestin->list_0[x].interval,3)
   SET interval = cnvtint(interval_str)
   INSERT  FROM br_sch_temp_slot_r bstsr
    SET bstsr.br_sch_temp_slot_r_id = seq(bedrock_seq,nextval), bstsr.br_sch_template_id =
     br_sch_template_id, bstsr.slot_name = trim(requestin->list_0[x].slot_type),
     bstsr.slot_start_str = trim(requestin->list_0[x].slot_start_time), bstsr.slot_start = begtime,
     bstsr.slot_end_str = trim(requestin->list_0[x].slot_end_time),
     bstsr.slot_end = endtime, bstsr.slot_release_to = trim(requestin->list_0[x].slot_release_to),
     bstsr.slot_release_to_id = slot_release_to_id,
     bstsr.slot_release_hrs =
     IF ((requestin->list_0[x].slot_release_hours > "")) cnvtint(requestin->list_0[x].
       slot_release_hours)
     ELSE 0
     ENDIF
     , bstsr.slot_type_id = slot_type_id, bstsr.interval_str = interval_str,
     bstsr.interval = interval, bstsr.time_block = time_block, bstsr.slot_status_flag =
     IF (slot_type_id > 0) 1
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE format_date(x)
   CALL echo(build("fdate1:",fdate))
   IF (substring(2,1,fdate)="/")
    SET fdate = concat("0",fdate)
   ENDIF
   IF (substring(5,1,fdate)="/")
    SET fdate = concat(substring(1,3,fdate),"0",substring(4,6,fdate))
   ENDIF
   CALL echo(build("fdate2:",fdate))
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE log_message(t)
  SELECT INTO value(logfilename)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    log_temp, col 40, log_msg,
    row + 1
   WITH nocounter, append
  ;end select
  RETURN(1.0)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_DEFSCHED","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
