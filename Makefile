run:
	@hugo server --buildDrafts

build:
	@hugo --baseUrl="/"

update-theme:
	@git submodule update --remote --merge
