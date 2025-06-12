CREATE PROGRAM bbt_cnvt_inv_device_r:dba
 RECORD reply(
   1 qual[*]
     2 bb_inv_device_r_id = f8
     2 device_r_type_cd = f8
 )
 SET new_device_id = 0.0
 SET loop = 0
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET locn_cd = 0.0
 SET invarea_cd = 0.0
 SET srvres_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(17396,"BBPATLOCN",1,locn_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBINVAREA",1,invarea_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBSRVRESRC",1,srvres_cd)
 SELECT INTO "nl:"
  *
  FROM bb_inv_device_r bd
  WHERE  NOT (bd.bb_inv_device_r_id IN (0.0, null))
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].bb_inv_device_r_id = bd.bb_inv_device_r_id, reply->qual[qual_cnt].
   device_r_type_cd = bd.device_r_type_cd
  WITH counter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 FOR (loop = 1 TO qual_cnt)
   UPDATE  FROM bb_inv_device_r bd
    SET bd.device_r_type_cd =
     IF ((reply->qual[loop].device_r_type_cd=8876236)) invarea_cd
     ELSEIF ((reply->qual[loop].device_r_type_cd=8876237)) locn_cd
     ELSEIF ((reply->qual[loop].device_r_type_cd=8876238)) srvres_cd
     ELSE bd.device_r_type_cd
     ENDIF
    WHERE (bd.bb_inv_device_r_id=reply->qual[loop].bb_inv_device_r_id)
   ;end update
 ENDFOR
 COMMIT
END GO
