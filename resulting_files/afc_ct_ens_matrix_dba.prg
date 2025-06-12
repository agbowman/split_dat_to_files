CREATE PROGRAM afc_ct_ens_matrix:dba
 DECLARE afc_ct_ens_matrix_version = vc WITH private, noconstant("318193.FT.002")
 RECORD reply(
   1 tier_cnt = i4
   1 tier_row[*]
     2 ruleset_id = f8
     2 tier_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dtempid = f8 WITH public, noconstant(0.0)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE idcnt = i4 WITH public, noconstant(0)
 DECLARE inserttierdetails(rowsize=i4,entityname=vc,entityid=vc) = null
 DECLARE inactivatetier(tierid=f8) = null
 DECLARE inactivatetierdetails(tierid=f8) = null
 DECLARE nextseq(seq=f8) = null
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET stat = alterlist(reply->tier_row,size(request->tier_row,5))
 FOR (cnt = 1 TO size(request->tier_row,5))
   IF ((request->tier_row[cnt].delete_tier=1))
    SET dtempid = request->tier_row[cnt].tier_id
    CALL inactivatetierdetails(dtempid)
    CALL inactivatetier(dtempid)
    SET dtempid = 0
   ELSE
    SET dtempid = request->tier_row[cnt].tier_id
    IF (dtempid=0)
     SET dtempid = nextseq(0.0)
     INSERT  FROM cs_cpp_tier t
      SET t.cs_cpp_tier_id = dtempid, t.cs_cpp_ruleset_id = request->tier_row[cnt].ruleset_id, t
       .priority_nbr = request->tier_row[cnt].row_num,
       t.health_plan_excld_ind = request->tier_row[cnt].health_plan_excl_ind, t
       .organization_excld_ind = request->tier_row[cnt].org_excl_ind, t.ins_org_excld_ind = request->
       tier_row[cnt].ins_org_excl_ind,
       t.encntr_type_excld_ind = request->tier_row[cnt].encntr_type_excl_ind, t
       .encntr_type_class_excld_ind = request->tier_row[cnt].encntr_type_class_excl_ind, t
       .fin_class_excld_ind = request->tier_row[cnt].fin_class_excl_ind,
       t.charge_status_ind = request->tier_row[cnt].charge_status_ind, t.active_ind = 1, t
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       t.updt_cnt = 1, t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.health_plan_id =
       0.0,
       t.organization_id = 0.0, t.ins_org_id = 0.0, t.encntr_type_cd = 0.0,
       t.fin_class_cd = 0.0
      WITH nocounter
     ;end insert
     IF (curqual < 1)
      GO TO end_script
     ENDIF
    ELSE
     UPDATE  FROM cs_cpp_tier t
      SET t.cs_cpp_ruleset_id = request->tier_row[cnt].ruleset_id, t.priority_nbr = request->
       tier_row[cnt].row_num, t.health_plan_excld_ind = request->tier_row[cnt].health_plan_excl_ind,
       t.organization_excld_ind = request->tier_row[cnt].org_excl_ind, t.ins_org_excld_ind = request
       ->tier_row[cnt].ins_org_excl_ind, t.encntr_type_excld_ind = request->tier_row[cnt].
       encntr_type_excl_ind,
       t.encntr_type_class_excld_ind = request->tier_row[cnt].encntr_type_class_excl_ind, t
       .fin_class_excld_ind = request->tier_row[cnt].fin_class_excl_ind, t.charge_status_ind =
       request->tier_row[cnt].charge_status_ind,
       t.updt_cnt = (t.updt_cnt+ 1), t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
      WHERE t.cs_cpp_tier_id=dtempid
      WITH nocounter
     ;end update
     IF (curqual < 1)
      GO TO end_script
     ENDIF
    ENDIF
    CALL inactivatetierdetails(dtempid)
    IF (size(request->tier_row[cnt].health_plan,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].health_plan,5),"HEALTH_PLAN")
    ENDIF
    IF (size(request->tier_row[cnt].encntr_type,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].encntr_type,5),"ENCNTR_TYPE")
    ENDIF
    IF (size(request->tier_row[cnt].organization,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].organization,5),"ORGANIZATION")
    ENDIF
    IF (size(request->tier_row[cnt].insurance_org,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].insurance_org,5),"INSURANCE_ORG")
    ENDIF
    IF (size(request->tier_row[cnt].fin_class,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].fin_class,5),"FIN_CLASS")
    ENDIF
    IF (size(request->tier_row[cnt].encntr_type_class,5) > 0)
     CALL inserttierdetails(size(request->tier_row[cnt].encntr_type_class,5),"ENCNTR_TYPE_CLASS")
    ENDIF
   ENDIF
   SET reply->tier_row[cnt].ruleset_id = request->tier_row[cnt].ruleset_id
   SET reply->tier_row[cnt].tier_id = dtempid
 ENDFOR
 SUBROUTINE nextseq(seq)
  SELECT INTO "nl:"
   next_seq = seq(pft_ref_seq,nextval)"###############;rp0"
   FROM dual
   DETAIL
    seq = next_seq
   WITH nocounter
  ;end select
  RETURN(seq)
 END ;Subroutine
 SUBROUTINE inserttierdetails(rowsize,entityname)
   DECLARE dtempdetid = f8 WITH public, noconstant(0.0)
   DECLARE entitysubtype = vc WITH public, noconstant("")
   DECLARE detailentityname = vc WITH public, noconstant("")
   FOR (idcnt = 1 TO rowsize)
     SET entitysubtype = ""
     IF (entityname="HEALTH_PLAN")
      SET detailentityname = "HEALTH_PLAN"
      SET temp = request->tier_row[cnt].health_plan[idcnt].health_plan_id
     ELSEIF (entityname="ORGANIZATION")
      SET detailentityname = "ORGANIZATION"
      SET temp = request->tier_row[cnt].organization[idcnt].org_id
     ELSE
      SET detailentityname = "CODE_VALUE"
      IF (entityname="INSURANCE_ORG")
       SET entitysubtype = "INSURANCE_ORG"
       SET temp = request->tier_row[cnt].insurance_org[idcnt].ins_org_id
      ELSEIF (entityname="ENCNTR_TYPE")
       SET entitysubtype = "ENCNTR_TYPE"
       SET temp = request->tier_row[cnt].encntr_type[idcnt].encntr_type_cd
      ELSEIF (entityname="FIN_CLASS")
       SET entitysubtype = "FIN_CLASS"
       SET temp = request->tier_row[cnt].fin_class[idcnt].fin_class_cd
      ELSEIF (entityname="ENCNTR_TYPE_CLASS")
       SET entitysubtype = "ENCNTR_TYPE_CLASS"
       SET temp = request->tier_row[cnt].encntr_type_class[idcnt].encntr_type_class_cd
      ENDIF
     ENDIF
     SET dtempdetid = nextseq(0.0)
     INSERT  FROM cs_cpp_tier_detail td
      SET td.active_ind = 1, td.cs_cpp_tier_detail_id = dtempdetid, td.cs_cpp_tier_id = dtempid,
       td.cs_cpp_tier_detail_entity_id = temp, td.cs_cpp_tier_detail_entity_name = detailentityname,
       td.cs_cpp_tier_detail_subtype = entitysubtype,
       td.updt_cnt = 1, td.updt_id = reqinfo->updt_id, td.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       td.updt_task = reqinfo->updt_task, td.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual < 1)
      GO TO end_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE inactivatetierdetails(tierid)
   UPDATE  FROM cs_cpp_tier_detail td
    SET td.active_ind = 0, td.updt_cnt = (td.updt_cnt+ 1), td.updt_id = reqinfo->updt_id,
     td.updt_dt_tm = cnvtdatetime(curdate,curtime3), td.updt_task = reqinfo->updt_task, td
     .updt_applctx = reqinfo->updt_applctx
    WHERE td.cs_cpp_tier_id=tierid
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE inactivatetier(tierid)
   UPDATE  FROM cs_cpp_tier t
    SET t.active_ind = 0, t.updt_cnt = (t.updt_cnt+ 1), t.updt_id = reqinfo->updt_id,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_applctx
      = reqinfo->updt_applctx
    WHERE t.cs_cpp_tier_id=tierid
    WITH nocounter
   ;end update
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET reply->tier_cnt = size(reply->tier_row,5)
 SET reqinfo->commit_ind = 1
#end_script
 IF ((reply->status_data.status="F"))
  SET reply->tier_cnt = 0
  SET stat = alterlist(reply->tier_row,0)
 ENDIF
END GO
