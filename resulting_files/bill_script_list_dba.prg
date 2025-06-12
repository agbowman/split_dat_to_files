CREATE PROGRAM bill_script_list:dba
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 FREE RECORD m_rec
 RECORD m_rec(
   1 script[*]
     2 s_name1 = c30
     2 s_name2 = vc
     2 n_found = i4
     2 s_body = vc
 )
 SELECT INTO "nl:"
  FROM oen_script o
  ORDER BY o.script_name
  HEAD REPORT
   pl_beg_pos = 0, pl_end_pos = 0, pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->script,pl_cnt), m_rec->script[pl_cnt].s_name1 = o
   .script_name,
   CALL echo(build2("name: ",o.script_name)), ms_tmp = cnvtupper(trim(replace(o.script_body," ","",0)
     )), ms_tmp = replace(ms_tmp,char(9),"",0),
   ms_tmp = replace(ms_tmp,char(10),"",0), pl_beg_pos = findstring("SCRIPTNAME:",ms_tmp), ms_tmp =
   substring(pl_beg_pos,200,ms_tmp),
   CALL echo(build2("char: ",ichar(substring(34,1,ms_tmp)))), m_rec->script[pl_cnt].s_body = ms_tmp,
   pl_beg_pos = (findstring(":",ms_tmp)+ 1),
   pl_end_pos = findstring("*",ms_tmp,pl_beg_pos),
   CALL echo(build2("beg: ",pl_beg_pos," end: ",pl_end_pos)), ms_tmp = substring(pl_beg_pos,(
    pl_end_pos - pl_beg_pos),ms_tmp),
   m_rec->script[pl_cnt].s_name2 = ms_tmp
   IF (findstring(trim(m_rec->script[pl_cnt].s_name1),o.script_body))
    CALL echo("found it"), m_rec->script[pl_cnt].n_found = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  name_from_column = m_rec->script[d.seq].s_name1, name_from_body = trim(m_rec->script[d.seq].s_name2,
   3), body = m_rec->script[d.seq].s_body,
  found = m_rec->script[d.seq].n_found
  FROM (dummyt d  WITH seq = value(size(m_rec->script,5)))
  ORDER BY name_from_body
  WITH format = variable, separator = " ", nocounter
 ;end select
#exit_script
END GO
