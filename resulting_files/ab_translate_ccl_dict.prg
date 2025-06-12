CREATE PROGRAM ab_translate_ccl_dict
 FREE RECORD ccl_objects
 RECORD ccl_objects(
   1 list[*]
     2 name = vc
     2 name_dba = vc
     2 compiled_by = vc
     2 source = vc
     2 ops_job_name = vc
     2 da2_name = vc
 )
 DECLARE mn_object_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cmd = vc WITH protect, noconstant("")
 DECLARE ml_len = i4 WITH protect, noconstant(0)
 DECLARE ml_status = i4 WITH protect, noconstant(0)
 DECLARE ml_err_msg = vc WITH protect, noconstant("")
 DECLARE lndx = i4 WITH protect, noconstant(0)
 DECLARE lndx2 = i4 WITH protect, noconstant(0)
 DECLARE mn_object_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_object_pos2 = i4 WITH protect, noconstant(0)
 DECLARE mn_object_pos3 = i4 WITH protect, noconstant(0)
 SET ml_cmd = "rm /cerner/d_p627/bhscust/bhs_trans_ccl_dict.dat"
 SET ml_len = size(trim(ml_cmd))
 SET ml_status = 0
 CALL dcl(ml_cmd,ml_len,ml_status)
 CALL echo("-- 1 --")
 CALL echo(ml_status)
 SELECT INTO "nl:"
  FROM dprotect dp
  WHERE dp.object="P"
  ORDER BY dp.object_name, dp.group
  DETAIL
   mn_object_cnt += 1, stat = alterlist(ccl_objects->list,mn_object_cnt), ccl_objects->list[
   mn_object_cnt].name = dp.object_name,
   ccl_objects->list[mn_object_cnt].name_dba = build(dp.object_name,":DBA"), ccl_objects->list[
   mn_object_cnt].compiled_by = dp.user_name, ccl_objects->list[mn_object_cnt].source = dp
   .source_name,
   ccl_objects->list[mn_object_cnt].ops_job_name = "N/A", ccl_objects->list[mn_object_cnt].da2_name
    = "N/A"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ops2_job oj,
   ops2_step o
  PLAN (oj
   WHERE oj.active_ind=1)
   JOIN (o
   WHERE o.ops2_job_id=oj.ops2_job_id
    AND o.active_ind=1
    AND o.request_name IN ("ccl_run_program_from_ops", "sys_runccl")
    AND expand(lndx,1,mn_object_cnt,trim(cnvtupper(substring(1,findstring(" ",o.batch_selection_txt),
       o.batch_selection_txt)),3),ccl_objects->list[lndx].name))
  DETAIL
   mn_object_pos = locateval(lndx2,1,mn_object_cnt,trim(cnvtupper(substring(1,findstring(" ",o
        .batch_selection_txt),o.batch_selection_txt)),3),ccl_objects->list[lndx2].name)
   IF (mn_object_pos > 0)
    ccl_objects->list[mn_object_pos].ops_job_name = trim(oj.job_name,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM ops_job oj,
   ops_job_step o
  PLAN (oj
   WHERE oj.active_ind=1)
   JOIN (o
   WHERE o.ops_job_id=oj.ops_job_id
    AND o.active_ind=1
    AND o.step_name IN ("ccl_run_program_from_ops", "sys_runccl")
    AND expand(lndx,1,mn_object_cnt,trim(cnvtupper(substring(1,findstring(" ",o.batch_selection),o
       .batch_selection)),3),ccl_objects->list[lndx].name))
  DETAIL
   mn_object_pos2 = locateval(lndx2,1,mn_object_cnt,trim(cnvtupper(substring(1,findstring(" ",o
        .batch_selection),o.batch_selection)),3),ccl_objects->list[lndx2].name)
   IF (mn_object_pos2 > 0)
    ccl_objects->list[mn_object_pos2].ops_job_name = trim(oj.name,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM da_report r,
   da_folder_report_reltn dfr
  PLAN (r
   WHERE r.active_ind=1
    AND r.report_type_cd=value(uar_get_code_by("DISPLAYKEY",4002472,"CCLREPORT"))
    AND expand(lndx,1,mn_object_cnt,cnvtupper(r.report_name),ccl_objects->list[lndx].name_dba))
   JOIN (dfr
   WHERE r.da_report_id=dfr.da_report_id)
  DETAIL
   mn_object_pos3 = locateval(lndx2,1,mn_object_cnt,cnvtupper(r.report_name),ccl_objects->list[lndx2]
    .name_dba)
   IF (mn_object_pos3 > 0)
    ccl_objects->list[mn_object_pos3].da2_name = trim(dfr.report_alias_name,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (mn_for_cnt = 1 TO mn_object_cnt)
   SELECT INTO value("bhscust:bhs_trans_ccl_dict.dat")
    FROM dual
    DETAIL
     col 0, "<<COMPILED_BY:", col + 1,
     ccl_objects->list[mn_for_cnt].compiled_by, col + 1, ">>",
     row + 1, col 0, "<<SOURCE:",
     col + 1, ccl_objects->list[mn_for_cnt].source, col + 1,
     ">>", row + 1, col 0,
     "<<DA2:", col + 1, ccl_objects->list[mn_for_cnt].da2_name,
     col + 1, ">>", row + 1,
     col 0, "<<OPS:", col + 1,
     ccl_objects->list[mn_for_cnt].ops_job_name, col + 1, ">>",
     row + 1
    WITH append
   ;end select
   SET ml_cmd = concat("translate into 'bhscust:bhs_trans_ccl_dict.dat' ",ccl_objects->list[
    mn_for_cnt].name,":dba with append go")
   CALL parser(ml_cmd,0)
   CALL echo(ml_cmd)
   CALL echo("***")
   SET stat = error(ml_err_msg,1)
 ENDFOR
 CALL echorecord(ccl_objects)
 FREE RECORD ccl_objects
END GO
