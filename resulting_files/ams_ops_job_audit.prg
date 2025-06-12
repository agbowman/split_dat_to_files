CREATE PROGRAM ams_ops_job_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Batch Selection String to Search For (use * for wildcard)" = "",
  "OR Enter a Start Time (0000-2359)" = "",
  "AND Enter an End Time (0000-2359)" = "",
  "OR Enter Request Number" = ""
  WITH outdev, batch, stime,
  etime, req
 DECLARE prog_name = vc
 SET prog_name = "AMS_OPS_JOB_AUDIT"
 IF (( $BATCH > " "))
  CALL updtdminfo(prog_name)
  DECLARE search_string = vc
  SET search_string = build2("*", $BATCH,"*")
  SELECT DISTINCT INTO  $OUTDEV
   control_group = ocg.name, name_of_ops_job = oj.name, osp.batch_selection,
   run_time = format(ost.schedule_dt_tm,"hh:mm;;q"), request_nbr = ojs.request_number
   FROM ops_job oj,
    ops_control_group ocg,
    ops_job_step ojs,
    ops_schedule_param osp,
    ops_task ot,
    ops_schedule_task ost
   PLAN (osp
    WHERE osp.batch_selection=patstring(search_string))
    JOIN (ojs
    WHERE ojs.ops_job_step_id=osp.ops_job_step_id)
    JOIN (oj
    WHERE oj.ops_job_id=ojs.ops_job_id)
    JOIN (ot
    WHERE ot.ops_task_id=osp.ops_task_id)
    JOIN (ost
    WHERE ot.ops_task_id=ost.ops_task_id)
    JOIN (ocg
    WHERE ocg.ops_control_grp_id=ot.ops_control_grp_id
     AND ocg.enable_ind=1)
   ORDER BY control_group, name_of_ops_job, osp.batch_selection,
    run_time, request_nbr
   WITH format(date,";;Q"), format, skipreport = 1,
    separator = " ", maxcol = 5000
  ;end select
 ELSEIF (( $STIME > " ")
  AND ( $ETIME > " "))
  CALL updtdminfo(prog_name)
  DECLARE start_time = i4
  DECLARE end_time = i4
  SET start_time = cnvtint( $STIME)
  SET end_time = cnvtint( $STIME)
  SELECT DISTINCT INTO  $OUTDEV
   control_group = ocg.name, name_of_ops_job = oj.name, osp.batch_selection,
   run_time = format(ost.schedule_dt_tm,"hh:mm;;q"), request_nbr = ojs.request_number
   FROM ops_job oj,
    ops_control_group ocg,
    ops_job_step ojs,
    ops_schedule_param osp,
    ops_task ot,
    ops_schedule_task ost
   PLAN (osp)
    JOIN (ojs
    WHERE ojs.ops_job_step_id=osp.ops_job_step_id)
    JOIN (oj
    WHERE oj.ops_job_id=ojs.ops_job_id)
    JOIN (ot
    WHERE ot.ops_task_id=osp.ops_task_id)
    JOIN (ost
    WHERE ot.ops_task_id=ost.ops_task_id
     AND ost.schedule_dt_tm >= cnvtdatetime(curdate,start_time)
     AND ost.schedule_dt_tm <= cnvtdatetime(curdate,end_time))
    JOIN (ocg
    WHERE ocg.ops_control_grp_id=ot.ops_control_grp_id
     AND ocg.enable_ind=1)
   ORDER BY control_group, name_of_ops_job, osp.batch_selection,
    run_time, request_nbr
   WITH format(date,";;Q"), format, skipreport = 1,
    separator = " ", maxcol = 5000
  ;end select
 ELSEIF (( $REQ > " "))
  CALL updtdminfo(prog_name)
  DECLARE req_nbr = i4
  SET req_nbr = cnvtint( $REQ)
  SELECT DISTINCT INTO  $OUTDEV
   control_group = ocg.name, name_of_ops_job = oj.name, osp.batch_selection,
   run_time = format(ost.schedule_dt_tm,"hh:mm;;q"), request_nbr = ojs.request_number
   FROM ops_job oj,
    ops_control_group ocg,
    ops_job_step ojs,
    ops_schedule_param osp,
    ops_task ot,
    ops_schedule_task ost
   PLAN (osp)
    JOIN (ojs
    WHERE ojs.ops_job_step_id=osp.ops_job_step_id
     AND ojs.request_number=req_nbr)
    JOIN (oj
    WHERE oj.ops_job_id=ojs.ops_job_id)
    JOIN (ot
    WHERE ot.ops_task_id=osp.ops_task_id)
    JOIN (ost
    WHERE ot.ops_task_id=ost.ops_task_id)
    JOIN (ocg
    WHERE ocg.ops_control_grp_id=ot.ops_control_grp_id
     AND ocg.enable_ind=1)
   ORDER BY control_group, name_of_ops_job, osp.batch_selection,
    run_time, request_nbr
   WITH format(date,";;Q"), format, skipreport = 1,
    separator = " ", maxcol = 5000
  ;end select
 ENDIF
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
END GO
