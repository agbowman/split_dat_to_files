CREATE PROGRAM cps_get_scd_patrn_updt_cnt:dba
 RECORD reply(
   1 updt_cnt = i4
   1 cki_source = vc
   1 cki_identifier = vc
 )
 SELECT INTO "NL:"
  p.updt_cnt, p.cki_source, p.cki_identifier
  FROM scr_pattern p
  WHERE (p.scr_pattern_id=request->scr_pattern_id)
  DETAIL
   reply->updt_cnt = p.updt_cnt, reply->cki_source = p.cki_source, reply->cki_identifier = p
   .cki_identifier
  WITH nocounter
 ;end select
END GO
