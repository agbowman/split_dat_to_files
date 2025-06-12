CREATE PROGRAM afc_rdm_ins_ct_tier_detail:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD cpptier
 RECORD cpptier(
   1 cpptierrows[*]
     2 cpp_tierid = f8
     2 encntrtypelist[1]
       3 encntrtypecd = f8
     2 healthplanlist[1]
       3 helathplanid = f8
     2 organizationlist[1]
       3 orgid = f8
     2 insorglist[1]
       3 insorgid = f8
     2 finclasslist[1]
       3 finclasscd = f8
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme afc_rdm_ins_ct_tier_detail failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE dseq = f8 WITH protect, noconstant(0.0)
 DECLARE insertdetailrow(tierid=f8,detailentityname=vc,entitysubtype=vc,entityid=f8) = null
 CALL echo("Evaluate existing tiers for processing")
 SELECT INTO "nl:"
  FROM cs_cpp_tier t
  WHERE t.cs_cpp_tier_id > 0.0
   AND ((t.fin_class_cd > 0.0) OR (((t.health_plan_id > 0.0) OR (((t.encntr_type_cd > 0.0) OR (((t
  .organization_id > 0.0) OR (t.ins_org_id > 0.0)) )) )) ))
  HEAD t.cs_cpp_tier_id
   icnt = (icnt+ 1), stat = alterlist(cpptier->cpptierrows,icnt), cpptier->cpptierrows[icnt].
   cpp_tierid = t.cs_cpp_tier_id
   IF (t.encntr_type_cd > 0.0)
    cpptier->cpptierrows[icnt].encntrtypelist[1].encntrtypecd = t.encntr_type_cd
   ENDIF
   IF (t.health_plan_id > 0.0)
    cpptier->cpptierrows[icnt].healthplanlist[1].helathplanid = t.health_plan_id
   ENDIF
   IF (t.organization_id > 0.0)
    cpptier->cpptierrows[icnt].organizationlist[1].orgid = t.organization_id
   ENDIF
   IF (t.ins_org_id > 0.0)
    cpptier->cpptierrows[icnt].insorglist[1].insorgid = t.ins_org_id
   ENDIF
   IF (t.fin_class_cd > 0.0)
    cpptier->cpptierrows[icnt].finclasslist[1].finclasscd = t.fin_class_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build(errmsg,
   "Failed to get retrieve tier rows for data porting to new table.")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Readme - There are no tiers which needs data porting to new table"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(cpptier->cpptierrows,5))
   IF ((cpptier->cpptierrows[i].encntrtypelist[1].encntrtypecd > 0.0))
    CALL insertdetailrow(cpptier->cpptierrows[i].cpp_tierid,"CODE_VALUE","ENCNTR_TYPE",cpptier->
     cpptierrows[i].encntrtypelist[1].encntrtypecd)
   ENDIF
   IF ((cpptier->cpptierrows[i].healthplanlist[1].helathplanid > 0.0))
    CALL insertdetailrow(cpptier->cpptierrows[i].cpp_tierid,"HEALTH_PLAN","",cpptier->cpptierrows[i].
     healthplanlist[1].helathplanid)
   ENDIF
   IF ((cpptier->cpptierrows[i].organizationlist[1].orgid > 0.0))
    CALL insertdetailrow(cpptier->cpptierrows[i].cpp_tierid,"ORGANIZATION","",cpptier->cpptierrows[i]
     .organizationlist[1].orgid)
   ENDIF
   IF ((cpptier->cpptierrows[i].insorglist[1].insorgid > 0.0))
    CALL insertdetailrow(cpptier->cpptierrows[i].cpp_tierid,"CODE_VALUE","INS_ORG",cpptier->
     cpptierrows[i].insorglist[1].insorgid)
   ENDIF
   IF ((cpptier->cpptierrows[i].finclasslist[1].finclasscd > 0.0))
    CALL insertdetailrow(cpptier->cpptierrows[i].cpp_tierid,"CODE_VALUE","FIN_CLASS",cpptier->
     cpptierrows[i].finclasslist[1].finclasscd)
   ENDIF
 ENDFOR
 UPDATE  FROM cs_cpp_tier t,
   (dummyt dt  WITH seq = value(size(cpptier->cpptierrows,5)))
  SET t.health_plan_id = 0.0, t.fin_class_cd = 0.0, t.encntr_type_cd = 0.0,
   t.organization_id = 0.0, t.ins_org_id = 0.0, t.updt_cnt = (t.updt_cnt+ 1),
   t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo
   ->updt_task,
   t.updt_applctx = reqinfo->updt_applctx
  PLAN (dt)
   JOIN (t
   WHERE (t.cs_cpp_tier_id=cpptier->cpptierrows[dt.seq].cpp_tierid))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = build(errmsg,"Failed to update existing tier rows.")
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET readme_data->status = "F"
  SET readme_data->message = build("None Qualified - Failed to update existing tier rows.")
  ROLLBACK
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme"
 GO TO exit_script
 SUBROUTINE insertdetailrow(tierid,detailentityname,entitysubtype,entityid)
   SET dseq = 0.0
   SELECT INTO "nl:"
    next_seq = seq(pft_ref_seq,nextval)"###############;rp0"
    FROM dual
    DETAIL
     dseq = next_seq
    WITH nocounter
   ;end select
   IF (((error(errmsg,0) != 0) OR (dseq=0.0)) )
    SET readme_data->status = "F"
    SET readme_data->message = build(errmsg,
     "insertDetailRow():Next Sequence - Failed to get next sequence.")
    GO TO exit_script
   ENDIF
   INSERT  FROM cs_cpp_tier_detail t
    SET t.cs_cpp_tier_detail_id = dseq, t.cs_cpp_tier_id = tierid, t.cs_cpp_tier_detail_entity_id =
     entityid,
     t.cs_cpp_tier_detail_entity_name = detailentityname, t.cs_cpp_tier_detail_subtype =
     entitysubtype, t.active_ind = true,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
     reqinfo->updt_task,
     t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = build(errmsg,"insertDetailRow():Insert - Failed to insert.")
    GO TO exit_script
   ENDIF
   IF (curqual < 1)
    SET readme_data->status = "F"
    SET readme_data->message = build("insertDetailRow():None - Failed to insert.")
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD cpptier
END GO
