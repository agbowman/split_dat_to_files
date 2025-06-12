CREATE PROGRAM dm2_load_cdr_trig_csv
 SET stat = moverec(requestin->list_0,luts_dyn_trig->tbl)
 SET luts_dyn_trig->table_cnt = size(luts_dyn_trig->tbl,5)
END GO
