header = documentclass.tex header.tex
layout = layout.md
title = begindocument.tex
contents = $(shell egrep -v "^figures/" ${layout}) enddocument.tex
output = output.tex

aux = $(output:%.tex=%.aux) $(output:%.tex=%.log) \
$(output:%.tex=%.out) $(output:%.tex=%.toc) $(dep:%.tex=%.aux)

biber_aux = $(output:%.tex=%.bbl) $(output:%.tex=%.bcf) \
$(output:%.tex=%.blg) $(output:%.tex=%.run.xml) \
$(output:%.tex=%-blx.bib)

# usar rubber para compilar pdf
cc   = rubber --pdf
#
crtf = latex2rtf
cbib = biber
crm  = rm -f

# construir pdf
all: pdf
	$(crm) $(output) $(aux) $(biber_aux)

temp: $(header) $(contents)
	@ cat $(header) > $(output)
	@ cat $(title) >> $(output)
	@ cat $(contents) >> $(output)

pdf: temp
	@ $(cc) $(output) || ( $(crm) $(output:%.tex=%.bcf); exit 1 )

# borrar todos los compilados y auxiliares
clean:
	$(crm) $(output) $(output:%.tex=%.pdf) $(aux) $(biber_aux)

