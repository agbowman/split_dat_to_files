CREATE PROGRAM cv_utl_switch_req_proc:dba
 PROMPT
  "Do you want CVNet processing active? [Y]" = "Y"
 DECLARE new_val = i2 WITH public, noconstant(0)
 DECLARE old_val = i2 WITH public, noconstant(0)
 DECLARE ierror = i4 WITH public, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE iprocknt = i4 WITH public, noconstant(0)
 IF (cnvtupper( $1)="Y")
  SET new_val = 1
  SET old_val = 0
 ELSE
  SET new_val = 0
  SET old_val = 1
 ENDIF
 SET iprocknt = (iprocknt+ 1)
 SET ierror = error(serrmsg,1)
 SET ierror = 0
 UPDATE  FROM request_processing r
  SET r.active_ind = new_val, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = (r.updt_cnt
   + 1),
   r.updt_applctx = 3091000
  PLAN (r
   WHERE r.request_number=3091000
    AND r.active_ind=old_val
    AND ((r.target_request_number=4100510) OR (r.format_script IN ("PFMT_CV_SUMMARY_DATA",
   "PFMT_CV_OMF_SUMMARY_DATA")
    AND new_val=0)) )
  WITH nocounter
 ;end update
 SET ierror = error(serrmsg,1)
 IF (ierror > 0)
  GO TO exit_script
 ENDIF
 SET iprocknt = (iprocknt+ 1)
 SET ierror = error(serrmsg,1)
 SET ierror = 0
 UPDATE  FROM request_processing r
  SET r.active_ind = new_val, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = (r.updt_cnt
   + 1),
   r.updt_applctx = 600353
  PLAN (r
   WHERE r.request_number=600353
    AND r.active_ind=old_val
    AND ((r.target_request_number=4100511) OR (r.format_script="PFMT_CV_FORM_CHARTED"
    AND new_val=0)) )
  WITH nocounter
 ;end update
 SET ierror = error(serrmsg,1)
 IF (ierror > 0)
  GO TO exit_script
 ENDIF
 SET iprocknt = (iprocknt+ 1)
 SET ierror = error(serrmsg,1)
 SET ierror = 0
 UPDATE  FROM request_processing r
  SET r.active_ind = new_val, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = (r.updt_cnt
   + 1),
   r.updt_applctx = 114001
  PLAN (r
   WHERE r.request_number=114001
    AND r.active_ind=old_val
    AND ((r.target_request_number=4100512) OR (r.format_script="PFMT_E_CV_GET_DISCH_DT_TM"
    AND new_val=0)) )
  WITH nocounter
 ;end update
 SET ierror = error(serrmsg,1)
 IF (ierror > 0)
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 IF (ierror > 0)
  ROLLBACK
  CALL echo("***")
  CALL echo(concat("*** Error   : ",serrmsg))
  CALL echo(concat("*** ProcKnt : ",cnvtstring(iprocknt)))
  CALL echo("***")
 ELSE
  CALL echo("***")
  CALL echo("*** Action Successful.")
  CALL echo("***")
 ENDIF
END GO
