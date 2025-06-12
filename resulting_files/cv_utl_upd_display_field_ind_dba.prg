CREATE PROGRAM cv_utl_upd_display_field_ind:dba
 PROMPT
  "Enter ACC follow up control indicator:(e.g. On use '1', Off use '0' [0] = " = "0",
  "Enter ACC device control indicator:(e.g. On use '1', Off use '0' [0] = " = "0"
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE upd_failed = c1 WITH public, noconstant("F")
 DECLARE fu_ind = i2 WITH public, noconstant(0)
 DECLARE device_ind = i2 WITH public, noconstant(0)
 IF (trim(cnvtupper( $1))="1")
  SET fu_ind = 1
 ENDIF
 IF (trim(cnvtupper( $2))="1")
  SET device_ind = 1
 ENDIF
 UPDATE  FROM cv_xref ref
  SET ref.display_field_ind = fu_ind, ref.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ref
   .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   ref.updt_dt_tm = cnvtdatetime(curdate,curtime), ref.updt_cnt = (ref.updt_cnt+ 1), ref.updt_id =
   reqinfo->updt_id,
   ref.updt_task = reqinfo->updt_task, ref.updt_applctx = reqinfo->updt_applctx, ref.active_status_cd
    = reqdata->active_status_cd,
   ref.updt_req = reqinfo->updt_req, ref.updt_app = reqinfo->updt_app, ref.active_ind = 1
  PLAN (ref
   WHERE ref.xref_internal_name IN ("ACC02_XDOF", "ACC02_XVITAL", "ACC02_XDEATH", "ACC02_XREADM",
   "ACC02_XRREASON"))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET upd_failed = "T"
 ENDIF
 UPDATE  FROM cv_xref ref
  SET ref.display_field_ind = device_ind, ref.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ref.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   ref.updt_dt_tm = cnvtdatetime(curdate,curtime), ref.updt_cnt = (ref.updt_cnt+ 1), ref.updt_id =
   reqinfo->updt_id,
   ref.updt_task = reqinfo->updt_task, ref.updt_applctx = reqinfo->updt_applctx, ref.active_status_cd
    = reqdata->active_status_cd,
   ref.updt_req = reqinfo->updt_req, ref.updt_app = reqinfo->updt_app, ref.active_ind = 1
  PLAN (ref
   WHERE ref.xref_internal_name IN ("ACC02_LDEVNUM", "ACC02_LDPTD", "ACC02_LDDEVICE",
   "ACC02_LDDEVICE1", "ACC02_LDDEVICE2",
   "ACC02_LDDEVICE3", "ACC02_LDDEVICE4", "ACC02_LDDEVICE5", "ACC02_LDDEVICE6", "ACC02_LDDEVICE7",
   "ACC02_LDDEVICE8", "ACC02_LDDEVICE9", "ACC02_LDDEVICE10", "ACC02_LDDEVICE11", "ACC02_LDDEVICE12",
   "ACC02_LDDEVICE13", "ACC02_LDDEVICE14", "ACC02_LDDEVICE15", "ACC02_LDDEVICE16", "ACC02_LDDEVICE17",
   "ACC02_LDDEVICE18", "ACC02_LDDEVICE19", "ACC02_LDDEVICE20"))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET upd_failed = "T"
 ENDIF
#exit_script
 IF (upd_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo("*******************************************************************")
  CALL echo("Display_field_ind in cv_xref were not updated and action rollbacked")
  CALL echo("*******************************************************************")
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("Display_field_ind in cv_xref were updated and action committed")
  CALL echo("**************************************************************")
 ENDIF
END GO
