CREATE PROGRAM ams_prsnl_org_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE ams_define_toolkit_common
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 DECLARE script_name = vc WITH protect, constant("AMS_PRSNL_ORG_AUDIT")
 SELECT DISTINCT INTO  $OUTDEV
  p.name_full_formatted, p.username, pn.name_title,
  p_position_disp = uar_get_code_display(p.position_cd), o.org_name, po_confid_level_disp =
  uar_get_code_display(po.confid_level_cd),
  po.end_effective_dt_tm, org_active = evaluate(o.active_ind,1,"YES",0,"NO"), last_updated_by = pr
  .name_full_formatted
  FROM prsnl p,
   prsnl_org_reltn po,
   organization o,
   person_name pn,
   prsnl pr
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner AMS", "Cerner IRC"))
   JOIN (po
   WHERE pn.person_id=po.person_id
    AND po.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE po.organization_id=o.organization_id)
   JOIN (pr
   WHERE pr.person_id=po.updt_id)
  ORDER BY p.name_full_formatted, o.org_name
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(script_name)
END GO
