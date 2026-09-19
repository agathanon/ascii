# Directories to leave out of the gallery (hidden dirs like .img are skipped automatically)
EXCLUDE := templates wip
IMG_DIR := .img
COLS    := 3
WIDTH   := 150
A2M2A   := /usr/bin/a2m2a

ART    := $(sort $(filter-out $(addsuffix /%,$(EXCLUDE)),$(wildcard */*.txt)))
THUMBS := $(patsubst %.txt,$(IMG_DIR)/%_thumb.png,$(ART))

.PHONY: gallery clean-thumbs

gallery: $(THUMBS)
	@python3 .scripts/gallery.py --img-dir $(IMG_DIR) --cols $(COLS) $(ART)

# a2m2a appends _thumb to the -o name, so -o .img/artist/name.png yields
# .img/artist/name_thumb.png. Only reruns when the .txt is newer.
$(IMG_DIR)/%_thumb.png: %.txt
	@mkdir -p $(@D)
	$(A2M2A) -i ./$< -thumb $(WIDTH) -o $(IMG_DIR)/$*.png

# Only touches generated thumbnails, never your other images in .img/
clean-thumbs:
	rm -f $(IMG_DIR)/*/*_thumb.png
