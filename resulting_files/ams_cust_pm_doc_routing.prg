CREATE PROGRAM ams_cust_pm_doc_routing
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select a PCID" = "",
  "OR Select a Printer" = 0,
  "OR Enter the Distribution Name" = ""
  WITH outdev, pcid, prnt,
  dist
 DECLARE prog_name = vc
 SET prog_name = "AMS_CUST_PM_DOC_ROUTING"
 IF (textlen( $PCID) > 1)
  CALL updtdminfo(prog_name)
  SELECT INTO  $OUTDEV
   transaction = pdf.value, change_encntrtype = evaluate(pdf4.value_ind,0,"NO",1,"YES"), old_et =
   uar_get_code_display(pdf5.value_cd),
   encounter_type = uar_get_code_display(pdf2.value_cd), location = uar_get_code_display(pdf3
    .value_cd), fin_class = uar_get_code_display(pdf6.value_cd),
   pcid = trim(pdf7.value), pddo.document_name, pddi.distribution_name,
   od.name, p.copies
   FROM pm_doc_destination p,
    pm_doc_distribution pddi,
    pm_doc_document pddo,
    output_dest od,
    pm_doc_dist_filter pdf,
    pm_doc_dist_filter pdf2,
    pm_doc_dist_filter pdf3,
    pm_doc_dist_filter pdf4,
    pm_doc_dist_filter pdf5,
    pm_doc_dist_filter pdf6,
    pm_doc_dist_filter pdf7,
    dummyt d
   PLAN (p
    WHERE p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (od
    WHERE p.output_dest_cd=od.output_dest_cd)
    JOIN (pddo
    WHERE pddo.document_id=p.document_id
     AND pddo.active_ind=1
     AND pddo.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddo.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pddi
    WHERE p.distribution_id=pddi.distribution_id
     AND pddi.active_ind=1
     AND pddi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pdf7
    WHERE pdf7.distribution_id=pddi.distribution_id
     AND pdf7.filter_type="PCI"
     AND (pdf7.value= $PCID))
    JOIN (pdf
    WHERE pdf.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf.filter_type=outerjoin("TRN"))
    JOIN (pdf2
    WHERE pdf2.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf2.filter_type=outerjoin("ET"))
    JOIN (pdf4
    WHERE pdf4.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf4.filter_type=outerjoin("CET"))
    JOIN (pdf5
    WHERE pdf5.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf5.filter_type=outerjoin("OET"))
    JOIN (pdf6
    WHERE pdf6.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf6.filter_type=outerjoin("FIN"))
    JOIN (d)
    JOIN (pdf3
    WHERE pdf3.distribution_id=pddi.distribution_id
     AND ((pdf3.filter_type="NU") OR (pdf3.filter_type="BLD")) )
   WITH outerjoin = d, nocounter, separator = " ",
    format
  ;end select
 ELSEIF (( $PRNT > 0.0))
  CALL updtdminfo(prog_name)
  SELECT INTO  $OUTDEV
   transaction = pdf.value, change_encntrtype = evaluate(pdf4.value_ind,0,"NO",1,"YES"), old_et =
   uar_get_code_display(pdf5.value_cd),
   encounter_type = uar_get_code_display(pdf2.value_cd), location = uar_get_code_display(pdf3
    .value_cd), fin_class = uar_get_code_display(pdf6.value_cd),
   pcid = trim(pdf7.value), pddo.document_name, pddi.distribution_name,
   od.name, p.copies
   FROM pm_doc_destination p,
    pm_doc_distribution pddi,
    pm_doc_document pddo,
    output_dest od,
    pm_doc_dist_filter pdf,
    pm_doc_dist_filter pdf2,
    pm_doc_dist_filter pdf3,
    pm_doc_dist_filter pdf4,
    pm_doc_dist_filter pdf5,
    pm_doc_dist_filter pdf6,
    pm_doc_dist_filter pdf7,
    dummyt d
   PLAN (p
    WHERE p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND p.output_dest_cd=value( $PRNT))
    JOIN (od
    WHERE p.output_dest_cd=od.output_dest_cd)
    JOIN (pddo
    WHERE pddo.document_id=p.document_id
     AND pddo.active_ind=1
     AND pddo.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddo.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pddi
    WHERE p.distribution_id=pddi.distribution_id
     AND pddi.active_ind=1
     AND pddi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pdf7
    WHERE pdf7.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf7.filter_type=outerjoin("PCI"))
    JOIN (pdf
    WHERE pdf.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf.filter_type=outerjoin("TRN"))
    JOIN (pdf2
    WHERE pdf2.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf2.filter_type=outerjoin("ET"))
    JOIN (pdf4
    WHERE pdf4.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf4.filter_type=outerjoin("CET"))
    JOIN (pdf5
    WHERE pdf5.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf5.filter_type=outerjoin("OET"))
    JOIN (pdf6
    WHERE pdf6.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf6.filter_type=outerjoin("FIN"))
    JOIN (d)
    JOIN (pdf3
    WHERE pdf3.distribution_id=pddi.distribution_id
     AND ((pdf3.filter_type="NU") OR (pdf3.filter_type="BLD")) )
   WITH outerjoin = d, nocounter, separator = " ",
    format
  ;end select
 ELSEIF (textlen( $DIST) > 1)
  CALL updtdminfo(prog_name)
  SELECT INTO  $OUTDEV
   transaction = pdf.value, change_encntrtype = evaluate(pdf4.value_ind,0,"NO",1,"YES"), old_et =
   uar_get_code_display(pdf5.value_cd),
   encounter_type = uar_get_code_display(pdf2.value_cd), location = uar_get_code_display(pdf3
    .value_cd), fin_class = uar_get_code_display(pdf6.value_cd),
   pcid = trim(pdf7.value), pddo.document_name, pddi.distribution_name,
   od.name, p.copies
   FROM pm_doc_destination p,
    pm_doc_distribution pddi,
    pm_doc_document pddo,
    output_dest od,
    pm_doc_dist_filter pdf,
    pm_doc_dist_filter pdf2,
    pm_doc_dist_filter pdf3,
    pm_doc_dist_filter pdf4,
    pm_doc_dist_filter pdf5,
    pm_doc_dist_filter pdf6,
    pm_doc_dist_filter pdf7,
    dummyt d
   PLAN (p
    WHERE p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (od
    WHERE p.output_dest_cd=od.output_dest_cd)
    JOIN (pddo
    WHERE pddo.document_id=p.document_id
     AND pddo.active_ind=1
     AND pddo.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddo.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pddi
    WHERE p.distribution_id=pddi.distribution_id
     AND pddi.active_ind=1
     AND pddi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pddi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND (pddi.distribution_name= $DIST))
    JOIN (pdf7
    WHERE pdf7.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf7.filter_type=outerjoin("PCI"))
    JOIN (pdf
    WHERE pdf.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf.filter_type=outerjoin("TRN"))
    JOIN (pdf2
    WHERE pdf2.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf2.filter_type=outerjoin("ET"))
    JOIN (pdf4
    WHERE pdf4.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf4.filter_type=outerjoin("CET"))
    JOIN (pdf5
    WHERE pdf5.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf5.filter_type=outerjoin("OET"))
    JOIN (pdf6
    WHERE pdf6.distribution_id=outerjoin(pddi.distribution_id)
     AND pdf6.filter_type=outerjoin("FIN"))
    JOIN (d)
    JOIN (pdf3
    WHERE pdf3.distribution_id=pddi.distribution_id
     AND ((pdf3.filter_type="NU") OR (pdf3.filter_type="BLD")) )
   WITH outerjoin = d, nocounter, separator = " ",
    format
  ;end select
 ENDIF
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
END GO
