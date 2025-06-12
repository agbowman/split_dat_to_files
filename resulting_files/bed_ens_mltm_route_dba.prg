CREATE PROGRAM bed_ens_mltm_route:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE route_disp_mltm = vc
 DECLARE route_disp_cv = vc
 DECLARE mltm_abbr = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET mltm_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="MULTUM"
   AND cv.active_ind=1
  DETAIL
   mltm_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = size(request->multum_routes,5)
 FOR (x = 1 TO cnt)
   IF ((request->multum_routes[x].route_code_value=0))
    SET mltm_abbr = " "
    SELECT INTO "nl:"
     FROM mltm_product_route mpr
     WHERE (mpr.route_code=request->multum_routes[x].route_id)
     DETAIL
      mltm_abbr = mpr.route_abbr
     WITH nocounter
    ;end select
    IF (mltm_abbr > " ")
     DELETE  FROM code_value_alias cva
      WHERE cva.alias=mltm_abbr
       AND cva.code_set=4001
       AND cva.contributor_source_cd=mltm_code_value
      WITH nocoutner
     ;end delete
    ENDIF
    DELETE  FROM code_value_alias cva
     WHERE cva.alias=trim(cnvtstring(request->multum_routes[x].route_id))
      AND cva.code_set=4001
      AND cva.contributor_source_cd=mltm_code_value
     WITH nocoutner
    ;end delete
    DELETE  FROM dcp_entity_reltn d
     WHERE d.entity_reltn_mean="DRC/ROUTE"
      AND (d.entity1_id=request->multum_routes[x].route_id)
      AND d.entity1_name="MLTM_DRC_PREMISE"
      AND d.entity2_name="CODE_VALUE"
     WITH nocounter
    ;end delete
   ELSE
    SET mltm_abbr = " "
    SELECT INTO "nl:"
     FROM mltm_product_route mpr
     WHERE (mpr.route_code=request->multum_routes[x].route_id)
     DETAIL
      mltm_abbr = mpr.route_abbr
     WITH nocounter
    ;end select
    INSERT  FROM code_value_alias cva
     SET cva.code_set = 4001, cva.contributor_source_cd = mltm_code_value, cva.alias = mltm_abbr,
      cva.code_value = request->multum_routes[x].route_code_value, cva.primary_ind = 0, cva
      .alias_type_meaning = "ROUTE",
      cva.updt_applctx = reqinfo->updt_applctx, cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    INSERT  FROM code_value_alias cva
     SET cva.code_set = 4001, cva.contributor_source_cd = mltm_code_value, cva.alias = trim(
       cnvtstring(request->multum_routes[x].route_id)),
      cva.code_value = request->multum_routes[x].route_code_value, cva.primary_ind = 0, cva
      .alias_type_meaning = null,
      cva.updt_applctx = reqinfo->updt_applctx, cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SELECT DISTINCT INTO "nl:"
     m.route_id
     FROM mltm_drc_premise m
     WHERE (m.route_id=request->multum_routes[x].route_id)
     HEAD m.route_id
      route_disp_mltm = m.route_disp
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE (cv.code_value=request->multum_routes[x].route_code_value)
      AND code_set=4001
      AND active_ind=1
     DETAIL
      route_disp_cv = cv.display
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
      request->multum_routes[x].route_id,
      d.entity1_display = route_disp_mltm, d.entity2_id = request->multum_routes[x].route_code_value,
      d.entity2_display = route_disp_cv,
      d.rank_sequence = 0, d.active_ind = 1, d.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.entity1_name = "MLTM_DRC_PREMISE", d
      .entity2_name = "CODE_VALUE",
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
      reqinfo->updt_task,
      d.updt_cnt = 0, d.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert: ",trim(route_disp_mltm),
      " into the dcp_entity_reltn table.")
     GO TO exit_script
    ENDIF
    DELETE  FROM br_name_value b
     WHERE b.br_nv_key1="MLTM_IGN_ROUTE"
      AND b.br_value=cnvtstring(request->multum_routes[x].route_id)
      AND b.br_name="MLTM_DRC_PREMISE"
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
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
