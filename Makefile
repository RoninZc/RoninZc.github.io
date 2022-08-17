run:
	@hugo server --buildDrafts -w

build:
	@hugo --baseUrl="/"

update-theme:
	@git submodule update --remote --merge
