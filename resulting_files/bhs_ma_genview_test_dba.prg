CREATE PROGRAM bhs_ma_genview_test:dba
 PROMPT
  "Encntr_id " = 2415849,
  "Genview object " = "BHS_MA_GENVIEW_PT_DATA"
 FREE RECORD request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[0]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[1]
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
 SET request->output_device = "MINE"
 SET request->script_name = cnvtupper( $2)
 SET request->person_cnt = 0
 SET request->visit_cnt = 1
 SET request->visit[1].encntr_id =  $1
 EXECUTE dcp_rpt_driver
END GO
