unexport DYLD_LIBRARY_PATH
CP  := $(wildcard *.cp)
DOT := $(wildcard *.dot)
TXT := $(patsubst %.cp,%.txt,$(CP))
PNG_LR := $(patsubst %.cp,%.png,$(CP))
PNG_HR := $(patsubst %.cp,%-hr.png,$(CP))
DOT_PNG := $(patsubst %.dot,%.png,$(DOT))
PDF := $(patsubst %.cp,%.pdf,$(CP))
EPS := $(patsubst %.cp,%.eps,$(CP))
SVG := $(patsubst %.cp,%.svg,$(CP))
PICT := $(patsubst %.cp,%.pict,$(CP))
GRAFFLE := $(patsubst %.cp,%.graffle,$(CP))
TARGETS := $(TXT) $(PNG_LR) $(PNG_HR) $(PDF) $(PDF) $(EPS) $(PICT) $(GRAFFLE) $(SVG) $(DOT_PNG)
CWD := $(shell pwd)

all: txt png

txt: $(TXT)
pdf: $(PDF)
eps: $(EPS)
png-lr: $(PNG_LR)
png-hr: $(PNG_HR)
dot-png: $(DOT_PNG)
png: png-lr png-hr dot-png
svg: $(SVG)
pict: $(PICT)
graffle: $(GRAFFLE)

clean:
	$(RM) $(TARGETS)

%.cp:
	./query.pl $* > $@

%.txt: %.cp
	callplot $^ > $@

%.vml: %.cp
	callplot -vml $^ > $@

%.svg: %.cp
	callplot -svg $^ > $@

%.pic: %.cp
	callplot -pic $^ > $@

%.graffle: %.cp
	@perl -pe 's/opt\/columnPitch\/(.*)/"opt\/columnPitch\/".int($$1*0.66)/e' < $^ > /tmp/$^
	callplot -graffle /tmp/$^ > $@
	@$(RM) /tmp/$^

%.png: %.graffle
	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" png 75

%-hr.png: %.graffle
	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" png 300

%.pdf: %.graffle
	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" pdf 300

%.eps: %.graffle
	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" eps 150

#%.svg: %.graffle
#	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" svg 150

%.pict: %.graffle
	osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" pict 300

%.png: %.dot
	dot -Tpng -o$@ $<

%.echo_osa: %.graffle
	@echo osascript graffle2img.scpt "$(CWD)/$^" "$(CWD)/$@" png 75

show.%:
	@echo $(*) = $($(*))

.PRECIOUS: %.cp
