CREATE PROGRAM benefit_level_task
 SET trace = noechorecord
 SET trace = nordbprogram
 SET trace = nosrvuint
 SET trace = nocost
 SET trace = noerror
 SET trace = nomemory5
 SET trace = nomemsort
 SET trace = rdbbindcons
 SET trace = rdbarrayfetch
 SET trace = nocallecho
 SET message = noinformation
 SET trace = nocost
 DECLARE start_batch_id = i4 WITH noconstant(1)
 DECLARE end_batch_id = i4 WITH noconstant(0)
 DECLARE temp_batch_id = i4 WITH noconstant(0)
 DECLARE max_task_id = f8 WITH noconstant(0.0)
 DECLARE max_task_str = vc WITH noconstant("")
 DECLARE cmd_line = vc WITH noconstant("")
 DECLARE date_str = vc WITH noconstant("")
 DECLARE start_ccl_upload = i4 WITH noconstant(0)
 SET logical export_dir "/cerner/d_t3921/data/bcbst_data/benefits/"
 SET date_str = trim(cnvtstring( $1,10,0))
 SET status = 0
 SET start_ccl_upload =  $2
 IF (cursys="AIX")
  SET dir = "cer_data/data/bcbst_data/benefits"
 ENDIF
 IF (cursys="AIX")
  SET cmd_line = concat("ls Benefit_Level_",date_str,".txt")
  CALL dcl(cmd_line,size(cmd_line),status)
  IF (status=0)
   SET trace = callecho
   CALL echo(concat("ERROR - Benefit_Level_",date_str,".txt file does not exist"))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM lh2_benefit_level_data l
  FOOT REPORT
   start_batch_id = (max(l.lh2_benefit_level_data_id)+ 1)
  WITH nocounter
 ;end select
 IF (cursys="AIX")
  SET cmd_line = "rm temp?.ctl"
  CALL dcl(cmd_line,size(cmd_line),status)
  SET cmd_line = concat('sed "s/FILENAME/Benefit_Level_',date_str,
   '.txt/g" benefitlevelupload.ctl > temp1.ctl ')
  CALL dcl(cmd_line,size(cmd_line),status)
  SET cmd_line = concat('sed "s/YYYYMM/',date_str,'/g" temp1.ctl > temp2.ctl')
  CALL dcl(cmd_line,size(cmd_line),status)
  SET cmd_line = concat("sqlldr v500/v500 control=temp2.ctl log=benefitlevel",date_str,".log skip=1")
  CALL dcl(cmd_line,size(cmd_line),status)
 ENDIF
 SET cmd_line = ""
 SELECT INTO "nl:"
  FROM lh2_task l
  FOOT REPORT
   max_task_id = (max(l.lh2_task_id)+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM lh2_benefit_level_data l
  FOOT REPORT
   end_batch_id = max(l.lh2_benefit_level_data_id)
  WITH nocounter
 ;end select
 INSERT  FROM lh2_task l
  SET l.lh2_task_id = max_task_id, l.est_completion_dt_tm = null, l.batch_program =
   "lh2_benefit_level_load",
   l.batch_start_id = start_batch_id, l.batch_end_id = end_batch_id, l.batch_size = 2500,
   l.timers = 0, l.batch_start_dt_tm = null, l.batch_end_dt_tm = null,
   l.batch_count = 0, l.iteration_start_id = 0, l.iteration_end_id = 0,
   l.iteration_count = 0, l.iteration_start_dt_tm = null, l.iteration_end_dt_tm = null,
   l.batch_average = 0.0, l.iteration_average = 0.0
 ;end insert
 COMMIT
 SET trace = callecho
 CALL echo(build("BENEFIT LEVEL UPLOAD COMPLETE.  BENEFIT LEVEL LH2_TASK_ID=",max_task_id))
 IF (start_ccl_upload > 0)
  SET max_task_str = trim(cnvtstring(max_task_id,20,0),3)
  IF (cursys="AIX")
   SET dir = "cer_log"
   SET cmd_line = concat("nohup /usr/bin/lh2_task.ksh ",max_task_str," > ",build("lh2_task",
     max_task_str,".log")," 2>&1 &")
   CALL dcl(cmd_line,size(cmd_line),status)
  ENDIF
  IF (cursys="AIX")
   SET cmd_line = concat("ps -eaf | grep lh2")
   CALL dcl(cmd_line,size(cmd_line),status)
  ENDIF
 ENDIF
#exit_script
END GO
