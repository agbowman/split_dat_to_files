CREATE PROGRAM bhs_rpt_find_fav_by_txt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Name to search (wildcard * accepted)" = "",
  "Catalog Type:" = 0,
  "Email Address:" = ""
  WITH outdev, s_search, f_cat_type_cd,
  s_email
 RECORD m_rec(
   1 m_list[*]
     2 mf_pathway_id = f8
     2 mf_synonym_id = f8
     2 ms_name = vc
     2 ms_folder = vc
     2 ms_item = vc
     2 ms_order_details = vc
 ) WITH protect
 EXECUTE bhs_sys_stand_subroutine
 DECLARE mf_cat_type_cd = f8 WITH protect, constant(cnvtreal( $F_CAT_TYPE_CD))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE emailind = i4 WITH protect, noconstant(0)
 DECLARE var_output = vc WITH protect, noconstant("")
 DECLARE filedelimiter1 = vc WITH protect, noconstant("")
 DECLARE filedelimiter2 = vc WITH protect, noconstant("")
 DECLARE ms_search = vc WITH protect, noconstant("")
 DECLARE ms_cat_type = vc WITH protect, noconstant(" ")
 IF (trim( $S_SEARCH)="")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "Please input text to search and don't use just asteriks *"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (mf_cat_type_cd <= 0.0)
  SET ms_cat_type = " o.catalog_type_cd > 0.0"
 ELSE
  SET ms_cat_type = concat(" o.catalog_type_cd = ",trim(cnvtstring(mf_cat_type_cd)))
 ENDIF
 CALL echo(build2("ms_cat_type: ",ms_cat_type))
 IF (size(trim( $S_EMAIL)) > 0)
  IF (findstring("@", $S_EMAIL) > 0)
   SET var_output = "finding_favor_report.csv"
   SET emailind = 1
   SET filedelimiter1 = '"'
   SET filedelimiter2 = ","
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     col 0, "Please input valid email."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ELSE
  SET var_output =  $OUTDEV
 ENDIF
 SET ms_search = build2('"*',cnvtupper(trim( $S_SEARCH)),'*"')
 SELECT INTO "nl:"
  FROM alt_sel_list asl,
   order_catalog_synonym o,
   order_sentence os,
   pathway_catalog pcg,
   alt_sel_cat ase,
   person p
  PLAN (asl
   WHERE asl.child_alt_sel_cat_id=0.0
    AND ((asl.synonym_id IN (
   (SELECT
    o.synonym_id
    FROM order_catalog_synonym o))) OR (asl.pathway_catalog_id IN (
   (SELECT
    pcg.pathway_catalog_id
    FROM pathway_catalog pcg)))) )
   JOIN (o
   WHERE o.synonym_id=asl.synonym_id
    AND parser(ms_cat_type))
   JOIN (os
   WHERE os.order_sentence_id=asl.order_sentence_id
    AND cnvtupper(os.order_sentence_display_line)=parser(ms_search))
   JOIN (pcg
   WHERE pcg.pathway_catalog_id=asl.pathway_catalog_id)
   JOIN (ase
   WHERE ase.alt_sel_category_id=asl.alt_sel_category_id
    AND ase.owner_id != 0.00)
   JOIN (p
   WHERE p.person_id=ase.owner_id)
  ORDER BY p.name_full_formatted
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(m_rec->m_list,(ml_cnt+ 99))
   ENDIF
   m_rec->m_list[ml_cnt].mf_pathway_id = asl.pathway_catalog_id, m_rec->m_list[ml_cnt].mf_synonym_id
    = asl.synonym_id, m_rec->m_list[ml_cnt].ms_name = trim(p.name_full_formatted),
   m_rec->m_list[ml_cnt].ms_folder = trim(ase.long_description), m_rec->m_list[ml_cnt].
   ms_order_details = trim(os.order_sentence_display_line)
   IF (asl.synonym_id=0.00)
    m_rec->m_list[ml_cnt].ms_item = trim(pcg.description)
   ELSE
    m_rec->m_list[ml_cnt].ms_item = trim(o.mnemonic_key_cap)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->m_list,ml_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value(trim(var_output))
  pathway_id_powerplan = trim(substring(1,40,cnvtstring(m_rec->m_list[d.seq].mf_pathway_id))),
  synonym_id = trim(substring(1,20,cnvtstring(m_rec->m_list[d.seq].mf_synonym_id))), name = trim(
   substring(1,40,m_rec->m_list[d.seq].ms_name)),
  folder = trim(substring(1,50,m_rec->m_list[d.seq].ms_folder)), item = trim(substring(1,100,m_rec->
    m_list[d.seq].ms_item)), order_detail = trim(substring(1,800,m_rec->m_list[d.seq].
    ms_order_details))
  FROM (dummyt d  WITH seq = ml_cnt)
  ORDER BY name
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   maxcol = 20000
 ;end select
 CALL echo(emailind)
 IF (emailind=1)
  CALL emailfile(var_output,var_output, $S_EMAIL,concat("Finding Favorites - ",format(cnvtdatetime(
      curdate,curtime),";;q")," - ",trim(curprog)),1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("File has been emailed to: ", $S_EMAIL), col 0, msg1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
