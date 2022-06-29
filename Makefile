
default: copy-agenda

tex/org.csv: ~/Org/*.org
	emacs -batch -l ~/.emacs \
		--eval="(add-to-list 'load-path \"./el\")" \
		--eval="(require 'orgToRem)" \
		--eval="(org-batch-agenda-csv \"y\")"> $@

orgToRem: hs/Main.hs
	stack build
	cp `stack exec which orgToRem` ./

tex/entries.tex: tex/org.csv orgToRem
	./orgToRem > $@

tex/agenda.pdf: tex/entries.tex tex/agenda.tex
	cd tex && latexmk -silent -lualatex -shell-escape agenda

clean:
	cd tex && latexmk -c

.PHONY: default clean copy-agenda copy-suspended copy-all

copy-all: copy-agenda copy-suspended

copy-agenda: tex/agenda.pdf agenda-uuid.txt
	scp tex/agenda.pdf remarkable:/home/root/.local/share/remarkable/xochitl/`cat agenda-uuid.txt`.pdf

copy-suspended: tex/suspended.png
	scp tex/suspended.png remarkable:/usr/share/remarkable/suspended.png
	ssh remarkable systemctl restart xochitl # necessary unfortunately, see https://github.com/Evidlo/remarkable_news/issues/25

tex/suspended.png: tex/suspended.tex tex/org.txt
	cd tex && pdflatex -shell-escape suspended

tex/org.txt: ~/Org/*.org
	emacs -batch -l ~/.emacs \
		--eval="(add-to-list 'load-path \"./el\")" \
		--eval="(require 'orgToRem)" \
		--eval="(org-batch-agenda \"d\")"> $@
