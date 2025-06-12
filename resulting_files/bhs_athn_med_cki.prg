CREATE PROGRAM bhs_athn_med_cki
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
 DECLARE v1 = vc WITH noconstant("")
 DECLARE v2 = vc WITH noconstant("")
 DECLARE v3 = vc WITH noconstant("")
 DECLARE v4 = vc WITH noconstant("")
 DECLARE v5 = vc WITH noconstant("")
 DECLARE v6 = vc WITH noconstant("")
 DECLARE v7 = vc WITH noconstant("")
 DECLARE v8 = vc WITH noconstant("")
 DECLARE v9 = vc WITH noconstant("")
 DECLARE v10 = vc WITH noconstant("")
 DECLARE v11 = vc WITH noconstant("")
 DECLARE v12 = vc WITH noconstant("")
 DECLARE v13 = vc WITH noconstant("")
 SELECT INTO  $1
  FROM (dummyt d1  WITH size(value(1)))
  WHERE d1.seq > 0
  HEAD REPORT
   col 0, '{"MED_CKI_RECORD":{', row + 1,
   col + 1, '"MED_SKI":[', row + 1
   FOR (i = 1 TO size(med_cki_record->med_ski))
     col + 1, "{", row + 1,
     v1 = build('"CAT_CD":',med_cki_record->med_ski[i].cat_cd,","), col + 1, v1,
     row + 1, v2 = build('"CAT_DISP":"',med_cki_record->med_ski[i].cat_disp,'",'), col + 1,
     v2, row + 1, v3 = build('"CKI":"',med_cki_record->med_ski[i].cki,'",'),
     col + 1, v3, row + 1,
     v4 = build('"CLI_DIS_LIN":"',med_cki_record->med_ski[i].cli_dis_lin,'",'), col + 1, v4,
     row + 1, v5 = build('"CUR_DT_TM":"',med_cki_record->med_ski[i].cur_dt_tm,'",'), col + 1,
     v5, row + 1, v6 = build('"HNA_ORD_MNE":"',med_cki_record->med_ski[i].hna_ord_mne,'",'),
     col + 1, v6, row + 1,
     v7 = build('"ORD_MNE":"',med_cki_record->med_ski[i].ord_mne,'",'), col + 1, v7,
     row + 1, v8 = build('"ORD_STS_DISP":"',med_cki_record->med_ski[i].ord_sts_disp,'",'), col + 1,
     v8, row + 1, v9 = build('"ORD_STS_ID":',med_cki_record->med_ski[i].ord_sts_id,","),
     col + 1, v9, row + 1,
     v10 = build('"ORDER_ID":',med_cki_record->med_ski[i].order_id,","), col + 1, v10,
     row + 1, v11 = build('"TEM_ORD_ID":',med_cki_record->med_ski[i].tem_ord_id), col + 1,
     v11, row + 1
     IF (i=size(med_cki_record->med_ski))
      col + 1, "}"
     ELSE
      col + 1, "},"
     ENDIF
     row + 1
   ENDFOR
  FOOT REPORT
   col + 1, "]", row + 1,
   col + 1, "}", row + 1,
   col + 1, "}"
  WITH format = variable, nocounter, maxrow = 0,
   maxcol = 32000, formfeed = none, time = 30
 ;end select
 FREE RECORD med_cki_record
END GO
