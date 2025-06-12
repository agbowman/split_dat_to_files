CREATE PROGRAM bhs_athn_get_iv_components
 FREE RECORD out_rec
 RECORD out_rec(
   1 status = c1
   1 cs_comp_qual[*]
     2 comp_seq = vc
     2 catalog_cd = vc
     2 synonym_id = vc
     2 mnemonic = vc
     2 order_sentence_id = vc
     2 oe_format_id = vc
     2 order_display = vc
     2 additive_ind = i2
     2 multiple_ord_sent_ind = i2
     2 lockdown_details_flag = i2
     2 cki = vc
 ) WITH protect
 FREE RECORD req500281
 RECORD req500281(
   1 catalog_cd = f8
   1 virtual_view_offset = i2
   1 facility_cd = f8
 ) WITH protect
 FREE RECORD rep500281
 RECORD rep500281(
   1 virtual_view_ind = i2
   1 cs_comp_qual[*]
     2 comp_seq = i4
     2 comp_type_cd = f8
     2 comp_label = vc
     2 comment_text = vc
     2 required_ind = i2
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 order_sentence_id = f8
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 orderable_type_flag = i2
     2 order_display = vc
     2 rx_mask = i4
     2 dcp_clin_cat_cd = f8
     2 ref_text_mask = i4
     2 ingred_ind = i2
     2 multiple_ord_sent_ind = i2
     2 include_exclude_ind = i2
     2 lockdown_details_flag = i2
     2 url = vc
     2 linked_date_comp_seq = i4
     2 cki = vc
     2 high_alert_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_required_ntfy_ind = i2
     2 high_alert_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetoscomponent(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET out_rec->status = "F"
 IF (( $2 <= 0))
  CALL echo("CATALOG_CD PARAMETER MUST BE SET...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetoscomponent(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(rep500281)
 IF (size(trim(moutputdevice,3)) > 0)
  SET stat = alterlist(out_rec->cs_comp_qual,size(rep500281->cs_comp_qual,5))
  FOR (idx = 1 TO size(rep500281->cs_comp_qual,5))
    SET out_rec->cs_comp_qual[idx].comp_seq = cnvtstring(rep500281->cs_comp_qual[idx].comp_seq)
    SET out_rec->cs_comp_qual[idx].catalog_cd = cnvtstring(rep500281->cs_comp_qual[idx].catalog_cd)
    SET out_rec->cs_comp_qual[idx].synonym_id = cnvtstring(rep500281->cs_comp_qual[idx].synonym_id)
    SET out_rec->cs_comp_qual[idx].mnemonic = rep500281->cs_comp_qual[idx].mnemonic
    SET out_rec->cs_comp_qual[idx].order_sentence_id = cnvtstring(rep500281->cs_comp_qual[idx].
     order_sentence_id)
    SET out_rec->cs_comp_qual[idx].oe_format_id = cnvtstring(rep500281->cs_comp_qual[idx].
     oe_format_id)
    SET out_rec->cs_comp_qual[idx].order_display = rep500281->cs_comp_qual[idx].order_display
    SET out_rec->cs_comp_qual[idx].additive_ind = evaluate(band(rep500281->cs_comp_qual[idx].rx_mask,
      1),0,1,0)
    SET out_rec->cs_comp_qual[idx].lockdown_details_flag = rep500281->cs_comp_qual[idx].
    lockdown_details_flag
    SET out_rec->cs_comp_qual[idx].multiple_ord_sent_ind = rep500281->cs_comp_qual[idx].
    multiple_ord_sent_ind
    SET out_rec->cs_comp_qual[idx].cki = rep500281->cs_comp_qual[idx].cki
  ENDFOR
 ENDIF
 CALL echorecord(out_rec)
 EXECUTE bhs_athn_write_json_output
 FREE RECORD out_rec
 FREE RECORD req500281
 FREE RECORD rep500281
 SUBROUTINE callgetoscomponent(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500195)
   DECLARE requestid = i4 WITH protect, constant(500281)
   SET req500281->catalog_cd =  $2
   CALL echorecord(req500281)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500281,
    "REC",rep500281,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500281)
   IF ((rep500281->status_data.status="S"))
    SET out_rec->status = "S"
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
