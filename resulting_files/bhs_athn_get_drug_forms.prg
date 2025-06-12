CREATE PROGRAM bhs_athn_get_drug_forms
 FREE RECORD out_rec
 RECORD out_rec(
   1 forms[*]
     2 form = vc
     2 form_code = vc
     2 form_value = vc
 )
 DECLARE d_cnt = i4 WITH protect, noconstant(0)
 IF (( $2 > 0))
  SELECT INTO "nl:"
   dose_form = uar_get_code_display(rfr.form_cd), dose_form_code = cv1.display_key
   FROM route_form_r rfr,
    code_value cv1
   PLAN (rfr
    WHERE (rfr.route_cd= $2))
    JOIN (cv1
    WHERE cv1.code_value=rfr.route_cd
     AND cv1.active_ind=1)
   ORDER BY dose_form
   HEAD dose_form
    d_cnt = (d_cnt+ 1), stat = alterlist(out_rec->forms,d_cnt), out_rec->forms[d_cnt].form =
    dose_form,
    out_rec->forms[d_cnt].form_code = dose_form_code, out_rec->forms[d_cnt].form_value = cnvtstring(
     rfr.form_cd)
   WITH nocounter, time = 30
  ;end select
 ELSE
  SELECT INTO "nl:"
   dose_form = cv1.display, dose_form_code = cv1.display_key
   FROM code_value cv1
   PLAN (cv1
    WHERE cv1.code_set=4002
     AND cv1.active_ind=1)
   ORDER BY dose_form
   HEAD dose_form
    d_cnt = (d_cnt+ 1), stat = alterlist(out_rec->forms,d_cnt), out_rec->forms[d_cnt].form =
    dose_form,
    out_rec->forms[d_cnt].form_code = dose_form_code, out_rec->forms[d_cnt].form_value = cnvtstring(
     cv1.code_value)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO
