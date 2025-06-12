CREATE PROGRAM bed_run_lights_on:dba
 RECORD request(
   1 program_name = vc
   1 skip_volume_check_ind = i2
   1 output_filename = vc
   1 paramlist[*]
     2 param_type_mean = vc
     2 pdate1 = dq8
     2 pdate2 = dq8
     2 vlist[*]
       3 dbl_value = f8
       3 string_value = vc
 )
 RECORD reply(
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
   1 high_volume_flag = i2
   1 output_filename = vc
   1 run_status_flag = i2
   1 statlist[*]
     2 statistic_meaning = vc
     2 status_flag = i2
     2 qualifying_items = i4
     2 total_items = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD tempx(
   1 xlist[*]
     2 xray_name = vc
     2 output_file = vc
 )
 SET xcnt = 0
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_DOC_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "doc_build_rec_audit.csv"
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_EMAR_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "emar_build_rec_audit.csv"
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_MARSUM_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "marsummary_build_rec_audit.csv"
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_ORDERS_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "orders_build_rec_audit.csv"
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_MEDREC_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "medrec_build_rec_audit.csv"
 SET xcnt = (xcnt+ 1)
 SET stat = alterlist(tempx->xlist,xcnt)
 SET tempx->xlist[xcnt].xray_name = "BED_AUD_IVIEW_BLD_REC"
 SET tempx->xlist[xcnt].output_file = "iview_build_rec_audit.csv"
 FOR (zzz = 1 TO xcnt)
   SET request->program_name = tempx->xlist[zzz].xray_name
   SET request->skip_volume_check_ind = 1
   SET request->output_filename = tempx->xlist[zzz].output_file
   SET trace = recpersist
   EXECUTE bed_rpt_driver
 ENDFOR
 COMMIT
#exit_script
 SET reply->status_data.status = "S"
END GO
