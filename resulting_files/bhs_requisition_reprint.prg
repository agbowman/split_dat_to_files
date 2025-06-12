CREATE PROGRAM bhs_requisition_reprint
 PROMPT
  "Output to File/Printer/MINE" = "",
  "Orders"
  WITH outdev, req_hx_ids
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 FREE RECORD ord_list
 RECORD ord_list(
   1 list[*]
     2 person_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 prsnl_id = f8
     2 req_prog = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 DECLARE reprint_ind = i2
 SELECT INTO "nl:"
  FROM bhs_req_request_hx bh,
   bhs_req_request_ord_hx br,
   orders o,
   order_catalog oc,
   code_value cv
  PLAN (bh
   WHERE (bh.req_request_hx_id= $REQ_HX_IDS))
   JOIN (br
   WHERE br.req_request_hx_id=bh.req_request_hx_id)
   JOIN (o
   WHERE o.order_id=br.order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (cv
   WHERE cv.code_value=oc.requisition_format_cd)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ord_list->list,(cnt+ 9))
   ENDIF
   ord_list->list[cnt].person_id = bh.person_id, ord_list->list[cnt].encntr_id = br.encntr_id,
   ord_list->list[cnt].prsnl_id = bh.print_prnl_id,
   ord_list->list[cnt].order_id = br.order_id, ord_list->list[cnt].req_prog = cv.definition
  FOOT REPORT
   stat = alterlist(ord_list->list,cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   SET stat = alterlist(request->order_qual,1)
   SET request->order_qual[1].encntr_id = ord_list->list[i].encntr_id
   SET request->order_qual[1].order_id = ord_list->list[i].order_id
   SET request->person_id = ord_list->list[i].person_id
   SET request->print_prsnl_id = reqinfo->updt_id
   SET request->printer_name =  $OUTDEV
   EXECUTE value(cnvtupper(ord_list->list[i].req_prog))
 ENDFOR
END GO
