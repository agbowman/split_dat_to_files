CREATE PROGRAM bhs_athn_read_nomen_by_snmct
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE cnt = i4
 DECLARE cnt1 = i4
 DECLARE snm_cd = vc
 SET snm_cd = build(" N1.CONCEPT_CKI IN ('0'")
 SET no_of_pairs =  $3
 SET param_list = replace( $2,"ltpipgt","|",0)
 FOR (i = 1 TO no_of_pairs)
   SET snm_cd = build(snm_cd,", 'SNOMED!",trim(piece(param_list,"|",i,"N/A")),"'")
 ENDFOR
 SET snm_cd = build(snm_cd,")")
 FREE RECORD prax_nom
 RECORD prax_nom(
   1 nomenclature[*]
     2 source_string = vc
     2 concept_cki = vc
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
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_source_vocabulary_mean
   = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n.source_vocabulary_cd),3
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  n_vocab_axis_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n
          .vocab_axis_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  n_principle_type_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n
          .principle_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), n1_concept_cki = trim(replace(replace(replace(replace(replace(replace(trim(n1
          .concept_cki,3),"SNOMED!","",0),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3)
  FROM nomenclature n1,
   nomenclature n
  PLAN (n1
   WHERE parser(snm_cd)
    AND n1.source_vocabulary_cd=778972
    AND n1.vocab_axis_cd=779305.00
    AND n1.primary_vterm_ind=1
    AND n1.beg_effective_dt_tm < sysdate
    AND n1.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.source_string_keycap=n1.source_string_keycap
    AND n.beg_effective_dt_tm < sysdate
    AND n.end_effective_dt_tm > sysdate
    AND n.source_vocabulary_cd=400646228)
  HEAD REPORT
   cnt1 = 0
  HEAD n.source_string
   cnt1 = (cnt1+ 1), stat = alterlist(prax_nom->nomenclature,cnt1), cnt = 0,
   prax_nom->nomenclature[cnt1].source_string = n.source_string, prax_nom->nomenclature[cnt1].
   concept_cki = n1_concept_cki
  DETAIL
   n.nomenclature_id, cnt = (cnt+ 1), stat = alterlist(prax_nom->nomenclature[cnt1].source_details,
    cnt),
   prax_nom->nomenclature[cnt1].source_details[cnt].nomenclature_id = n.nomenclature_id, prax_nom->
   nomenclature[cnt1].source_details[cnt].concept_identifier = n.concept_identifier, prax_nom->
   nomenclature[cnt1].source_details[cnt].source_identifier = n.source_identifier,
   prax_nom->nomenclature[cnt1].source_details[cnt].source_string = n.source_string, prax_nom->
   nomenclature[cnt1].source_details[cnt].source_vocab = n_source_vocabulary_mean, prax_nom->
   nomenclature[cnt1].source_details[cnt].vocab_axis = n_vocab_axis_mean,
   prax_nom->nomenclature[cnt1].source_details[cnt].source_display = n_principle_type_mean
  WITH maxcol = 32000, time = 60
 ;end select
 SET json = cnvtrectojson(prax_nom)
 SELECT INTO  $1
  json
  FROM dummyt d
  HEAD REPORT
   col 01, json
  WITH maxcol = 32000, nocounter, format,
   separator = " ", time = 60
 ;end select
END GO
