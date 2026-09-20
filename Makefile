# Directories to leave out of the gallery (hidden dirs like .img are skipped automatically)
EXCLUDE := templates wip
IMG_DIR := .img
COLS    := 4
WIDTH   := 150
A2M2A   := /usr/bin/a2m2a
# For the raw .txt links. REPO (owner/name) is read from the origin remote when empty.
# HEAD always resolves to the default branch; set a branch name to pin it instead.
REPO    :=
BRANCH  := HEAD

ART    := $(sort $(filter-out $(addsuffix /%,$(EXCLUDE)),$(wildcard */*.txt)))
FULLS  := $(patsubst %.txt,$(IMG_DIR)/%.png,$(ART))
THUMBS := $(patsubst %.txt,$(IMG_DIR)/%_thumb.png,$(ART))

.PHONY: gallery clean-thumbs

gallery: $(THUMBS) $(FULLS)
	@python3 .scripts/gallery.py --img-dir $(IMG_DIR) --cols $(COLS) --branch $(BRANCH) $(if $(REPO),--repo $(REPO)) $(ART)

# One a2m2a run writes both files: -png gives the full-size .img/artist/name.png,
# -thumb gives .img/artist/name_thumb.png (a2m2a appends _thumb to the -o name).
# Reruns when the .txt is newer than either image, or either image is missing.
$(IMG_DIR)/%_thumb.png $(IMG_DIR)/%.png: %.txt
	@mkdir -p $(@D)
	$(A2M2A) -i ./$< -png -thumb $(WIDTH) -o $(IMG_DIR)/$*.png

# Only removes generated images, never your other files in .img/
clean-thumbs:
	rm -f $(THUMBS) $(FULLS)
