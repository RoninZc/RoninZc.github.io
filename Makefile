run:
	@hugo server --buildDrafts

build:
	@hugo --baseURL="/"

update-theme:
	@git submodule update --remote --merge
