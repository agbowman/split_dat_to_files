CREATE PROGRAM bhs_athn_get_ord_codeset
 DECLARE input_string = vc WITH constant(cnvtupper(trim( $3)))
 IF (input_string="AT")
  SET where_params = build("d.entity_reltn_mean = ","'",concat("AT/",cnvtstring( $2)),"'",
   " and d.entity1_id = ",
    $4," ")
 ELSEIF (input_string="CT")
  SET where_params = build("d.entity_reltn_mean = ","'",concat("CT/",cnvtstring( $2)),"'",
   " and d.entity1_id = ",
    $4," ")
 ELSE
  SET where_params = build("d.entity_reltn_mean = ","'",concat("ORC/",cnvtstring( $2)),"'",
   " and d.entity1_id = ",
    $4," ")
 ENDIF
 SELECT DISTINCT INTO  $1
  codevalue = d.entity2_id, displayvalue = trim(replace(replace(replace(replace(replace(d
        .entity2_display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
   ), opf.default_start_dt_tm,
  meaning = uar_get_code_meaning(d.entity2_id), opf.disable_freq_ind
  FROM dcp_entity_reltn d,
   order_priority_flexing opf
  PLAN (d
   WHERE parser(where_params)
    AND d.active_ind=1)
   JOIN (opf
   WHERE opf.priority_cd=outerjoin(d.entity2_id))
  ORDER BY d.entity2_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD d.entity2_id
   col 1, "<CodeValues>", row + 1
  DETAIL
   r_id = build("<CodeValue>",cnvtint(codevalue),"</CodeValue>"), col + 1, r_id,
   row + 1, r_desc = build("<DisplayValue>",displayvalue,"</DisplayValue>"), col + 1,
   r_desc, row + 1, r_disablefreq = build("<DisableFrequencyIndicator>",cnvtint(opf.disable_freq_ind),
    "</DisableFrequencyIndicator>"),
   col + 1, r_disablefreq, row + 1
   IF (d.entity2_id=uar_get_code_by("DISPLAY_KEY",1304,"NEXTAM"))
    r_def_start_date = build("<DefaultStDateTime>",opf.default_start_dt_tm,"</DefaultStDateTime>"),
    col + 1, r_def_start_date,
    row + 1
   ENDIF
   r_meaning = build("<Meaning>",meaning,"</Meaning>"), col + 1, r_meaning,
   row + 1
  FOOT  d.entity2_id
   col 1, "</CodeValues>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
