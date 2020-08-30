#!/bin/bash

# transformar archivo generado con articul8

sed -i -e 's/“/``/g' -e "s/”/''/g" -e 's,\\textit,\\e,g' ${1}

# sed -e 's,\\section,\\chapter,g' -e 's,\\subsection,\\section,g' -e 's,\\subsubsection,\\subsection,g' -e 's,\\paragraph,\\subsubsection,g' ${1} > imported.tex

