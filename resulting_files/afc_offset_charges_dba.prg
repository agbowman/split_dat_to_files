CREATE PROGRAM afc_offset_charges:dba
 PROMPT
  "Encounter ID (optional): " = 0
 RECORD reply(
   1 charge_qual = i4
   1 charge[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 item_quantity = f8
 )
 RECORD parentchild(
   1 parent_qual = i4
   1 parent[*]
     2 charge_item_id = f8
     2 item_quantity = f8
     2 child_qual = i2
     2 child[*]
       3 charge_item_id = f8
       3 item_quantity = f8
 )
 RECORD updateable(
   1 charge_qual = i4
   1 charge[*]
     2 charge_item_id = f8
 )
 RECORD nonupdateable(
   1 charge_qual = i4
   1 charge[*]
     2 charge_item_id = f8
 )
 DECLARE encounterid = vc
 IF (cnvtreal( $1) > 0)
  SET encounterid = build("c.encntr_id = ",cnvtstring( $1,17,2))
 ELSE
  SET encounterid = "c.encntr_id > 0"
 ENDIF
 DECLARE creditchargetypecode = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 SET code_set = 13028
 SET cdf_meaning = "CR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,creditchargetypecode)
 SET count1 = 0
 SET stat = alterlist(reply->charge,count1)
 SELECT INTO "nl:"
  c.charge_item_id, c.parent_charge_item_id
  FROM charge c
  WHERE parser(encounterid)
   AND c.charge_type_cd=creditchargetypecode
   AND c.parent_charge_item_id > 0
   AND c.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->charge,count1), reply->charge[count1].charge_item_id
    = c.charge_item_id,
   reply->charge[count1].parent_charge_item_id = c.parent_charge_item_id, reply->charge[count1].
   item_quantity = c.item_quantity
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->charge,count1)
 SET reply->charge_qual = count1
 SET count1 = 0
 SET stat = alterlist(parentchild->parent,count1)
 SELECT INTO "nl:"
  FROM charge c,
   (dummyt d1  WITH seq = value(reply->charge_qual))
  PLAN (d1)
   JOIN (c
   WHERE (c.charge_item_id=reply->charge[d1.seq].parent_charge_item_id))
  DETAIL
   count1 = (count1+ 1), stat = alterlist(parentchild->parent,count1), parentchild->parent[d1.seq].
   charge_item_id = c.charge_item_id,
   parentchild->parent[d1.seq].item_quantity = c.item_quantity
  WITH nocounter
 ;end select
 SET stat = alterlist(parentchild->parent,count1)
 SET parentchild->parent_qual = count1
 FOR (x = 1 TO parentchild->parent_qual)
  SET count1 = 0
  FOR (y = 1 TO reply->charge_qual)
    IF ((reply->charge[y].parent_charge_item_id=parentchild->parent[x].charge_item_id))
     SET count1 = (count1+ 1)
     SET stat = alterlist(parentchild->parent[x].child,count1)
     SET parentchild->parent[x].child[count1].charge_item_id = reply->charge[y].charge_item_id
     SET parentchild->parent[x].child[count1].item_quantity = reply->charge[y].item_quantity
     SET stat = alterlist(parentchild->parent[x].child,count1)
     SET parentchild->parent[x].child_qual = count1
    ENDIF
  ENDFOR
 ENDFOR
 SET count1 = 0
 SET count2 = 0
 FOR (x = 1 TO parentchild->parent_qual)
   SET childrenquantity = 0.0
   FOR (y = 1 TO parentchild->parent[x].child_qual)
     SET childrenquantity = (childrenquantity+ parentchild->parent[x].child[y].item_quantity)
   ENDFOR
   IF ((childrenquantity=parentchild->parent[x].item_quantity))
    SET count1 = (count1+ 1)
    SET stat = alterlist(updateable->charge,count1)
    SET updateable->charge[count1].charge_item_id = parentchild->parent[x].charge_item_id
    FOR (y = 1 TO parentchild->parent[x].child_qual)
      SET count1 = (count1+ 1)
      SET stat = alterlist(updateable->charge,count1)
      SET updateable->charge[count1].charge_item_id = parentchild->parent[x].child[y].charge_item_id
    ENDFOR
    SET updateable->charge_qual = count1
   ELSE
    SET count2 = (count2+ 1)
    SET stat = alterlist(nonupdateable->charge,count2)
    SET nonupdateable->charge[count2].charge_item_id = parentchild->parent[x].charge_item_id
    FOR (y = 1 TO parentchild->parent[x].child_qual)
      SET count2 = (count2+ 1)
      SET stat = alterlist(nonupdateable->charge,count2)
      SET nonupdateable->charge[count2].charge_item_id = parentchild->parent[x].child[y].
      charge_item_id
    ENDFOR
    SET nonupdateable->charge_qual = count2
   ENDIF
 ENDFOR
 FOR (x = 1 TO updateable->charge_qual)
   UPDATE  FROM charge c
    SET c.process_flg = 10, c.updt_id = 9999
    WHERE (c.charge_item_id=updateable->charge[x].charge_item_id)
    WITH nocounter
   ;end update
 ENDFOR
 IF ((nonupdateable->charge_qual > 0))
  SELECT
   charge_item_id = nonupdateable->charge[d1.seq].charge_item_id
   FROM (dummyt d1  WITH seq = value(nonupdateable->charge_qual))
   WHERE d1.seq > 0
   HEAD REPORT
    row + 1, col 0,
    "Charges that weren't updated because quantities of the credits didn't match the parent charge",
    row + 2
   DETAIL
    row + 1, col 5, charge_item_id
   WITH nocounter
  ;end select
 ENDIF
END GO
