CREATE PROGRAM bhs_ma_menu:dba
 PROMPT
  "PRINTER " = "MINE",
  "ENCNTR_ID " = 1136059,
  "Object Name = " = "BHS_MA_CLINICAL_SUMMARY1"
 FREE SET request
 FREE RECORD request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[0]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[2]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[1]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[0]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 SET request->output_device =  $1
 SET request->script_name =  $3
 SET request->person_cnt = 0
 SET request->visit_cnt = 2
 SET request->visit[1].encntr_id =  $2
 SET request->visit[2].encntr_id = 1134252
 EXECUTE value(cnvtupper( $3))
END GO
