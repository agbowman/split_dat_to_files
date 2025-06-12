CREATE PROGRAM bhs_update_vv:dba
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 fac_cd = f8
 )
 RECORD temp2(
   1 cnt = i2
   1 qual[*]
     2 synonym_id = f8
 )
 SET temp->cnt = 10
 SET stat = alterlist(temp->qual,temp->cnt)
 SET temp->qual[1].fac_cd = 673937
 SET temp->qual[2].fac_cd = 679586
 SET temp->qual[3].fac_cd = 673936
 SET temp->qual[4].fac_cd = 243897385
 SET temp->qual[5].fac_cd = 679549
 SET temp->qual[6].fac_cd = 673938
 SET temp->qual[7].fac_cd = 2159646
 SET temp->qual[8].fac_cd = 2583987
 SET temp->qual[9].fac_cd = 580062482
 SET temp->qual[10].fac_cd = 580061823
 FREE DEFINE rtl
 DEFINE rtl "bhscust:synonymidlist.dat"
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   temp2->cnt = (temp2->cnt+ 1), stat = alterlist(temp2->qual,temp2->cnt), temp2->qual[temp2->cnt].
   synonym_id = cnvtreal(r.line)
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp2->cnt)
  DELETE  FROM ocs_facility_r o
   WHERE (o.synonym_id=temp2->qual[y].synonym_id)
  ;end delete
  COMMIT
 ENDFOR
 FOR (x = 1 TO 8)
   FOR (y = 1 TO temp2->cnt)
    INSERT  FROM ocs_facility_r o
     SET o.facility_cd = temp->qual[x].fac_cd, o.synonym_id = temp2->qual[y].synonym_id, o
      .updt_applctx = 999,
      o.updt_cnt = 0, o.updt_dt_tm = sysdate, o.updt_id = 999,
      o.updt_task = 999
     WITH nocounter
    ;end insert
    COMMIT
   ENDFOR
 ENDFOR
END GO
