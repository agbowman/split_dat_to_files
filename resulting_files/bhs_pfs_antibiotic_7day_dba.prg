CREATE PROGRAM bhs_pfs_antibiotic_7day:dba
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\plain \f0 \fs18 "
 SET reop = "\pard "
 IF ((reqinfo->updt_app=600005))
  SET reol = "\par "
  SET rtab = "\tab "
 ELSE
  SET reol = "\cell\row "
  SET rtab = "\cell "
 ENDIF
 SET rbopt = "\pard \tx1200\tx1900\tx2650\tx3325\tx3800\tx4400\tx5050\tx5750\tx6500 "
 SET wr = "\plain \f0 \fs18 "
 SET wb = "\plain \f0 \fs18 \b "
 SET wu = "\plain \f0 \fs18 \ul \b "
 SET wbi = "\plain \f0 \fs18 \b \i "
 SET ws = "\plain \f0 \fs18 \strike "
 SET hi = "\pard\fi-2340\li2340 "
 SET rtfeof = "}"
 IF (validate(request->visit)=0)
  FREE RECORD request
  RECORD request(
    1 visit[1]
      2 encntr_id = f8
  )
  SET request->visit[1].encntr_id = 45103327.00
 ENDIF
 IF (validate(reply->text,"NOTDECLARED")="NOTDECLARED")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
  )
 ENDIF
 DECLARE altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_cnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i2 WITH protect, noconstant(0)
 DECLARE slabel = vc WITH protect, noconstant("")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE sindent = c3 WITH protect, constant("   ")
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 RECORD roc(
   1 cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 display = vc
     2 alt_sel_category_id = f8
 )
 RECORD rrec(
   1 qual[*]
     2 order_id = f8
     2 order_catalog_cd = f8
     2 order_mnemonic = vc
     2 order_status = vc
     2 order_detail = vc
     2 order_dose = vc
     2 order_route = vc
     2 order_first_dt_tm = dq8
     2 order_last_dt_tm = dq8
     2 order_dc_dt_tm = dq8
     2 calendar_day = i2
   1 qual_cnt = i2
 )
 DECLARE ml_cnt = i4
 DECLARE ml_pos = i4
 DECLARE ndx = i4
 DECLARE ndx2 = i4
 SELECT INTO "nl:"
  ocs.catalog_type_cd, ocs.catalog_cd
  FROM alt_sel_cat a,
   alt_sel_list asl,
   alt_sel_list asl2,
   order_catalog_synonym ocs
  PLAN (a
   WHERE a.long_description_key_cap IN ("ANTI-INFECTIVES", "AMEBICIDES", "AMINOGLYCOSIDES",
   "ANTHELMINTICS", "ANTIFUNGALS",
   "AZOLE ANTIFUNGALS", "ECHINOCANDINS", "MISCELLANEOUS ANTIFUNGALS", "POLYENES",
   "ANTIMALARIAL AGENTS",
   "ANTIMALARIAL COMBINATIONS", "ANTIMALARIAL QUINOLINES", "MISCELLANEOUS ANTIMALARIALS",
   "ANTITUBERCULOSIS AGENTS", "AMINOSALICYLATES",
   "ANTITUBERCULOSIS COMBINATIONS", "DIARYLQUINOLINES", "HYDRAZIDE DERIVATIVES",
   "MISCELLANEOUS ANTITUBERCULOSIS AGENTS", "RIFAMYCIN DERIVATIVES",
   "STREPTOMYCES DERIVATIVES", "THIOCARBAMIDE DERIVATIVES", "ANTIVIRAL AGENTS",
   "ADAMANTANE ANTIVIRALS", "ANTIVIRAL BOOSTERS",
   "ANTIVIRAL CHEMOKINE RECEPTOR ANTAGONIST", "ANTIVIRAL COMBINATIONS", "ANTIVIRAL INTERFERONS",
   "INTEGRASE STRAND TRANSFER INHIBITOR", "MISCELLANEOUS ANTIVIRALS",
   "NEURAMINIDASE INHIBITORS", "NNRTIS", "NRTIS", "NS5A INHIBITORS", "PROTEASE INHIBITORS",
   "PURINE NUCLEOSIDES", "CARBAPENEMS", "CARBAPENEMS/BETA-LACTAMASE INHIBITORS", "CEPHALOSPORINS",
   "CEPHALOSPORINS/BETA-LACTAMASE INHIBITORS",
   "FIFTH GENERATION CEPHALOSPORINS", "FIRST GENERATION CEPHALOSPORINS",
   "FOURTH GENERATION CEPHALOSPORINS", "OTHER CEPHALOSPORINS", "SECOND GENERATION CEPHALOSPORINS",
   "THIRD GENERATION CEPHALOSPORINS", "GLYCOPEPTIDE ANTIBIOTICS", "GLYCYLCYCLINES", "LEPROSTATICS",
   "LINCOMYCIN DERIVATIVES",
   "MACROLIDE DERIVATIVES", "KETOLIDES", "MACROLIDES", "MISCELLANEOUS ANTIBIOTICS",
   "OXAZOLIDINONE ANTIBIOTICS",
   "PENICILLINS", "AMINOPENICILLINS", "ANTIPSEUDOMONAL PENICILLINS", "NATURAL PENICILLINS",
   "PENICILLINASE RESISTANT PENICILLINS",
   "PENICILLINS/BETA-LACTAMASE INHIBITORS", "QUINOLONES", "STREPTOGRAMINS", "SULFONAMIDES",
   "TETRACYCLINES",
   "URINARY ANTI-INFECTIVES")
    AND a.ahfs_ind=1)
   JOIN (asl
   WHERE asl.alt_sel_category_id=a.alt_sel_category_id)
   JOIN (asl2
   WHERE asl2.alt_sel_category_id=asl.child_alt_sel_cat_id)
   JOIN (ocs
   WHERE ocs.synonym_id=asl2.synonym_id
    AND ocs.catalog_type_cd=2516)
  ORDER BY ocs.catalog_cd
  HEAD REPORT
   ml_cnt = 0
  HEAD ocs.catalog_cd
   ml_cnt += 1, stat = alterlist(roc->qual,ml_cnt), roc->qual[ml_cnt].alt_sel_category_id = asl2
   .child_alt_sel_cat_id,
   roc->qual[ml_cnt].catalog_cd = ocs.catalog_cd, roc->qual[ml_cnt].display = trim(
    uar_get_code_display(ocs.catalog_cd),3)
  FOOT REPORT
   roc->cnt = ml_cnt
  WITH nocounter, uar_code(d)
 ;end select
 SELECT INTO "nl:"
  FROM alt_sel_list asl,
   order_catalog_synonym ocs
  PLAN (asl
   WHERE expand(ndx,1,roc->cnt,asl.alt_sel_category_id,roc->qual[ndx].alt_sel_category_id))
   JOIN (ocs
   WHERE ocs.synonym_id=asl.synonym_id
    AND ocs.catalog_type_cd=2516)
  ORDER BY ocs.catalog_cd
  HEAD ocs.catalog_cd
   ml_pos = 0, ml_pos = locateval(ndx2,1,roc->cnt,ocs.catalog_cd,roc->qual[ndx2].catalog_cd)
   IF (ml_pos=0)
    roc->cnt += 1, stat = alterlist(roc->qual,roc->cnt), roc->qual[roc->cnt].alt_sel_category_id =
    asl.alt_sel_category_id,
    roc->qual[roc->cnt].catalog_cd = ocs.catalog_cd, roc->qual[roc->cnt].display = trim(
     uar_get_code_display(ocs.catalog_cd),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  o.order_mnemonic, cm.admin_start_dt_tm, cm_admin_route_disp = uar_get_code_display(cm
   .admin_route_cd),
  cm.admin_dosage, cm_dosage_unit_disp = uar_get_code_display(cm.dosage_unit_cd)
  FROM orders o,
   orders o2,
   clinical_event ce,
   ce_med_result cm
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND expand(idx,1,roc->cnt,o.catalog_cd,roc->qual[idx].catalog_cd)
    AND o.order_status_cd IN (value(uar_get_code_by("MEANING",6004,"ORDERED")), value(uar_get_code_by
    ("MEANING",6004,"DISCONTINUED")), value(uar_get_code_by("MEANING",6004,"COMPLETED")))
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag=0)
   JOIN (o2
   WHERE (o2.template_order_id= Outerjoin(o.order_id)) )
   JOIN (ce
   WHERE ce.order_id IN (o.order_id, o2.order_id)
    AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1)
   JOIN (cm
   WHERE cm.event_id=ce.event_id
    AND cm.diluent_type_cd=0.0
    AND cm.valid_until_dt_tm > cnvtdatetime(sysdate))
  ORDER BY o.order_id, cm.admin_start_dt_tm
  HEAD REPORT
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt += 1, stat = alterlist(rrec->qual,ord_cnt), rrec->qual[ord_cnt].order_id = o.order_id,
   rrec->qual[ord_cnt].order_mnemonic = o.hna_order_mnemonic, rrec->qual[ord_cnt].order_detail = o
   .simplified_display_line, rrec->qual[ord_cnt].order_catalog_cd = o.catalog_cd,
   rrec->qual[ord_cnt].order_first_dt_tm = cm.admin_start_dt_tm, rrec->qual[ord_cnt].order_status =
   uar_get_code_display(o.order_status_cd)
   IF (o.order_status_cd=value(uar_get_code_by("MEANING",6004,"DISCONTINUED")))
    rrec->qual[ord_cnt].order_dc_dt_tm = o.discontinue_effective_dt_tm
   ELSEIF (o.order_status_cd=value(uar_get_code_by("MEANING",6004,"COMPLETED")))
    rrec->qual[ord_cnt].order_dc_dt_tm = o.status_dt_tm
   ENDIF
  FOOT  o.order_id
   rrec->qual[ord_cnt].order_last_dt_tm = cm.admin_start_dt_tm, rrec->qual[ord_cnt].calendar_day = ((
   curdate - cnvtdate(rrec->qual[ord_cnt].order_first_dt_tm))+ 1)
  FOOT REPORT
   rrec->qual_cnt = ord_cnt
  WITH nocounter, expand = 1
 ;end select
 SET reply->text = rhead
 SELECT INTO "nl:"
  sort_date = rrec->qual[d.seq].order_last_dt_tm, order_id = rrec->qual[d.seq].order_id
  FROM (dummyt d  WITH seq = size(rrec->qual,5))
  PLAN (d
   WHERE (rrec->qual[d.seq].order_status="Ordered"))
  ORDER BY sort_date DESC, order_id
  HEAD REPORT
   lcnt += 1
   IF ((reqinfo->updt_app=600005))
    reply->text = concat(reply->text,"\pard \tx3500\tx5000\tx5500\tx8000")
   ELSE
    reply->text = concat(reply->text,"\trowd\cellx4500\cellx6250\cellx8500\cellx10500")
   ENDIF
   reply->text = concat(reply->text," ",wb,wu,"Active Anti-Infectives",
    rtab,"Calendar Day",rtab,"Last Administered",rtab,
    "First Administered",reol)
  HEAD order_id
   reply->text = concat(reply->text," ",wr,wb,rrec->qual[d.seq].order_mnemonic,
    wr," ",rrec->qual[d.seq].order_detail,rtab,build2(rrec->qual[d.seq].calendar_day),
    rtab,wr,format(rrec->qual[d.seq].order_last_dt_tm,"mm/dd/yyyy hh:mm;;d"),rtab,format(rrec->qual[d
     .seq].order_first_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    reol)
  FOOT REPORT
   reply->text = concat(reply->text," \par")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sort_date = rrec->qual[d.seq].order_last_dt_tm, order_id = rrec->qual[d.seq].order_id
  FROM (dummyt d  WITH seq = size(rrec->qual,5))
  PLAN (d
   WHERE (rrec->qual[d.seq].order_status IN ("Discontinued", "Completed")))
  ORDER BY sort_date DESC, order_id
  HEAD REPORT
   IF (datetimediff(cnvtdatetime(sysdate),rrec->qual[d.seq].order_last_dt_tm) <= 7)
    IF ((reqinfo->updt_app=600005))
     reply->text = concat(reply->text,"\pard \tx3500\tx5000\tx5500\tx8000")
    ELSE
     reply->text = concat(reply->text,"\trowd\cellx4500\cellx6250\cellx8500\cellx10500")
    ENDIF
    reply->text = concat(reply->text," ",wb,wu,"Stopped Antimicrobials",
     rtab,"Stop Date/Time",rtab,"Last Administered",rtab,
     "First Administered",reol)
   ENDIF
  HEAD order_id
   IF (datetimediff(cnvtdatetime(sysdate),rrec->qual[d.seq].order_last_dt_tm) <= 7)
    lcnt += 1, reply->text = concat(reply->text," ",wr,wb,rrec->qual[d.seq].order_mnemonic,
     wr," ",rrec->qual[d.seq].order_detail,rtab,format(rrec->qual[d.seq].order_dc_dt_tm,
      "mm/dd/yyyy hh:mm;;d"),
     rtab,format(rrec->qual[d.seq].order_last_dt_tm,"mm/dd/yyyy hh:mm;;d"),rtab,format(rrec->qual[d
      .seq].order_first_dt_tm,"mm/dd/yyyy hh:mm;;d"),reol)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (lcnt=0)
  SET reply->text = rhead
  SET reply->text = concat(reply->text,wr,"No qualifying data available.")
 ENDIF
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 IF ((reqinfo->updt_app=3010000))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    CALL print(trim(reply->text))
   WITH nocounter, maxcol = 35000
  ;end select
 ENDIF
#exit_program
END GO
