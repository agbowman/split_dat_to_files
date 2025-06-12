CREATE PROGRAM djh_l_infoscan_org
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  i.addr1, i.city, i.formulary_identifier,
  i.infoscan_org_identifier, i.inject_drug_cvrg_flag, i.name,
  i.new_app_drug_cvrg_flag, i.non_formu_cvrg_flag, i.oc_cvrg_flag,
  i.otc_cvrg_flag, i.policy_brand_interchg_flag, i.policy_brand_reimburse_flag,
  i.policy_generic_drug_flag, i.policy_unlisted_drug_flag, i.rowid,
  i.smoke_cess_cvrg_flag, i.state, i.tier_flag,
  i.type_flag, i.updt_applctx, i.updt_cnt,
  i.updt_dt_tm, i.updt_id, i.updt_task,
  i.xprmntl_drug_cvrg_flag
  FROM infoscan_org i
  ORDER BY i.infoscan_org_identifier
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
