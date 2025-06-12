CREATE PROGRAM ctp_get_node_list:dba
 EXECUTE ccl_prompt_api_dataset "autoset", "dataset", "misc"
 DECLARE getnodenames(domain=vc,nodes=vc(ref)) = i2 WITH protect
 SUBROUTINE getnodenames(domain,nodes)
   DECLARE node_list = vc WITH protect, noconstant(" ")
   DECLARE node_name = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   EXECUTE ccluarxhost
   SET node_list = uar_gethostnames(nullterm(domain))
   IF (size(trim(node_list,3))=0)
    RETURN(false)
   ENDIF
   SET cnt = 1
   SET node_name = piece(node_list,"|",cnt,not_found)
   WHILE (node_name != not_found)
     SET stat = alterlist(nodes->qual,cnt)
     SET nodes->qual[cnt].name = node_name
     SET cnt = (cnt+ 1)
     SET node_name = piece(node_list,"|",cnt,not_found)
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 RECORD nodes(
   1 qual[*]
     2 name = vc
 ) WITH protect
 CALL getnodenames(curdomain,nodes)
 SELECT INTO "nl:"
  display = substring(1,20,cnvtupper(nodes->qual[d.seq].name))
  FROM (dummyt d  WITH seq = value(size(nodes->qual,5)))
  ORDER BY display
  HEAD REPORT
   stat = makedataset(50), display_idx = addstringfield("display","display",1,20)
  DETAIL
   cnt = getnextrecord(0), stat = setstringfield(cnt,display_idx,trim(display))
  FOOT REPORT
   stat = closedataset(0), stat = setstatus("S")
  WITH reporthelp, check
 ;end select
 SET last_mod = "000 11/09/17 CJ012163 Initial Release"
END GO
