CREATE PROGRAM bhs_prax_med_cki
 IF (( $2=0))
  SET where_params = build("O.ENCNTR_ID =", $3," AND O.ORDER_STATUS_CD IN ", $4," ")
 ELSE
  SET where_params = build("O.PERSON_ID =", $2," AND O.ORDER_STATUS_CD IN ", $4," ")
 ENDIF
 DECLARE json = vc
 FREE RECORD med_cki_record
 RECORD med_cki_record(
   1 med_ski[*]
     2 cur_dt_tm = vc
     2 order_id = f8
     2 tem_ord_id = f8
     2 hna_ord_mne = vc
     2 ord_mne = vc
     2 cli_dis_lin = vc
     2 cat_cd = f8
     2 cat_disp = vc
     2 cki = vc
     2 ord_sts_id = f8
     2 ord_sts_disp = vc
 )
 DECLARE vcnt = i4
 SELECT INTO "NL:"
  o.current_start_dt_tm, o.order_id, o.template_order_id,
  hna_order_mnemonic = o.hna_order_mnemonic, order_mnemonic = o.order_mnemonic, clinical_display_line
   = o.clinical_display_line,
  o.catalog_cd, catlog = uar_get_code_display(o.catalog_cd), cki = o.cki,
  o.order_status_cd, order_status = uar_get_code_display(o.order_status_cd)
  FROM orders o
  PLAN (o
   WHERE parser(where_params)
    AND o.catalog_type_cd=2516)
  ORDER BY o.template_order_id, o.current_start_dt_tm, o.order_id
  HEAD o.template_order_id
   vcnt = (vcnt+ 1), stat = alterlist(med_cki_record->med_ski,vcnt), med_cki_record->med_ski[vcnt].
   cur_dt_tm = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM"),
   med_cki_record->med_ski[vcnt].order_id = cnvtint(o.order_id), med_cki_record->med_ski[vcnt].
   tem_ord_id = cnvtint(o.template_order_id), med_cki_record->med_ski[vcnt].hna_ord_mne = trim(o
    .hna_order_mnemonic,3),
   med_cki_record->med_ski[vcnt].ord_mne = trim(o.order_mnemonic,3), med_cki_record->med_ski[vcnt].
   cli_dis_lin = trim(o.clinical_display_line,3), med_cki_record->med_ski[vcnt].cat_cd = cnvtint(o
    .catalog_cd),
   med_cki_record->med_ski[vcnt].cat_disp = trim(catlog,3), med_cki_record->med_ski[vcnt].cki = trim(
    o.cki,3), med_cki_record->med_ski[vcnt].ord_sts_id = cnvtint(o.order_status_cd),
   med_cki_record->med_ski[vcnt].ord_sts_disp = trim(order_status,3)
  WITH nocounter, format, time = 30
 ;end select
 SET json = cnvtrectojson(med_cki_record)
 CALL echo(json)
 SELECT INTO  $1
  json
  FROM dummyt d
  HEAD REPORT
   col 01, json
  WITH format, separator = " ", maxrow = 0,
   maxcol = 32000, time = 30
 ;end select
 FREE RECORD med_cki_record
END GO
