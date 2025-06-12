CREATE PROGRAM act_get_diagnosis_by_encntrs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 item[*]
      2 diagnosis_id = f8
      2 diagnosis_group = f8
      2 encntr_id = f8
      2 person_id = f8
      2 clinical_diag = vc
      2 nomenclature_id = f8
      2 concept_cki = vc
      2 diag_ftdesc = vc
      2 diagnosis_display = vc
      2 conditional_qual_cd = f8
      2 conditional_qual_disp = vc
      2 conditional_qual_mean = c12
      2 confirmation_status_cd = f8
      2 confirmation_status_disp = vc
      2 confirmation_status_mean = c12
      2 diag_dt_tm = dq8
      2 classification_cd = f8
      2 classification_disp = vc
      2 classification_mean = c12
      2 clinical_service_cd = f8
      2 clinical_service_disp = vc
      2 clinical_service_mean = c12
      2 diag_type_cd = f8
      2 diag_type_disp = vc
      2 diag_type_mean = c12
      2 ranking_cd = f8
      2 ranking_disp = vc
      2 ranking_mean = c12
      2 severity_cd = f8
      2 severity_disp = vc
      2 severity_mean = c12
      2 severity_ftdesc = vc
      2 severity_class_cd = f8
      2 severity_class_disp = vc
      2 severity_class_mean = c12
      2 certainty_cd = f8
      2 certainty_disp = vc
      2 certainty_mean = c12
      2 probability = i4
      2 long_blob_id = f8
      2 comment = gvc
      2 comment_updt_id = f8
      2 comment_updt_dt_tm = dq8
      2 diag_prsnl_id = f8
      2 diag_prsnl_name = vc
      2 active_ind = i2
      2 diag_priority = i4
      2 diagnosis_code = vc
      2 secondary_desc_list[*]
        3 group_sequence = i4
        3 group[*]
          4 sequence = i4
          4 secondary_desc_id = f8
          4 nomenclature_id = f8
          4 source_string = vc
      2 procedure_cnt = i4
      2 procedure_list[*]
        3 procedure_id = f8
        3 nomenclature_id = f8
        3 source_string = vc
        3 concept_cki = vc
        3 proc_ftdesc = vc
        3 proc_dt_tm = dq8
        3 proc_loc_cd = f8
        3 proc_loc_disp = vc
        3 proc_loc_mean = vc
        3 procedure_note = vc
        3 anesthesia_cd = f8
        3 anesthesia_disp = vc
        3 anesthesia_mean = vc
        3 anesthesia_minutes = i4
        3 tissue_type_cd = f8
        3 tissue_type_disp = vc
        3 tissue_type_mean = vc
        3 proc_priority = i4
        3 proc_minutes = i4
        3 comment_id = f8
        3 comment = vc
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 active_ind = i2
        3 proc_prsnl_reltn_list[*]
          4 proc_prsnl_reltn_cd = f8
          4 proc_prsnl_reltn_disp = vc
          4 proc_prsnl_reltn_mean = vc
          4 prsnl_person_id = f8
          4 prsnl_full_name_formatted = vc
        3 secondary_desc_list[*]
          4 group_sequence = i4
          4 group[*]
            5 sequence = i4
            5 secondary_desc_id = f8
            5 nomenclature_id = f8
            5 source_string = vc
    1 related_dx_list[*]
      2 parent_entity_id = f8
      2 parent_nomen_id = f8
      2 parent_source_string = vc
      2 parent_freetext_desc = vc
      2 parent_concept_cki = vc
      2 child_entity_id = f8
      2 child_nomen_id = f8
      2 child_source_string = vc
      2 child_freetext_desc = vc
      2 child_concept_cki = vc
      2 reltn_type_cd = f8
      2 reltn_type_disp = vc
      2 reltn_type_mean = c12
      2 reltn_subtype_cd = f8
      2 reltn_subtype_disp = vc
      2 reltn_subtype_mean = c12
      2 priority = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE wherestr = vc WITH public, noconstant(" ")
 DECLARE buildstr = vc WITH public, noconstant(" ")
 DECLARE sec_desc_cnt = i4 WITH public, noconstant(0)
 DECLARE rel_dx_cnt = i4 WITH public, noconstant(0)
 DECLARE group_cnt = i4 WITH public, noconstant(0)
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE working = f8 WITH public, noconstant(0.0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE codestr = vc WITH public, noconstant(" ")
 DECLARE prsnl = f8 WITH public, noconstant(0.0)
 DECLARE 3m = f8 WITH public, noconstant(0.0)
 DECLARE 3m_aus = f8 WITH public, noconstant(0.0)
 DECLARE 3m_can = f8 WITH public, noconstant(0.0)
 DECLARE kodip = f8 WITH public, noconstant(0.0)
 DECLARE profile = f8 WITH public, noconstant(0.0)
 DECLARE clin_srv_cnt = i4 WITH public, noconstant(size(request->clinical_service_list,5))
 DECLARE diag_type_cnt = i4 WITH public, noconstant(size(request->diag_type_list,5))
 DECLARE class_cnt = i4 WITH public, noconstant(size(request->classification_list,5))
 DECLARE encntr_cnt = i4 WITH public, noconstant(size(request->encntrs,5))
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET stat = uar_get_meaning_by_codeset(17,nullterm("WORKING"),1,working)
 SET stat = uar_get_meaning_by_codeset(213,nullterm("PRSNL"),1,prsnl)
 SET stat = uar_get_meaning_by_codeset(89,nullterm("3M"),1,3m)
 SET stat = uar_get_meaning_by_codeset(89,nullterm("3M-AUS"),1,3m_aus)
 SET stat = uar_get_meaning_by_codeset(89,nullterm("3M-CAN"),1,3m_can)
 SET stat = uar_get_meaning_by_codeset(89,nullterm("KODIP"),1,kodip)
 SET stat = uar_get_meaning_by_codeset(89,nullterm("PROFILE"),1,profile)
 FOR (j = 1 TO clin_srv_cnt)
   IF (j=1)
    SET wherestr = "d.clinical_service_cd in ("
    SET buildstr = build(request->clinical_service_list[j].clinical_service_cd)
   ELSE
    SET buildstr = build(buildstr,",",request->clinical_service_list[j].clinical_service_cd)
   ENDIF
 ENDFOR
 IF (clin_srv_cnt > 0)
  SET wherestr = concat(wherestr,buildstr,")")
 ENDIF
 FOR (j = 1 TO diag_type_cnt)
   IF (j=1)
    IF (wherestr != "")
     SET wherestr = concat(wherestr," and ")
    ENDIF
    SET wherestr = concat(wherestr," d.diag_type_cd in (")
    SET buildstr = build(request->diag_type_list[j].diag_type_cd)
   ELSE
    SET buildstr = build(buildstr,",",request->diag_type_list[j].diag_type_cd)
   ENDIF
 ENDFOR
 IF (diag_type_cnt > 0)
  SET wherestr = concat(wherestr,buildstr,")")
 ENDIF
 FOR (j = 1 TO class_cnt)
   IF (j=1)
    IF (wherestr != "")
     SET wherestr = concat(wherestr," and ")
    ENDIF
    SET wherestr = concat(wherestr," d.classification_cd in (")
    SET buildstr = build(request->classification_list[j].classification_cd)
   ELSE
    SET buildstr = build(buildstr,",",request->classification_list[j].classification_cd)
   ENDIF
 ENDFOR
 IF (class_cnt > 0)
  SET wherestr = concat(wherestr,buildstr,")")
 ENDIF
 IF (wherestr="")
  SET wherestr = "1 = 1"
 ENDIF
 SELECT INTO "nl:"
  d1.seq, d.*, n.source_string,
  l.long_blob
  FROM (dummyt d1  WITH seq = value(encntr_cnt)),
   diagnosis d,
   nomenclature n,
   long_blob l
  PLAN (d1)
   JOIN (d
   WHERE (d.encntr_id=request->encntrs[d1.seq].encntr_id)
    AND parser(wherestr)
    AND  NOT (d.contributor_system_cd IN (3m, 3m_aus, 3m_can, kodip, profile))
    AND ((d.active_ind=1
    AND d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (d.diag_type_cd=working
    AND d.active_ind=0)) )
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
   JOIN (l
   WHERE l.long_blob_id=outerjoin(d.long_blob_id)
    AND l.active_ind=outerjoin(1))
  ORDER BY d.diagnosis_group
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->item,(count1+ 9))
   ENDIF
   reply->item[count1].diagnosis_id = d.diagnosis_id, reply->item[count1].diagnosis_group = d
   .diagnosis_group, reply->item[count1].encntr_id = d.encntr_id,
   reply->item[count1].person_id = d.person_id, reply->item[count1].clinical_diag = n.source_string,
   reply->item[count1].nomenclature_id = n.nomenclature_id,
   reply->item[count1].concept_cki = n.concept_cki, reply->item[count1].diag_ftdesc = d.diag_ftdesc,
   reply->item[count1].diagnosis_display = d.diagnosis_display,
   reply->item[count1].conditional_qual_cd = d.conditional_qual_cd, reply->item[count1].
   confirmation_status_cd = d.confirmation_status_cd, reply->item[count1].diag_dt_tm = cnvtdatetime(d
    .diag_dt_tm),
   reply->item[count1].classification_cd = d.classification_cd, reply->item[count1].
   clinical_service_cd = d.clinical_service_cd, reply->item[count1].diag_type_cd = d.diag_type_cd,
   reply->item[count1].ranking_cd = d.ranking_cd, reply->item[count1].severity_cd = d.severity_cd,
   reply->item[count1].severity_ftdesc = d.severity_ftdesc,
   reply->item[count1].severity_class_cd = d.severity_class_cd, reply->item[count1].certainty_cd = d
   .certainty_cd, reply->item[count1].probability = d.probability,
   reply->item[count1].long_blob_id = d.long_blob_id, reply->item[count1].comment = l.long_blob,
   reply->item[count1].comment_updt_id = l.updt_id,
   reply->item[count1].comment_updt_dt_tm = l.updt_dt_tm, reply->item[count1].diag_prsnl_id = d
   .diag_prsnl_id, reply->item[count1].diag_prsnl_name = d.diag_prsnl_name,
   reply->item[count1].active_ind = d.active_ind, reply->item[count1].diag_priority = d.diag_priority,
   reply->item[count1].diagnosis_code = n.source_identifier
  FOOT REPORT
   stat = alterlist(reply->item,count1)
  WITH nocounter, memsort
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, pm.parent_entity_id, pm.parent_entity_name,
  pm.group_seq, pm.sequence, pm.nomenclature_id,
  pm.active_ind, n.nomenclature_id, n.source_string
  FROM (dummyt d  WITH seq = value(count1)),
   proc_modifier pm,
   nomenclature n
  PLAN (d)
   JOIN (pm
   WHERE pm.parent_entity_name="DIAGNOSIS"
    AND (pm.parent_entity_id=reply->item[d.seq].diagnosis_group)
    AND pm.active_ind=1
    AND pm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=pm.nomenclature_id
    AND n.active_ind=1)
  ORDER BY pm.parent_entity_id, pm.group_seq, pm.sequence
  HEAD pm.parent_entity_id
   sec_desc_cnt = 0
  HEAD pm.group_seq
   sec_desc_cnt = (sec_desc_cnt+ 1)
   IF (mod(sec_desc_cnt,10)=1)
    stat = alterlist(reply->item[d.seq].secondary_desc_list,(sec_desc_cnt+ 9))
   ENDIF
   reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group_sequence = pm.group_seq, group_cnt = 0
  HEAD pm.sequence
   group_cnt = (group_cnt+ 1)
   IF (mod(group_cnt,10)=1)
    stat = alterlist(reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group,(group_cnt+ 9))
   ENDIF
   reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].secondary_desc_id = pm
   .proc_modifier_id, reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].
   nomenclature_id = pm.nomenclature_id, reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group[
   group_cnt].source_string = n.source_string,
   reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].sequence = pm.sequence
  FOOT  pm.group_seq
   stat = alterlist(reply->item[d.seq].secondary_desc_list[sec_desc_cnt].group,group_cnt)
  FOOT  pm.parent_entity_id
   stat = alterlist(reply->item[d.seq].secondary_desc_list,sec_desc_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ner.parent_entity_id, ner.parent_entity_name, ner.child_entity_id,
  ner.child_entity_name, ner.encntr_id, diag.diagnosis_id,
  diag.diag_ftdesc, diag.nomenclature_id, n.nomenclature_id
  FROM (dummyt d  WITH seq = value(count1)),
   nomen_entity_reltn ner,
   diagnosis diag,
   nomenclature n
  PLAN (d
   WHERE (reply->item[d.seq].diagnosis_group > 0.0))
   JOIN (ner
   WHERE ner.parent_entity_name="DIAGNOSIS"
    AND ner.child_entity_name="DIAGNOSIS"
    AND (ner.parent_entity_id=reply->item[d.seq].diagnosis_group)
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ner.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (diag
   WHERE diag.diagnosis_group=ner.child_entity_id
    AND diag.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(diag.nomenclature_id)
    AND n.active_ind=outerjoin(1))
  ORDER BY ner.priority
  HEAD REPORT
   rel_dx_cnt = 0
  DETAIL
   rel_dx_cnt = (rel_dx_cnt+ 1)
   IF (mod(rel_dx_cnt,10)=1)
    stat = alterlist(reply->related_dx_list,(rel_dx_cnt+ 9))
   ENDIF
   reply->related_dx_list[rel_dx_cnt].parent_entity_id = reply->item[d.seq].diagnosis_id, reply->
   related_dx_list[rel_dx_cnt].parent_nomen_id = reply->item[d.seq].nomenclature_id, reply->
   related_dx_list[rel_dx_cnt].parent_source_string = reply->item[d.seq].clinical_diag,
   reply->related_dx_list[rel_dx_cnt].parent_freetext_desc = reply->item[d.seq].diag_ftdesc, reply->
   related_dx_list[rel_dx_cnt].parent_concept_cki = reply->item[d.seq].concept_cki, reply->
   related_dx_list[rel_dx_cnt].child_entity_id = ner.child_entity_id,
   reply->related_dx_list[rel_dx_cnt].child_nomen_id = n.nomenclature_id, reply->related_dx_list[
   rel_dx_cnt].child_source_string = n.source_string, reply->related_dx_list[rel_dx_cnt].
   child_freetext_desc = diag.diag_ftdesc,
   reply->related_dx_list[rel_dx_cnt].child_concept_cki = n.concept_cki, reply->related_dx_list[
   rel_dx_cnt].reltn_type_cd = ner.reltn_type_cd, reply->related_dx_list[rel_dx_cnt].reltn_subtype_cd
    = ner.reltn_subtype_cd,
   reply->related_dx_list[rel_dx_cnt].priority = ner.priority
  FOOT REPORT
   stat = alterlist(reply->related_dx_list,rel_dx_cnt)
  WITH counter
 ;end select
 SELECT INTO "nl:"
  proc.active_ind, proc.anesthesia_cd, proc.anesthesia_minutes,
  proc.beg_effective_dt_tm, proc.nomenclature_id, proc.procedure_id,
  proc.procedure_note, proc.proc_ftdesc, proc.proc_loc_cd,
  proc.proc_minutes, proc.proc_priority, proc.tissue_type_cd
  FROM (dummyt d  WITH seq = value(count1)),
   nomen_entity_reltn ner,
   procedure proc,
   nomenclature n
  PLAN (d
   WHERE (reply->item[d.seq].diagnosis_group > 0.0))
   JOIN (ner
   WHERE ner.parent_entity_name="DIAGNOSIS"
    AND (ner.parent_entity_id=reply->item[d.seq].diagnosis_group)
    AND ner.child_entity_name="PROCEDURE"
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ner.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (proc
   WHERE proc.procedure_id=ner.child_entity_id
    AND proc.active_ind=1
    AND proc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND proc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(proc.nomenclature_id)
    AND n.active_ind=outerjoin(1)
    AND n.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND n.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD REPORT
   proc_cnt = 0, prevproc = 0
  HEAD d.seq
   proc_cnt = 0
  DETAIL
   IF (proc.procedure_id != prevproc)
    proc_cnt = (proc_cnt+ 1)
    IF (mod(proc_cnt,10)=1)
     stat = alterlist(reply->item[d.seq].procedure_list,(proc_cnt+ 9))
    ENDIF
    reply->item[d.seq].procedure_list[proc_cnt].procedure_id = proc.procedure_id, reply->item[d.seq].
    procedure_list[proc_cnt].nomenclature_id = n.nomenclature_id, reply->item[d.seq].procedure_list[
    proc_cnt].source_string = n.source_string,
    reply->item[d.seq].procedure_list[proc_cnt].concept_cki = n.concept_cki, reply->item[d.seq].
    procedure_list[proc_cnt].proc_ftdesc = proc.proc_ftdesc, reply->item[d.seq].procedure_list[
    proc_cnt].proc_dt_tm = cnvtdatetime(proc.proc_dt_tm),
    reply->item[d.seq].procedure_list[proc_cnt].proc_loc_cd = proc.proc_loc_cd, reply->item[d.seq].
    procedure_list[proc_cnt].procedure_note = proc.procedure_note, reply->item[d.seq].procedure_list[
    proc_cnt].anesthesia_cd = proc.anesthesia_cd,
    reply->item[d.seq].procedure_list[proc_cnt].anesthesia_minutes = proc.anesthesia_minutes, reply->
    item[d.seq].procedure_list[proc_cnt].tissue_type_cd = proc.tissue_type_cd, reply->item[d.seq].
    procedure_list[proc_cnt].proc_priority = proc.proc_priority,
    reply->item[d.seq].procedure_list[proc_cnt].proc_minutes = proc.proc_minutes, reply->item[d.seq].
    procedure_list[proc_cnt].comment_id = proc.long_text_id, reply->item[d.seq].procedure_list[
    proc_cnt].beg_effective_dt_tm = cnvtdatetime(proc.beg_effective_dt_tm),
    reply->item[d.seq].procedure_list[proc_cnt].end_effective_dt_tm = cnvtdatetime(proc
     .end_effective_dt_tm), reply->item[d.seq].procedure_list[proc_cnt].active_ind = proc.active_ind
   ENDIF
   prevproc = proc.procedure_id
  FOOT  d.seq
   stat = alterlist(reply->item[d.seq].procedure_list,proc_cnt), reply->item[d.seq].procedure_cnt =
   proc_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text
  FROM (dummyt d1  WITH seq = value(count1)),
   (dummyt d2  WITH seq = 1000),
   long_text lt
  PLAN (d1
   WHERE (reply->item[d1.seq].diagnosis_group > 0.0))
   JOIN (d2
   WHERE (d2.seq <= reply->item[d1.seq].procedure_cnt)
    AND (reply->item[d1.seq].procedure_list[d2.seq].comment_id > 0.0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->item[d1.seq].procedure_list[d2.seq].comment_id)
    AND lt.active_ind=1)
  DETAIL
   reply->item[d1.seq].procedure_list[d2.seq].comment = lt.long_text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ppr.proc_prsnl_reltn_cd, ppr.prsnl_person_id, pn.name_full
  FROM (dummyt d1  WITH seq = value(count1)),
   (dummyt d2  WITH seq = 1000),
   proc_prsnl_reltn ppr,
   person_name pn
  PLAN (d1
   WHERE (reply->item[d1.seq].diagnosis_group > 0.0))
   JOIN (d2
   WHERE (d2.seq <= reply->item[d1.seq].procedure_cnt))
   JOIN (ppr
   WHERE (ppr.procedure_id=reply->item[d1.seq].procedure_list[d2.seq].procedure_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pn
   WHERE pn.person_id=ppr.prsnl_person_id
    AND pn.name_type_cd=prsnl
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   ppr_cnt = 0
  HEAD d2.seq
   ppr_cnt = 0
  DETAIL
   ppr_cnt = (ppr_cnt+ 1)
   IF (mod(ppr_cnt,10)=1)
    stat = alterlist(reply->item[d1.seq].procedure_list[d2.seq].proc_prsnl_reltn_list,(ppr_cnt+ 9))
   ENDIF
   reply->item[d1.seq].procedure_list[d2.seq].proc_prsnl_reltn_list[ppr_cnt].proc_prsnl_reltn_cd =
   ppr.proc_prsnl_reltn_cd, reply->item[d1.seq].procedure_list[d2.seq].proc_prsnl_reltn_list[ppr_cnt]
   .prsnl_person_id = ppr.prsnl_person_id, reply->item[d1.seq].procedure_list[d2.seq].
   proc_prsnl_reltn_list[ppr_cnt].prsnl_full_name_formatted = pn.name_full
  FOOT  d2.seq
   stat = alterlist(reply->item[d1.seq].procedure_list[d2.seq].proc_prsnl_reltn_list,ppr_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pm.parent_entity_id, pm.parent_entity_name, pm.group_seq,
  pm.sequence, pm.nomenclature_id, pm.active_ind,
  n.nomenclature_id, n.source_string
  FROM (dummyt psec  WITH seq = value(count1)),
   (dummyt d2  WITH seq = 1000),
   proc_modifier pm,
   nomenclature n
  PLAN (psec)
   JOIN (d2
   WHERE (d2.seq <= reply->item[psec.seq].procedure_cnt)
    AND (reply->item[psec.seq].procedure_list[d2.seq].procedure_id > 0.0))
   JOIN (pm
   WHERE pm.parent_entity_name="PROCEDURE"
    AND (pm.parent_entity_id=reply->item[psec.seq].procedure_list[d2.seq].procedure_id)
    AND pm.active_ind=1
    AND pm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=pm.nomenclature_id
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY pm.parent_entity_id, pm.group_seq, pm.sequence
  HEAD d2.seq
   sec_desc_cnt = 0
  HEAD pm.group_seq
   sec_desc_cnt = (sec_desc_cnt+ 1)
   IF (mod(sec_desc_cnt,10)=1)
    stat = alterlist(reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list,(sec_desc_cnt+
     9))
   ENDIF
   reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].group_sequence = pm
   .group_seq, group_cnt = 0
  HEAD pm.sequence
   group_cnt = (group_cnt+ 1)
   IF (mod(group_cnt,10)=1)
    stat = alterlist(reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].
     group,(group_cnt+ 9))
   ENDIF
   reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].
   secondary_desc_id = pm.proc_modifier_id, reply->item[psec.seq].procedure_list[d2.seq].
   secondary_desc_list[sec_desc_cnt].group[group_cnt].nomenclature_id = pm.nomenclature_id, reply->
   item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].
   source_string = n.source_string,
   reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].group[group_cnt].
   sequence = pm.sequence
  FOOT  pm.group_seq
   stat = alterlist(reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list[sec_desc_cnt].
    group,group_cnt)
  FOOT  d2.seq
   stat = alterlist(reply->item[psec.seq].procedure_list[d2.seq].secondary_desc_list,sec_desc_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
