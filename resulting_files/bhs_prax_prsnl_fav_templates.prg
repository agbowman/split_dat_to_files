CREATE PROGRAM bhs_prax_prsnl_fav_templates
 DECLARE scr_pattern_id_list = vc WITH noconstant("")
 DECLARE where_params = vc WITH noconstant("")
 IF (( $2 != ""))
  SET where_params = build(" dp.prsnl_id IN   ", $2)
 ELSE
  SET where_params = build(" dp.prsnl_id != 0 ")
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE cntv = i4 WITH noconstant(0)
 FREE RECORD detail_pref_ls
 RECORD detail_pref_ls(
   1 qual[*]
     2 pvc_value = vc
     2 prsnl_id = f8
 )
 FREE RECORD scr_ptrn_ls
 RECORD scr_ptrn_ls(
   1 qual[*]
     2 scr_ptrn_id = f8
     2 prsnl_id = f8
 )
 SELECT INTO "NL:"
  pvc_value = trim(replace(replace(trim(nvp.pvc_value,3),".000000","",0),".","",0),3)
  FROM detail_prefs dp,
   name_value_prefs nvp,
   prsnl pr
  PLAN (dp
   WHERE parser(where_params)
    AND dp.position_cd=0
    AND dp.application_number=964500
    AND dp.view_name="SCD"
    AND dp.view_seq=0
    AND dp.comp_name="SCD"
    AND dp.comp_seq=0
    AND dp.active_ind > 0
    AND dp.updt_dt_tm > cnvtdatetime("01-Jan-2010 00:00:00"))
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.active_ind > 0
    AND nvp.pvc_name="FAV_EP_LIST1"
    AND nvp.pvc_value != " ")
   JOIN (pr
   WHERE pr.person_id=dp.prsnl_id
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm < sysdate
    AND pr.end_effective_dt_tm > sysdate)
  HEAD REPORT
   cnt = 0
  HEAD dp.detail_prefs_id
   cnt = (cnt+ 1), stat = alterlist(detail_pref_ls->qual,cnt), detail_pref_ls->qual[cnt].pvc_value =
   pvc_value,
   detail_pref_ls->qual[cnt].prsnl_id = dp.prsnl_id
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 IF (cnt > 0)
  SET cntv = 0
  FOR (j = 0 TO cnt)
    SET scr_pattern_id_list = detail_pref_ls->qual[j].pvc_value
    SET prsnl_id = detail_pref_ls->qual[j].prsnl_id
    FOR (i = 0 TO 100)
     SET scr_ptrn_id = cnvtint(piece(trim(replace(replace(trim(scr_pattern_id_list,3),".000000","",0),
         ".","",0),3),"|",i,"N/A"))
     IF (scr_ptrn_id != 0
      AND cntv < 500)
      SET cntv = (cntv+ 1)
      SET stat = alterlist(scr_ptrn_ls->qual,cntv)
      SET scr_ptrn_ls->qual[cntv].scr_ptrn_id = scr_ptrn_id
      SET scr_ptrn_ls->qual[cntv].prsnl_id = prsnl_id
     ENDIF
    ENDFOR
  ENDFOR
  SELECT INTO  $1
   s.cki_identifier, s_definition = trim(replace(replace(replace(replace(replace(trim(s.definition,3),
         "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), s_display =
   trim(replace(replace(replace(replace(replace(trim(s.display,3),"&","&amp;",0),"<","&lt;",0),">",
       "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
   s.display_key, s_entry_mode_disp = uar_get_code_display(s.entry_mode_cd), s_pattern_type_disp =
   uar_get_code_display(s.pattern_type_cd),
   s_required_field_enforcement_disp = uar_get_code_display(s.required_field_enforcement_cd), user_id
    = cnvtint(scr_ptrn_ls->qual[d1.seq].prsnl_id)
   FROM (dummyt d1  WITH seq = size(scr_ptrn_ls->qual,5)),
    scr_pattern s
   PLAN (d1)
    JOIN (s
    WHERE (s.scr_pattern_id=scr_ptrn_ls->qual[d1.seq].scr_ptrn_id)
     AND s.pattern_type_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=14409
      AND cdf_meaning="EP"
      AND active_ind=1)))
   ORDER BY s.scr_pattern_id
   HEAD REPORT
    html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   HEAD s.scr_pattern_id
    col + 1, "<Template>", row + 1,
    v0 = build("<PrsnlId>",user_id,"</PrsnlId>"), col + 1, v0,
    row + 1, v1 = build("<ScrPatternId>",cnvtint(s.scr_pattern_id),"</ScrPatternId>"), col + 1,
    v1, row + 1, v2 = build("<Name>",s_display,"</Name>"),
    col + 1, v2, row + 1,
    v3 = build("<Description>",s_definition,"</Description>"), col + 1, v3,
    row + 1, col + 1, "</Template>",
    row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 20
  ;end select
 ELSE
  SELECT INTO  $1
   FROM dummyt d2
   HEAD REPORT
    html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage></ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 10
  ;end select
 ENDIF
 FREE RECORD scr_ptrn_ls
 FREE RECORD detail_pref_ls
END GO
