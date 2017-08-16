header = documentclass.tex header.tex
layout = layout.md
title = begindocument.tex
contents = $(shell egrep -v -e "^figures/" -e "^[\#%]" ${layout}) enddocument.tex
figures = $(shell ls figures/*/figure.tex) $(shell ls figures/*/caption.tex)
tikzfigures = $(shell find figures -iname "*.tikz.tex")
output = output.tex
revision = revision.tex

aux = $(output:%.tex=%.aux) $(output:%.tex=%.log) \
$(output:%.tex=%.out) $(output:%.tex=%.toc) $(header:%.tex=%.aux) \
$(title:%.tex=%.aux) $(contents:%.tex=%.aux) $(revision:%.tex=%.aux) \
$(tikzfigures:%.tex=%.aux) $(tikzfigures:%.tikz.tex=%.run.xml) \
$(tikzfigures:%.tikz.tex=%.log) $(tikzfigures:%.tikz.tex=%.dpth) \
$(tikzfigures:%.tex=%.tex.annot)

biber_aux = $(output:%.tex=%.bbl) $(output:%.tex=%.bcf) \
$(output:%.tex=%.blg) $(output:%.tex=%.run.xml) \
$(output:%.tex=%-blx.bib)

tikzfigs = $(shell ls figures/*/*.tikz.tex | sed 's/.tikz.tex//')

# usar rubber para compilar pdf
cc   = rubber --pdf --unsafe

# compilador para imagenes tikz
tikzcc = pdflatex -halt-on-error -interaction=batchmode

#
crtf = latex2rtf
cbib = biber
crm  = rm -f

# construir pdf
all: pdf tikzimages
	$(crm) $(aux) $(biber_aux)

rev:
	@  echo -n '\\iflatexml\\else\\ohead{\small ' > $(revision)
	@- git rev-parse --abbrev-ref HEAD | tr -d '\n' >> $(revision)
	@  echo -n ', rev. ' >> $(revision)
	@- git rev-parse HEAD | cut -c1-7 | tr -d '\n' >> $(revision)
	@- git diff-index --quiet HEAD -- || echo -n '+' >> $(revision)
	@  echo ', \\today}\\fi' >> $(revision)
	@- git status > /dev/null || echo '' > $(revision)

temp: $(header) $(contents)
	echo '\\include{documentclass}' > $(output)
	echo '\\include{header}' >> $(output)
	echo '\\include{revision}' >> $(output)
	echo '\\input{begindocument}' >> $(output)
	egrep -v '^[#%]' $(layout) | perl -ne 'chomp; if (m{^figures/}){ \
s{/[^/]+$$}{}; print "\\begin{figure}[H]\n\\figureStyle\n\\input{$$_/figure}\
\\caption{\\captionStyle\\protect\\input{$$_/caption}}\
\\end{figure}\n"; } else { s{.tex$$}{}; print "\\input{$$_}\n"; }' >> $(output)
	echo '\\include{enddocument}' >> $(output)

pdf: rev temp
	@ $(cc) $(output) || ( $(crm) $(output:%.tex=%.bcf); exit 1 )

tikzimages: $(tikzfigs:%=%.png)

$(tikzfigs:%=%.pdf): $(@:%.pdf=%.tikz.tex)
	-$(tikzcc) -jobname "$(@:%.pdf=%)" \
"\def\tikzexternalrealjob{$(output:%.tex=%)}\input{$(output:%.tex=%)}"

%.png: %.pdf
	-convert -density 300 $(<) $(<:%.pdf=%.png)

# borrar todos los compilados y auxiliares
clean:
	$(crm) $(output:%.tex=%.pdf) $(aux) $(biber_aux) \
$(tikzfigures:%.tikz.tex=%.pdf) $(tikzfigures:%.tikz.tex=%.png)
