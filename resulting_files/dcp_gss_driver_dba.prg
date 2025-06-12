CREATE PROGRAM dcp_gss_driver:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 spread_type = i2
    1 report_title = vc
    1 grid_lines_ind = i2
    1 col_cnt = i2
    1 col[*]
      2 header = vc
      2 width = i2
      2 type = i2
      2 wrap_ind = i2
    1 row_cnt = i2
    1 row[*]
      2 keyl[*]
        3 key_type = i2
        3 key_id = f8
      2 col[*]
        3 data_string = vc
        3 data_double = f8
        3 data_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET trace hipaa off
 SET program_name = fillstring(30," ")
 IF (trim(request->script_name) > " ")
  SET program_name = cnvtupper(trim(request->script_name))
  EXECUTE value(program_name)
  FOR (x = 1 TO reply->row_cnt)
    CALL echo(build("reporttitle:",reply->report_title))
    CALL echo(build("row:",x))
    FOR (y = 1 TO reply->col_cnt)
      CALL echo(build("col contents:",reply->row[x].col[y].data_string))
    ENDFOR
  ENDFOR
  GO TO exit_program
 ENDIF
#exit_program
 SET modify = hipaa
 DECLARE slifecycle = vc WITH noconstant("")
 IF ((request->output_device=""))
  SET slifecycle = "Access/Use"
 ELSE
  SET slifecycle = "Report"
 ENDIF
 IF ((request->person_cnt > 0))
  DECLARE person_counter = i4 WITH noconstant(0)
  FOR (person_counter = 1 TO request->person_cnt)
   EXECUTE cclaudit 1, "Run Report", "PowerChart",
   "Person", "Patient", "Patient",
   slifecycle, request->person[person_counter].person_id, ""
   EXECUTE cclaudit 3, "Run Report", "PowerChart",
   "System Object", "Report", "Report",
   slifecycle, 0.0, request->script_name
  ENDFOR
 ELSEIF ((request->visit_cnt > 0))
  DECLARE visit_counter = i4 WITH noconstant(0)
  FOR (visit_counter = 1 TO request->visit_cnt)
   EXECUTE cclaudit 1, "Run Report", "PowerChart",
   "Encounter", "Patient", "Encounter",
   slifecycle, request->visit[visit_counter].encntr_id, ""
   EXECUTE cclaudit 3, "Run Report", "PowerChart",
   "System Object", "Report", "Report",
   slifecycle, 0.0, request->script_name
  ENDFOR
 ELSE
  EXECUTE cclaudit 0, "Run Report", "PowerChart",
  "System Object", "Report", "Report",
  slifecycle, 0.0, request->script_name
 ENDIF
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "MOD 001 10/10/06 NC014668"
END GO
