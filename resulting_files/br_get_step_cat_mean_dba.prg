CREATE PROGRAM br_get_step_cat_mean:dba
 FREE SET reply
 RECORD reply(
   1 sclist[*]
     2 step_cat_mean = vc
     2 step_cat_disp = vc
     2 selected_ind = i2
     2 scslist[*]
       3 step_mean = vc
       3 step_disp = vc
       3 default_seq = i4
   1 sollist[*]
     2 sol_mean = vc
     2 sol_disp = vc
     2 solslist[*]
       3 step_mean = vc
       3 step_disp = vc
       3 step_cat_mean = vc
   1 liclist[*]
     2 lic_mean = vc
     2 lic_disp = vc
     2 selected_ind = i2
   1 vlist[*]
     2 version_disp = vc
     2 version_value = i2
   1 reglist[*]
     2 region_disp = vc
     2 region_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET lcnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
    AND (bnv.br_client_id=request->br_client_id))
  ORDER BY bnv.br_value
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->sclist,cnt), reply->sclist[cnt].step_cat_mean = bnv
   .br_name,
   reply->sclist[cnt].step_cat_disp = bnv.br_value, reply->sclist[cnt].selected_ind = bnv
   .default_selected_ind
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="LICENSE"
    AND (bnv.br_client_id=request->br_client_id))
  ORDER BY bnv.br_value
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(reply->liclist,lcnt), reply->liclist[lcnt].lic_mean = bnv
   .br_name,
   reply->liclist[lcnt].lic_disp = bnv.br_value, reply->liclist[lcnt].selected_ind = bnv
   .default_selected_ind
  WITH nocounter, skipbedrock = 1
 ;end select
 FOR (x = 1 TO cnt)
   SELECT INTO "nl:"
    FROM br_step bs
    PLAN (bs
     WHERE (bs.step_cat_mean=reply->sclist[x].step_cat_mean))
    ORDER BY bs.default_seq
    HEAD REPORT
     scscnt = 0
    DETAIL
     scscnt = (scscnt+ 1), stat = alterlist(reply->sclist[x].scslist,scscnt), reply->sclist[x].
     scslist[scscnt].step_mean = bs.step_mean,
     reply->sclist[x].scslist[scscnt].step_disp = bs.step_disp, reply->sclist[x].scslist[scscnt].
     default_seq = bs.default_seq
    WITH nocounter
   ;end select
 ENDFOR
 SET vcnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="STARTVERSION"
    AND (bnv.br_client_id=request->br_client_id))
  ORDER BY bnv.br_name_value_id DESC
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(reply->vlist,vcnt), reply->vlist[vcnt].version_disp = bnv
   .br_name,
   reply->vlist[vcnt].version_value = cnvtint(bnv.br_value)
  WITH nocounter, skipbedrock = 1
 ;end select
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="REGION"
    AND (bnv.br_client_id=request->br_client_id))
  ORDER BY bnv.br_name_value_id DESC
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->reglist,rcnt), reply->reglist[rcnt].region_disp = bnv
   .br_name,
   reply->reglist[rcnt].region_value = bnv.br_value
  WITH nocounter, skipbedrock = 1
 ;end select
#exit_script
 CALL echorecord(reply)
END GO
