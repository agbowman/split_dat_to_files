CREATE PROGRAM dcp_set_def_encntr:dba
 RECORD encntr(
   1 nv_cnt = i4
   1 qual[*]
     2 flag = i2
     2 pvc_name = vc
 )
 RECORD name_value(
   1 nv_cnt = i4
   1 qual[*]
     2 pvc_name = vc
 )
 SET count1 = 5
 SET stat = alterlist(encntr->qual,count1)
 FOR (x = 1 TO count1)
   SET encntr->qual[x].flag = 0
 ENDFOR
 SET encntr->qual[1].pvc_name = text("encntrDisp.INPATIENT")
 SET encntr->qual[2].pvc_name = text("encntrDisp.EMERGENCY")
 SET encntr->qual[3].pvc_name = text("encntrDisp.OUTPATIENT")
 SET encntr->qual[4].pvc_name = text("encntrDisp.RECURRING")
 SET encntr->qual[5].pvc_name = text("encntrDisp.DEFAULT")
 SET encntr->nv_cnt = count1
 SET count = 0
 DECLARE app_prefs_id = f8 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  aps.app_prefs_id
  FROM app_prefs aps
  WHERE aps.prsnl_id=0
   AND aps.position_cd=0
   AND aps.application_number=600005
  DETAIL
   app_prefs_id = aps.app_prefs_id
  WITH nocounter
 ;end select
 IF (app_prefs_id=0)
  SELECT INTO "nl:"
   j = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    app_prefs_id = j
   WITH format, nocounter
  ;end select
  INSERT  FROM app_prefs ap
   SET ap.app_prefs_id = app_prefs_id, ap.application_number = 600005, ap.position_cd = 0,
    ap.prsnl_id = 0, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
    updt_applctx,
    ap.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET readme_data->message = build(
   "PVReadMe 1102:No sys level app prefs row found. App Pref row added for 600005.")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  nvp.pvc_name
  FROM name_value_prefs nvp
  WHERE nvp.parent_entity_id=app_prefs_id
   AND nvp.pvc_name="encntrDisp.*"
  DETAIL
   count = (count+ 1), stat = alterlist(name_value->qual,count), name_value->qual[count].pvc_name =
   nvp.pvc_name,
   name_value->nv_cnt = count
  WITH nocounter
 ;end select
 IF ((name_value->nv_cnt > 0))
  SET readme_data->message = build(
   "PVReadMe 1102:Found value pref rows where pvc_name like 'encntrDisp'.")
 ELSE
  SET readme_data->message = build(
   "PVReadMe 1102:No value pref rows where pvc_name like 'encntrDisp'.")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
 FOR (x = 1 TO name_value->nv_cnt)
   CASE (name_value->qual[x].pvc_name)
    OF "encntrDisp.INPATIENT":
     SET encntr->qual[1].flag = 1
    OF "encntrDisp.EMERGENCY":
     SET encntr->qual[2].flag = 1
    OF "encntrDisp.OUTPATIENT":
     SET encntr->qual[3].flag = 1
    OF "encntrDisp.RECURRING":
     SET encntr->qual[4].flag = 1
    OF "encntrDisp.DEFAULT":
     SET encntr->qual[5].flag = 1
   ENDCASE
 ENDFOR
 IF (app_prefs_id > 0)
  SET insert_cnt = 0
  SET pvc_value = fillstring(255," ")
  FOR (x = 1 TO encntr->nv_cnt)
    IF ((encntr->qual[x].flag=0))
     CASE (encntr->qual[x].pvc_name)
      OF "encntrDisp.INPATIENT":
       SET pvc_value = "%1 [%5 - %6]"
      OF "encntrDisp.OUTPATIENT":
       SET pvc_value = "%1 [%5]:Fin#:%8"
      OF "encntrDisp.RECURRING":
       SET pvc_value = "%1 [%5 %6]:Fin#:%8"
      OF "encntrDisp.EMERGENCY":
       SET pvc_value = "%1 [%5 %6] Fin#:%8"
      OF "encntrDisp.DEFAULT":
       SET pvc_value = "%1"
     ENDCASE
     SET insert_cnt = (insert_cnt+ 1)
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = app_prefs_id,
       nvp.pvc_name = encntr->qual[x].pvc_name,
       nvp.pvc_value = pvc_value, nvp.parent_entity_name = "APP_PREFS", nvp.active_ind = 1,
       nvp.updt_id = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     ;end insert
    ENDIF
  ENDFOR
  SET readme_data->status = "S"
  IF (insert_cnt > 0)
   SET readme_data->message = build("PVReadMe 1102:",insert_cnt,
    "rows inserted into name_value_prefs.")
   EXECUTE dm_readme_status
  ELSE
   SET readme_data->message = build(
    "PVReadMe 1102:Zero rows inserted to nvp, no pvc_names needed updated.")
   EXECUTE dm_readme_status
  ENDIF
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1102:App Prefs Id = 0, no update to nvp made.")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
 SET readme_data->message = build("PVReadMe 1102:dcp_set_def_encntr: Update of def encntr prefs.")
 EXECUTE dm_readme_status
 COMMIT
 COMMIT
END GO
