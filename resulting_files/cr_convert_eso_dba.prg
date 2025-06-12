CREATE PROGRAM cr_convert_eso:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD eso_settings
 RECORD eso_settings(
   1 output_dest_name = c20
   1 output_dest_cd = f8
   1 qual[*]
     2 chart_format_id = f8
   1 qual2[*]
     2 routine_args = vc
 )
 DECLARE lindex1 = i4 WITH protect, noconstant(0)
 DECLARE lindex2 = i4 WITH protect, noconstant(0)
 DECLARE lroutineargsize = i4 WITH protect, noconstant(0)
 DECLARE lstartpos = i4 WITH protect, noconstant(0)
 DECLARE lendpos = i4 WITH protect, noconstant(0)
 DECLARE sargname = c25 WITH protect, noconstant("")
 DECLARE sargval = c25 WITH protect, noconstant("")
 DECLARE lselectresult = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = c55 WITH protect, noconstant("")
 DECLARE no_error = i4 WITH protect, constant(0)
 DECLARE ccl_error = i4 WITH protect, constant(1)
 DECLARE no_eso = i4 WITH protect, constant(2)
 SET readme_data->status = "F"
 SET readme_data->message = "Starting readme, status initialized to FAILURE"
 SET reqinfo->commit_ind = 0
 CALL echo("Reading settings from the ESO tables.")
 SELECT INTO "nl:"
  FROM eso_routine er,
   eso_trig_routine_r etr
  PLAN (er
   WHERE er.script="ESO_INSERT_CHART_REQUEST"
    AND er.active_ind=1)
   JOIN (etr
   WHERE etr.routine_id=er.routine_id
    AND trim(etr.routine_args) > ""
    AND etr.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (findstring(";",etr.routine_args) != 0)
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(eso_settings->qual2,(cnt+ 9))
    ENDIF
    eso_settings->qual2[cnt].routine_args = trim(etr.routine_args)
   ENDIF
  FOOT REPORT
   stat = alterlist(eso_settings->qual2,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET lselectresult = no_eso
  GO TO exit_script
 ENDIF
 IF (0 < error(serrormessage,0))
  SET lselectresult = ccl_error
  GO TO exit_script
 ENDIF
 FOR (lindex1 = 1 TO size(eso_settings->qual2,5))
  SET lstartpos = 0
  WHILE (lstartpos < size(eso_settings->qual2[lindex1].routine_args))
    SET lendpos = findstring("=",eso_settings->qual2[lindex1].routine_args,lstartpos)
    SET sargname = substring(lstartpos,(lendpos - lstartpos),eso_settings->qual2[lindex1].
     routine_args)
    SET lstartpos = (lendpos+ 1)
    SET lendpos = findstring(";",eso_settings->qual2[lindex1].routine_args,lstartpos)
    SET sargval = substring(lstartpos,(lendpos - lstartpos),eso_settings->qual2[lindex1].routine_args
     )
    SET lstartpos = (lendpos+ 1)
    CASE (sargname)
     OF "NAME":
      SET eso_settings->output_dest_name = sargval
     OF "ID":
      SET lindex2 = (lindex2+ 1)
      IF (mod(lindex2,10)=1)
       SET stat = alterlist(eso_settings->qual,(lindex2+ 9))
      ENDIF
      SET eso_settings->qual[lindex2].chart_format_id = cnvtreal(sargval)
    ENDCASE
  ENDWHILE
 ENDFOR
 SET stat = alterlist(eso_settings->qual,lindex2)
 CALL echo("Reading output_dest_cd from the output_dest table.")
 SELECT INTO "nl:"
  FROM output_dest od
  WHERE (od.name=eso_settings->output_dest_name)
  DETAIL
   eso_settings->output_dest_cd = od.output_dest_cd
  WITH nocounter
 ;end select
 IF (0 < error(serrormessage,0))
  SET lselectresult = ccl_error
  GO TO exit_script
 ENDIF
 CALL echo("Finished extracting ESO settings.")
 CALL echorecord(eso_settings)
 CALL echo("Updating chart_format table")
 UPDATE  FROM chart_format cf,
   (dummyt d  WITH seq = value(size(eso_settings->qual,5)))
  SET cf.ascii_ind = 1, cf.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (cf
   WHERE (cf.chart_format_id=eso_settings->qual[d.seq].chart_format_id))
  WITH nocounter
 ;end update
 IF (0 < error(serrormessage,0))
  SET lselectresult = ccl_error
  GO TO exit_script
 ENDIF
 CALL echo("Updating chart_server_settings table.")
 UPDATE  FROM chart_server_settings c
  SET c.ascii_output_dest_cd = eso_settings->output_dest_cd, c.updt_task = reqinfo->updt_task
  WHERE c.active_ind=1
  WITH nocounter
 ;end update
 IF (0 < error(serrormessage,0))
  SET lselectresult = ccl_error
  GO TO exit_script
 ENDIF
#exit_script
 CASE (lselectresult)
  OF no_error:
   SET reqinfo->commit_ind = 1
   SET readme_data->status = "S"
   SET readme_data->message = "Script ran successfully."
  OF no_eso:
   SET reqinfo->commit_ind = 1
   SET readme_data->status = "S"
   SET readme_data->message = "Script ran successfully, no ESO settings found."
  OF ccl_error:
   SET readme_data->status = "F"
   SET readme_data->message = build("CCL error:  ",serrormessage)
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message = "Unknown error."
 ENDCASE
 CALL echo("Updating readme status...")
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 CALL echo("Exiting cr_convert_eso script.")
END GO
