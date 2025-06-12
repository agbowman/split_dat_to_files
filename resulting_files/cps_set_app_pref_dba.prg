CREATE PROGRAM cps_set_app_pref:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 except_data[*]
      2 app_id = i4
      2 spec[*]
        3 section = vc
        3 success = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET true = 1
 SET false = 0
 SET reply->status_data.status = "F"
 SET nbr_of_apps = size(request->appl,5)
 SET stat = alterlist(reply->except_data,nbr_of_apps)
 SET nbr_of_secs = 0
 SET app_knt = 0
 SET sec_knt = 0
 SET app_knt += 1
 FOR (app_knt = app_knt TO nbr_of_apps)
   SET nbr_of_secs = size(request->appl[app_knt].sect,5)
   SET stat = alterlist(reply->except_data[app_knt].spec,nbr_of_secs)
   SET reply->except_data[app_knt].app_id = request->appl[app_knt].application_number
   SET sec_knt = 1
   FOR (sec_knt = sec_knt TO nbr_of_secs)
     SET reply->except_data[app_knt].spec[sec_knt].section = request->appl[app_knt].sect[sec_knt].
     section
     SET reply->except_data[app_knt].spec[sec_knt].success = true
     IF (sec_knt=1)
      DELETE  FROM application_ini a
       WHERE (a.person_id=request->person_id)
        AND (a.application_number=request->appl[app_knt].application_number)
       WITH nocounter
      ;end delete
      IF (curqual != 0)
       COMMIT
      ENDIF
     ENDIF
     INSERT  FROM application_ini a
      SET a.person_id = request->person_id, a.application_number = request->appl[app_knt].
       application_number, a.section = request->appl[app_knt].sect[sec_knt].section,
       a.parameter_data = request->appl[app_knt].sect[sec_knt].parameter_data, a.updt_dt_tm =
       cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
       a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      SET reply->except_data[app_knt].spec[sec_knt].success = false
      ROLLBACK
     ELSE
      COMMIT
     ENDIF
   ENDFOR
 ENDFOR
END GO
