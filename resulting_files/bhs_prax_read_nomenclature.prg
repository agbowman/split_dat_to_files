CREATE PROGRAM bhs_prax_read_nomenclature
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE cnt = i4
 DECLARE cnt1 = i4
 SET where_params = build("CNVTUPPER(N.SOURCE_STRING) IN ",cnvtupper(replace(replace( $2,"'",'"',0),
    "@","'",0))," ")
 FREE RECORD prax_nom
 RECORD prax_nom(
   1 nomenclature[*]
     2 source_string = vc
     2 source_details[*]
       3 nomenclature_id = i4
       3 concept_identifier = vc
       3 source_identifier = vc
       3 source_string = vc
       3 source_vocab = vc
       3 vocab_axis = vc
       3 source_display = vc
 )
 SELECT INTO "NL:"
  n.nomenclature_id, n_concept_identifier = trim(replace(replace(replace(replace(replace(trim(n
         .concept_identifier,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), n_source_identifier = trim(replace(replace(replace(replace(replace(trim(n
         .source_identifier,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3),
  n_source_string = trim(replace(replace(replace(replace(replace(trim(n.source_string,3),"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_source_vocabulary_disp
   = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(n.source_vocabulary_cd),3
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  n_vocab_axis_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(n
          .vocab_axis_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  n_principle_type_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(n
          .principle_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3)
  FROM nomenclature n
  PLAN (n
   WHERE parser(where_params)
    AND n.active_ind=1
    AND n.beg_effective_dt_tm < sysdate
    AND n.end_effective_dt_tm > sysdate)
  HEAD REPORT
   cnt1 = 0
  HEAD n.source_string
   cnt1 = (cnt1+ 1), stat = alterlist(prax_nom->nomenclature,cnt1), cnt = 0,
   prax_nom->nomenclature[cnt1].source_string = n.source_string
  DETAIL
   n.nomenclature_id, cnt = (cnt+ 1), stat = alterlist(prax_nom->nomenclature[cnt1].source_details,
    cnt),
   prax_nom->nomenclature[cnt1].source_details[cnt].nomenclature_id = n.nomenclature_id, prax_nom->
   nomenclature[cnt1].source_details[cnt].concept_identifier = n.concept_identifier, prax_nom->
   nomenclature[cnt1].source_details[cnt].source_identifier = n.source_identifier,
   prax_nom->nomenclature[cnt1].source_details[cnt].source_string = n.source_string, prax_nom->
   nomenclature[cnt1].source_details[cnt].source_vocab = n_source_vocabulary_disp, prax_nom->
   nomenclature[cnt1].source_details[cnt].vocab_axis = n_vocab_axis_disp,
   prax_nom->nomenclature[cnt1].source_details[cnt].source_display = n_principle_type_disp
  WITH maxcol = 32000, time = 30
 ;end select
 SET json = cnvtrectojson(prax_nom)
 SELECT INTO  $1
  json
  FROM dummyt d
  HEAD REPORT
   col 01, json
  WITH maxcol = 32000, nocounter, format,
   separator = " ", time = 30
 ;end select
END GO
