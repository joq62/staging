all:
#	service
	rm -rf *_specs dbase host loader leader my* sd;
	rm -rf loader;
	git clone https://github.com/joq62/loader.git;
	erl -pa loader/ebin -setcookie cookie_test -sname h200 -s boot_loader start worker
