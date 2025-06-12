CREATE PROGRAM dcp_upd_pw_cat_flex:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "FAIL:dcp_upd_pw_cat_flex.prg failed to update plan catalog flexing rows"
 RECORD plans(
   1 list[*]
     2 pathway_catalog_id = f8
     2 description = vc
 )
 DECLARE plancnt = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM pathway_catalog pwc
  PLAN (pwc
   WHERE pwc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND pwc.ref_owner_person_id=0
    AND  NOT ( EXISTS (
   (SELECT
    pcf.pathway_catalog_id
    FROM pw_cat_flex pcf
    WHERE pcf.pathway_catalog_id=pwc.pathway_catalog_id
     AND pcf.parent_entity_name="CODE_VALUE"))))
  HEAD REPORT
   plancnt = 0
  DETAIL
   plancnt = (plancnt+ 1)
   IF (plancnt > size(plans->list,5))
    stat = alterlist(plans->list,(plancnt+ 100))
   ENDIF
   plans->list[plancnt].pathway_catalog_id = pwc.pathway_catalog_id, plans->list[plancnt].description
    = trim(pwc.description)
  FOOT REPORT
   stat = alterlist(plans->list,plancnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO plancnt)
  INSERT  FROM pw_cat_flex pcf
   SET pcf.display_description_key = trim(cnvtupper(plans->list[i].description)), pcf
    .pathway_catalog_id = plans->list[i].pathway_catalog_id, pcf.parent_entity_id = 0,
    pcf.parent_entity_name = "CODE_VALUE", pcf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcf
    .updt_id = 0,
    pcf.updt_task = 0, pcf.updt_applctx = 0, pcf.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET readme_data->message = "Unable to insert into PW_CAT_FLEX"
   GO TO exit_script
  ENDIF
 ENDFOR
 FREE RECORD plans
 SET plancnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog pwc
  PLAN (pwc
   WHERE pwc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pwc.display_description IN (" ", null))
  HEAD REPORT
   plancnt = 1
  WITH nocounter
 ;end select
 IF (plancnt > 0)
  UPDATE  FROM pathway_catalog pwc
   SET pwc.display_description = pwc.description, pwc.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE pwc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pwc.display_description IN (" ", null)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET readme_data->message = "Unable to update PATHWAY_CATALOG"
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "PW_CAT_FLEX & PATHWAY_CATALOG updated successfully"
#exit_script
 EXECUTE dm_readme_status
END GO
