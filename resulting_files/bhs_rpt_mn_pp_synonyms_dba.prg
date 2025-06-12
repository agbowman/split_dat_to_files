CREATE PROGRAM bhs_rpt_mn_pp_synonyms:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mf_mgeneric_syn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICTOP"))
 DECLARE mf_ntrade_syn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADETOP"))
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  powerplan = p.description, phase = pcp.description, p.type_mean,
  ocs.mnemonic, mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd), order_sentence = os
  .order_sentence_display_line
  FROM pathway_catalog p,
   pw_cat_reltn pcr,
   pathway_catalog pcp,
   pathway_comp pc,
   order_catalog_synonym ocs,
   pw_comp_os_reltn pcor,
   order_sentence os
  PLAN (p
   WHERE p.active_ind=1
    AND p.type_mean != "PHASE")
   JOIN (pcr
   WHERE (pcr.pw_cat_s_id= Outerjoin(p.pathway_catalog_id))
    AND (pcr.type_mean= Outerjoin("GROUP")) )
   JOIN (pcp
   WHERE (pcp.pathway_catalog_id= Outerjoin(pcr.pw_cat_t_id))
    AND (pcp.type_mean= Outerjoin("PHASE"))
    AND (pcp.active_ind= Outerjoin(1)) )
   JOIN (pc
   WHERE ((pc.pathway_catalog_id=p.pathway_catalog_id) OR (pc.pathway_catalog_id=pcp
   .pathway_catalog_id))
    AND pc.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND pc.active_ind=1)
   JOIN (pcor
   WHERE (pcor.pathway_comp_id= Outerjoin(pc.pathway_comp_id)) )
   JOIN (os
   WHERE (os.order_sentence_id= Outerjoin(pcor.order_sentence_id)) )
   JOIN (ocs
   WHERE ocs.synonym_id=pc.parent_entity_id
    AND ocs.mnemonic_type_cd IN (mf_mgeneric_syn_cd, mf_ntrade_syn_cd))
  ORDER BY powerplan
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  SET ms_filename_out = concat("mn_powerplan_synonyms_",format(curdate,"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out,ms_address_list,"M and N Synonyms in Powerplans",1)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
