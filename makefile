comp	:clean vcs

vcs	:
	vcs	\
			-f filelist.f\
			-timescale=1ns/1ps\
			-fsdb -full64 -R +vc +v2k -sverilog -debug_all\
			-LDFLAGS -Wl,--no-as-needed \
			-cm line+cond+tgl+fsm\
			-P 	$(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
				$(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a\
			| tee vcs.log &

verdi	:
	verdi -f filelist.f -ssf tb.fsdb

cov_rep:
	urg -dir simv.vdb -report cov_rep
cpsrc:
	cp -R /share/sgyang/codec/* ./

clean 	:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log cov_rep *.fsdb  *.conf

clean_all:	
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log cov_rep *.fsdb  *.conf


