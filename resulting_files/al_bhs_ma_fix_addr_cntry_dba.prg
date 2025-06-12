CREATE PROGRAM al_bhs_ma_fix_addr_cntry:dba
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(10000)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_address_id = f8
 )
 SELECT INTO "nl:"
  FROM encounter e,
   address a
  PLAN (e
   WHERE e.reg_dt_tm > cnvtdatetime((curdate - 712),0)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE a.parent_entity_id=e.person_id
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND a.address_type_cd=756.00
    AND a.country_cd=0)
  ORDER BY a.address_id
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD a.address_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_address_id = a.address_id
  WITH nocounter
 ;end select
 CALL echo(m_rec->l_cnt)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   CALL echo(concat("EXECUTE FROM: ",trim(cnvtstring(ml_idx1,20),3)))
   CALL echo(concat("EXECUTE TO: ",trim(cnvtstring(ml_idx2,20),3)))
   UPDATE  FROM address a
    SET a.country_cd = 309221, a.country = "US", a.updt_cnt = (a.updt_cnt+ 1),
     a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = 21310040.0
    WHERE expand(ml_cnt,ml_idx1,ml_idx2,a.address_id,m_rec->qual[ml_cnt].f_address_id)
    WITH nocounter, expand = 1
   ;end update
   COMMIT
   SET ml_idx1 += 9999
   SET ml_idx2 += 10000
   IF ((ml_idx2 > m_rec->l_cnt))
    SET ml_idx2 = m_rec->l_cnt
   ENDIF
 ENDFOR
#exit_script
END GO
