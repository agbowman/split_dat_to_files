CREATE PROGRAM bhs_fix_dicom_result:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_event_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop2 = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str2 = vc WITH protect, noconstant("")
 FREE RECORD bfdr
 RECORD bfdr(
   1 ml_cnt = i4
   1 list[*]
     2 ms_visit = vc
     2 mf_order_id = f8
     2 ms_accession = vc
     2 qual[*]
       3 mf_event_id = f8
       3 ms_blob_handle = vc
 )
 FOR (ml_idx1 = 1 TO size(requestin->list_0,5))
   UPDATE  FROM ce_blob_result
    SET storage_cd = 643452.0, format_cd = 643451.0, updt_id = 997799.0,
     blob_handle = concat(trim(requestin->list_0[ml_idx1].url,3)," HNAM URL")
    WHERE event_id IN (
    (SELECT
     ce.event_id
     FROM clinical_event ce
     WHERE ce.order_id=cnvtreal(requestin->list_0[ml_idx1].orderid)))
     AND blob_handle="1.*"
     AND storage_cd=140.0
     AND format_cd=113.0
   ;end update
 ENDFOR
END GO
