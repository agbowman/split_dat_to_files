CREATE PROGRAM bed_ens_route:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE SET reply
 RECORD reply(
   1 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE route_disp = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET medication = 1
 SET intermittent = 2
 SET continuous = 4
 SET field_value = 0.0
 SET cnt = 0
 IF ((request->medication_ind=1))
  SET field_value = (field_value+ medication)
 ENDIF
 IF ((request->intermittent_ind=1))
  SET field_value = (field_value+ intermittent)
 ENDIF
 IF ((request->continuous_ind=1))
  SET field_value = (field_value+ continuous)
 ENDIF
 SET request_cv->cd_value_list[1].action_flag = 1
 SET request_cv->cd_value_list[1].code_set = 4001
 SET request_cv->cd_value_list[1].collation_seq = 1
 SET request_cv->cd_value_list[1].display = substring(1,40,request->display)
 SET request_cv->cd_value_list[1].description = substring(1,60,request->description)
 SET request_cv->cd_value_list[1].definition = request->description
 SET request_cv->cd_value_list[1].active_ind = 1
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET reply->code_value = reply_cv->qual[1].code_value
 ELSE
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert ",trim(request->display)," into codeset 4001.")
  GO TO exit_script
 ENDIF
 INSERT  FROM code_value_extension c
  SET c.code_value = reply->code_value, c.code_set = 4001, c.field_name = "ORDERED AS",
   c.field_type = 1.00, c.field_value = cnvtstring(field_value), c.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
   c.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert: ",trim(request->display),
   " into the code_value_extension table.")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  m.route_id
  FROM mltm_drc_premise m
  WHERE (m.route_id=request->route_id)
  HEAD m.route_id
   route_disp = m.route_disp
  WITH nocounter
 ;end select
 SET new_entity_id = 0.0
 SELECT INTO "NL:"
  j = seq(carenet_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_entity_id = cnvtreal(j)
  WITH format, counter
 ;end select
 INSERT  FROM dcp_entity_reltn d
  SET d.dcp_entity_reltn_id = new_entity_id, d.entity_reltn_mean = "DRC/ROUTE", d.entity1_id =
   request->route_id,
   d.entity1_display = route_disp, d.entity2_id = reply->code_value, d.entity2_display = request->
   display,
   d.rank_sequence = 0, d.active_ind = 1, d.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.entity1_name = "MLTM_DRC_PREMISE", d
   .entity2_name = "CODE_VALUE",
   d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
   ->updt_task,
   d.updt_cnt = 0, d.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to insert: ",trim(request->display),
   " into the dcp_entity_reltn table.")
  GO TO exit_script
 ENDIF
 SET cnt = size(request->route_forms,5)
 FOR (x = 1 TO cnt)
  INSERT  FROM route_form_r r
   SET r.route_cd = reply->code_value, r.form_cd = request->route_forms[x].code_value, r.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_cnt = 0,
    r.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert: ",trim(request->display),
    " into the route_form_r table.")
   GO TO exit_script
  ENDIF
 ENDFOR
 IF ((request->route_id > 0))
  DELETE  FROM br_name_value b
   WHERE b.br_nv_key1="MLTM_IGN_ROUTE"
    AND b.br_value=cnvtstring(request->route_id)
    AND b.br_name="MLTM_DRC_PREMISE"
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
