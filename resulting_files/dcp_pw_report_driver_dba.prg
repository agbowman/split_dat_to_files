CREATE PROGRAM dcp_pw_report_driver:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_id = f8
    1 pw_cnt = i4
    1 qual_pw[*]
      2 pathway_id = f8
    1 batch_selection = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET program_name = fillstring(30," ")
 IF (trim(request->script_name) > " ")
  SET program_name = cnvtupper(trim(request->script_name))
  EXECUTE value(program_name)
  GO TO exit_program
 ENDIF
#batch_mode
 SET drd_cnt = 0
 SET drd_idx = 0
 SET person_cnt = 0
 SET pw_cnt = 0
 SET hold_batch_selection = fillstring(255," ")
 SET hold_batch_selection = trim(request->batch_selection)
 SET ns_disp_key = fillstring(40," ")
 SET bld_disp_key = fillstring(40," ")
 SET ns_cd = 0
 SET prog_cnt = 0
 SET census_type_cd = 0
 SET code_value = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 339
 SET cdf_meaning = "CENSUS"
 EXECUTE cpm_get_cd_for_cdf
 SET census_type_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "STARTED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_act_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_comp_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_disc_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_ord_status_cd = code_value
 SET code_set = 14169
 SET cdf_meaning = "PATIENTCARE"
 EXECUTE cpm_get_cd_for_cdf
 SET patcare_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "NURSEUNIT"
 EXECUTE cpm_get_cd_for_cdf
 SET nurse_unit_cd = code_value
 RECORD person_list(
   1 person_cnt = i4
   1 qual_person[*]
     2 person_id = f8
     2 pw_cnt = i4
     2 qual_pw[*]
       3 pathway_id = f8
 )
 RECORD progs(
   1 plist[*]
     2 pname = vc
 )
 SET prog_cnt = 1
 SET stat = alterlist(progs->plist,1)
 SET progs->plist[1].pname = "DCP_PW_SUMMARY_RPT"
 SET drd_idx = findstring(";",hold_batch_selection)
 IF (drd_idx > 0)
  SET bld_disp_key = substring(1,(drd_idx - 1),hold_batch_selection)
  SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
 ELSE
  CALL echo("Missing building code")
  GO TO exit_program
 ENDIF
 SET drd_idx = findstring(";",hold_batch_selection)
 IF (drd_idx > 0)
  SET ns_disp_key = substring(1,(drd_idx - 1),hold_batch_selection)
  SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
 ELSE
  CALL echo("Missing nursing unit code")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c1,
   location_group lg,
   location l,
   code_value c2
  PLAN (c1
   WHERE c1.code_set=220
    AND c1.cdf_meaning="BUILDING"
    AND c1.display_key=bld_disp_key
    AND c1.active_ind=1)
   JOIN (lg
   WHERE lg.parent_loc_cd=c1.code_value)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.location_type_cd=nurse_unit_cd)
   JOIN (c2
   WHERE c2.code_value=l.location_cd
    AND c2.display_key=ns_disp_key)
  DETAIL
   ns_cd = c2.code_value
  WITH nocounter
 ;end select
 IF (ns_cd=0)
  CALL echo(build("Error: unable to find the appropriate location code"))
  GO TO exit_program
 ENDIF
 SET drd_idx = findstring(";",hold_batch_selection)
 IF (drd_idx > 0)
  SET request->output_device = substring(1,(drd_idx - 1),hold_batch_selection)
  SET hold_batch_selection = substring((drd_idx+ 1),(254 - drd_idx),hold_batch_selection)
 ELSE
  CALL echo("Missing printer name")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  ed.person_id, pw.pathway_id
  FROM encntr_domain ed,
   pathway pw
  PLAN (ed
   WHERE ed.encntr_domain_type_cd=census_type_cd
    AND ed.loc_nurse_unit_cd=ns_cd
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime((curdate - 1),235959)
    AND ed.end_effective_dt_tm >= cnvtdatetime((curdate - 1),000000))
   JOIN (pw
   WHERE pw.person_id=ed.person_id
    AND ((pw.pw_status_cd=pw_comp_status_cd) OR (pw.pw_status_cd=pw_disc_status_cd))
    AND pw.actual_end_dt_tm <= cnvtdatetime((curdate - 1),235959)
    AND pw.actual_end_dt_tm >= cnvtdatetime((curdate - 1),000000))
  ORDER BY ed.person_id, pw.start_dt_tm
  HEAD REPORT
   person_cnt = 0
  HEAD ed.person_id
   person_cnt = (person_cnt+ 1), stat = alterlist(person_list->qual_person,person_cnt), person_list->
   qual_person[person_cnt].person_id = ed.person_id,
   pw_cnt = 0
  HEAD pw.pathway_id
   pw_cnt = (pw_cnt+ 1), stat = alterlist(person_list->qual_person[person_cnt].qual_pw,pw_cnt),
   person_list->qual_person[person_cnt].qual_pw[pw_cnt].pathway_id = pw.pathway_id
  FOOT  ed.person_id
   person_list->qual_person[person_cnt].pw_cnt = pw_cnt
  FOOT REPORT
   person_list->person_cnt = person_cnt
  WITH nocounter
 ;end select
 IF (person_cnt=0)
  GO TO exit_program
 ENDIF
 FOR (ind = 1 TO person_list->person_cnt)
   SET request->person_id = person_list->qual_person[ind].person_id
   SET request->pw_cnt = person_list->qual_person[ind].pw_cnt
   FOR (j = 1 TO request->pw_cnt)
    SET stat = alterlist(request->qual_pw,j)
    SET request->qual_pw[j].pathway_id = person_list->qual_person[ind].qual_pw[j].pathway_id
   ENDFOR
   EXECUTE value(progs->plist[1].pname)
   SET stat = alterlist(request->qual_pw,0)
   SET request->person_id = 0.0
   SET request->pw_cnt = 0
 ENDFOR
#exit_program
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
