CREATE PROGRAM bhs_orc_syn_custom_import:dba
 SET trace = echorecord
 FREE RECORD requeststat
 RECORD requeststat(
   1 max_list = i2
   1 list_0[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 prod_itemid = f8
     2 status = c1
     2 targetobjectname = c25
     2 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 qual[*]
     2 synonym_id = f8
     2 upd_qual[*]
       3 item_id = f8
     2 del_qual[*]
       3 item_id = f8
 )
 CALL echo("Entering bhs_orc_syn_custom_import")
 SET requeststat->max_list = size(requestin->list_0,5)
 SET stat = alterlist(requeststat->list_0,requeststat->max_list)
 CALL echo(build("list size:",requeststat->max_list))
 FOR (x = 1 TO requeststat->max_list)
   CALL echo(x)
   SET tempsyn = cnvtreal(requestin->list_0[x].synonym_id)
   SET tempitem_id = cnvtreal(requestin->list_0[x].prod_itemid)
   SET tempcat_cd = cnvtreal(requestin->list_0[x].catalog_cd)
   IF (tempsyn > 0
    AND tempitem_id > 0)
    FREE RECORD request
    RECORD request(
      1 qual[*]
        2 synonym_id = f8
        2 upd_qual[*]
          3 item_id = f8
        2 del_qual[*]
          3 item_id = f8
    )
    SET stat = alterlist(request->qual,1)
    SET stat = alterlist(request->qual[1].upd_qual,1)
    FREE RECORD reply
    RECORD reply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request->qual[1].synonym_id = tempsyn
    SET request->qual[1].upd_qual[1].item_id = tempitem_id
    EXECUTE bhs_upd_synonym_item_r
    SET requeststat->list_0[x].status = reply->status_data.status
    SET requeststat->list_0[x].targetobjectname = reply->status_data.subeventstatus[1].
    targetobjectname
    SET requeststat->list_0[x].targetobjectvalue = reply->status_data.subeventstatus[1].
    targetobjectvalue
   ELSE
    SET requeststat->list_0[x].status = "F"
    SET requeststat->list_0[x].targetobjectname = "Zero value"
   ENDIF
   SET requeststat->list_0[x].synonym_id = tempsyn
   SET requeststat->list_0[x].prod_itemid = tempitem_id
   SET requeststat->list_0[x].catalog_cd = tempcat_cd
 ENDFOR
 SET filename = concat("bhsorcsynmcustomimport",format(cnvtdatetime(curdate,curtime3),
   "MMDDYYYYHHMM;;d"))
 SELECT INTO value(filename)
  max = requeststat->max_list, synonym_id = requeststat->list_0[d.seq].synonym_id, item_id =
  requeststat->list_0[d.seq].prod_itemid,
  catcd = requeststat->list_0[d.seq].catalog_cd, status = requeststat->list_0[d.seq].status,
  targetobjectname = requeststat->list_0[d.seq].targetobjectname,
  targetobjectvalue = requeststat->list_0[d.seq].targetobjectvalue
  FROM (dummyt d  WITH seq = size(requeststat->list_0,5))
  PLAN (d)
  WITH nocounter, separator = " ", format,
   pcformat('"',","), append, time = 15
 ;end select
 SET trace = noechorecord
 SET last_mod = "000"
END GO
