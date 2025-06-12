CREATE PROGRAM di_event_log_ref_data
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET tablename = fillstring(255," ")
 SET update_time = cnvtdatetime(curdate,curtime3)
 SET end_dt_tm = cnvtdatetime("31-DEC-2100")
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!042SUBNSAID"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!042SUBNSAID", e.title = "Stepped-Care Approach to Prescribing NSAIDs", e
    .program_name = "DI_SUB_NSAID.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!042SUBNSAID already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!525ASUBCEFTRI"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!525ASUBCEFTRI", e.title =
    "Antibiotic Therapeutic Substitution: ceftriaxone to ceftizoxime", e.program_name =
    "DI_SUB_CEFTRI.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!525ASUBCEFTRI already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!525SUBCEFOX"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!525SUBCEFOX", e.title =
    "Antibiotic Therapeutic Substitution: cefoxitin to ceftizoxime", e.program_name =
    "DI_SUB_CEFOX.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!525SUBCEFOX already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!MODALALERT"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!MODALALERT", e.title = "Insights Modal Alert", e.program_name =
    "DI_ALERT.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!MODALALERT already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!117LABLITH"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!117LABLITH", e.title = "Serum Lithium Monitor", e.program_name =
    "DI_LAB_LITH.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!117LABLITH already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!368INFVAC"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!368INFVAC", e.title = "Influenza Vaccination in the Elderly", e
    .program_name = "DI_INFVAC.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!368INFVAC already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="PN_POE!DRUGDRUG"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "PN_POE!DRUGDRUG", e.title = "Drug Drug Interaction Checking", e.program_name =
    "Pharmnet Order Entry",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("PN_POE!DRUGDRUG already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="PN_POE!DRUGALLERGY"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "PN_POE!DRUGALLERGY", e.title = "Drug Allergy Interaction Checking", e
    .program_name = "Pharmnet Order Entry",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("PN_POE!DRUGALLERGY already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!348EWARF"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!348EWARF", e.title = "Conversion of Heparin to Warfarin", e.program_name
     = "DI_EWARF.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!348EWARF already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!536PED_IMM"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!536PED_IMM", e.title = "Pediatric Immunization", e.program_name =
    "DI_PED_IMM.ocx",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!536PED_IMM already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="MUL_MED!DRUGDRUG"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "MUL_MED!DRUGDRUG", e.title = "Drug Interaction Checking", e.program_name = " ",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("MUL_MED!DRUGDRUG already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="MUL_MED!DRUGALLERGY"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "MUL_MED!DRUGALLERGY", e.title = "Drug Allergy Interaction Checking", e
    .program_name = " ",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("MUL_MED!DRUGALLERGY already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="MUL_MED!DRUGFOOD"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "MUL_MED!DRUGFOOD", e.title = "Drug Food Interaction Checking", e.program_name =
    " ",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("MUL_MED!DRUGFOOD already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!506SUBNMB"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!506SUBNMB", e.title = "Neuromuscular blockade substitution", e
    .program_name = "DI_SUB_NMB.ocx ",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!506SUBNMB already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!509OPTPHENY"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!509OPTPHENY", e.title = "Phenytoin therapeutic drug monitoring", e
    .program_name = "DI_OPT_PHENYLAB.ocx ",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!509OPTPHENY already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_ROUTE_ALERT"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_ROUTE_ALERT", e.title = "DI_ROUTE_ALERT", e.program_name =
    "DI_ROUTE_ALERT.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_ROUTE_ALERT already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_CREATLAB_AMIN"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_CREATLAB_AMIN", e.title = "Elevated creatinine with aminoglycoside", e
    .program_name = "DI_CREATLAB_AMIN.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_CREATLAB_AMIN already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_CREAT_METFORM"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_CREAT_METFORM", e.title = "Elevated creatinine with metformin", e
    .program_name = "DI_CREAT_METFORM.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_CREAT_METFORM already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_DIGL_DIGOX"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_DIGL_DIGOX", e.title = "Elevated dig level with digoxin", e
    .program_name = "DI_DIGL_DIGOX.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_DIGL_DIGOX already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_DIGOX_K"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_DIGOX_K", e.title = "Digoxin order with low potassium", e.program_name
     = "DI_DIGOX_K.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_DIGOX_K already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_HEM_CREATININELAB"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_HEM_CREATININELAB", e.title =
    "Low creatinine clearance with enoxaparin", e.program_name = "DI_HEM_CREATININELAB.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_HEM_CREATININELAB already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_HEM_ENOXAPAIN"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_HEM_ENOXAPAIN", e.title =
    "Enoxaparin order & low creatinine clearance", e.program_name = "DI_HEM_ENOXAPAIN.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_HEM_ENOXAPAIN already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_K_DIGOX"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_K_DIGOX", e.title = "Low potassium with digoxin", e.program_name =
    "DI_K_DIGOX.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_K_DIGOX already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_MG_DIGOX"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_MG_DIGOX", e.title = "Low magnesium with digoxin", e.program_name =
    "DI_MG_DIGOX.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_MG_DIGOX already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_NEP_KET"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_NEP_KET", e.title = "High Ketorolac dose in elderly", e.program_name
     = "DI_NEP_KET.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_NEP_KET already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_SED_ELD_ALERT"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_SED_ELD_ALERT", e.title = "Sedation risk in elderly", e.program_name
     = "DI_SED_ELD_ALERT.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_SED_ELD_ALERT already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_EKM!DI_THROMB_DRUG"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_EKM!DI_THROMB_DRUG", e.title = "Low platelets & platelet-inhibiting drug", e
    .program_name = "DI_THROMB_DRUG.EKM",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_EKM!DI_THROMB_DRUG already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  e.version_major, e.version_minor
  FROM eks_dlg e
  WHERE e.dlg_name="DI_INS!517AGLYSDD"
  DETAIL
   ver_maj = e.version_major, ver_min = e.version_minor
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg e
   SET e.dlg_name = "DI_INS!517AGLYSDD", e.title = "Extended Interval Aminoglycoside Dosing", e
    .program_name = "DI_AGLY_SDD.OCX",
    e.active_ind = 1, e.version_major = 1, e.version_minor = 001,
    e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_INS!517AGLYSDD already present in eks_dlg")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!042YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!042YES", e.answer_txt =
    "Yes to 1. Has ibuprofen ever proven ineffective in your patient during a 2-month trial?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!042YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!042NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!042NO", e.answer_txt =
    "No to 1. Has ibuprofen ever proven ineffective in your patient during a 2-month trial?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!042NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525ANORMAL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525ANORMAL", e.answer_txt = "Normal renal function", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525AMILD is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!042YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525AMILD", e.answer_txt = "Mild renal dysfunction (CLcr 50-79 ml/min)",
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525AMILD is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525AMODERATE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525AMODERATE", e.answer_txt =
    "Moderate or severe renal dysfunction (CLcr 5-49ml/min)", e.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525AMODERATE is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525ADIALYSIS"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525ADIALYSIS", e.answer_txt = "Dialysis (CLcr 0-4 ml/min)", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525ADIALYSIS is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525AUNKNOWN"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525AUNKNOWN", e.answer_txt = "Unknown renal function", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525AUNKNOWN is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525NORMAL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525NORMAL", e.answer_txt = "Normal renal function", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525NORMAL is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525MILD"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525MILD", e.answer_txt = "Mild renal dysfunction (CLcr 50-79 ml/min)",
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525MILD is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525MODERATE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525MODERATE", e.answer_txt =
    "Moderate or severe renal dysfunction (CLcr 5-49 ml/min)", e.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525MODERATE is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525DIALYSIS"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525DIALYSIS", e.answer_txt = "Dialysis (CLcr 0-4 ml/min)", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525DIALYSIS is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!525UNKNOWN"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!525UNKNOWN", e.answer_txt = "Unknown renal function", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!525UNKNOWN is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348NO_1"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348NO_1", e.answer_txt =
    "No to 1. A diagnostic test has excluded the diagnosis", e.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348NO_1 is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348SUSPECTED"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348SUSPECTED", e.answer_txt = "A diagnostic test has notbeen done", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348SUSPECTED is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348YES_1"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348YES_1", e.answer_txt =
    "Yes to 1. A diagnostic test has confirmed  the diagnosis", e.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348YES_1 is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348YES_2"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348YES_2", e.answer_txt =
    "Yes to 1. Patient have pulmonary embolismwithe severe circulatory impairment", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348YES_2 is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348NO_2"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348NO_2", e.answer_txt =
    "No to 1. Patient don't have pulmonary embolism with severe circulatory impairment", e.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348NO_2 is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348ALLERGY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348ALLERGY", e.answer_txt = "An allergy to warfarin", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348ALLERGY is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348SURGERY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348SURGERY", e.answer_txt =
    "Recent surgery resulting in large open spaces", e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348SURGERY is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348BLEEDING"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348BLEEDING", e.answer_txt =
    "Bleeding tendencies associated with active ulceration", e.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348BLEEDING is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348MALIGNANT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348MALIGNANT", e.answer_txt = "Malignant or severe hypertension", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348MALIGNANT is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348UNSUPERVISED"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348UNSUPERVISED", e.answer_txt =
    "Unsupervised senile, alcoholic, uncooperative or psychotic patient", e.updt_dt_tm = cnvtdatetime
    (curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348UNSUPERVISED is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348PREGNANCY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348PREGNANCY", e.answer_txt = "Pregnancy", e.updt_dt_tm = cnvtdatetime
    (curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348PREGNANCY is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!348NONE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!348NONE", e.answer_txt = "None of above", e.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!348NONE is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q1YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q1YES", e.answer_txt =
    "Yes to 1. Patient has received influenza vaccine for the current influenza season", e.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q1YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q1NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q1NO", e.answer_txt =
    "No to 1. Patient has not received influenza vaciine for the curremt influenza season", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_task = 0,
    e.updt_applctx = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q1NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q2YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q2YES", e.answer_txt =
    "Yes to 2. Patient has had a known historyof anaphylactic hypersensitivity", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q2YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q2NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q2NO", e.answer_txt =
    "No to 2. Patient has not had a known history of anaphylactic hypersensitivity", e.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q2NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q3YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q3YES", e.answer_txt =
    "Yes to 3. Patient has had hypersensitivity to eggs or others.", e.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q3YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q3NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q3NO", e.answer_txt = "No to 3. Patient has not had hypersensivity",
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q3NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q4YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q4YES", e.answer_txt =
    "Yes to 4. Patient has had an acute febrile illness (body temperature more than 101 F)", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q4YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!368Q4NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!368Q4NO", e.answer_txt =
    "No to 4. Patient hasn't had an acute febrile illness (body temperature more than 101 F)", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!368Q4NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506NMBAYES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506NMBAYES", e.answer_txt = "Patient requires a NMB agent", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506NMBAYES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506NMBANO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506NMBANO", e.answer_txt = "Patient does not require a NMB agent", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506NMBANO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506HEARTYES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506HEARTYES", e.answer_txt = "Patient has ischemic heart disease", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506HEARTYES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506HEARTNO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506HEARTNO", e.answer_txt =
    "Patient does not have ischemic heart disease", e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!042YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506HYPERSENS"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506HYPERSENS", e.answer_txt =
    "Patient has hypersensitivity to pancuronium", e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506HYPERSENS is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506ASTHMA"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506ASTHMA", e.answer_txt = "Patient has history of asthma or atopy", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506ASTHMA is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!506NONE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!506NONE", e.answer_txt = "Patient does not have any contraindications",
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!506NONE is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q1YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q1YES", e.answer_txt = "Q1:Are seizures still uncontrolled?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q1YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q1NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q1NO", e.answer_txt = "Q1:Are seizures still uncontrolled?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q1NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q2YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q2YES", e.answer_txt = "Q2:Are there signs of toxicity?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q2YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q2NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q2NO", e.answer_txt = "Q2:Are there signs of toxicity?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q2NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q3YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q3YES", e.answer_txt = "Q3:Initiation of phenytoin < 6 days?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q3YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!509Q3NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!509Q3NO", e.answer_txt = "Q3:Initiation of phenytoin < 6 days?", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!509Q3NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!517YES"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!517YES", e.answer_txt = "Patient has contraindications", e.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!517YES is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_answer e
  WHERE e.answer_name="DI_ANS!517NO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_answer e
   SET e.answer_name = "DI_ANS!517NO", e.answer_txt = "Patient doesn't have contraindications", e
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    e.updt_id = 0.0, e.updt_cnt = 0, e.updt_applctx = 0,
    e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ANSWER"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ANS!517NO is already in EKS_DLG_ANSWER.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!ALERTOK"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!ALERTOK", e.action_txt = "OK", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!ALERTOK is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!ALERTCANCEL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!ALERTCANCEL", e.action_txt = "CANCEL", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!ALERTCANCEL is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042CONTINUE", e.action_txt = "Continue order for <Drug>", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042CHANGEIBU"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042CHANGEIBU", e.action_txt =
    "Change order for <Drug> to ibuprofen 400mg TID", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042CHANGEIBU is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042CHANGENAP"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042CHANGENAP", e.action_txt =
    "Change order for <Drug> to naproxen 250mg BID", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042CHANGENAP is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042CHANGEDIC"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042CHANGEDIC", e.action_txt =
    "Change order for <Drug> to diclofenac sodium 75mg BID", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042CHANGEDIC is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!042ALTTHER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!042ALTTHER", e.action_txt = "Consider alternative therapy to an NSAID",
    e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!042ALTTHER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525AQUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525AQUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525AQUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525ACHANGEAPP"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525ACHANGEAPP", e.action_txt =
    "Stop ceftriaxone order AND order appropriate agents", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525ACHANGEAPP is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525ACHANGECEF"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525ACHANGECEF", e.action_txt =
    "Stop ceftriaxone order AND order ceftizoxime", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525ACHANGECEF is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525ACONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525ACONTINUE", e.action_txt = "Continue with ceftriaxone order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525ACONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525CHANGEAPP"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525CHANGEAPP", e.action_txt =
    "Stop cefoxitin order AND order appropriate agents", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525CHANGEAPP is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525CHANGECEF"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525CHANGECEF", e.action_txt =
    "Stop cefoxitin order AND order ceftizoxime", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525CHANGECEF is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!525CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!525CONTINUE", e.action_txt = "Continue with cefoxitin order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!525CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!117QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!117QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!117QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!117CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!117CONTINUE", e.action_txt = "Continue", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!117CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!117ORDERSL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!117ORDERSL", e.action_txt = "Order Serum Lithium", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!117ORDERSL is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!117NOORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!117NOORDER", e.action_txt = "No order Serum Lithium", e.default_ind =
    0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!117NOORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!117ORDERSC"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!117ORDERSC", e.action_txt = "Order Serum Ceratinine", e.default_ind =
    1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!117ORDERSC is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348TERMINATE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348TERMINATE", e.action_txt = "user teminates insights", e.default_ind
     = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348TERMINATE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348ORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348ORDER", e.action_txt = "Order warfarin", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348ORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348NOORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348NOORDER", e.action_txt = "No order for Warfarin", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348NOORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348ORDERPTINR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348ORDERPTINR", e.action_txt = "Order daily PT/INR", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348ORDERPTINR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348ORDERAPPT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348ORDERAPPT", e.action_txt = "Order daily aPPT", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348ORDERAPPT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!348ORDERPLATELET"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!348ORDERPLATELET", e.action_txt = "Order daily platelet count", e
    .default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!348ORDERPLATELET is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="PN_ACT!DCPROFILEORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "PN_ACT!DCPROFILEORDER", e.action_txt = "Discontinue Profile Order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("PN_ACT!DCPROFILEORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="PN_ACT!SUSPPROFILEORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "PN_ACT!SUSPPROFILEORDER", e.action_txt = "Suspend Profile Order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("PN_ACT!SUSPPROFILEORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="PN_ACT!ACCEPTNEWORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "PN_ACT!ACCEPTNEWORDER", e.action_txt = "Accept New Order", e.default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("PN_ACT!ACCEPTNEWORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368ORDERINF"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368ORDERINF", e.action_txt = "Order influenza vaccine 0.5 ml IM", e
    .default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368ORDERINF is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368ORDERAMA"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368ORDERAMA", e.action_txt = "Order amantadine 100mg PO daily", e
    .default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368ORDERAMA is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368ORDERALG"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368ORDERALG", e.action_txt = "Order consultation with allergist", e
    .default_ind = 1,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368ORDERALG is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368CONTINUE", e.action_txt = "Continue", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368TERMINATE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368TERMINATE", e.action_txt = "user teminates insights", e.default_ind
     = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368TERMINATE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!368QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!368QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!368QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CONTINUEATR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CONTINUEATR", e.action_txt = "Continue atracurium order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CONTINUEATR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506LIVFUNTESTS"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506LIVFUNTESTS", e.action_txt = "Order liver function tests", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506LIVFUNTESTS is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CLCR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CLCR", e.action_txt = "Order Clcr", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CLCR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CPK"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CPK", e.action_txt = "Order daily serum CPK", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CP is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CHANGEATR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CHANGEATR", e.action_txt = "Change vecuronium order to atracurium",
    e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CHANGEATR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CONTINUEVEC"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CONTINUEVEC", e.action_txt = "Continue vecuronium order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CONTINUEVEC is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CHANGEPAN"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CHANGEPAN", e.action_txt = "Change order to pancuronium", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CHANGEPAN is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506CANCEL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506CANCEL", e.action_txt = "Cancel", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!506CANCEL is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!506QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!506QUIT", e.action_txt = "Quit the Insight", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509CONTINUE", e.action_txt = "Continue the current order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509DELAY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509DELAY", e.action_txt = "Delay the current order", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509DELAY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509TCHANGEF"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509TCHANGEF", e.action_txt =
    "Change phenytoin total level to free level", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509TCHANGEF is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509FCHANGET"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509FCHANGET", e.action_txt =
    "Change phenytoin free level to total level", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509FCHANGET is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!509CANCEL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!509CANCEL", e.action_txt = "Cancel the current order", e.default_ind
     = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!509CANCEL is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!536CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!536CONTINUE", e.action_txt = "Continue", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!536CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!536QUIT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!536QUIT", e.action_txt = "Quit", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!536QUIT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ACTIONA"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ACTIONA", e.action_txt =
    "Change MDD regimen to extended dose interval", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ACTIONA is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ACTIONB"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ACTIONB", e.action_txt = "Continue MDD regimen", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ACTIONB is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ACTIONC"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ACTIONC", e.action_txt = "Discontinue order for MDD regiment", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ACTIONC is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517CONTINUEMDDR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517CONTINUEMDDR", e.action_txt = "Continue with MDD regimen", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517CONTINUEMDDR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ORDERPC"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ORDERPC", e.action_txt = "Order pharmacokinetic consult", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ORDERPC is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517SERUMCREAT"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517SERUMCREAT", e.action_txt = "Order serum creatinine measurement", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517SERUMCREAT is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ORDERIV"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ORDERIV", e.action_txt = "Order an IV infusion of aminoglycoside",
    e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ORDERIV is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ORDERMDDR"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ORDERMDDR", e.action_txt = "Order a multiple daily dosing regimen",
    e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ORDERMDDR is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517ORDERNO"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517ORDERNO", e.action_txt = "No aminoglycoside order", e.default_ind
     = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517ORDERNO is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517CONTINUE"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517CONTINUE", e.action_txt = "Continue current order (message #5)", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517CONTINUE is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!517CANCEL"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!517CANCEL", e.action_txt = "Cancel current order (message #5)", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!517CANCEL is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DIKDIGOXNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DIKDIGOXNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DIKDIGOXNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DIMGDIGOXNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DIMGDIGOXNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DIMGDIGOXNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DIDIGLDIGOXNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DIDIGLDIGOXNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DIDIGLDIGOXNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DIHCREATLAB"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DIHCREATLAB", e.action_txt = "Result notification and recommendation",
    e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DIHCREATLAB is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DICREATLABAMINNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DICREATLABAMINNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DICREATLABAMINNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DICREATMETFORMNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DICREATMETFORMNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DICREATMETFORMNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!DITHROMBDRUGNOTIFY"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!DITHROMBDRUGNOTIFY", e.action_txt =
    "Result notification and recommendation", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!DITHROMBDRUGNOTIFY is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!ALERTCANCELORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!ALERTCANCELORDER", e.action_txt = "Cancel previous order", e
    .default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!ALERTCANCELORDER is already in EKS_DLG_ACTION.")
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_action e
  WHERE e.action_name="DI_ACT!ALERTNEWORDER"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  INSERT  FROM eks_dlg_action e
   SET e.action_name = "DI_ACT!ALERTNEWORDER", e.action_txt = "Add new order", e.default_ind = 0,
    e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = 0.0, e.updt_cnt = 0,
    e.updt_applctx = 0, e.updt_task = 0
   WITH nocounter
  ;end insert
  IF (curqual < 1)
   SET tablename = "EKS_DLG_ACTION"
   CALL echo(concat("Error writing into: ",tablename))
  ENDIF
 ELSE
  CALL echo("DI_ACT!ALERTNEWORDER is already in EKS_DLG_ACTION.")
 ENDIF
 COMMIT
END GO
