CREATE PROGRAM bhs_athn_get_future_diag
 SELECT INTO  $1
  n.nomenclature_id, n.source_identifier, n_source_vocabulary_disp = uar_get_code_display(n
   .source_vocabulary_cd),
  n_source_string = trim(replace(replace(replace(replace(replace(substring(1,255,n.source_string),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), ner.active_ind,
  ner.beg_effective_dt_tm,
  ner.encntr_id, ner.end_effective_dt_tm
  FROM nomen_entity_reltn ner,
   nomenclature n
  PLAN (ner
   WHERE (ner.parent_entity_id= $2)
    AND (ner.person_id= $3)
    AND ner.child_entity_name="ORDER_POTENTIAL_DIAGNOSIS")
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id)
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD ner.child_entity_id
   header_grp = build("<Diagnosis>"), col + 1, header_grp,
   row + 1, v3 = build("<EncounterId>",cnvtstring(ner.encntr_id),"</EncounterId>"), col + 1,
   v3, row + 1, v4 = build("<PersonId>",cnvtstring(ner.person_id),"</PersonId>"),
   col + 1, v4, row + 1,
   v9 = build("<DiagnosisDisplay>",n.source_string,"</DiagnosisDisplay>"), col + 1, v9,
   row + 1, v13 = build("<NomenclatureId>",cnvtint(n.nomenclature_id),"</NomenclatureId>"), col + 1,
   v13, row + 1, v14 = build("<SourceIdentifier>",n.source_identifier,"</SourceIdentifier>"),
   col + 1, v14, row + 1,
   v15 = build("<SourceString>",n_source_string,"</SourceString>"), col + 1, v15,
   row + 1, v16 = build("<SourceVacabulary>",n_source_vocabulary_disp,"</SourceVacabulary>"), col + 1,
   v16, row + 1, v26 = build("<ActiveIndicator>",cnvtint(ner.active_ind),"</ActiveIndicator>"),
   col + 1, v26, row + 1,
   v27 = build("<EndEffectiveDate>",format(ner.end_effective_dt_tm,"MM/DD/YYYY"),
    "</EndEffectiveDate>"), col + 1, v27,
   row + 1
  FOOT  ner.child_entity_id
   foot_grp = build("</Diagnosis>"), col + 1, foot_grp,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
