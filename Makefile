run:
	@hugo server --buildDrafts --watch=false

build:
	@hugo --baseUrl="/"

update-theme:
	@git submodule update --remote --merge
