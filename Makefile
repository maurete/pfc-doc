header = documentclass.tex header.tex
layout = layout.md
title = begindocument.tex
contents = $(shell egrep -v "^figures/" ${layout}) enddocument.tex
figures = $(shell ls figures/*/figure.tex) $(shell ls figures/*/caption.tex)
output = output.tex
revision = revision.tex

aux = $(output:%.tex=%.aux) $(output:%.tex=%.log) \
$(output:%.tex=%.out) $(output:%.tex=%.toc) $(header:%.tex=%.aux) \
$(title:%.tex=%.aux) $(contents:%.tex=%.aux) $(revision:%.tex=%.aux)

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

rev:
	echo -n '\\iflatexml\\else\\ohead{\small ' > $(revision)
	git rev-parse --abbrev-ref HEAD | tr -d '\n' >> $(revision)
	echo -n ', rev. ' >> $(revision)
	git rev-parse HEAD | cut -c1-7 | tr -d '\n' >> $(revision)
	git diff-index --quiet HEAD -- || echo -n '+' >> $(revision)
	echo ', \\today}\\fi' >> $(revision)

temp: $(header) $(contents)
	echo '\\include{documentclass}' > $(output)
	echo '\\include{header}' >> $(output)
	echo '\\include{revision}' >> $(output)
	echo '\\include{begindocument}' >> $(output)
	cat $(layout) | sed 's/^/\\includeFileOrFigure\{/g ; s/$$/}/g ;' >> $(output)
	echo '\\include{enddocument}' >> $(output)

pdf: rev temp
	@ $(cc) $(output) || ( $(crm) $(output:%.tex=%.bcf); exit 1 )

# borrar todos los compilados y auxiliares
clean:
	$(crm) $(output) $(output:%.tex=%.pdf) $(aux) $(biber_aux)

