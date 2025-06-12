CREATE PROGRAM bed_get_mos_chk_sentences:dba
 FREE SET reply
 RECORD reply(
   1 found_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pre_ord_sent_ind = 0
 IF (validate(request->check_pre_order_sent_ind))
  SET pre_ord_sent_ind = request->check_pre_order_sent_ind
 ENDIF
 DECLARE osparse = vc
 IF (pre_ord_sent_ind=1)
  SET osparse = "os.external_identifier = 'MUL.OP*' and os.usage_flag = 2"
 ELSEIF (pre_ord_sent_ind=2)
  SET osparse = "os.usage_flag = 2"
 ELSE
  SET osparse = "os.external_identifier = 'MUL.IP*' and os.usage_flag = 1"
 ENDIF
 CALL echo(osparse)
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os
  PLAN (os
   WHERE parser(osparse))
   JOIN (ocsr
   WHERE ocsr.order_sentence_id=os.order_sentence_id)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  HEAD REPORT
   reply->found_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
