all:
#	service
	rm -rf *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf tmp;
	mkdir tmp;
	cp h200/Makefile tmp;
	rm -rf h200/*;
	mv tmp/Makefile h200;
	cp h201/Makefile tmp;
	rm -rf h201/*;
	mv tmp/Makefile h201;
	cp h202/Makefile tmp;
	rm -rf h202/*;
	mv tmp/Makefile h202;
	rm -rf tmp;
	echo Done
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	mkdir test_ebin;
#	common
#	cp ../common/src/*.app ebin;
	erlc -D unit_test -I ../infra/log_server/include -o test_ebin ../common/src/*.erl;
#	sd
	cp ../sd/src/*.app test_ebin;
	erlc -I include -o test_ebin ../sd/src/*.erl;
#	test application
	cp test_src/*.app test_ebin;
	erlc -D unit_test -I ../infra/log_server/include -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie cookie_test\
	    -sname test\
	    -unit_test monitor_node test\
	    -unit_test cluster_id test\
	    -unit_test cookie cookie_test\
	    -run unit_test start_test test_src/test.config
