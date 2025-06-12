CREATE PROGRAM bhs_load_cs_util_tables
 PROMPT
  "Beginning Date: " = "01012000",
  "Ending Date: " = "01312000"
 DECLARE order_action_order_cd = f8
 SET order_action_order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 IF (( $1="YESTERDAY"))
  SET beg_date_qual = (curdate - 1)
 ELSE
  SET beg_date_qual = cnvtdate( $1)
 ENDIF
 IF (( $2="YESTERDAY"))
  SET end_date_qual = (curdate - 1)
 ELSE
  SET end_date_qual = cnvtdate( $2)
 ENDIF
 FREE RECORD cs_util
 RECORD cs_util(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 facility_cd = f8
     2 ordering_physician_id = f8
     2 order_id = f8
     2 orig_order_dt_tm = dq8
     2 primary_mnemonic = vc
     2 cnt = i4
     2 list[*]
       3 catalog_cd = f8
       3 order_id = f8
       3 primary_mnemonic = vc
 )
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   orders o2,
   encounter e
  PLAN (oa
   WHERE oa.action_type_cd=order_action_order_cd
    AND oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual,0) AND cnvtdatetime(end_date_qual,235959))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.orderable_type_flag=6
    AND  NOT ( EXISTS (
   (SELECT
    oi.order_id
    FROM bhs_ord_cs_utiliz oi
    WHERE oi.order_id=o.order_id))))
   JOIN (o2
   WHERE o2.cs_order_id=o.order_id
    AND o2.template_order_flag IN (0, 1))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY o.order_id, o2.order_id
  HEAD REPORT
   cs_util->cnt = 0
  HEAD o.order_id
   cs_util->cnt = (cs_util->cnt+ 1)
   IF (mod(cs_util->cnt,100)=1)
    stat = alterlist(cs_util->list,(cs_util->cnt+ 99))
   ENDIF
   cs_util->list[cs_util->cnt].catalog_cd = o.catalog_cd, cs_util->list[cs_util->cnt].order_id = o
   .order_id, cs_util->list[cs_util->cnt].facility_cd = e.loc_facility_cd,
   cs_util->list[cs_util->cnt].ordering_physician_id = oa.order_provider_id, cs_util->list[cs_util->
   cnt].primary_mnemonic = o.order_mnemonic, cs_util->list[cs_util->cnt].orig_order_dt_tm = oa
   .action_dt_tm
  HEAD o2.order_id
   cs_util->list[cs_util->cnt].cnt = (cs_util->list[cs_util->cnt].cnt+ 1)
   IF (mod(cs_util->list[cs_util->cnt].cnt,10)=1)
    stat = alterlist(cs_util->list[cs_util->cnt].list,(cs_util->list[cs_util->cnt].cnt+ 9))
   ENDIF
   cs_util->list[cs_util->cnt].list[cs_util->list[cs_util->cnt].cnt].catalog_cd = o2.catalog_cd,
   cs_util->list[cs_util->cnt].list[cs_util->list[cs_util->cnt].cnt].order_id = o2.order_id, cs_util
   ->list[cs_util->cnt].list[cs_util->list[cs_util->cnt].cnt].primary_mnemonic = o2.order_mnemonic
  FOOT  o.order_id
   stat = alterlist(cs_util->list[cs_util->cnt].list,cs_util->list[cs_util->cnt].cnt)
  FOOT REPORT
   stat = alterlist(cs_util->list,cs_util->cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(cs_util->list,5))
   INSERT  FROM bhs_ord_cs_utiliz bocu
    SET bocu.catalog_cd = cs_util->list[i].catalog_cd, bocu.facility_cd = cs_util->list[i].
     facility_cd, bocu.order_id = cs_util->list[i].order_id,
     bocu.orig_order_dt_tm = cnvtdatetime(cs_util->list[i].orig_order_dt_tm), bocu.primary_mnemonic
      = cs_util->list[i].primary_mnemonic, bocu.ordering_physician_id = cs_util->list[i].
     ordering_physician_id
    WITH nocounter
   ;end insert
   INSERT  FROM bhs_ord_cs_utiliz_detail bocud,
     (dummyt d  WITH seq = value(cs_util->list[i].cnt))
    SET bocud.catalog_cd = cs_util->list[i].list[d.seq].catalog_cd, bocud.cs_order_id = cs_util->
     list[i].order_id, bocud.order_id = cs_util->list[i].list[d.seq].order_id,
     bocud.primary_mnemonic = cs_util->list[i].list[d.seq].primary_mnemonic
    PLAN (d)
     JOIN (bocud)
    WITH nocounter
   ;end insert
   IF (mod(i,1000)=1)
    COMMIT
   ENDIF
 ENDFOR
 COMMIT
 DECLARE purge_date_qual = dq8
 SET purge_date_qual = cnvtlookbehind("365,D",cnvtdatetime(curdate,curtime3))
 DELETE  FROM bhs_ord_cs_utiliz_detail bocud
  PLAN (bocud
   WHERE bocud.cs_order_id IN (
   (SELECT
    bocu.order_id
    FROM bhs_ord_cs_utiliz bocu
    WHERE bocu.orig_order_dt_tm < cnvtdatetime(purge_date_qual))))
  WITH nocounter
 ;end delete
 DELETE  FROM bhs_ord_cs_utiliz bocu
  PLAN (bocu
   WHERE bocu.orig_order_dt_tm < cnvtdatetime(purge_date_qual))
  WITH nocounter
 ;end delete
 COMMIT
#endprogram
END GO
