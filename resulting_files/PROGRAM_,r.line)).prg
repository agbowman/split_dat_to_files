     ELSEIF (findstring("DROP PROGRAM",r.line))
      rpt_plan_found = 0
     ELSEIF (trim(r.line,3) > ""
      AND trim(r.line,3) != fillstring(130,"=")
      AND rpt_plan_found=1)
      dccp_parsefile->row_cnt = (dccp_parsefile->row_cnt+ 1), stat = alterlist(dccp_parsefile->rows,
       dccp_parsefile->row_cnt), dccp_parsefile->rows[dccp_parsefile->row_cnt].row = build(
       dccp_driver->scripts[dccp_file_idx].script_name,",",dccp_querynum_str,",",trim(r.line,3))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Adding script plans to ",dccp_plan_file)
   SELECT INTO value(build(dccp_directory,dccp_path_separator,dccp_plan_file))
    FROM (dummyt d  WITH seq = dccp_parsefile->row_cnt)
    HEAD REPORT
     IF (dccp_file_idx=1)
      col 0, "CUSTOM CCL PLAN REPORT", row + 1,
      col 0,
      CALL print(concat("Environment: ",logical("environment"),"    Date: ",format(cnvtdatetime(
         curdate,curtime3),";;q"))), row + 1,
      col 0,
      CALL print(fillstring(130,"-"))
     ENDIF
    DETAIL
     row + 1, col 0, dccp_parsefile->rows[d.seq].row
    WITH nocounter, append, maxcol = 5000,
     format = variable, formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(dccp_plan_file)
    CALL echorecord(dccp_parsefile)
   ENDIF
   SET dccp_parsefile->row_cnt = 0
   SET stat = alterlist(dccp_parsefile->rows,dccp_parsefile->row_cnt)
 ENDFOR
 IF (dcr_apply_rpt_retention(null)=0)
  GO TO exit_program
 ENDIF
 GO TO exit_program
#exit_program
 SET dm_err->eproc = build("Plan information was generated successfully for <",dccp_driver->
  script_cnt,"> custom scripts to <",dccp_plan_file,">.")
 CALL final_disp_msg("dm2_custcclcp")
END GO
