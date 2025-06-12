CREATE PROGRAM drc_grp_reltn_fix_nohistory:dba
 DECLARE fix_code = vc
 SET fix_code = "-"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="MULTUM"
   AND d.info_name="201311_DRC_GRP_RELTN_FIX"
  DETAIL
   fix_code = d.info_char
  WITH nocounter
 ;end select
 DECLARE missing_data = vc
 SET missing_data = "F"
 SELECT INTO "nl:"
  FROM drc_group_reltn_ver dgrv
  WHERE  NOT ( EXISTS (
  (SELECT
   1
   FROM drc_group_reltn dgr
   WHERE dgr.drug_synonym_id=dgrv.drug_synonym_id
    AND dgr.formulation_id=dgrv.formulation_id)))
  DETAIL
   missing_data = "T"
  WITH nocounter
 ;end select
 CALL echo(build("The value of missing data is ",missing_data))
 IF (missing_data="T")
  INSERT  FROM drc_group_reltn dgr
   (dgr.drc_group_reltn_id, dgr.formulation_id, dgr.drug_synonym_id,
   dgr.drc_group_id, dgr.active_ind, dgr.updt_applctx,
   dgr.updt_cnt, dgr.updt_dt_tm, dgr.updt_id,
   dgr.updt_task)(SELECT
    drc_group_reltn_id, formulation_id, drug_synonym_id,
    drc_group_id, active_ind, updt_applctx,
    updt_cnt, updt_dt_tm, updt_id,
    updt_task
    FROM drc_group_reltn_ver t1
    WHERE (t1.ver_seq=
    (SELECT
     max(ver_seq)
     FROM drc_group_reltn_ver t2
     WHERE t1.drc_group_id=t2.drc_group_id
      AND t1.drug_synonym_id=t2.drug_synonym_id
      AND t1.formulation_id=t2.formulation_id))
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM drc_group_reltn t3
     WHERE t1.drug_synonym_id=t3.drug_synonym_id
      AND t1.formulation_id=t3.formulation_id))))
  ;end insert
  COMMIT
  EXECUTE kia_rdm_mltm_drc
  COMMIT
 ENDIF
 IF (fix_code="-")
  INSERT  FROM dm_info d
   SET d.info_domain = "MULTUM", d.info_name = "201311_DRC_GRP_RELTN_FIX", d.info_char = "1"
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
END GO
