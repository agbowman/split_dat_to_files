CREATE PROGRAM dm_ref_domain_val:dba
 INSERT  FROM dm_ref_domain d
  SET d.ref_domain_name = cnvtupper(trim(requestin->list_0[1].ref_domain_name)), d.table_name =
   cnvtupper(requestin->list_0[1].table_name), d.display_column = cnvtupper(requestin->list_0[1].
    display_column),
   d.cki_column = cnvtupper(requestin->list_0[1].cki_column), d.primary_key_column = cnvtupper(
    requestin->list_0[1].primary_key_column), d.unique_ident_column = cnvtupper(requestin->list_0[1].
    unique_ident_column),
   d.from_clause = substring(1,255,requestin->list_0[1].from_clause), d.where_clause = substring(1,
    255,requestin->list_0[1].where_clause), d.human_reqd_ind = cnvtint(requestin->list_0[1].
    human_reqd_ind),
   d.source_from_clause = substring(1,255,requestin->list_0[1].source_from_clause), d.code_set =
   cnvtint(requestin->list_0[1].code_set), d.display_header = cnvtupper(requestin->list_0[1].
    display_header),
   d.active_column = cnvtupper(requestin->list_0[1].active_column), d.order_by_column = cnvtupper(
    requestin->list_0[1].order_by_column), d.translate_name = cnvtupper(requestin->list_0[1].
    translate_name)
  WITH nocounter
 ;end insert
 COMMIT
 INSERT  FROM dm_ref_domain_r r
  SET r.group_name = "ALL", r.ref_domain_name = cnvtupper(requestin->list_0[1].ref_domain_name)
  WITH nocounter
 ;end insert
 COMMIT
END GO
