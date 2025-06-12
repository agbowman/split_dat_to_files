CREATE PROGRAM bhs_athn_read_nomenclaturev2
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE cnt = i4
 DECLARE cnt1 = i4
 DECLARE source_string = vc WITH protect, noconstant(" ")
 SET source_string = cnvtlower(replace(replace( $2,"'",'"',0),"@","'",0))
 SET where_params = build(" CNVTLOWER(N.SOURCE_STRING) IN ",source_string," ")
 SET sub_query = "SELECT CODE_VALUE FROM CODE_VALUE WHERE "
 DECLARE source_vocab = vc WITH protect, noconstant(" ")
 SET source_vocab = replace(trim( $3,3),";","','",0)
 SET src_vocab_where_params = build(" N.SOURCE_VOCABULARY_CD IN (",sub_query," CDF_MEANING IN ",
  source_vocab,") ")
 DECLARE source_vocab_axis = vc WITH protect, noconstant(" ")
 SET source_vocab_axis = replace(trim( $4,3),";","','",0)
 SET src_vocab_axis_params = build(" N.VOCAB_AXIS_CD IN (",sub_query," CDF_MEANING IN ",
  source_vocab_axis,") ")
 SET endpos = (findstring("''", $4,1) - 1)
 IF (endpos >= 0)
  SET src_vocab_axis_where_params = build(src_vocab_axis_params," OR N.VOCAB_AXIS_CD = 0"," ")
 ELSE
  SET src_vocab_axis_where_params = build(src_vocab_axis_params," ")
 ENDIF
 SET src_principle_type_params = build(" N.PRINCIPLE_TYPE_CD IN (",sub_query," CDF_MEANING IN ",
  replace(replace( $5,";","','",0),"'",'"',0),") ")
 SET endpos1 = (findstring("''", $5,1) - 1)
 IF (endpos1 >= 0)
  SET src_principle_type_where_params = build(src_principle_type_params," OR N.PRINCIPLE_TYPE_CD = 0",
   " ")
 ELSE
  SET src_principle_type_where_params = build(src_principle_type_params," ")
 ENDIF
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
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n_source_vocabulary_mean
   = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n.source_vocabulary_cd),3
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  n_vocab_axis_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n
          .vocab_axis_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  n_principle_type_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(n
          .principle_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3)
  FROM nomenclature n
  PLAN (n
   WHERE parser(where_params)
    AND n.active_ind=1
    AND n.beg_effective_dt_tm < sysdate
    AND n.end_effective_dt_tm > sysdate
    AND parser(src_vocab_where_params)
    AND parser(src_vocab_axis_where_params)
    AND parser(src_principle_type_where_params))
  HEAD REPORT
   cnt1 = 0
  HEAD n.source_string
   cnt1 += 1, stat = alterlist(prax_nom->nomenclature,cnt1), cnt = 0,
   prax_nom->nomenclature[cnt1].source_string = n.source_string
  DETAIL
   n.nomenclature_id, cnt += 1, stat = alterlist(prax_nom->nomenclature[cnt1].source_details,cnt),
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
