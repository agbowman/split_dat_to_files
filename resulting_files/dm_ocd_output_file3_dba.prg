CREATE PROGRAM dm_ocd_output_file3:dba
 SET oname = build("ocd_schema_",cnvtstring(afd_nbr))
 SET fname = build("ccluserdir:ocd_schema_",cnvtstring(afd_nbr),".ccl")
 SET cnumber = cnvtstring(afd_nbr)
 CALL echo(fname)
 SET tempstr = fillstring(255," ")
 SELECT INTO value(fname)
  FROM dm_tables_doc t,
   dm_afd_tables a
  WHERE a.alpha_feature_nbr=afd_nbr
   AND t.table_name=a.table_name
  ORDER BY t.table_name
  HEAD REPORT
   "free set tbl_doc go", row + 2, "record tbl_doc (",
   row + 1, "1 qual[10]", row + 1,
   "2 table_name = vc", row + 1, "2 data_model_section = vc",
   row + 1, "2 description = vc", row + 1,
   "2 definition = vc", row + 1, "2 primary_update_script = vc",
   row + 1, "2 primary_insert_script = vc", row + 1,
   "2 primary_delete_script = vc", row + 1, "2 static_size_flg = i4",
   row + 1, "2 static_rows = i4", row + 1,
   "2 reads_flg = i4", row + 1, "2 update_flg = i4",
   row + 1, "2 insert_flg = i4", row + 1,
   "2 delete_flg = i4", row + 1, "2 core_ind = i2",
   row + 1, "2 updt_cnt = i4", row + 1,
   "2 bytes_per_row = i4", row + 1, "2 reference_ind = i2",
   row + 1, "2 pct_free  = i4", row + 1,
   "2 pct_used = i4", row + 1, "2 bpr_mean = f8",
   row + 1, "2 bpr_min = f8", row + 1,
   "2 bpr_max = f8", row + 1, "2 bpr_std_dev = f8",
   row + 1, "2 human_reqd_ind = i2", row + 1,
   "2 purge_except_ind = i2", row + 1, "2 freelist_cnt = i4  ) go",
   row + 2, cnt = 0
  DETAIL
   cnt = (cnt+ 1), ldesc = 0
   IF (size(trim(t.definition)) > 100)
    ldesc = 1, 'set def1 = fillstring(100, " ") go', row + 1,
    'set def2 = fillstring(100, " ") go', row + 1, 'set def3 = fillstring(100, " ") go',
    row + 1, 'set def4 = fillstring(100, " ") go', row + 1,
    tempstr = build('set def1 = "',substring(1,100,replace(t.definition,'"',"'",0)),'" go'), tempstr,
    row + 1,
    tempstr = build('set def2 = "',substring(101,100,replace(t.definition,'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def3 = "',substring(201,100,replace(t.definition,'"',"'",0)),'" go'),
    tempstr, row + 1,
    tempstr = build('set def4 = "',substring(301,100,replace(t.definition,'"',"'",0)),'" go'),
    tempstr, row + 1
   ENDIF
   tempstr = build("set stat = alterlist(tbl_doc->qual,",cnt," ) go"), tempstr, row + 1,
   tempstr = build("set tbl_doc->qual[",cnt,"]->table_name = '",t.table_name,"' go"), tempstr, row +
   1,
   tempstr = build("set tbl_doc->qual[",cnt,"]->data_model_section = '",t.data_model_section,"' go"),
   tempstr, row + 1,
   tempstr = build("set tbl_doc->qual[",cnt,']->description = "',replace(t.description,'"',"'",0),
    '" go'), tempstr, row + 1
   IF (ldesc=1)
    tempstr = build("set tbl_doc->qual[",cnt,
     "]->definition = concat(trim(def1),trim(def2),trim(def3),trim(def4)) go")
   ELSE
    tempstr = build("set tbl_doc->qual[",cnt,']->definition = "',replace(t.definition,'"',"'",0),
     '" go')
   ENDIF
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_update_script = '",trim(t
     .primary_update_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_insert_script = '",trim(t
     .primary_insert_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->primary_delete_script = '",trim(t
     .primary_delete_script),"' go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->static_size_flg = ",t
    .static_size_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->static_rows = ",t.static_rows," go"
    ),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->reads_flg = ",t.reads_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->update_flg = ",t.update_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->insert_flg = ",t.insert_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->delete_flg = ",t.delete_flg," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->core_ind = ",t.core_ind," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->updt_cnt = ",t.updt_cnt," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bytes_per_row = ",t.bytes_per_row,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->reference_ind = ",t.reference_ind,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->pct_free = ",t.pct_free," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->pct_used = ",t.pct_used," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_mean = ",t.bpr_mean," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_min = ",t.bpr_min," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_max = ",t.bpr_max," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->bpr_std_dev = ",t.bpr_std_dev," go"
    ),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->human_reqd_ind = ",t.human_reqd_ind,
    " go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->purge_except_ind = ",t
    .purge_except_ind," go"),
   tempstr, row + 1, tempstr = build("set tbl_doc->qual[",cnt,"]->freelist_cnt= ",t.freelist_cnt,
    " go"),
   tempstr, row + 2, row + 1
  FOOT REPORT
   "execute dm_ins_upd_tbl_doc go", row + 2
  WITH nocounter, maxcol = 512, format = variable,
   formfeed = none, maxrow = 2
 ;end select
 SELECT INTO value(fname)
  FROM dm_tables_doc t,
   dm_columns_doc d,
   dm_afd_columns c,
   dm_afd_tables a
  WHERE a.alpha_feature_nbr=afd_nbr
   AND c.alpha_feature_nbr=a.alpha_feature_nbr
   AND t.table_name=a.table_name
   AND c.table_name=t.table_name
   AND d.table_name=c.table_name
   AND d.column_name=c.column_name
  ORDER BY d.table_name, d.column_name
  HEAD REPORT
   "free set col_doc go", row + 2, "record col_doc (",
   row + 1, "1 qual[10]", row + 1,
   "2 table_name = vc", row + 1, "2 column_name = vc",
   row + 1, "2 sequence_name = vc", row + 1,
   "2 code_set = i4", row + 1, "2 description = vc",
   row + 1, "2 definition = vc", row + 1,
   "2 flag_ind = i2", row + 1, "2 updt_cnt = i4",
   row + 1, "2 unique_ident_ind = i2", row + 1,
   "2 root_entity_name = vc", row + 1, "2 root_entity_attr = vc",
   row + 1, "2 constant_value = vc", row + 1,
   "2 parent_entity_col = vc", row + 1, "2 exception_flg = i4",
   row + 1, "2 defining_attribute_ind = i2", row + 1,
   "2 merge_updateable_ind = i2", row + 1, "2 nls_col_ind = i2 ) go",
   row + 2, cknt = 0
  DETAIL
   cknt = (cknt+ 1), tempstr = build("set stat = alterlist(col_doc->qual,",cknt," ) go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->table_name = '",t.table_name,"' go"),
   tempstr,
   row + 1, lcoldesc = 0
   IF (size(trim(d.definition)) > 90)
    lcoldesc = 1, row + 1, 'set cdef1 = fillstring(100, " ") go',
    row + 1, 'set cdef2 = fillstring(100, " ") go', row + 1,
    'set cdef3 = fillstring(100, " ") go', row + 1, 'set cdef4 = fillstring(100, " ") go',
    row + 1, tempstr = build('set cdef1 = "',substring(1,100,replace(d.definition,'"',"'",0)),'" go'),
    tempstr,
    row + 1, tempstr = build('set cdef2 = "',substring(101,100,replace(d.definition,'"',"'",0)),
     '" go'), tempstr,
    row + 1, tempstr = build('set cdef3 = "',substring(201,100,replace(d.definition,'"',"'",0)),
     '" go'), tempstr,
    row + 1, tempstr = build('set cdef4 = "',substring(301,100,replace(d.definition,'"',"'",0)),
     '" go'), tempstr,
    row + 1
   ENDIF
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->column_name = '",d.column_name,"' go"),
   tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->sequence_name = '",trim(d.sequence_name),
    "' go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->code_set = ",d.code_set," go"), tempstr,
   row + 1, tempstr = build("set col_doc->qual[",cknt,"]->description = '",d.description,"' go"),
   tempstr,
   row + 1
   IF (lcoldesc=1)
    tempstr = build("set col_doc->qual[",cknt,
     "]->definition = concat(trim(cdef1),trim(cdef2),trim(cdef3),trim(cdef4)) go")
   ELSE
    tempstr = build("set col_doc->qual[",cknt,"]->definition = '",replace(d.definition,'"',"'",0),
     "' go")
   ENDIF
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->flag_ind = ",d.flag_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->updt_cnt = ",d.updt_cnt," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->unique_ident_ind = ",d
    .unique_ident_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->root_entity_name = '",trim(d
     .root_entity_name),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->root_entity_attr = '",trim(d
     .root_entity_attr),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->constant_value ='",trim(d
     .constant_value),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->parent_entity_col='",trim(d
     .parent_entity_col),"' go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->exception_flg = ",d.exception_flg,
    " go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->defining_attribute_ind = ",d
    .defining_attribute_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->merge_updateable_ind = ",d
    .merge_updateable_ind," go"),
   tempstr, row + 1, tempstr = build("set col_doc->qual[",cknt,"]->nls_col_ind = ",d.nls_col_ind,
    " go"),
   tempstr, row + 1
  FOOT  d.table_name
   "execute dm_ins_upd_col_doc go", row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 2
 ;end select
END GO
