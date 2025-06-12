CREATE PROGRAM br_ss_oc_match:dba
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 activity_type = vc
     2 desc = vc
     2 match = vc
     2 add = vc
     2 oc_desc = vc
 )
 SELECT INTO "nl:"
  FROM br_oc_work b,
   order_catalog oc
  PLAN (b)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(b.match_orderable_cd))
  ORDER BY cnvtupper(b.catalog_type), cnvtupper(b.activity_type), cnvtupper(b.long_desc)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->qual,cnt),
   temp->qual[cnt].activity_type = b.activity_type, temp->qual[cnt].desc = b.long_desc, temp->qual[
   cnt].desc = replace(temp->qual[cnt].desc,",",";")
   IF (b.match_ind > 0)
    temp->qual[cnt].match = "Matched"
   ELSE
    temp->qual[cnt].match = "Not Matched"
   ENDIF
   IF (b.match_orderable_cd > 0)
    temp->qual[cnt].add = "Added"
   ELSE
    temp->qual[cnt].add = "Not Added"
   ENDIF
   temp->qual[cnt].oc_desc = oc.description, temp->qual[cnt].oc_desc = replace(temp->qual[cnt].
    oc_desc,",",";")
  WITH nocounter
 ;end select
 DECLARE ord_string = vc
 DECLARE header_string = vc
 SELECT INTO "cer_temp:oc_match.csv"
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   header_string = "Activity Type,Description,Match,Added,Order Catalog Description"
  DETAIL
   col 0, header_string, row + 1
   FOR (x = 1 TO temp->cnt)
     ord_string = build(temp->qual[x].activity_type,",",temp->qual[x].desc,",",temp->qual[x].match,
      ",",temp->qual[x].add,",",temp->qual[x].oc_desc), col 0, ord_string,
     row + 1
   ENDFOR
  WITH nocounter, format = pcformat, maxrow = 400,
   maxcol = 400
 ;end select
END GO
